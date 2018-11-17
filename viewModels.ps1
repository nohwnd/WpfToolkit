
class MainViewModel : WpfToolkit.ViewModelBase {
    [String] $Value = "*"
    [Windows.Input.ICommand] $Click 

    MainViewModel () {
        $this.Init('Value')

        $this.Click = $this.NewCommand({
            param($this, $o)

            $psCmd = [powershell]::Create()
            $work = {       
                "$(Get-Date) Ping" | Out-File -FilePath "c:\temp\put.txt" -Append
                
                Start-Sleep -Seconds 4


                [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ 
                    function w ($string) {
                     $string | Out-File -FilePath "c:\temp\put.txt" -Append
                    }

                    w ("callback $($synchash.callback)")
                    &$syncHash.CallBack $syncHash.This 
                })


            }
            $callback = {  
                    param($this)
                    function w ($string) {
                     $string | Out-File -FilePath "c:\temp\put.txt" -Append
                    }


                    w ($null -eq $this)
                    
                    
                     "heelllooo" 
                    $this.SetValue("2234")
                    
                    w "Dispatcher done"
                    }

            $syncHash = [hashtable]::Synchronized(@{ 
                This = $this
                CallBack = $callback })

            $newRunspace =[runspacefactory]::CreateRunspace()      
            $newRunspace.Open()
            
            Write-Host "o is populated: " ($null-ne $syncHash)
            $newRunspace.SessionStateProxy.SetVariable("syncHash",  $syncHash) 
            $psCmd.Runspace = $newRunspace
            $psCmd.AddScript($work)

            $psCmd.BeginInvoke()
        })
    }
}