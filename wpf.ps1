Add-Type -Path  "C:\projects\WPwshF\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"
Import-Module "C:\projects\WPwshF\ObservableConcurrentQueue.dll"

[WpfToolkit.ViewModelBase]::InvokeCommand = $ExecutionContext.InvokeCommand
[WpfToolkit.ViewModelBase]::InitScript = {
    # could also be implemented as Action<> that we set directly
    # from powershell
    param($self, $PropertyName)
    $self | 
        Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
            param(`$value)
            `$this.'$PropertyName' = `$value
            `$this.OnPropertyChanged('$PropertyName')
        ")) -PassThru | 
        Add-Member -MemberType ScriptMethod -Name "Get$PropertyName" -Value ([ScriptBlock]::Create("
            `$this.'$PropertyName'
        "))
}