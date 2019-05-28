Add-Type -AssemblyName PresentationFramework

$Model = [PSCustomObject]@{
    Text = "👋, psconfeu!"
}

[string]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <Grid>
        <Label FontSize="100" Name="Text"  /> 
    </Grid>
</Window>
"@



$Window = [Windows.Markup.XamlReader]::Parse($xaml)

$Text = $Window.Content.FindName("Text")
$Text.Content = $Model.Text

$Window.ShowDialog()


