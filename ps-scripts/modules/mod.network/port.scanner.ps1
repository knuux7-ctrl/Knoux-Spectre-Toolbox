# Knoux Spectre Port Scanner Module

function Get-LocalOpenPorts {
    $tcpConnections = Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"}
    return $tcpConnections | Sort-Object LocalPort | Select-Object LocalPort, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | Select-Object -First 20
}

function Test-RemotePort {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$Timeout = 1000
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $success = $asyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($success) {
            $tcpClient.EndConnect($asyncResult)
            $tcpClient.Close()
            return $true
        }
        $tcpClient.Close()
        return $false
    } catch {
        return $false
    }
}

Export-ModuleMember -Function @('Get-LocalOpenPorts', 'Test-RemotePort')
