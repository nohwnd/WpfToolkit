class PokemonLinkViewModel : WpfToolkit.ViewModelBase { 
    [string] $Name 
    [string] $Url

    PokemonLinkViewModel () {
        Write-Host "Constructing Main view Model"

        $this.Init('Name')
        $this.Init('Url')
   }
}