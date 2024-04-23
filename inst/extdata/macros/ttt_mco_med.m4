define([ttt_mco_med], [dnl

  define([ARG_ANO_PSA], $1)
  define([ARG_TTT_ATC], $2)
  define([ARG_DTE_DBT], $3)
  define([ARG_DTE_FIN], $4)
  define([ARG_OUT_TBL], $5)

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
  create_table(UCD_ATC)
    select [substr](PHA_ATC_CLA, 1, 7) as PHA_ATC_C07
      ,    ta.*
      ,    PHA_ATC_L03
      ,    to_char(PHA_CIP_UCD) as PHA_CIP_UCD
      ,    trim(PHA_PRD_LIB1) as BOITE
    from IR_PHA_R
    inner join ARG_TTT_ATC ta
      on    [substr](PHA_ATC_CLA, 1, 7) like ta.PREFIXE_ATC || '%'
/
  
  
  define([ANNEE], 2015) dnl random year to create empty table
  
  create_table(ARG_OUT_TBL)
  select     ap.BEN_IDT_ANO
    ,        ucd.*
    ,        '01010000' as ENT_DAT
    ,        '31129999' as SOR_DAT
    ,        c.ETA_NUM
    ,        c.RSA_NUM
    ,        1 as [ANNEE]
  from       T_MCOaaMED med
  inner join UCD_ATC ucd
    on       med.UCD_UCD_COD like '34008' || ucd.PHA_CIP_UCD || '%'
    and      ucd.PHA_CIP_UCD = 'Create empty table'
  inner join T_MCOaaC c
    on       j2k(med, c)
  inner join ARG_ANO_PSA ap
    on       ap.BEN_NIR_PSA = c.NIR_ANO_17
/

 forloop([ANNEE], VAR_ANNEE_DBT, VAR_ANNEE_FIN, [
   ifelse(eval(ANNEE < 2009), 1,
   dnl --- then ---
   [define([VAR_DTE_ENT], ['05'|| c.SOR_MOI || c.SOR_ANN])
   define( [VAR_DTE_SOR], ['15'|| c.SOR_MOI || c.SOR_ANN])],
   dnl --- else ---
   [define([VAR_DTE_ENT], [c.ENT_DAT])
   define( [VAR_DTE_SOR], [c.SOR_DAT])])
    
    insert into ARG_OUT_TBL
    select     ap.BEN_IDT_ANO
      ,        ucd.*
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
      
  from       T_MCOaaMED med
  inner join UCD_ATC ucd
    on       med.UCD_UCD_COD like '34008' || ucd.PHA_CIP_UCD || '%'
    inner join T_MCOaaC c
      on       j2k(med, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
    inner join T_MCOaaB b
      on       j2k(b, c)
      nettoyage_sejours(b)
/


  ])
  
dnl  drop_table(UCD_ATC)
  
drop table FLUSH_INSERTIONS
/
])