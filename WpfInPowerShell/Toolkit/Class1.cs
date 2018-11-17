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


    public abstract class ViewModelBase :  INotifyPropertyChanged
    {
        public static CommandInvocationIntrinsics InvokeCommand { get; set; }
        public static string InitScript { get; set; }

        public event PropertyChangedEventHandler PropertyChanged = delegate { };

        public virtual void OnPropertyChanged(string propertyName)
        {
            Console.WriteLine("Notified property '" + propertyName +"'");
            PropertyChanged.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public RelayCommand NewCommand(
            Action<object, object> execute,
            Func<object, object, bool> canExecute = null)
        {
            return new RelayCommand(this, execute, canExecute);
        }

        public void Init(string propertyName)
        {
            if (string.IsNullOrWhiteSpace(propertyName))
                throw new ArgumentException("Value cannot be null or whitespace.", nameof(propertyName));
            
            InvokeCommand.NewScriptBlock(InitScript).Invoke(this, propertyName);
        }
    }
}