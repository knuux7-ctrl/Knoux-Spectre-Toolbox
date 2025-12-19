<#
# file: security/access.control.ps1
.SYNOPSIS
    AccessControlManager for users, roles, and permissions
#>

using namespace System.Security.Cryptography
using namespace System.Text

class AccessControlManager {
    [hashtable] $Users
    [hashtable] $Roles
    [hashtable] $Permissions
    [string] $AuthFile
    [bool] $RequireAuthentication

    AccessControlManager([string]$authFile = "./config/auth.json", [bool]$requireAuth = $false) {
        $this.AuthFile = $authFile
        $this.RequireAuthentication = $requireAuth
        $this.Users = @{}
        $this.Roles = @{}
        $this.Permissions = @{}
        $this.LoadAuthData()
    }

    [void] LoadAuthData() {
        if (Test-Path $this.AuthFile) {
            try {
                $data = Get-Content $this.AuthFile | ConvertFrom-Json
                $this.Users = $data.users
                $this.Roles = $data.roles
                $this.Permissions = $data.permissions
                Write-Verbose "🔒 Authentication data loaded"
            } catch { Write-Warning "Failed to load auth data: $($_.Exception.Message)" }
        } else { $this.InitializeDefaultAuth() }
    }

    [void] InitializeDefaultAuth() {
        $this.Roles = @{
            "admin" = @("full_access","module_management","system_config")
            "user" = @("read_access","basic_commands")
            "guest" = @("read_only")
        }

        $this.Permissions = @{
            "full_access" = @("*")
            "read_access" = @("read:*")
            "read_only" = @("read:view")
            "module_management" = @("modules:*")
            "system_config" = @("config:*")
            "basic_commands" = @("execute:basic_*")
        }

        $this.SaveAuthData()
    }

    [void] SaveAuthData() {
        $data = @{ users = $this.Users; roles = $this.Roles; permissions = $this.Permissions }
        $json = $data | ConvertTo-Json -Depth 10
        $dir = Split-Path $this.AuthFile -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        $json | Out-File -FilePath $this.AuthFile -Encoding UTF8
    }

    [string] HashPassword([string]$password) {
        $salt = "KnouxSpectreToolboxSalt2024"
        $bytes = [Encoding]::UTF8.GetBytes($password + $salt)
        $hash = SHA256.Create().ComputeHash($bytes)
        return [BitConverter]::ToString($hash).Replace("-", "").ToLower()
    }

    [bool] CreateUser([string]$username, [string]$password, [string]$role = "user") {
        if ($this.Users.ContainsKey($username)) { Write-Warning "User $username already exists"; return $false }
        if (-not $this.Roles.ContainsKey($role)) { Write-Warning "Role $role does not exist"; return $false }

        $this.Users[$username] = @{
            username = $username
            password_hash = $this.HashPassword($password)
            role = $role
            created_at = Get-Date
            last_login = $null
            enabled = $true
        }

        $this.SaveAuthData()
        Write-Host "👤 User $username created successfully" -ForegroundColor Green
        return $true
    }

    [bool] Authenticate([string]$username, [string]$password) {
        if (-not $this.Users.ContainsKey($username)) { Write-Warning "User $username not found"; return $false }
        $user = $this.Users[$username]
        if (-not $user.enabled) { Write-Warning "User $username is disabled"; return $false }
        $hashed = $this.HashPassword($password)
        if ($hashed -eq $user.password_hash) { $user.last_login = Get-Date; $this.Users[$username] = $user; $this.SaveAuthData(); Write-Verbose "🔑 User $username authenticated"; return $true }
        Write-Warning "Invalid password for user $username"; return $false
    }

    [bool] HasPermission([string]$username, [string]$permission) {
        if (-not $this.RequireAuthentication) { return $true }
        if (-not $this.Users.ContainsKey($username)) { return $false }
        $user = $this.Users[$username]
        $role = $user.role
        $rolePerms = $this.Roles[$role] ?: @()

        foreach ($perm in $rolePerms) {
            $permRules = $this.Permissions[$perm] ?: @()
            foreach ($rule in $permRules) {
                if ($rule -eq "*" -or $permission -like $rule) { return $true }
            }
        }
        return $false
    }

    [string[]] GetUserPermissions([string]$username) {
        if (-not $this.Users.ContainsKey($username)) { return @() }
        $user = $this.Users[$username]
        $rolePerms = $this.Roles[$user.role] ?: @()
        $permissions = @()
        foreach ($perm in $rolePerms) { $permissions += ($this.Permissions[$perm] ?: @()) }
        return $permissions
    }

    [void] EnableUser([string]$username) { if ($this.Users.ContainsKey($username)) { $this.Users[$username].enabled = $true; $this.SaveAuthData(); Write-Host "🔓 User $username enabled" -ForegroundColor Green } }
    [void] DisableUser([string]$username) { if ($this.Users.ContainsKey($username)) { $this.Users[$username].enabled = $false; $this.SaveAuthData(); Write-Host "🔒 User $username disabled" -ForegroundColor Yellow } }

    [void] ChangeUserRole([string]$username, [string]$newRole) {
        if (-not $this.Roles.ContainsKey($newRole)) { throw "Role $newRole does not exist" }
        if ($this.Users.ContainsKey($username)) { $this.Users[$username].role = $newRole; Write-Host "🎭 User $username role changed to $newRole" -ForegroundColor Green }
    }

    [hashtable] GetUserInfo([string]$username) { return $this.Users[$username] ?: $null }
    [string[]] GetAllUsers() { return [string[]]($this.Users.Keys) }

    [hashtable] GetSession([string]$username) {
        $user = $this.GetUserInfo($username)
        if ($user) { return @{ username = $username; role = $user.role; permissions = $this.GetUserPermissions($username); authenticated = $true; session_start = Get-Date } }
        return @{ authenticated = $false }
    }
}

# Initialize global access control
$global:AccessControl = [AccessControlManager]::new((Join-Path $PSScriptRoot '..\config\auth.json'), $false)
