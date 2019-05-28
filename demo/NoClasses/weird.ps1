Add-Type -AssemblyName PresentationFramework

[string]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
<StackPanel>
    <Label Content="{Binding Name}" />
    <Label Content="{Binding Status}" />
    <Label Content="{Binding p.Name}" />
    <Label Content="{Binding p.Status}" />
</StackPanel>
</Window>
"@

[Diagnostics.PresentationTraceSources]::Refresh()
[Diagnostics.PresentationTraceSources]::DataBindingSource.Listeners.Add([Diagnostics.ConsoleTraceListener]::new())
[Diagnostics.PresentationTraceSources]::DataBindingSource.Switch.Level = "Warning, Error"

$Window=[Windows.Markup.XamlReader]::Parse($xaml)
$vm = [PSCustomObject]@{
    p = (Get-Service | Select -First 1)
}

# just Status works because that is a ".net" property,
# but Name does not work because that is alias property
$Window.DataContext = $vm.p

# both Name and Status works for some reason, I am guessing
# that either some special property resolver is used for psobject
# that was provided by powershell, or it falls back to some other 
# resolver for some different reason, like not having any ".net"
# properties, but I cannot find the real reason
$Window.DataContext = $vm

# works for all
$Window.DataContext = [PSCustomObject]@{ 
    p= [PSCustomObject]@{
       Name = 'name'
        Status = 'running' 
    }

    Name = 'name'
    Status = 'running' 
}

 
$Window.ShowDialog()