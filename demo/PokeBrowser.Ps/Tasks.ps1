function Get-Pokemon { 
    $url = "https://pokeapi.co/api/v2/pokemon/?limit=300"
    $response = Invoke-RestMethod -Uri $url

    $response.Results | foreach { [PsCustomObject]$_ }
}


function Get-PokemonDetail ($Url) {
    $response = Invoke-RestMethod -Uri $url

    [PSCustomObject]@{ 
       Name = $response.name
       Height = $response.Height
       Weight = $response.weight
       Type = $response.types[0].type.name
       Image = $response.sprites.front_default 
   }
}

