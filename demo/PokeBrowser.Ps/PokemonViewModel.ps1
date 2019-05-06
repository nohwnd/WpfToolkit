class PokemonViewModel : WpfToolkit.ViewModelBase { 
    [string] $Name 
    [int]    $Weight
    [int]    $Height
    [string] $Type
    [string] $Image

    PokemonLinkViewModel () {
        Write-Host "Constructing Main view Model"

        $this.Init('Name')
        $this.Init('Weight')
        $this.Init('Height')
        $this.Init('Type')
        $this.Init('Image')
   }
}