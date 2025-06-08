function Stringify ($Object, $check = $true) {
    #$global:Object2 = $Object
    if ($check -and $null -ne $Object -and $null -ne $global:Rule['ALLOW_TYPE'] 
                    -and -not $global:Rule['ALLOW_TYPE'].Contains($Object.GetType())) { throw 'Type denied!' }
    if ($check -and $null -ne $Object -and ($global:Rule['BAN_TYPE'].Contains($Object.GetType()) 
                    -or @('RuntimeAssembly') -contains $Object.GetType().Name)) { throw 'Type denied!' }
    if ($global:Rule['STRONG_TYPE']) { $t = (../Deobfuscation/ConvertTo-Expression.ps1 $Object $check -Strong -Expand -1 -Depth 3); }
    else { $t = (../Deobfuscation/ConvertTo-Expression.ps1 $Object $check -Expand -1 -Depth 3); }
    if ($check -and $t -match '\[pscustomobject\]') { throw 'pscustomobject denied!' }
    return $t
}
