```


        _            ___                       
       ( )          (  _`\                     
   _ _ | |/')   ___ | (_) )   _ _   ___    __  
 /'_` )| , <  /',__)|  _ <' /'_` )/',__) /'__`\
( (_| || |\`\ \__, \| (_) )( (_| |\__, \(  ___/
`\__,_)(_) (_)(____/(____/'`\__,_)(____/`\____)

aks and omnious resources [provisioning]
```
v1.0

# Nasazení AKS pomocí Bicep

Nasazení Azure Kubernetes Service (AKS) pomocí Bicep

- pouziva skromny, avsak prehledny a ucelu dostacujici modul naming
- pouziva overlay model pro setreni adresami
- nasazuje acr, kvalut a log analytics workspace
- konfigurace podporuje více node poolů pro různé workloady, edituje se na jednom miste
- clustery aks se nasazuji kazdy zvlast, dle potreby
- moduly pracuji s verzemi (aka api)
- custom naming space ak[s/n] (aks - service), akn (akn - nodes)
- deploy muze byt paralelni pro jednotliva aks do subskripce pri pouziti --name parametru

# Vytvoření AKS

Prihlasit se do spravne subskripce (napr. LAB.Otest):

```
az login
az account set --subscription "a9e591c0-f3c2-4e9d-87f1-0b0408c87dda"
az account show --output table
```

Deploy aks887 (pri spusteni prosim vzdy pouzivejte parametr __--name__)
```
az deployment sub create --location westeurope --name deploy-aks-887 --template-file deploy-aks.bicep --parameters params\NIS.olab.deploy-aks887.bicepparam
```

Deploy aks888 (pri spusteni prosim vzdy pouzivejte parametr __--name__)
```
az deployment sub create --location westeurope --name deploy-aks-890 --template-file deploy-aks.bicep --parameters params\NIS.olab.deploy-aks890.bicepparam
```

TODO:
- common RG pridat spolecny valut
- pridat grafanu
- jeden acr per subskripce
- vytvorit simple psql deploy s parametrizaci pro db 
- pipeliny pro separatni start stop clusteru

SECURITY2DO:
- container registries should not allow unrestricted network access
- running containers as root user should be avoided
- container images should be deployed from trusted registries only
