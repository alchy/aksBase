```
v1.1

        _            ___                       
       ( )          (  _`\                     
   _ _ | |/')   ___ | (_) )   _ _   ___    __  
 /'_` )| , <  /',__)|  _ <' /'_` )/',__) /'__`\
( (_| || |\`\ \__, \| (_) )( (_| |\__, \(  ___/
`\__,_)(_) (_)(____/(____/'`\__,_)(____/`\____)

aks and omnious resources [provisioning]
```

# Nasazení AKS 

```
. ./deploy-aks-helper.ps1
```


```
DeployAks -ConfigPath "./params/LAB.Otest/" -AksNumber "770"
```

# Nasazení Azure Function App (Python)

```
. ./deploy-fnapp-helper.ps1
```

```
DeployFnapp -ConfigPath "params\LAB.Otest" -FnappNumber "008"
```


