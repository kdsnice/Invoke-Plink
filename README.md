# Invoke-Plink
PowerShell module which wraps the plink.exe.

This is slight  modification of [Sample PowerShell module](https://gallery.technet.microsoft.com/scriptcenter/Sample-PowerShell-module-8d961a1c).</br>
Added two additional options: `-Port` and `-UseAgent`

This module has a dependency on [PLink.exe](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) available in the PuttyFiles folder. Before use this module, download `plink.exe` file and place it in the PuttyFiles folder, near to `Invoke-Plink.psd1` and `Invoke-Plink.psm1` files. 