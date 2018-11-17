using System;
using System.Windows.Input;
using System.ComponentModel;

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

    public abstract class ViewModelBase : INotifyPropertyChanged
    {
        protected ViewModelBase()
        {
            Factory = new Factory(this);
        }

        public event PropertyChangedEventHandler PropertyChanged = delegate { };

        public virtual void OnPropertyChanged(string propertyName)
        {
            Console.WriteLine("Notified " + propertyName);
            PropertyChanged.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public Factory Factory { get; set; }
    }
}