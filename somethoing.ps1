$keys = $valuelog.Keys | Where-Object { $valuelog[$_] -is [NaObject] -or "$($valuelog[$_])"
                                            .Contains('System.Management.Automation.Deobfuscation.NaNObject') }
foreach ($key in $keys) { $valuelog[$key] = $null; }
