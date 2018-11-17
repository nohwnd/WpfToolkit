using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Hardcodet.Wpf.DataBinding;

namespace WpfInPowerShell
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private string _a;
        private string _b;

        public MainWindow()
        {
            InitializeComponent();
            DataContext = this;
            A = "Hello";
            B = "Hell";

        }

        public string B
        {
            get => _b;
            set => _b = value;
        }

        public string A
        {
            get => _a;
            set => _a = value;
        }
    }

    public class PBinding : BindingDecoratorBase
    {
        private string _path;

        public PBinding()
        {

        }

        public PBinding(string path) : base(path)
        {
            
        }

        public override object ProvideValue(IServiceProvider serviceProvider)
        {
            //delegate binding creation etc. to the base class
            object val = base.ProvideValue(serviceProvider);

            //try to get bound items for our custom work
            DependencyObject targetObject;
            DependencyProperty targetProperty;
            bool status = TryGetTargetItems(serviceProvider, out targetObject,
                out targetProperty);

            if (status)
            {
                //associate an input listener with the control
                var a = 10;
            }

            return val;

        }
    }

    public class NullConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return value;
        }

        public static IValueConverter Instance => new NullConverter();
    }

    public class LoggingConverter : IValueConverter
    {
        private readonly IValueConverter _converter;

        public LoggingConverter(IValueConverter converter)
        {
            _converter = converter;
        }
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            Console.WriteLine("Running Convert");
            var r =_converter.Convert(value, targetType, parameter, culture);
            Console.WriteLine("Convert done.");
            return r;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            Console.WriteLine("Running ConvertBack");
            var r = _converter.ConvertBack(value, targetType, parameter, culture);
            Console.WriteLine("ConvertBack done.");
            return r;
        }
    }
}