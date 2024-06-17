## Pour vous connecter à la base ORACLE du SNDS
connect()

## Si vous avez besoin d'importer des données côté ORACLE :
upload_from_csv("data/départements_par_région.csv", "AAA_DPTS_REGIONS")


## NOTA BENE --------------------------------------------------------
## if(sys.nframe() == 0) <=> exécuter uniquement en mode interactif |
## autrement dit si vous exécutez le script, la ligne est ignorée   |
## ------------------------------------------------------------------

if(sys.nframe() == 0)  create_sql_file("01-xxxxxxxxxxx")
