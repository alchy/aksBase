function DeployAks {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$AksNumber,

        [Parameter()]
        [bool]$UseExistingKeyVault,

        [Parameter()]
        [bool]$UseExistingACR
    )

    # Cesta k podadresáři aks
    $aksDir = Join-Path -Path $ConfigPath -ChildPath "aks"

    # Vytvoření cesty k podadresáři tmp v aks
    $tmpDir = Join-Path -Path $aksDir -ChildPath "tmp"
    if (-not (Test-Path -Path $tmpDir)) {
        New-Item -ItemType Directory -Path $tmpDir | Out-Null
    }

    # Vytvoření cesty a názvu dočasného JSON souboru
    $jsonFileName = "aks${AksNumber}-tmp.json"
    $jsonFilePath = Join-Path -Path $tmpDir -ChildPath $jsonFileName

    # Načtení env.json z ConfigPath
    $envJsonPath = Join-Path -Path $ConfigPath -ChildPath "env.json"
    if (-not (Test-Path -Path $envJsonPath)) {
        Write-Error "Soubor env.json nenalezen v cestě $ConfigPath"
        return
    }
    $envData = Get-Content -Path $envJsonPath | ConvertFrom-Json
    $subscriptionId = $envData.subscriptionId
    $location = $envData.location  # Převzetí location z env.json

    # Nastavení subscription v Azure CLI
    az account set --subscription $subscriptionId

    # Zjištění hodnoty useExistingKeyVault
    if ($PSBoundParameters.ContainsKey('UseExistingKeyVault')) {
        # Uživatel zadal parametr, použije se jeho hodnota
        $useExistingKeyVaultValue = $UseExistingKeyVault
    } else {
        # Parametr nebyl zadán, proveď automatickou detekci
        $keyVaults = az keyvault list --subscription $subscriptionId --query "[?contains(name, '$AksNumber')]" --output json | ConvertFrom-Json
        if ($keyVaults.Count -gt 0) {
            $useExistingKeyVaultValue = $true
            Write-Host "Nalezen Key Vault obsahující '$AksNumber', nastavuji useExistingKeyVault na true."
        } else {
            $useExistingKeyVaultValue = $false
            Write-Host "Key Vault obsahující '$AksNumber' nebyl nalezen, nastavuji useExistingKeyVault na false."
        }
    }

    # Zjištění hodnoty useExistingACR
    if ($PSBoundParameters.ContainsKey('UseExistingACR')) {
        # Uživatel zadal parametr, použije se jeho hodnota
        $useExistingACRValue = $UseExistingACR
    } else {
        # Parametr nebyl zadán, proveď automatickou detekci
        $acrs = az acr list --subscription $subscriptionId --query "[?contains(name, '$AksNumber')]" --output json | ConvertFrom-Json
        if ($acrs.Count -gt 0) {
            $useExistingACRValue = $true
            Write-Host "Nalezen ACR obsahující '$AksNumber', nastavuji useExistingACR na true."
        } else {
            $useExistingACRValue = $false
            Write-Host "ACR obsahující '$AksNumber' nebyl nalezen, nastavuji useExistingACR na false."
        }
    }

    # Vytvoření JSON obsahu na základě parametrů
    $jsonContent = @{
        useExistingKeyVault = $useExistingKeyVaultValue
        useExistingACR = $useExistingACRValue
    } | ConvertTo-Json

    # Zápis JSON obsahu do dočasného souboru
    $jsonContent | Set-Content -Path $jsonFilePath

    # Vytvoření názvu nasazení
    $deploymentName = "deploy-aks-${AksNumber}"

    # Cesta k parametrickému souboru v aks
    $paramsFile = Join-Path -Path $aksDir -ChildPath "aks${AksNumber}.bicepparam"

    # Debug výpisy cest
    Write-Host "ConfigPath: $ConfigPath"
    Write-Host "aksDir: $aksDir"
    Write-Host "tmpDir: $tmpDir"
    Write-Host "envJsonPath: $envJsonPath"
    Write-Host "jsonFilePath: $jsonFilePath"
    Write-Host "paramsFile: $paramsFile"
    Write-Host "deploymentName: $deploymentName"

    # Spuštění nasazení přes az cli
    az deployment sub create --location $location --name $deploymentName --template-file deploy-aks.bicep --parameters $paramsFile

    # Kontrola výsledku nasazení
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Nasazení AKS clusteru $AksNumber proběhlo úspěšně."
    } else {
        Write-Error "Nasazení AKS clusteru $AksNumber selhalo."
    }
}