$sampleSyntax = ((Get-DscResource User -Syntax).Split("`n") -join "`n")

#reference
{"
    UserName = [string]
    [DependsOn = [string[]]]
    [Description = [string]]
    [Disabled = [bool]]
    [Ensure = [string]{ Absent | Present }]
    [FullName = [string]]
    [Password = [PSCredential]]
    [PasswordChangeNotAllowed = [bool]]
    [PasswordChangeRequired = [bool]]
    [PasswordNeverExpires = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
" | ConvertFrom-StringData}

$fields = $sampleSyntax.Split("`n")[2..(($sampleSyntax.Split("`n").length)-3)] | ConvertFrom-StringData

foreach ($field in $fields){
    $name = $field.Keys[0] 
    if ($name -like "``[*"){$name = $name -replace '\['}
    if ($name -like "Ensure*"){"$name is our special absent/present and should be a radio";continue}
    if ($field.Values[0] -like "*string*"){"$name should render as a textbox for strings"}
    if ($field.Values[0] -like "*bool*")  {"$name should render as a radio true/false"}

}

