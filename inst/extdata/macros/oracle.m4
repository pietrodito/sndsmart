dnl **********************************
dnl * drop_table                     *
dnl *--------------------------------*
dnl * Supprimer une table            *
dnl *--------------------------------*
dnl * usage: drop_table(ONE_TABLE)   *
dnl **********************************
define([drop_table], [
drop table $1
/
])

define([create_empty], [
/**********************************************/
/* !!       Requête DROP automatisée       !! */
/* !! Erreur attendue si table inexistante !! */
/**********************************************/
drop_table($1)
create table $1])

dnl **********************************
dnl * create_table                   *
dnl *--------------------------------*
dnl * Crée une table                 *
dnl *--------------------------------*
dnl * usage: drop_table(ONE_TABLE)   *
dnl *--------------------------------*
dnl * La macro tente de supprimer la *
dnl * table avant de la créer.       *
dnl **********************************
define([create_table], [
create_empty($1) as])

dnl **********************************
dnl * count_lines                    *
dnl *--------------------------------*
dnl * Compte les lignes d'une table  *
dnl *--------------------------------*
dnl * usage: count_lines(ONE_TABLE)  *
dnl **********************************
define([count_lines], [
  select count(*) as N
  from $1
/
])

dnl **********************************
dnl * export                         *
dnl *--------------------------------*
dnl * Exporte une table côté R       *
dnl *--------------------------------*
dnl * usage: export(ONE_TABLE)       *
dnl **********************************
define([export],[
 select * from $1
/
])

dnl **********************************
dnl * export_first                   *
dnl *--------------------------------*
dnl * Exporte les premières lignes   *
dnl * d'une table côté R             *
dnl *--------------------------------*
dnl * usage:                         *
dnl * export_first(ONE_TABLE, 10)    *
dnl *--------------------------------*
dnl * exporte les 10 premières lignes*
dnl **********************************
define([export_first],[
 select * from $2
 where rownum <= $1
/
])

dnl **********************************
dnl * rename_table                   *
dnl *--------------------------------*
dnl * Renomme une table ORACLE       *
dnl *--------------------------------*
dnl * usage:                         *
dnl * rename_table(TABLE, NEW_NAME)  *
dnl *--------------------------------*
dnl * La macro tente de supprimer    *
dnl * la table NEW_NAME              *
dnl **********************************
define([rename_table], [dnl
drop_table($2)dnl
rename $1 to $2
/])

dnl **********************************
dnl * copy_table                     *
dnl *--------------------------------*
dnl * Copie une table ORACLE         *
dnl *--------------------------------*
dnl * usage:                         *
dnl * copy_table(TABLE, DEST)        *
dnl *--------------------------------*
dnl * La macro tente de supprimer    *
dnl * la table DEST                  *
dnl **********************************
define([copy_table], [dnl
drop_table($2)
create_table($2)
select * from $1
/
])

dnl **********************************
dnl * date_oracle                    *
dnl *--------------------------------*
dnl * Convertit une date au format   *
dnl * ORACLE                         *
dnl *--------------------------------*
dnl * usage:                         *
dnl * date_oracle('21032015')        *
dnl **********************************
define([date_oracle], [to_date($1, 'DDMMYYYY')])
