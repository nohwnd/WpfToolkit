
. "$PSScriptRoot\wpf.ps1"
. "$PSScriptRoot\viewModels.ps1"

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Initial Window" WindowStartupLocation = "CenterScreen" 
    Width = "800" Height = "600" ShowInTaskbar = "True">
    <StackPanel>
        <TextBox Text="{Binding Value}" />
        <Button Command="{Binding Click}" Content="Click me!" />
        <ProgressBar Value="{Binding Progress}" Height="10" />
    </StackPanel>
</Window>
"@ 

$reader=New-Object System.Xml.XmlNodeReader $xaml
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$Window.DataContext = [MainViewModel]::new()
$Window.ShowDialog()
