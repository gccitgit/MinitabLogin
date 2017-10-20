#
#  Credit for much of this goes to /u/Lee_Dailey
#  https://www.reddit.com/r/PowerShell/comments/6wkjes/find_and_replaceedit_multiple_lines_in_text_file/dm8wuy9/
#

$SourceDir = $env:ProgramData+"\Minitab"
$SourceFile = 'License.ini'
$file = Join-Path -Path $SourceDir -ChildPath $SourceFile

if(Test-Path $file)
    {
    $InContent = Get-Content($file).Split("`n").Trim()

    # $first = (get-aduser $env:USERNAME).givenname - THIS ONLY WORKS IF ACTIVEDIRECTORY MODULE IS IMPORTED, WHICH IT ISN'T, AND CAN'T/WON'T BE
    # $last = (get-aduser $env:USERNAME).surname
    $dom = $env:userdomain
    $usr = $env:username
    $fullname = ([adsi]"WinNT://$dom/$usr,user").fullname | out-string
    $fullname = $fullname -replace '\s',''
    $last,$first = $fullname.split(',')
    if ($first -eq $null)
        {
        $first = "UNIVERSITY" #PII removed
        }
    if ($last -eq $null)
        {
        $last = "UNIVERSITY" #PII removed
        }
    $PC = $env:COMPUTERNAME
    $guid = New-GUID

    $Lookup = @{
        machineID = $PC
        EMail = $env:username+"@my.UNIVERSITY.edu" #PII removed
        firstName = $first
        lastName = $last
        guidID = $guid
        }

    $KeyList = $Lookup.Keys

    $OutContent = foreach ($IS_Item in $InContent)
        {
        $ISI_Split = $IS_Item.Split('=')
        foreach ($KL_Item in $KeyList)
            {
            if ($ISI_Split[0] -eq $KL_Item)
                {
                $ISI_Split[1] = $Lookup[$KL_Item]
                $IS_Item = $ISI_Split -join '='
                }
            }
        $IS_Item
        }

    $OutContent |
        Set-Content -LiteralPath $file -Force
    }