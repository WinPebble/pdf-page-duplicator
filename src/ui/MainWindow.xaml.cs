using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using Path = System.IO.Path;
using Microsoft.Win32;
using PdfSharp.Pdf.IO;
using WinPebble.PdfPageDuplicator;

namespace WinPebble.PdfPageDuplicator.Ui;

public partial class MainWindow : Window
{
    private string? _selectedPath;
    private double _sourceWidth;
    private double _sourceHeight;
    private int _pageCount;
    private readonly Brush _sheetFill = Brushes.White;
    private static readonly Brush SheetStroke = new SolidColorBrush(Color.FromRgb(136, 149, 169));
    private static readonly Brush CopyFill = new SolidColorBrush(Color.FromRgb(222, 236, 253));
    private static readonly Brush CopyStroke = new SolidColorBrush(Color.FromRgb(73, 133, 203));

    public MainWindow() => InitializeComponent();

    private void Window_Loaded(object sender, RoutedEventArgs e)
    {
        var args = Environment.GetCommandLineArgs();
        if (args.Length > 1 && File.Exists(args[1]))
            LoadPdf(args[1]);
    }

    private void Browse_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Title = "Choose PDF",
            Filter = "PDF documents (*.pdf)|*.pdf",
            CheckFileExists = true,
            Multiselect = false
        };
        if (dialog.ShowDialog(this) == true) LoadPdf(dialog.FileName);
    }

    private void LoadPdf(string path)
    {
        _selectedPath = null;
        GenerateButton.IsEnabled = false;
        OriginalCanvas.Children.Clear();
        OutputCanvas.Children.Clear();
        try
        {
            using var document = PdfReader.Open(path, PdfDocumentOpenMode.Import);
            if (document.PageCount == 0)
                throw new InvalidDataException("The PDF has no pages.");
            var first = document.Pages[0];
            var media = first.MediaBoxReadOnly;
            _sourceWidth = media.X2 - media.X1;
            _sourceHeight = media.Y2 - media.Y1;
            if (_sourceWidth <= 0 || _sourceHeight <= 0)
                throw new InvalidDataException("Invalid paper dimensions.");
            // Only display an accurate preview for files that the current POC engine accepts.
            for (int i = 0; i < document.PageCount; ++i)
            {
                var p = document.Pages[i];
                var m = p.MediaBoxReadOnly;
                var c = p.EffectiveCropBoxReadOnly;
                static bool Close(double x, double y) => Math.Abs(x - y) < .001;
                if (p.Rotate % 360 != 0 || !Close(m.X1,0) || !Close(m.Y1,0)
                    || !Close(c.X1,m.X1) || !Close(c.Y1,m.Y1)
                    || !Close(c.X2,m.X2) || !Close(c.Y2,m.Y2))
                    throw new NotSupportedException($"Page {i+1}: rotated or non-default page boxes are not supported in this POC.");
            }
            _pageCount = document.PageCount;
            _selectedPath = path;
            FileLabel.Text = Path.GetFileName(path);
            StatusText.Foreground = Brushes.SlateGray;
            StatusText.Text = _pageCount > 1 ? $"Preview shows page 1 of {_pageCount}. Each page is processed separately." : "Ready to create PDF.";
            GenerateButton.IsEnabled = true;
            RefreshPreview();
        }
        catch (Exception ex)
        {
            FileLabel.Text = Path.GetFileName(path);
            StatusText.Foreground = Brushes.Firebrick;
            StatusText.Text = ex.Message;
            OriginalSizeLabel.Text = "No available preview";
            OutputSizeLabel.Text = "—";
        }
    }

    private void SettingsChanged(object sender, RoutedEventArgs e)
    {
        if (IsLoaded && _selectedPath is not null) RefreshPreview();
    }

    private void RefreshPreview()
    {
        if (_selectedPath is null) return;
        int copies = FourOption.IsChecked == true ? 4 : 2;
        bool portrait = PortraitOption.IsChecked == true;
        var layout = LayoutCalculator.Calculate(_sourceWidth, _sourceHeight, copies, portrait);
        OriginalSizeLabel.Text = string.Format(CultureInfo.InvariantCulture,
            "Page 1 of {0}  •  {1:0.#} × {2:0.#} pt", _pageCount, _sourceWidth, _sourceHeight);
        OutputSizeLabel.Text = string.Format(CultureInfo.InvariantCulture,
            "{0} copies  •  {1}  •  {2:0.#} × {3:0.#} pt",
            copies, portrait ? "Portrait" : "Landscape", layout.Width, layout.Height);
        DrawPaper(OriginalCanvas, _sourceWidth, _sourceHeight, null);
        DrawPaper(OutputCanvas, layout.Width, layout.Height, layout);
    }

    private void DrawPaper(Canvas canvas, double width, double height, SheetLayout? layout)
    {
        canvas.Children.Clear();
        double factor = Math.Min((canvas.Width - 28) / width, (canvas.Height - 28) / height);
        double shownWidth = width * factor;
        double shownHeight = height * factor;
        double left = (canvas.Width - shownWidth) / 2;
        double top = (canvas.Height - shownHeight) / 2;
        AddRectangle(canvas, left, top, shownWidth, shownHeight, _sheetFill, SheetStroke, 1.5);
        if (layout is null) return;
        for (int i = 0; i < layout.Slots.Length; ++i)
        {
            var slot = layout.Slots[i];
            AddRectangle(canvas, left + slot.X * factor, top + slot.Y * factor,
                slot.Width * factor, slot.Height * factor, CopyFill, CopyStroke, 1.1);
            var number = new TextBlock
            {
                Text = (i+1).ToString(CultureInfo.InvariantCulture),
                FontSize = 13, FontWeight = FontWeights.SemiBold,
                Foreground = new SolidColorBrush(Color.FromRgb(46,94,155))
            };
            number.Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
            Canvas.SetLeft(number,left+(slot.X+slot.Width/2)*factor-number.DesiredSize.Width/2);
            Canvas.SetTop(number,top+(slot.Y+slot.Height/2)*factor-number.DesiredSize.Height/2);
            canvas.Children.Add(number);
        }
    }

    private static void AddRectangle(Canvas canvas, double x, double y, double w, double h,
        Brush fill, Brush stroke, double thickness)
    {
        var shape = new Rectangle
        {
            Width = w, Height = h, Fill = fill,
            Stroke = stroke, StrokeThickness = thickness
        };
        Canvas.SetLeft(shape,x);
        Canvas.SetTop(shape,y);
        canvas.Children.Add(shape);
    }

    private async void Generate_Click(object sender, RoutedEventArgs e)
    {
        if (_selectedPath is null) return;
        string engine = Path.Combine(AppContext.BaseDirectory, "Engine", "WinPebble.PDFPageDuplicator.POC.exe");
        if (!File.Exists(engine))
        {
            StatusText.Foreground = Brushes.Firebrick;
            StatusText.Text = "Engine executable was not found. Use the complete CI UI artifact including the Engine folder.";
            return;
        }

        GenerateButton.IsEnabled = false;
        BrowseButton.IsEnabled = false;
        StatusText.Foreground = Brushes.SlateGray;
        StatusText.Text = "Creating PDF…";
        try
        {
            var info = new ProcessStartInfo
            {
                FileName = engine,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            info.ArgumentList.Add(_selectedPath);
            info.ArgumentList.Add("--copies");
            info.ArgumentList.Add(FourOption.IsChecked == true ? "4" : "2");
            info.ArgumentList.Add("--orientation");
            info.ArgumentList.Add(PortraitOption.IsChecked == true ? "portrait" : "landscape");
            using var process = Process.Start(info) ?? throw new IOException("Could not start the PDF engine.");
            var output = process.StandardOutput.ReadToEndAsync();
            var error = process.StandardError.ReadToEndAsync();
            await process.WaitForExitAsync();
            string stdout = await output, stderr = await error;
            if (process.ExitCode != 0)
                throw new InvalidOperationException(string.IsNullOrWhiteSpace(stderr) ? "PDF conversion failed." : stderr.Trim());
            StatusText.Foreground = new SolidColorBrush(Color.FromRgb(26, 125, 77));
            StatusText.Text = stdout.Trim();
        }
        catch (Exception ex)
        {
            StatusText.Foreground = Brushes.Firebrick;
            StatusText.Text = ex.Message;
        }
        finally
        {
            GenerateButton.IsEnabled = _selectedPath is not null;
            BrowseButton.IsEnabled = true;
        }
    }
}
