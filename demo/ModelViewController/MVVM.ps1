Add-Type -AssemblyName PresentationFramework

$ViewModel = [PSCustomObject]@{
    Text = "👋, psconfeu!"
}

[string]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <Grid>
        <Label FontSize="100" Content="{Binding Text}"  /> 
    </Grid>
</Window>
"@



$Window = [Windows.Markup.XamlReader]::Parse($xaml)

$Window.DataContext = $ViewModel

$Window.ShowDialog()