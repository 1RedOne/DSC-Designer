File EnsureTemp #ResourceName
{
    DestinationPath = 'c:\ham'
    Ensure = 'Present'
    SourcePath = 'c:\temp'
    Type = 'Directory'
    Recurse = $true
    }