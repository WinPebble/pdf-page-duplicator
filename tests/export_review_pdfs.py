"""Create actual PDFsharp output files for human Foxit review in CI."""
from pathlib import Path
import json
from verify_poc import fixture, run, verify

root = Path(__file__).resolve().parents[1]
destination = root / "ci-review-pdfs"
destination.mkdir(exist_ok=True)
source = destination / "Source_Letter_Landscape_2Pages.pdf"
fixture(source)
manifest = []
for copies in (2,4):
    for orient in ("portrait","landscape"):
        name = f"PDFsharp_{copies}x_{orient.title()}.pdf"
        path = destination / name
        run(source,"--copies",copies,"--orientation",orient,"--output",path)
        verify(source,path,copies,orient)
        manifest.append({"file":name,"copies":copies,"orientation":orient})
(destination / "MANIFEST.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
print("Created 4 PDFsharp-generated review files plus their source PDF.")
