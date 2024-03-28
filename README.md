# sndsmart

+ Ce package facilite l'accès et le requêtage des données ORACLE sur le SNDS

## Installation
+ Il faut d'abord installer le package suivant https://github.com/pietrodito/sndshare

## Connexion
```
sndsmart::connect()
```

## Éxecution de requêtes SQL
+ Préparez un fichier `test.sql`
+ Chaque requête devra être séparée d'une autre par la ligne suivante :
    ```
    /
    ```
+ Exemple de fichier :
    ```{sql}
    create table ZZZ_PARISIENS_100ANS_H as
    select *
    from IR_BEN_R
    where BEN_RES_DPT = '075'
      and BEN_NAI_ANN < 1924
      and BEN_SEX_COD = '1'
    /

    create table ZZZ_PARISIENS_100ANS_F as
    select *
    from IR_BEN_R
    where BEN_RES_DPT = '075'
      and BEN_NAI_ANN < 1924
      and BEN_SEX_COD = '2'
    /
    ```
    + On exécute ce fichier :
        ```
        sndsmart::exec_sql_file("test.sql")
        ```

    + On obtient ceci :

    <p align="center">
          <img alt="résultat après exécution des requêtes"
               src="./README_images/résultat_après_exécution_des_requêtes.PNG"/>
    </p>

