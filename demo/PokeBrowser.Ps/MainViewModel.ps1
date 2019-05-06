class MainViewModel : WpfToolkit.ViewModelBase {
    [Windows.Input.ICommand] $Refresh 
    [Windows.Input.ICommand] $Show

    [Collections.ObjectModel.ObservableCollection[PokemonLinkViewModel]] $PokemonList 
    [PokemonLinkViewModel] $Selected
    [PokemonViewModel] $Detail
    [Windows.Visibility] $ProgressVisibility
    
    MainViewModel () {
        $this.Init('PokemonList')
        $this.Init('Selected')
        $this.Init('Detail')
        $this.Init('ProgressVisibility')


        $doRefresh = { 
            param($this, $o)
            
            try {
                Dispatch { $this.ProgressVisibility = "Visible" }
                log "root: $PSScriptRoot"
                log "getting pokemon"
                $p = Get-Pokemon         
                log ($p.count)
                $pokemon = $p | foreach { 
                    $p = [PokemonLinkViewModel]::new()
                    $p.Name = $_.Name
                    $p.Url = $_.Url
                    $p
                }

                $collection = [Collections.ObjectModel.ObservableCollection[PokemonLinkViewModel]]::new($pokemon)
                $this.SetPokemonList($collection)
                $this.SetSelected(($pokemon | Select -First 1))                
            }
            finally { 
                Dispatch { $this.ProgressVisibility = "Hidden" }
            }
        }
         
        $doShow = {
            param($this, $o)
            
            try {
                Dispatch { $this.ProgressVisibility = "Visible" }
                
            }
            finally { 
                Dispatch { $this.ProgressVisibility = "Hidden" }
            }
        }
         

        $this.Refresh = $this.NewBackgroundCommand($doRefresh, {})
         
        $this.Show = $this.NewBackgroundCommand($doShow, {})
    }
}

