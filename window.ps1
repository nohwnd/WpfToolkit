
# run this first manually, the powershell class below needs this type
Add-Type -Path  "C:\projects\WPwshF\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"
[WpfToolkit.ViewModelBase]::InvokeCommand = $ExecutionContext.InvokeCommand
[WpfToolkit.ViewModelBase]::InitScript = {
    param($self, $PropertyName)
    Write-Host 'x' + ($self) + 'x'
    Write-Host 'x' + ($PropertyName) + 'x'
    $self | Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
        param(`$value)
        Write-Host ""value is `$value""
         Write-Host ""this is `$this""
        `$this.'$PropertyName' = `$value
        `$this.OnPropertyChanged('$PropertyName')
    "))

    $self | Get-Member -MemberType ScriptMethod | Out-String | Write-Host
}


class MainViewModel : WpfToolkit.ViewModelBase {
    [String] $Value = "*"
   
    [Windows.Input.ICommand] $Click 

    MainViewModel () {
        # $this | 
        #     Add-Member -MemberType ScriptMethod -Name SetValue -Value {
        #         param($value) 
        #         $this.Value = $value
        #         $this.OnPropertyChanged("Value")
        #     }

        $this.Init('Value')
   #     $this.SetValue(1)

        $this.Click = $this.Factory.RelayCommand({
            param($self, $o)
   
            # change the value of the Value property and
            # notify the ui about the update
            # in the view (UI) you should see the value updated
            #$self.Value += "=*"
            #$self.OnPropertyChanged("Value")
            $self.SetValue($self.Value + "=*")
   
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
