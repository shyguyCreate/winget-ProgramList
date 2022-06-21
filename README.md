# System Installed Programs (winget)

## Description

If you have used `winget list` and counted the number of programs, maybe you have noticed that the number does not match with the number of applications in the Control Panel or in the Apps and Programs section in the Settings app.

And if you are like me and wanted to know where `winget` get all that many programs, this script makes just that.

The script will look through the registry, grab the programs and information about the *type of program* that it finds, and stored them in variables. Finally, the script also creates a file with all the programs that are found, this file is written in a similar way in which `winget` writes its logs.

If you `echo` the most important variable `$allPrograms`, it will be sort in ASCII order, because that is the way `winget` sort the `Id` column in the **list** output.

**NOTE:** All programs in the variables will match the same name as the `Id` column if you run `winget list -s msstore`.

### Purpose

As mention before, this script was made to understand from where is that `winget` is obtaining information about the programs that are displayed when running `winget list`.

### How to run it

Make sure your system has permission for running scripts. Enter this in your powershell terminal.

> Set-ExecutionPolicy RemoteSigned

**Running process**
1. Download the powershell script into your system.
2. In a powershell terminal, `cd` into the script directory.
3. Enter `. .\wingetProgramList.ps1` in the terminal.

### See also

- [winget-GetProperties](https://github.com/shyguyCreate/winget-GetProperties) - Transform `winget` output columns into real properties.
- [winget-MakeLogsEasier](https://github.com/shyguyCreate/winget-MakeLogsEasier) - Delete unnecessary log information created by `winget`.
