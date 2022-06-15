#----------------------------------------------------------
#
#     Author of the script: shyguyCreate
#                Github.com/shyguyCreate
#
#----------------------------------------------------------


#################### Fuctions ############################

function SeparateARP([System.Collections.ArrayList]$arpList, [string]$path)
{
    foreach($arp in (Get-ChildItem $path | Select-Object Name))
    {   
        #Adds 'Registry::' to beginning so that it can be recognized by Get-ItemProperty
        $arpReg = "Registry::$($arp.Name)"
        
        #Leaves only the program name without path.
        $arp.Name = $arp.Name | Split-Path -Leaf

        #If this arp has no SystemComponent and if DisplayName exist enters here.
        if($null -ne (Get-ItemProperty $arpReg | Where-Object SystemComponent -ne 1 | Where-Object DisplayName -ne $null)){
            $arp | Add-Member -NotePropertyName Type -NotePropertyValue Program;
        }
        #If this arp has SystemComponent enters here.
        elseif($null -ne (Get-ItemProperty $arpReg | Where-Object SystemComponent -eq 1)){
            $arp | Add-Member -NotePropertyName Type -NotePropertyValue SystemComponent;
        }
        #If this arp has no Property at all enters here.
        else{
            $arp | Add-Member -NotePropertyName Type -NotePropertyValue $null;
        }
        #Adds the ARP with the New Member to the list.
        $arpList.Add($arp) > $null;
    }
}


################## For ARP entries ########################

#All paths for ARP programs
$arpLM64Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*";
$arpLM86Path = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*";
$arpCU64Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*";

#List for each ARP path.
$Global:arpLM64Programs = [System.Collections.ArrayList]::new();
$Global:arpLM86Programs = [System.Collections.ArrayList]::new();
$Global:arpCU64Programs = [System.Collections.ArrayList]::new();

#It adds the ARP by path and also adds a property to identify the type of programs that they are.
SeparateARP $Global:arpLM64Programs -path $arpLM64Path;
SeparateARP $Global:arpLM86Programs -path $arpLM86Path;
SeparateARP $Global:arpCU64Programs -path $arpCU64Path;

#Add all the ARP with the new property to a single variable for later.
$Global:arpALLPrograms = $Global:arpLM64Programs + $Global:arpLM86Programs + $Global:arpCU64Programs;
$Global:arpALLPrograms = $Global:arpALLPrograms | Sort-Object Name -Unique;



################## For MSIX entries ########################

$Global:msixPrograms = (Get-AppxPackage -PackageTypeFilter Main | 
                        Where-Object -Property SignatureKind -ne 'System' |
                        Select-Object -ExpandProperty PackageFamilyName);



################## For Winget List Command ########################

#List for all programs to be sorted in ASCII.
$Global:allPrograms = [System.Collections.ArrayList]::new();

#For some inexplicable reason only when you add one by one the items it can sort correctly in ASCII.
foreach($prog in (($Global:arpALLPrograms | Where-Object Type -eq Program).Name + $Global:msixPrograms))
{
    $Global:allPrograms.Add($prog) > $null;
}
#List is sorted in ASCII.
$Global:allPrograms.Sort([System.StringComparer]::Ordinal);



################## For Sending to File ########################

#Path for the .txt file
$txtPath =  "$env:USERPROFILE\Desktop\winget programs.txt";

#If the file does not exits then it is ceated.
if((Test-Path $txtPath) -eq $false)
{
    New-Item $txtPath > $null;
}

#Sends all the data to a .txt file, but first it removes all previous data.
Clear-Content $txtPath;
#Sends ARP to .txt file
Add-Content $txtPath ("ARP entries for Machine | X64`n");
Add-Content $txtPath (($Global:arpLM64Programs | Where-Object Type -eq Program).Name);
Add-Content $txtPath ("`nARP entries for Machine | X86`n");
Add-Content $txtPath (($Global:arpLM86Programs | Where-Object Type -eq Program).Name);
Add-Content $txtPath ("`nARP entries for User | X64`n");
Add-Content $txtPath (($Global:arpCU64Programs | Where-Object Type -eq Program).Name);
#Sends MSIX to .txt file
Add-Content $txtPath ("`nARP (MSIX) entries for User | X64`n");
Add-Content $txtPath ($Global:msixPrograms);

Write-Host "`nOpening .txt file with information about programs on the system."
#Open .txt file
Invoke-Item $txtPath;

#List of global variables
Write-Output "`r`n`n============List of available script variables============`n";
#Gets the variables and prints them with a dollar sign ($) char in the beginning.
Get-Variable -Name all*,arp*,msix* -Exclude *Path -Scope Global | ForEach-Object {Write-Output "`$$($_.Name)"};

#Gives some advice to the host for the variables usage
Write-Output "`n--Use 'Where-Object' to separte parts of the variable output"
Write-Output "--Use 'Measure-Object' to count the number of programs"
Write-Output "--Use 'Set-Clipboard -Append' to add the variable output to the clipboard`n`n"


#END of the script