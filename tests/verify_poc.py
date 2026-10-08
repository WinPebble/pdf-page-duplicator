"""Independent end-to-end check of compiled PDFsharp outputs on Windows CI.
PyMuPDF is only a test dependency; it is not bundled with WinPebble.
"""
from __future__ import annotations
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path
import fitz

ROOT = Path(__file__).resolve().parents[1]
BINARY = ROOT / "src/bin/Release/net10.0/WinPebble.PDFPageDuplicator.POC.dll"

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(*args, ok=True):
    proc = subprocess.run(["dotnet", str(BINARY), *map(str, args)], capture_output=True, text=True, timeout=100)
    if (proc.returncode == 0) != ok:
        raise AssertionError(f"Unexpected result code {proc.returncode}; stdout={proc.stdout}; stderr={proc.stderr}")
    return proc

def fixture(path, mixed=False):
    with fitz.open() as doc:
        sizes = [(792,612),(595.28,841.89),(715,300)] if mixed else [(792,612),(792,612)]
        for idx, (w,h) in enumerate(sizes):
            page = doc.new_page(width=w,height=h)
            page.insert_text((30,65), f"PDF PAGE DUPLICATOR - PAGE {idx+1}", fontsize=12, fontname="helv")
            page.draw_rect(fitz.Rect(20,20,w-20,h-20),color=(0.1,0.2,0.4))
        doc.save(path)

def verify(srcpath, outpath, copies, orientation):
    with fitz.open(srcpath) as source, fitz.open(outpath) as output:
        assert len(output)==len(source), "page count changed"
        for idx,(a,b) in enumerate(zip(source,output)):
            sw,sh=a.rect.width,a.rect.height
            w,h = (min(sw,sh),max(sw,sh)) if orientation=="portrait" else (max(sw,sh),min(sw,sh))
            assert abs(b.rect.width-w)<0.15 and abs(b.rect.height-h)<0.15, "paper dimensions wrong"
            marker=f"PDF PAGE DUPLICATOR - PAGE {idx+1}"
            assert a.get_text().count(marker)==1, "fixture invalid"
            assert b.get_text().count(marker)==copies, f"wrong copy count for {marker}: {b.get_text()!r}"
            assert len(b.get_images(full=True))==0, "source was rasterized"
            assert len(b.get_drawings())>=len(a.get_drawings()), "vector drawing lost"
            for j in range(len(source)):
                if j!=idx:
                    assert f"PDF PAGE DUPLICATOR - PAGE {j+1}" not in b.get_text(), "other page leaked"

def main():
    assert BINARY.exists(), f"Missing compiled binary: {BINARY}"
    cases=0
    with tempfile.TemporaryDirectory(prefix="winpebble-poc-") as d:
        root=Path(d)
        src=root/"source.pdf"
        fixture(src)
        sourcehash=sha(src)
        for copies in (2,4):
            for orientation in ("portrait","landscape"):
                dst=root/f"{copies}_{orientation}.pdf"
                run(src,"--copies",copies,"--orientation",orientation,"--output",dst)
                verify(src,dst,copies,orientation)
                cases+=1
        mixed=root/"mixed.pdf"
        fixture(mixed,mixed=True)
        for copies, orientation in ((2,"portrait"),(4,"landscape")):
            dst=root/f"mixed_{copies}_{orientation}.pdf"
            run(mixed,"--copies",copies,"--orientation",orientation,"--output",dst)
            verify(mixed,dst,copies,orientation)
            cases+=1
        nested=root/"Lồng nhau" /"Tài liệu Tiếng Việt"
        nested.mkdir(parents=True)
        unicode_src=nested/"Bản thử 1.pdf"
        unicode_src.write_bytes(src.read_bytes())
        run(unicode_src,"--copies",2,"--orientation","portrait")
        first=nested/"Bản thử 1_2x_Portrait.pdf"
        verify(unicode_src,first,2,"portrait")
        run(unicode_src,"--copies",2,"--orientation","portrait")
        second=nested/"Bản thử 1_2x_Portrait (2).pdf"
        assert second.exists()
        verify(unicode_src,second,2,"portrait")
        cases+=1
        digest=sha(first)
        run(unicode_src,"--copies",4,"--orientation","portrait","--output",first,ok=False)
        assert sha(first)==digest
        cases+=1
        corrupt=root/"corrupt.pdf"
        corrupt.write_bytes(b"%PDF-1.5\nThis is not a valid PDF\n")
        run(corrupt,"--copies",2,"--orientation","portrait",ok=False)
        assert not (root/"corrupt_2x_Portrait.pdf").exists()
        cases+=1
        textfile=root/"not_pdf.txt"
        textfile.write_text("not pdf",encoding="utf-8")
        run(textfile,"--copies",2,"--orientation","portrait",ok=False)
        cases+=1
        encrypted=root/"encrypted.pdf"
        with fitz.open(src) as doc:
            doc.save(encrypted,encryption=fitz.PDF_ENCRYPT_AES_256,owner_pw="owner",user_pw="user")
        run(encrypted,"--copies",2,"--orientation","portrait",ok=False)
        cases+=1
        with fitz.open(src) as doc:
            doc[0].set_rotation(90)
            rotated=root/"rotated.pdf"
            doc.save(rotated)
        run(rotated,"--copies",2,"--orientation","portrait",ok=False)
        cases+=1
        with fitz.open(src) as doc:
            doc[0].set_cropbox(fitz.Rect(50,40,700,500))
            crop=root/"cropped.pdf"
            doc.save(crop)
        run(crop,"--copies",2,"--orientation","portrait",ok=False)
        cases+=1
        assert not list(root.rglob("*.winpebble-*.tmp.pdf")), "staging artifacts left behind"
        assert sha(src)==sourcehash, "source modified"
    print(json.dumps({"status":"PASS","compiled_engine":"PDFsharp","cases":cases},ensure_ascii=False))

if __name__=="__main__":
    try: main()
    except Exception as exc:
        print(f"FAIL: {type(exc).__name__}: {exc}",file=sys.stderr)
        raise
