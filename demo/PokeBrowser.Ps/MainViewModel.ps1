class MainViewModel : WpfToolkit.ViewModelBase {
    [Windows.Input.ICommand] $Refresh 
    [Windows.Input.ICommand] $Show

    [Collections.ObjectModel.ObservableCollection[object]] $PokemonList 
    [object] $Selected
    [PokemonViewModel] $Detail
    [Windows.Visibility] $ProgressVisibility

    [String] $_root = $PSScriptRoot
    
    MainViewModel () {
        $this.Init('PokemonList')
        $this.Init('Selected')
        $this.Init('Detail')
        $this.Init('ProgressVisibility')
        $this.SetProgressVisibility('Hidden')

        $doRefresh = { 
            param($this, $o)
            
            try {
                Dispatch { $this.SetProgressVisibility("Visible") }

                . "$($this._root)/Tasks.ps1"
                $pokemon = Get-Pokemon     
                Start-Sleep -Seconds 1     
                
                $collection = [Collections.ObjectModel.ObservableCollection[object]]::new($pokemon)
                $this.SetPokemonList($collection)
                $this.SetSelected(($pokemon | Select -First 1))       
            }
            finally { 
                Dispatch { $this.SetProgressVisibility('Hidden') }
            }
        }
         
        $doShow = {
            param($this, $o)
            
            try {
                Dispatch { $this.SetProgressVisibility("Visible") }

                . "$($this._root)/Tasks.ps1"
                $pokemon = Get-PokemonDetail ($this.Selected.Url)

                Start-Sleep -Seconds 1     
                
                $this.SetDetail($pokemon)
            }
            finally { 
                Dispatch { $this.SetProgressVisibility('Hidden') }
            }
        }
         

        $this.Refresh = $this.NewBackgroundCommand($doRefresh, {})
         
        $this.Show = $this.NewBackgroundCommand($doShow, {})
    }
}

