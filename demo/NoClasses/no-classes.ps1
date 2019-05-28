Add-Type -AssemblyName PresentationFramework, WindowsBase

Add-Type -TypeDefinition "
using System;
using System.Windows.Input;
using System.ComponentModel;
using System.Management.Automation;

namespace Wpf {

    public class RelayCommand : ICommand
    {
        private Action<object, object> execute;
        private Func<object, object, bool> canExecute;
        public object Self { get; set;}

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        public RelayCommand(Action<object, object> execute, Func<object, object, bool> canExecute = null)
        {
            this.execute = execute;
            this.canExecute = canExecute;
        }

        public bool CanExecute(object parameter)
        {
            return this.canExecute == null || this.canExecute(Self, parameter);
        }

        public void Execute(object parameter)
        {
            this.execute(Self, parameter);
        }
    }

    public class ViewModel : INotifyPropertyChanged {
        public event PropertyChangedEventHandler PropertyChanged = delegate { };

        public void OnPropertyChanged(string propertyName = null) {
            PropertyChanged.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
" -ReferencedAssemblies "PresentationCore"

function Notifize {
    param(
        [Parameter(ValueFromPipeline)]
        [PSObject] $PSObject
    )

    process {
        
        $vm = [Wpf.ViewModel]::new()
        foreach ($p in $PSObject.PSObject.Properties) 
        {
            $PropertyName = $p.Name

            if ($p.IsInstance -and $p.IsGettable -and $p.IsSettable) {
                $vm | Add-Member -MemberType NoteProperty -Name $p.Name -Value $p.Value

                if ($p.Value -is [Wpf.RelayCommand]) {
                    $p.Value.Self = $vm
                }
            
                $vm | 
                    Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
                        param(`$value)
                        Write-Host 'Notifying $PropertyName'
                        Write-host (`$this | out-string)
                        `$this.'$PropertyName' = `$value
                        `$this.OnPropertyChanged('$PropertyName')
                        Write-Host 'Notified $PropertyName'
                    "))
            }
        }

        [PSCustomObject]@{ o = $vm }
    }
}


[string]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <StackPanel>
        <Label Content="{Binding o.ProcessName}" />
        <Button Command="{Binding o.Change}" />
    </StackPanel>
</Window>
"@

$o = [PSCustomObject] @{ 
    ProcessName = "Process1" 
    Change = [Wpf.RelayCommand]::new({param($this, $o) $this.SetProcessName("n") }, {$true})
} | Notifize

# log binding errors
[Diagnostics.PresentationTraceSources]::Refresh()
[Diagnostics.PresentationTraceSources]::DataBindingSource.Listeners.Add([Diagnostics.ConsoleTraceListener]::new())
[Diagnostics.PresentationTraceSources]::DataBindingSource.Switch.Level = "Warning, Error"

$Window = [Windows.Markup.XamlReader]::Parse($xaml)
$Window.DataContext = $o
$Window.ShowDialog()


