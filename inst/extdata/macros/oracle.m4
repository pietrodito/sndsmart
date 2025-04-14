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



  define([rec_helper], [
    define([ARG_FIRST], $1)
    define([ARG_LAST], $2)
    define([ARG_PREFIXE], $3)

    ifelse(eval(ARG_FIRST < ARG_LAST), 1, [
      dnl then
      define([NEW_FIRST], eval(ARG_FIRST + 1))
      create_table(ZZZ_TEMP)
      select * from ARG_PREFIXE
        union all
      select * from ARG_PREFIXE[]_[]NEW_FIRST
/

    create_table(ARG_PREFIXE)
    select * from ZZZ_TEMP

/
    rec_helper(NEW_FIRST, ARG_LAST, ARG_PREFIXE)
    ])
  ])

dnl **********************************
dnl * merge_annees                   *
dnl *--------------------------------*
dnl *                                *
dnl *                                *
dnl *--------------------------------*
dnl * usage:                         *
dnl * merge_annees(PREFIXE_TABLE,    *
dnl *              annee_debut,      *
dnl *              annee_fin)        *
dnl **********************************
define([merge_annees], [

  define([ARG_PREFIXE], $1)
  define([ARG_AN_DEBUT], $2)
  define([ARG_AN_FIN], $3)

  create_table(ARG_PREFIXE)
  select * from ARG_PREFIXE[]_[]ARG_AN_DEBUT
/

  rec_helper(ARG_AN_DEBUT, ARG_AN_FIN, ARG_PREFIXE)

  forloop([ANNEE], ARG_AN_DEBUT, ARG_AN_FIN, [
  drop_table(ARG_PREFIXE[]_[]ANNEE)
  ])

])


