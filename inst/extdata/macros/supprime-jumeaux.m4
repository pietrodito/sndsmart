dnl ##########################################################
dnl #                                                        #
dnl # supprime_jumeaux(TABLE_ANO_PSA)                        #
dnl #                                                        #
dnl # Cette macro prend en entrée une table issue de l'appel #
dnl # à la macro ano_psa() et la modifie en supprimant les   #
dnl # sujets pour lesquels il existe des PSA/ANO ambigus     #
dnl # autrement dit les jumeaux.                             #
dnl # ------------------------------------------------------ #
dnl #                                                        #
dnl # Cette macro doit être appelé avec 1 argument           #
dnl #                                                        #
dnl # supprime_jumeaux(TABLE_ANO_PSA)                        #
dnl #                                                        #
dnl ##########################################################
  
define([supprime_jumeaux], [dnl
                            
  define([ARG_TABLE_ANO_PSA], $1)
  
  create_table(SJ_TABLE_ANO_LIE_PSA_AMB)
  select distinct 
                  BEN_IDT_ANO
  from            ARG_TABLE_ANO_PSA
  where           PSA_AMB is not null
    and           ANO_AMB is not null
/
  
  create_table(SJ_TABLE_TEMP)
  select distinct 
                  BEN_IDT_ANO
    ,             BEN_NIR_PSA
  from            ARG_TABLE_ANO_PSA
  where           PSA_AMB is null
    and           BEN_IDT_ANO not in (
                     select BEN_IDT_ANO from SJ_TABLE_ANO_LIE_PSA_AMB)
/
  
  rename_table(SJ_TABLE_TEMP, ARG_TABLE_ANO_PSA)
  drop_table(SJ_TABLE_ANO_LIE_PSA_AMB)
])