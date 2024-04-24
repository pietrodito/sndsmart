dnl ##########################################################
dnl #                                                        #
dnl # ano_psa(NOM_TABLE_SORTIE, option, liste_1, [liste_2])  #
dnl #                                                        #
dnl # Cette macro produit une nouvelle table faisant         #
dnl # correspondre les BEN_NIR_PSA aux BEN_IDT_ANO.          #
dnl #                                                        #
dnl # Dans cette nouvelle table on trouvera deux autres      #
dnl # colonnes :                                             #
dnl #   - PSA_AMB non NULL si BEN_NIR_PSA est lié à plus     #
dnl #     d'un ANO distinct, c'est le cas pour des jumeaux   #
dnl #     de même sexe ayants-droits du même assuré, si      #
dnl #     non NULL, sa valeur est celle du nbr. d'ANO        #
dnl #                                                        #
dnl #   - ANO_AMB non NULL si BEN_IDT_ANO est lié à plus     #
dnl #     d'un PSA distinct, c'est le cas pour des jumeaux   #
dnl #     de même sexe ayants-droits du même assuré, si      #
dnl #     non NULL, sa valeur est celle du nbr. de PSA       #
dnl #                                                        #
dnl # ------------------------------------------------------ #
dnl #                                                        #
dnl # Cette macro peut être appelé avec 3 ou 4 arguments, en #
dnl # fonctions des 3 options possibles ANO, PSA, ANO_PSA :  #
dnl #                                                        #
dnl # ano_psa(NOM_TABLE_SORTIE,                              #
dnl #         ANO,                                           #
dnl #         LISTE_ANO)                                     #
dnl #                                                        #
dnl # ano_psa(NOM_TABLE_SORTIE,                              #
dnl #         PSA,                                           #
dnl #         LISTE_PSA)                                     #
dnl #                                                        #
dnl # ano_psa(NOM_TABLE_SORTIE,                              #
dnl #         ANO_PSA,                                       #
dnl #         LISTE_ANO,                                     #
dnl #         LISTE_PSA)                                     #
dnl #                                                        #
dnl ##########################################################

define([ano_psa_tous_les_psa], [
  define([ap_liste_anos], $1)
  create_table(ANO_PSA_TOUS_LES_PSA)
    select     b.BEN_NIR_PSA
    from       IR_BEN_R b
    inner join ap_liste_anos t
      on       b.BEN_IDT_ANO = t.BEN_IDT_ANO
      and      b.BEN_CDI_NIR = '00'

   union

    select     b.BEN_NIR_PSA
    from       IR_BEN_R_ARC b
    inner join ap_liste_anos t
      on       b.BEN_IDT_ANO = t.BEN_IDT_ANO
/
])

define([ano_psa_prepare_psa], [
  define([ap_liste_psas], $1)
   create_table(ANO_PSA_TOUS_LES_PSA)
    select *
    from ap_liste_psas
/
])

define([ano_psa_prepare_ano], [
  define([ap_liste_anos], $1)
  ano_psa_tous_les_psa(ap_liste_anos)
])

define([ano_psa_tous_les_ano], [
  create_table(ANO_PSA_TOUS_LES_ANO)
    select b.BEN_IDT_ANO
    from       IR_BEN_R b
    inner join ANO_PSA_TOUS_LES_PSA p
      on       b.BEN_NIR_PSA = p.BEN_NIR_PSA
      and      b.BEN_IDT_ANO is not null

   union

    select b.BEN_IDT_ANO
    from       IR_BEN_R_ARC b
    inner join ANO_PSA_TOUS_LES_PSA p
      on       b.BEN_NIR_PSA = p.BEN_NIR_PSA
      and      b.BEN_IDT_ANO is not null
/
])

define([ano_psa_prepare_ano_psa], [
  define([ap_liste_anos], $1)
  define([ap_liste_psas], $2)
  ano_psa_tous_les_psa(ap_liste_anos)
  rename_table(ANO_PSA_TOUS_LES_PSA, ANO_PSA_TMP)
  create_table(ANO_PSA_TOUS_LES_PSA)
    (select BEN_NIR_PSA from ap_liste_psas)
   union
    (select BEN_NIR_PSA from ANO_PSA_TMP)
/
])

define([ano_psa_tous_les_ano_psa], [
  create_table(ANO_PSA_TOUS_LES_ANO_PSA)
    select          b.BEN_IDT_ANO
      ,             b.BEN_NIR_PSA
    from            IR_BEN_R b
    inner join      ANO_PSA_TOUS_LES_ANO t
      on            b.BEN_IDT_ANO = t.BEN_IDT_ANO
      and           b.BEN_CDI_NIR = '00'

   union

    select          b.BEN_IDT_ANO
      ,             b.BEN_NIR_PSA
    from            IR_BEN_R_ARC b
    inner join      ANO_PSA_TOUS_LES_ANO t
      on            b.BEN_IDT_ANO = t.BEN_IDT_ANO
/
])

define([ano_psa_create_psa_ambigus], [
   create_table(ANO_PSA_PSA_AMBIGUS)
   select BEN_NIR_PSA
     ,    N_ANO
   from
          (select  BEN_NIR_PSA
            ,      count(BEN_IDT_ANO) as N_ANO
          from     ANO_PSA_TOUS_LES_ANO_PSA
          group by BEN_NIR_PSA)
   where  N_ANO > 1
/
])

define([ano_psa_merge_psa_ambigus], [
  create_table(ANO_PSA_PSA_AMBIGUS_MERGED)
  select     ap.*
    ,        pa.N_ANO as PSA_AMB
  from       ANO_PSA_TOUS_LES_ANO_PSA ap
  left join  ANO_PSA_PSA_AMBIGUS pa
    on       pa.BEN_NIR_PSA = ap.BEN_NIR_PSA
/
])

define([ano_psa_create_ano_ambigus], [
   create_table(ANO_PSA_POSSIBLE_ANO_AMBIGUS)
   select BEN_IDT_ANO
   from ANO_PSA_PSA_AMBIGUS_MERGED
   where  PSA_AMB is not null
/

   create_table(ANO_PSA_COUNT_ANO_AMBIGUS)
   select BEN_IDT_ANO
     ,    N_PSA
     from
     (
       select BEN_IDT_ANO
         ,     count(BEN_IDT_ANO) as N_PSA
       from   (select * from ANO_PSA_PSA_AMBIGUS_MERGED
               where  BEN_IDT_ANO in (select * from
                                        ANO_PSA_POSSIBLE_ANO_AMBIGUS))
       group by BEN_IDT_ANO
     )
   where  N_PSA > 1
/
])

define([ano_psa_merge_ano_ambigus], [
  create_table(ANO_PSA_ANO_AMBIGUS_MERGED)
  select     pam.*
    ,        aa.N_PSA as ANO_AMB
  from       ANO_PSA_PSA_AMBIGUS_MERGED pam
  left join  ANO_PSA_COUNT_ANO_AMBIGUS aa
    on       pam.BEN_IDT_ANO = aa.BEN_IDT_ANO
/
])

define([ano_clean_tmp_tables], [
  drop_table(ANO_PSA_PSA_AMBIGUS)
  drop_table(ANO_PSA_PSA_AMBIGUS_MERGED)
  drop_table(ANO_PSA_TOUS_LES_ANO)
  drop_table(ANO_PSA_TOUS_LES_PSA)
  drop_table(ANO_PSA_TOUS_LES_ANO_PSA)
  drop_table(ANO_PSA_ANO_AMBIGUS)
  drop_table(ANO_PSA_TMP)
])

define([ano_psa_main], [
  ano_psa_tous_les_ano
  ano_psa_tous_les_ano_psa
  ano_psa_create_psa_ambigus
  ano_psa_merge_psa_ambigus
  ano_psa_create_ano_ambigus
  ano_psa_merge_ano_ambigus
])

define([ano_psa], [

  define([ap_table_sortie], $1)
  define([ap_option], $2)
  define([ap_liste_1], $3)
  define([ap_liste_2], $4)


  ifelse(ap_option, ANO,     [ano_psa_prepare_ano(ap_liste_1)],
         ap_option, PSA,     [ano_psa_prepare_psa(ap_liste_1)],
         ap_option, ANO_PSA, [ano_psa_prepare_ano_psa(ap_liste_1, ap_liste_2)])

  ano_psa_main

 rename_table(ANO_PSA_ANO_AMBIGUS_MERGED, ap_table_sortie)

 ano_clean_tmp_tables
])
