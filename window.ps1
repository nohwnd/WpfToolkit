﻿
# run this first manually, the powershell class below needs this type
Import-Module "C:\projects\WPwshF\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"

class MainViewModel : ViewModelBase {
    [String] $Value = "hello"

    [System.Windows.Input.ICommand] $Click = [RelayCommand]::new($this, {
        param($self, $o)
       
        # change the value of the Value property and 
        # notify the ui about the update
        # in the view (UI) you should see the value updated
        $self.Value = "gef"
        $self.OnPropertyChanged("Value")
  
    }, { $true })
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