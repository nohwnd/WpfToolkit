[string]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Poke Browser" Height="450" Width="800">

    <DockPanel>
        <ProgressBar DockPanel.Dock="Bottom" Visibility="{Binding ProgressVisibility}" 
                     IsIndeterminate="True" Height="20" BorderThickness="0" />

        <StackPanel DockPanel.Dock="Top">
            <Button Command="{Binding Refresh}">Refresh</Button>
            <TextBlock Margin="0 32 0 0">Select Pokemon:</TextBlock>
            <ComboBox 
                ItemsSource="{Binding PokemonList}" 
                DisplayMemberPath="Name" 
                SelectedValue="{Binding Selected, Mode=TwoWay}"/>
            <Button Command="{Binding Show}">Show</Button>

        </StackPanel>
        <Grid Margin="20" DataContext="{Binding Detail}">
            <TextBlock Text="{Binding Name}" FontSize="48" Grid.ColumnSpan="2"/>

            <TextBlock Grid.Column="0" Grid.Row="1">Weight</TextBlock>
            <TextBlock Grid.Column="1" Grid.Row="1" Text="{Binding Weight}"/>

            <TextBlock Grid.Column="0" Grid.Row="2">Height</TextBlock>
            <TextBlock Grid.Column="1" Grid.Row="2" Text="{Binding Height}"/>

            <Image Grid.Column="1" Grid.Row="0" Grid.RowSpan="4" Source="{Binding Image}" />


            <Grid.ColumnDefinitions>
                <ColumnDefinition/>
                <ColumnDefinition Width="4*"/>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition />
            </Grid.RowDefinitions>
        </Grid>

    </DockPanel>
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontSize" Value="24"/>
        </Style>
        <Style TargetType="ComboBox">
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontSize" Value="24"/>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="FontSize" Value="24"/>
        </Style>
    </Window.Resources>
</Window>
"@ 

