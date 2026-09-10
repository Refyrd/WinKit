Add-Type -AssemblyName PresentationFramework
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinKit" Width="800" Height="550" 
        WindowStartupLocation="CenterScreen" Background="#202020" Foreground="#FFFFFF"
        FontFamily="Segoe UI" FontSize="14">
    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="Background" Value="#2D2D2D"/>
            <Setter Property="Foreground" Value="Black"/>
            <Setter Property="Padding" Value="15,10"/>
        </Style>
    </Window.Resources>
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock Text="WinKit - App Installer" FontSize="28" FontWeight="SemiBold" Foreground="#4CC2FF" Margin="0,0,0,20"/>
        <TabControl Name="TabCats" Grid.Row="1" Background="#282828" BorderThickness="0" Padding="10"/>
    </Grid>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader([xml]$xaml))
$win = [Windows.Markup.XamlReader]::Load($reader)
$win.Close()
Write-Host "Success"
