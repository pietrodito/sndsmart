# sndsmart

+ Ce package facilite l'accès et le requêtage des données ORACLE sur le SNDS

## Installation
+ Il faut d'abord installer le package suivant https://github.com/pietrodito/sndshare

## Connexion
```
sndsmart::connect()`
```

## Éxecution de requêtes SQL
+ Préparez un fichier `test.sql`
+ Chaque requête devra être séparée d'une autre par la ligne suivante :
    ```
    /
    ```
+ Exemple de fichier :
    ```{sql}
    create table CENTENAIRES_PARISIENS_HOMMES
    select *
    from IR_BEN_R
    where BEN_RES_DTP = '075'
      and BEN_NAI_ANN < 1924
        and BEN_SEX_COD = 1
        /

        create table CENTENAIRES_PARISIENS_FEMMES
        select *
        from IR_BEN_R
        where BEN_RES_DTP = '075'
          and BEN_NAI_ANN < 1924
            and BEN_SEX_COD = 2
            /
    ```
