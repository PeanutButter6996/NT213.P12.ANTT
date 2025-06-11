function DeObfuscate ($ScriptString) {
    $Info = @{}
    $Ast = [scriptblock]::Create($ScriptString).Ast
    $Childs = @{}
    $NodeString = @{}
    $NodeValue = @{}
    $funcNodes = [System.Collections.Generic.List[object]]::new()
    $nodes = [object[]]$Ast.FindAll({
            param($node)
            if ($node.Parent) {
                $parId = (GetHashCode $node.Parent)
                if (!$Childs[$parId]) { $Childs[$parId] = [System.Collections.ArrayList]@(); }
                if (-not @('ParamBlockAst', 'FunctionDefinitionAst', 'DataStatementAst').Contains($node.GetType().Name)) {
                    $Childs[$parId].Add($node)
                }
            }
            $NodeString[(GetHashCode $node)] = $node.Extent.Text
            #if ($node.GetType().Name -eq 'FunctionDefinitionAst') { $funcDef[$node.Name + $node.Extent.StartOffset + ',' + $node.Extent.EndOffset] = $node.Extent.Text }
            if ($node.GetType().Name -eq 'FunctionDefinitionAst') {
                $funcDef[$node.Name] = $node.Extent.Text
                $funcNodes.Add($node)
            }
            # if ($node.GetType().Name -eq 'ParamBlockAst' -and $node.Attributes.Count) {
            #     $NodeString[(GetHashCode $node)] = $ScriptString.SubString($node.Attributes[0].Extent.StartOffset, $node.Extent.EndOffset - $node.Attributes[0].Extent.StartOffset)
            #     $Childs[$parId][-1] = @{
            #         Attributes = $node.Attributes
            #         Parameters = $node.Parameters
            #         Extent     = @{
            #             StartOffset = $node.Attributes[0].Extent.StartOffset
            #             EndOffset   = $node.Extent.EndOffset
            #             Text        = $ScriptString.SubString($node.Attributes[0].Extent.StartOffset, $node.Extent.EndOffset - $node.Attributes[0].Extent.StartOffset)
            #         }
            #         Parent     = $node.Parent
            #         HashCode   = (GetHashCode $node)
            #     }
            # }
            return $true
        }, $true)
    $Info['Root'] = (GetHashCode $Ast)
    $Info['Childs'] = [System.Collections.Generic.Dictionary[string, [string[]]]]::new()
    $Info['OriginNodeString'] = [System.Collections.Generic.Dictionary[string, string]]::new()
    $Info['ResultNodeString'] = [System.Collections.Generic.Dictionary[string, string]]::new()
    foreach ($key in $Childs.Keys) {
        try {
            $Info['Childs'][$key] = $Childs[$key] | Sort-Object { $_.Extent.StartOffset } | ForEach-Object { (GetHashCode $_) }
        } catch { $Info['Childs'][$key] = @() }
    }
    foreach ($key in $NodeString.Keys) { $Info['OriginNodeString'][$key] = $NodeString[$key]; }
    $stack = [System.Collections.Stack]@($Ast)
    if ($global:Rule['KEEP_USER_FUNCTION']) { $funcNodes | ForEach-Object { $stack.Push($_) } }
    $visited = @{}
    $user_function_parents = [System.Collections.Generic.HashSet[String]]::new()
    $var_node_parents = [System.Collections.Generic.HashSet[String]]::new()
    $nodes | ForEach-Object { $visited[(GetHashCode $_)] = $false; }
    while ($stack.Count) {
        $curNode = $stack.Pop()
        if ($visited[(GetHashCode $curNode)]) { ValueTraversal -curNode $curNode }
        else {
            $visited[(GetHashCode $curNode)] = $true
            $stack.Push($curNode)
            $Childs[(GetHashCode $curNode)] | Sort-Object { - $_.Extent.StartOffset } | ForEach-Object { $stack.Push($_); }
        }
    }
    #Write-Host $iexPrefix;
    $stack = [System.Collections.Stack]@($Ast)
    if ($global:Rule['KEEP_USER_FUNCTION']) { $funcNodes | ForEach-Object { $stack.Push($_) } }
    $nodes | ForEach-Object { $visited[(GetHashCode $_)] = $false; }
    while ($stack.Count) {
        $curNode = $stack.Pop()
        $curId = (GetHashCode $curNode)
        if ($visited[$curId]) {
            $childnodes = $Childs[$curId] | Sort-Object { - $_.Extent.StartOffset }
            try {
                $childnodes | ForEach-Object {
                    if ($_.Extent.GetType().Name -ne 'EmptyScriptExtent') {
                        $NodeString[$curId] = $NodeString[$curId].SubString(0, $_.Extent.StartOffset - $curNode.Extent.StartOffset) `
                            + $NodeString[(GetHashCode $_)] + $NodeString[$curId].SubString($_.Extent.EndOffset - $curNode.Extent.StartOffset) 
                    } }
            } catch {
                Write-Host -ForegroundColor red 'Substring Failed!'
            }
            PostTraversal -curNode $curNode
        } else {
            $visited[(GetHashCode $curNode)] = $true
            if ($user_function_parents.Contains((GetHashCode $curNode))) { $f = $true }
            else { $f = PreTraversal -curNode $curNode }
            if ($f) {
                $stack.Push($curNode)
                $Childs[$curId] | Sort-Object { $_.Extent.StartOffset } | ForEach-Object { $stack.Push($_); }
            }
        }
    }
    #Write-Host $iexPrefix;
    foreach ($key in $NodeString.Keys) { $Info['ResultNodeString'][$key] = $NodeString[$key]; }
    if ($SaveLog) { $Info | ConvertTo-Json > ('' + $Info['Root'] + '.json') }
    $s = $NodeString[(GetHashCode $Ast)]
    $s = CodeFormat -ScriptString $NodeString[(GetHashCode $Ast)]
    try {
        Get-Command -Name 'Invoke-Formatter' -ErrorAction SilentlyContinue | Out-Null || Import-Module ../Deobfuscation/PSScriptAnalyzer/1.21.0/PSScriptAnalyzer.psd1
        $t = Start-Job {Invoke-Formatter -ScriptDefinition $input -Settings ../Deobfuscation/FormatterSettings.psd1} -InputObject $s|Wait-Job -Timeout 30|Receive-Job
        if ($t) { $s = $t } else { throw "Timeout!" }
    } catch { Write-Host -ForegroundColor red 'Invoke-Formatter Failed!' }
    return $s
}
