using PdfSharp.Drawing;
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;
using WinPebble.PdfPageDuplicator;

// CLI proof-of-concept only; no WPF or Explorer extension in this milestone.
static int Run(string[] args)
{
    try
    {
        if (args.Length == 1 && args[0] == "--self-test")
        {
            LayoutCalculator.SelfTest();
            return 0;
        }
        if (args.Length < 5 || args.Length % 2 != 1) return Usage();
        string input = Path.GetFullPath(args[0]);
        string? output = null;
        int copies = 0;
        bool? portrait = null;
        for (int i = 1; i < args.Length; i += 2)
        {
            string value = args[i+1];
            switch (args[i].ToLowerInvariant())
            {
                case "--copies" when int.TryParse(value, out int count) && count is 2 or 4:
                    copies = count; break;
                case "--orientation" when value.Equals("portrait", StringComparison.OrdinalIgnoreCase):
                    portrait = true; break;
                case "--orientation" when value.Equals("landscape", StringComparison.OrdinalIgnoreCase):
                    portrait = false; break;
                case "--output": output = Path.GetFullPath(value); break;
                default: return Usage();
            }
        }
        if (copies == 0 || portrait is null) return Usage();
        if (!File.Exists(input) || !Path.GetExtension(input).Equals(".pdf", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Input must be an existing PDF file.");
        string folder = Path.GetDirectoryName(input)!;
        string stem = Path.GetFileNameWithoutExtension(input);
        string suffix = $"_{copies}x_{(portrait.Value ? "Portrait" : "Landscape")}";
        string target = output ?? Path.Combine(folder, stem + suffix + ".pdf");
        if (string.Equals(input, target, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Input and output must differ.");
        if (output is not null && File.Exists(output))
            throw new IOException("Specified output already exists. Refusing overwrite.");
        string destDir = Path.GetDirectoryName(target)!;
        Directory.CreateDirectory(destDir);
        string temp = Path.Combine(destDir,
            $".{Path.GetFileNameWithoutExtension(target)}.winpebble-{Guid.NewGuid():N}.tmp.pdf");
        try
        {
            int pages;
            using (var source = PdfReader.Open(input, PdfDocumentOpenMode.Import))
            using (var form = XPdfForm.FromFile(input))
            using (var result = new PdfDocument())
            {
                pages = source.PageCount;
                if (pages <= 0 || form.PageCount != pages)
                    throw new InvalidOperationException("Unable to read all PDF pages.");
                for (int index = 0; index < pages; index++)
                {
                    var src = source.Pages[index];
                    // POC safety gates: these non-default geometries need additional
                    // parity verification before this tool may silently export them.
                    if (src.Rotate % 360 != 0)
                        throw new NotSupportedException($"Page {index+1} has /Rotate; not yet supported.");
                    var media = src.MediaBoxReadOnly;
                    var crop = src.EffectiveCropBoxReadOnly;
                    static bool Close(double x, double y) => Math.Abs(x-y) < .001;
                    if (!Close(media.X1,0) || !Close(media.Y1,0) ||
                        !Close(crop.X1,media.X1) || !Close(crop.Y1,media.Y1) ||
                        !Close(crop.X2,media.X2) || !Close(crop.Y2,media.Y2))
                        throw new NotSupportedException($"Page {index+1} has non-default PDF page boxes.");
                    form.PageNumber = index+1;
                    var layout = LayoutCalculator.Calculate(form.PointWidth,form.PointHeight,copies,portrait.Value);
                    var dest = result.AddPage();
                    dest.Width = XUnit.FromPoint(layout.Width);
                    dest.Height = XUnit.FromPoint(layout.Height);
                    using var gfx = XGraphics.FromPdfPage(dest);
                    foreach (var s in layout.Slots)
                        gfx.DrawImage(form,new XRect(s.X,s.Y,s.Width,s.Height));
                }
                result.Info.Title = "PDF Page Duplicator - WinPebble Engineering POC";
                result.Save(temp);
            }
            using (var check = PdfReader.Open(temp, PdfDocumentOpenMode.Import))
                if (check.PageCount != pages)
                    throw new IOException("Result page count failed validation.");
            string saved;
            if (output is not null)
            {
                File.Move(temp,target); // no overwrite
                saved = target;
            }
            else
            {
                int attempt = 1;
                while (true)
                {
                    string candidate = attempt == 1 ? target :
                        Path.Combine(destDir,$"{stem}{suffix} ({attempt}).pdf");
                    try
                    {
                        File.Move(temp,candidate); // no overwrite
                        saved = candidate;
                        break;
                    }
                    catch (IOException) when (File.Exists(candidate) && attempt < 10000)
                    {
                        attempt++;
                    }
                }
            }
            Console.WriteLine($"SUCCESS: {pages} PDF page(s), {copies} copies each. {saved}");
            return 0;
        }
        finally
        {
            if (File.Exists(temp))
                try { File.Delete(temp); } catch (IOException) { /* cleanup best effort */ }
        }
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"ERROR: {ex.GetType().Name}: {ex.Message}");
        return 1;
    }
}
static int Usage()
{
    Console.Error.WriteLine("Usage: WinPebble.PDFPageDuplicator.POC.exe <input.pdf> --copies 2|4 --orientation portrait|landscape [--output <path.pdf>]");
    Console.Error.WriteLine("       WinPebble.PDFPageDuplicator.POC.exe --self-test");
    return 2;
}
return Run(args);
