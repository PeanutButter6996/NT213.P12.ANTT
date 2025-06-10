 try {
        if ($valuelog[$key] -and ([System.Management.Automation.PSSerializer]::Serialize($valuelog[$key])) -ne 
                            ([System.Management.Automation.PSSerializer]::Serialize($info))) { $valuelog[$key] = $NaObject; }
        else { $valuelog[$key] = $info; }
    } catch {
        if ($valuelog[$key] -and (Stringify $valuelog[$key] $false) -ne (Stringify $info $false)) { $valuelog[$key] = $NaObject; }
        else { $valuelog[$key] = $info; }
    } 
