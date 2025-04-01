function DeployFnapp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$FnappNumber
    )

    # Cesta k podadresáři functionapp
    $fnappDir = Join-Path -Path $ConfigPath -ChildPath "fnapp"

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

    # Vytvoření názvu nasazení
    $deploymentName = "deploy-fnapp-${FnappNumber}"

    # Cesta k parametrickému souboru v functionapp
    $paramsFile = Join-Path -Path $fnappDir -ChildPath "fnapp${FnappNumber}.bicepparam"

    # Kontrola existence definičního souboru
    if (-not (Test-Path -Path $paramsFile)) {
        Write-Warning "Definiční soubor $paramsFile pro Function App $FnappNumber neexistuje."
        return
    }

    # Debug výpisy cest a parametrů
    Write-Host "ConfigPath: $ConfigPath"
    Write-Host "fnappDir: $fnappDir"
    Write-Host "envJsonPath: $envJsonPath"
    Write-Host "paramsFile: $paramsFile"
    Write-Host "deploymentName: $deploymentName"
    Write-Host "location: $location"

    # Spuštění nasazení přes az cli
    az deployment sub create --location $location --name $deploymentName --template-file deploy-fnapp.bicep --parameters $paramsFile

    # Kontrola výsledku nasazení
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Nasazení FunctionApp $FnappNumber proběhlo úspěšně."
    } else {
        Write-Error "Nasazení FunctionApp $FnappNumber selhalo."
    }
}