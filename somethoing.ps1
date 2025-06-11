$valuelog = @{}
$foreachCount = @{}
$funcCount = @{}
$funcDef = @{}
$funcDeob = @{}
foreach ($info in $infos) {
    if ($info.output -and $info.astType -eq 'ExpandableStringExpressionAst') { continue; }
    $prefix = ''
    if ($info.iexOffset) { $prefix = -join ($info.iexOffset | Sort-Object { - $info.iexOffset.IndexOf($_) } | ForEach-Object { '[{0},{1}]' -f $_[0], $_[1] }); }
    if ($info.output) { $key = $prefix + 'o' + $info.startOffset + ',' + $info.endOffset; }
    else { $key = $prefix + $info.astType + $info.startOffset + ',' + $info.endOffset; }
    try {
        if ($valuelog[$key] -and ([System.Management.Automation.PSSerializer]::Serialize($valuelog[$key])) -ne 
                                            ([System.Management.Automation.PSSerializer]::Serialize($info))) { $valuelog[$key] = $NaObject; }
        else { $valuelog[$key] = $info; }
    } catch {
        if ($valuelog[$key] -and (Stringify $valuelog[$key] $false) -ne (Stringify $info $false)) { $valuelog[$key] = $NaObject; }
        else { $valuelog[$key] = $info; }
    } 
    if ($info.commandName -eq 'ForEach-Object') { $foreachCount[$prefix + $info.startOffset + ',' + $info.endOffset] += 1 }
    if ($info.commandType -eq 'Function') { $funcCount[$info.commandName] += 1 }
}
