```


        _            ___                       
       ( )          (  _`\                     
   _ _ | |/')   ___ | (_) )   _ _   ___    __  
 /'_` )| , <  /',__)|  _ <' /'_` )/',__) /'__`\
( (_| || |\`\ \__, \| (_) )( (_| |\__, \(  ___/
`\__,_)(_) (_)(____/(____/'`\__,_)(____/`\____)


```
# Nasazení AKS pomocí Bicep

Nasazení Azure Kubernetes Service (AKS) pomocí Bicep

- pouziva skromny avsak prehledny a ucelu dostacujici modul naming
- pouziva overlay model pro setreni adresami
- nasazuje acr, kvalut a log analytics workspace
- konfigurace podporuje více node poolů pro různé workloady, edituje se na jednom miste
- clustery aks se nasazuji kazdy zvlast dle potreby
- moduly pracuji s verzemi (aka api)

# Vytvoření AKS

Prihlasit se do spravne subskripce:

```
az login
az account set --subscription "xxxxxx"
```


```
az deployment sub create --location westeurope --template-file deploy-aks.bicep --parameters params\NIS.olab.deploy-aks887.bicepparam
az deployment sub create --location westeurope --template-file deploy-aks.bicep --parameters params\NIS.olab.deploy-aks888.bicepparam
```

TODO:
- common RG pridat spolecny valut
- pridat grafanu
- jeden acr per subskripce
- vytvorit simple psql deploy s parametrizaci pro db 
