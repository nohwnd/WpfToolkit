Add-Type -AssemblyName PresentationFramework

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
         
            $vm.PSObject.Properties.Add($p) 
            if ($p.IsInstance -and $p.IsGettable -and $p.IsSettable) {
                if ($p.Value -is [Wpf.RelayCommand]) {
                    $p.Value.Self = $vm
                }

                $propertyName = $p.Name
                $vm | 
                    Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
                        param(`$value)
                        Write-Host 'Notifying $PropertyName'
                        `$this.'$PropertyName' = `$value
                        `$this.OnPropertyChanged('$PropertyName')
                    "))
            }
        }

        $vm
    }
}


[string]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Height="450" Width="800">
    <StackPanel>
        <Button Command="{Binding Change}"/>
        <Label FontSize="48" Content="{Binding Text}" />
    </StackPanel>
    </Window>
"@

$o = [pscustomobject]@{
    Text = "txt"
    Change = [Wpf.RelayCommand]::new({param ($this, $o) $this.SetText("FFFFFFF") }, { $true })
} 

$vm = $o | Notifize



$Window = [Windows.Markup.XamlReader]::Parse($xaml)
$Window.DataContext = $vm[0]
$Window.ShowDialog()


