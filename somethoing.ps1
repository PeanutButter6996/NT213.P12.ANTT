function CodeFormat ($ScriptString) {
    $tokens = [System.Management.Automation.PSParser]::Tokenize($ScriptString, [ref]$null)
    $tokens = $tokens | Sort-Object { - $_.Start }
    $lineflag = $false
    $linestart = 0
    $lineend = 0
    $groupdepth = 0
    $identtype = '    '
    for ($i = 0; $i -lt $tokens.Count; $i++) {
        $token = $tokens[$i]
        if ($token.Type -eq 'GroupEnd') { $groupdepth ++ }
        if ($token.Type -eq 'GroupStart') { $groupdepth -- }
        if (($token.Type -eq 'StatementSeparator' -and $groupdepth -eq 0) -or ($token.Type -eq 'NewLine')) {
            if (!$lineflag) { $lineend = $token.Start + $token.Length; $lineflag = $true; }
        } elseif ($lineflag) {
            $lineflag = $false
            $linestart = $token.Start + $token.Length
            $ScriptString = $ScriptString.SubString(0, $linestart) + "`r`n" + $ScriptString.SubString($lineend)
        }
        if ($token.Type -eq 'Command' -and $tokens[$i + 1] -and @('NewLine', 'LineContinuation').Contains($tokens[$i + 1].Type.ToString())) {
            $ScriptString = $ScriptString.SubString(0, $tokens[$i + 1].Start + $tokens[$i + 1].Length) + 
                                                            $identtype * $groupdepth + $ScriptString.SubString($token.Start)
        }
    }
    return $ScriptString
}
