using System;
using System.Windows.Input;
using System.ComponentModel;
using System.Management.Automation;
using ConsoleDump;

namespace WpfToolkit
{

    public class RelayCommand : ICommand
    {
        private Action<object, object> execute;
        private Func<object, object, bool> canExecute;
        private object self;

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        public RelayCommand(object self, Action<object, object> execute, Func<object, object, bool> canExecute = null)
        {
            this.self = self;
            this.execute = execute;
            this.canExecute = canExecute;
        }

        public bool CanExecute(object parameter)
        {
            return this.canExecute == null || this.canExecute(self, parameter);
        }

        public void Execute(object parameter)
        {
            this.execute(self, parameter);
        }
    }

    public class Factory
    {
        private readonly object _self;

        public Factory(object self)
        {
            _self = self;
        }

        public RelayCommand RelayCommand(
            Action<object, object> execute,
            Func<object, object, bool> canExecute = null)
        {
            return new RelayCommand(_self, execute, canExecute);
        }
    }

    public abstract class ViewModelBase :  INotifyPropertyChanged
    {
        protected ViewModelBase()
        {
            
            Console.WriteLine("Creating vm base with "+ this.GetType().Name );
            Factory = new Factory(this);
            Console.WriteLine($"Created vm. with {this.Factory.GetType().Name}");
        }

        public static CommandInvocationIntrinsics InvokeCommand { get; set; }
        public static string InitScript { get; set; }

        public event PropertyChangedEventHandler PropertyChanged = delegate { };

        public virtual void OnPropertyChanged(string propertyName)
        {
            Console.WriteLine("Notified property '" + propertyName +"'");
            PropertyChanged.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public Factory Factory { get; set; }



        public void Init(string propertyName)
        {
            Console.WriteLine($"Initializing '{propertyName}'");
            Console.WriteLine($"this value is  '{this}'");
            if (string.IsNullOrWhiteSpace(propertyName))
                throw new ArgumentException("Value cannot be null or whitespace.", nameof(propertyName));
            
            InitScript.Dump("init script");
            InvokeCommand.NewScriptBlock(InitScript).Invoke(this, propertyName);
            

            //sb.Invoke();
            //$@"
            //param($self)
            //Write-Host ('x'+($self)+'x')
            //$self | Add-Member -MemberType ScriptMethod -Name Set{propertyName} -Value {{
            //    param($value)
            //    $this.Value = $value
            //    this.OnPropertyChanged('{propertyName}')
            //}}
            //").Invoke(this);
            Console.WriteLine($"Done - initializing '{propertyName}");
        }
    }
}