# What's working 
#   + clicking a check box now adds the DSC configuration to a tab, but you can't edit it ???
#   - removed the wonky sizing and now handle sizing using a grid
#   - super long delay when clicking a button, need to find a better way to handle that
#   - need to remove the expander box and instead just display the compiled config below 

$inputXML = @"
<Window x:Class="WpfTutorialSamples.Panels.GridColRowSpan"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       Title="DSC Explorer" SizeToContent="Height" Width="525" Height="277.286">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="1*" />
            <ColumnDefinition Width="2*" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="5*" />
            <RowDefinition Height="2*" />
        </Grid.RowDefinitions>
        <GroupBox x:Name="groupBox" Header="Resources" HorizontalAlignment="Left" VerticalAlignment="Top"  Margin="0,0,0,5">
            <WrapPanel x:Name="Resources" HorizontalAlignment="Left" Margin="0,0,0,0" VerticalAlignment="Top" >
                <WrapPanel.Background>
                    <LinearGradientBrush EndPoint="0.5,1" StartPoint="0.5,0">
                        <GradientStop Color="#FFBD5B04" Offset="0"/>
                        <GradientStop Color="#FF1AD3E5" Offset="1"/>
                        <GradientStop Color="White" Offset="0.505"/>
                    </LinearGradientBrush>
                </WrapPanel.Background>
                <Button Name="Clear" Content="Remove All" Width="137" />
            </WrapPanel>
        </GroupBox>
        
            <TabControl x:Name="tabControl" Grid.Column="1" >
                <TabItem Header="TabItem">
                    <Grid Background="#FFE5E5E5"/>
                </TabItem>

            </TabControl>
        
        <DockPanel Grid.ColumnSpan="2" Grid.Row="2">
            <Expander Grid.ColumnSpan="2" Margin="2,0,0,0" Header="Preview" IsExpanded="False" Grid.Row="2" >
                <RichTextBox x:Name="richTextBox" FontFamily="Consolas">
                    <FlowDocument>
                        <Paragraph>
                            <Run Background="White" Text="RichTextBox"/>
                        </Paragraph>
                    </FlowDocument>
                </RichTextBox>

            </Expander>
        </DockPanel>
    </Grid>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way <span class="wp-smiley wp-emoji wp-emoji-bigsmile" title=":D">:D</span>
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
    #===========================================================================
    # Use this space to add code to the various form elements in your GUI
    #===========================================================================
    
    $resources = Get-DscResource                                                                
     
    ForEach ($resource in $resources){
        $newCheckBox = New-Object System.Windows.Controls.CheckBox                                                                                                                                             
            $newCheckBox.Name = $resource.Name
            $newCheckBox.Content = $resource.Name
            $newCheckBox.Background = "White"
            $newCheckBox.Width = '137'
            $newCheckBox.Add_checked({
                    $TabName = $this.Name
                    $tab = New-Object System.Windows.Controls.TabItem
                    $tab.Name = "$($TabName)Tab"
                    $tab.Header = $TabName
                    $tab.Content = Get-DscResource $this.Name -Syntax
                    $WPFtabControl.AddChild($tab)
                    })

            $newCheckBox.Add_unchecked({
                    $WPFtabControl.Items.Remove(($WPFtabControl.Items | Where Header -eq $this.Name))
                    })
            
        [void]$WPFResources.Children.Add($newCheckBox) 

    }

    $WPFClear.Add_Click({
        $WPFResources.Children | ? Name -ne Clear | % {$_.IsChecked = $False}
    })
   # for ($i =0; $i -lt $WPFResources.Children.Count; $i++){
   #     $WPFResources.children[$i] | %{
   #         "setting up event handler for $($_.Name)"
   #         $TabName = $WPFResources.children[$i].Name
   #         $_.Add_Click({
   #         $tab = New-Object System.Windows.Controls.TabItem
   #         $tab.Name = "$($TabName)Tab"
   #         $tab.Header = "$($TabName)"
   #         $WPFtabControl.AddChild($tab)
   #         })
   #     }
   # }
    #Reference 
 
    #Remove an item when unchecked
      #$WPFtabControl.Items.Remove($WPFtabControl.Items[0])
     
    #Setting the text of a text box to the current PC name    
      #$WPFtextBox.Text = $env:COMPUTERNAME
     
    #Adding code to a button, so that when clicked, it pings a system
    # $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
    # })
    #===========================================================================
    # Shows the form
    #===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'
 
 
 $Form.ShowDialog() | out-null