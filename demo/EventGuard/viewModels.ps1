
[string]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Initial Window" Width="800" Height="600">
    <Grid>
        <TextBox FontSize="24" Text="{Binding Text}" Grid.ColumnSpan="3" TextWrapping="Wrap" />
        <TextBox FontSize="24" Text="Nothing...." Grid.ColumnSpan="3" TextWrapping="Wrap" Grid.Row="1" />
      
        <Button Command="{Binding AddStar}" Content="Add *" Grid.Row="2" Grid.Column ="1" />


        
        <Grid.RowDefinitions>
            <RowDefinition/>
            <RowDefinition/>
            <RowDefinition/>
        </Grid.RowDefinitions>

        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
    </Grid>
</Window>
"@ 


$Window=[Windows.Markup.XamlReader]::Parse($xaml)
$Window.DataContext = [MainViewModel]::new()
$Window.ShowDialog()


class MainViewModel : WpfToolkit.ViewModelBase {
    [String] $Text = "*"
    [int] $Progress
    [Windows.Input.ICommand] $AddStar
    

    MainViewModel () {
        $this.Init('Text')


        Write-host ($this.NewCommand| out-string)
        $this.AddStar = $this.NewCommand({ 
            param($this, $parameter)
            $this.SetText($this.Text + "*") 
        }, 
        {  
            param ($this, $parameter)

            $can =-not [String]::IsNullOrWhiteSpace($this.Text)
            Write-Host "Can Add* execute? $can"

            return $can
        })
    }
}