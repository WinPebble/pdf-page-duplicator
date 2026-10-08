namespace WinPebble.PdfPageDuplicator;

// Coordinates are PDF points, 72 points per inch. WPF will reuse this
// deterministic layout computation, scaled to fit its preview canvas.
internal readonly record struct Placement(double X, double Y, double Width, double Height);
internal sealed record SheetLayout(double Width, double Height, Placement[] Slots);

internal static class LayoutCalculator
{
    public static SheetLayout Calculate(double sourceWidth, double sourceHeight, int copies, bool portrait)
    {
        if (!double.IsFinite(sourceWidth) || !double.IsFinite(sourceHeight) || sourceWidth <= 0 || sourceHeight <= 0)
            throw new ArgumentOutOfRangeException(nameof(sourceWidth), "Invalid page dimensions.");
        if (copies is not (2 or 4))
            throw new ArgumentOutOfRangeException(nameof(copies), "Only 2 or 4 copies are supported.");
        // v1 layout policy: preserve the original physical paper dimensions,
        // changing orientation only; do not grow/shrink the final paper size.
        double width = portrait ? Math.Min(sourceWidth, sourceHeight) : Math.Max(sourceWidth, sourceHeight);
        double height = portrait ? Math.Max(sourceWidth, sourceHeight) : Math.Min(sourceWidth, sourceHeight);
        int columns = copies == 2 && portrait ? 1 : 2;
        int rows = copies / columns;
        double cellWidth = width / columns, cellHeight = height / rows;
        double scale = Math.Min(cellWidth / sourceWidth, cellHeight / sourceHeight);
        double drawnWidth = sourceWidth * scale, drawnHeight = sourceHeight * scale;
        var slots = new Placement[copies];
        for (int i = 0; i < copies; ++i)
        {
            int row = i / columns, col = i % columns;
            slots[i] = new Placement(
                col * cellWidth + (cellWidth - drawnWidth) / 2,
                row * cellHeight + (cellHeight - drawnHeight) / 2,
                drawnWidth, drawnHeight);
        }
        return new SheetLayout(width, height, slots);
    }

    public static void SelfTest()
    {
        double[][] sizes = { new double[] { 792, 612 }, new double[] { 612, 792 },
            new double[] { 841.89, 595.28 }, new double[] { 595.28, 841.89 },
            new double[] { 715, 300 } };
        int checks = 0;
        foreach (var size in sizes)
        foreach (int copies in new[] { 2, 4 })
        foreach (bool portrait in new[] { true, false })
        {
            var result = Calculate(size[0], size[1], copies, portrait);
            if (result.Slots.Length != copies) throw new Exception("Wrong copy count");
            foreach (var s in result.Slots)
            {
                if (s.X < -1e-7 || s.Y < -1e-7 ||
                    s.X + s.Width > result.Width + 1e-7 ||
                    s.Y + s.Height > result.Height + 1e-7)
                    throw new Exception("Clipped placement");
                if (Math.Abs(s.Width / s.Height - size[0] / size[1]) > 1e-8)
                    throw new Exception("Aspect ratio distorted");
            }
            for (int a = 0; a < copies; a++)
            for (int b = a + 1; b < copies; b++)
            {
                var r = result.Slots[a]; var s = result.Slots[b];
                double overlapX = Math.Min(r.X+r.Width,s.X+s.Width)-Math.Max(r.X,s.X);
                double overlapY = Math.Min(r.Y+r.Height,s.Y+s.Height)-Math.Max(r.Y,s.Y);
                if (overlapX > 1e-7 && overlapY > 1e-7)
                    throw new Exception("Overlapping placements");
            }
            checks++;
        }
        Console.WriteLine($"PASS: {checks} layout geometry checks.");
    }
}
