# command that runs on background
$work = { 
    param($this, $o)

    "$(Get-Date) Ping" | Out-File -FilePath "c:\temp\put.txt" -Append
                
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ $syncHash.this.SetProgress(10)});
    Start-Sleep -Seconds 2
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ $syncHash.this.SetProgress(50)});
    Start-Sleep -Seconds 2
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ $syncHash.this.SetProgress(99)});
}

$callback = {  
    param($this)
    function w ($string) {
        $string | Out-File -FilePath "c:\temp\put.txt" -Append
    }


    w ($null -eq $this)
      
    $this.SetValue("2234")
                    
    w "Dispatcher done"
}

$afterWork = 
{
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ 
        function w ($string) {
            $string | Out-File -FilePath "c:\temp\put.txt" -Append
        }

        w ("callback $($synchash.callback)")
        &$syncHash.CallBack $syncHash.This 
    })
}

# main worker that builds the runspace and invokes work in it

$d = 