$DebugPreference = 'continue'
. "$PSScriptRoot\..\..\wpf.ps1"

. "$PSScriptRoot\Tasks.ps1"

. "$PSScriptRoot\PokemonViewModel.ps1"

. "$PSScriptRoot\PokemonLinkViewModel.ps1"

. "$PSScriptRoot\MainView.ps1"
. "$PSScriptRoot\MainViewModel.ps1"

$DebugPreference = 'continue'

[Diagnostics.PresentationTraceSources]::Refresh()
[Diagnostics.PresentationTraceSources]::DataBindingSource.Listeners.Add([Diagnostics.ConsoleTraceListener]::new())
[Diagnostics.PresentationTraceSources]::DataBindingSource.Switch.Level = "Warning, Error"


$Window=[Windows.Markup.XamlReader]::Parse($xaml)
$Window.DataContext = [MainViewModel]::new()
$Window.ShowDialog()