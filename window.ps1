
# run this first manually, the powershell class below needs this type
Add-Type -Path  "C:\projects\WPwshF\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"
[WpfToolkit.ViewModelBase]::InvokeCommand = $ExecutionContext.InvokeCommand
[WpfToolkit.ViewModelBase]::InitScript = {
    # could also be implemented as Action<> that we set directly
    # from powershell
    param($self, $PropertyName)
    $self | 
        Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
            param(`$value)
            `$this.'$PropertyName' = `$value
            `$this.OnPropertyChanged('$PropertyName')
        ")) -PassThru | 
        Add-Member -MemberType ScriptMethod -Name "Get$PropertyName" -Value ([ScriptBlock]::Create("
            `$this.'$PropertyName'
        "))
        

    $self | Get-Member -MemberType ScriptMethod | Out-String | Write-Host
}


class MainViewModel : WpfToolkit.ViewModelBase {
    [String] $Value = "*"
   
    [Windows.Input.ICommand] $Click 

    MainViewModel () {
        $this.Init('Value')

        $this.Click = $this.Factory.RelayCommand({
            param($this, $o)
            $this.SetValue($this.Value + "=*")
        })


    }
}

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen" 
    Width = "800" Height = "600" ShowInTaskbar = "True">
    <StackPanel>
        <TextBox Text="{Binding Value}" />
        <Button Command="{Binding Click}" Content="Click me!" />
    </StackPanel>
</Window>
"@ 

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$Window.DataContext = [MainViewModel]::new()
$Window.ShowDialog()
