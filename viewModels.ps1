class MainViewModel : WpfToolkit.ViewModelBase {
    [String] $Value = "*"
    [Windows.Input.ICommand] $Click 

    MainViewModel () {
        $this.Init('Value')

        $this.Click = $this.NewCommand({
            param($this, $o)
            $this.SetValue($this.Value + "====*")
        })


    }
}