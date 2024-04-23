define([create_ARG_TBL],   [

  define([ANNEE], 2015) dnl random year to create empty table
  
  create_table(ARG_OUT_TBL)
    select     ap.BEN_IDT_ANO
      ,        sd.*
      ,        'DGN_XXX_123456' as TYP_DGN
      ,        '19071977' as ENT_DAT
      ,        '03032018' as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaB b
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(b.DGN_PAL) = sd.CODE_CIM
      and      sd.CODE_CIM = 'impossible code'
    inner join T_MCOaaC c
      on       j2k(b, c)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
/
])

define([diags_MCO_DP], [dnl

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
      ,        sd.*
      ,        'DGN_PAL' as TYP_DGN
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaB b
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(b.DGN_PAL) = sd.CODE_CIM
    inner join T_MCOaaC c
      on       j2k(b, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
      nettoyage_sejours(b)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
/

  ])
])


define([diags_MCO_DR], [dnl

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
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
      ,        sd.*
      ,        'DGN_REL' as TYP_DGN
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaB b
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(b.DGN_REL) = sd.CODE_CIM
    inner join T_MCOaaC c
      on       j2k(b, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
      nettoyage_sejours(b)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
/

  ])
])

define([diags_MCO_DAS], [dnl

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
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
      ,        sd.*
      ,        'DGN_ASS' as TYP_DGN
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaD d
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(d.ASS_DGN) = sd.CODE_CIM
    inner join T_MCOaaC c
      on       j2k(d, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
    inner join T_MCOaaB b
      on       j2k(b, c)
      nettoyage_sejours(b)
/

  ])
])


define([diags_MCO_DP_RUM], [dnl

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
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
      ,        sd.*
      ,        'DGN_ASS_DP_RUM' as TYP_DGN
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaUM um
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(um.DGN_PAL) = sd.CODE_CIM
    inner join T_MCOaaC c
      on       j2k(um, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
    inner join T_MCOaaB b
      on       j2k(b, c)
      nettoyage_sejours(b)
/

  ])
])

define([diags_MCO_DR_RUM], [dnl

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
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
      ,        sd.*
      ,        'DGN_ASS_DR_RUM' as TYP_DGN
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaUM um
    inner join ZZ_SOUGHT_DIAGS sd
      on       trim(um.DGN_REL) = sd.CODE_CIM
    inner join T_MCOaaC c
      on       j2k(um, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
    inner join T_MCOaaB b
      on       j2k(b, c)
      nettoyage_sejours(b)
/

  ])
])

define([select_sought_diags], [

  create_empty(ZZ_ALL_DIAGS)
  (CODE_CIM varchar2(10))
/

  forloop([ANNEE], VAR_ANNEE_DBT, VAR_ANNEE_FIN, [
    insert into ZZ_ALL_DIAGS
    select distinct trim(DGN_PAL) as CODE_CIM from T_MCOaaB b
     union 
    select distinct trim(DGN_REL) as CODE_CIM from T_MCOaaB b
     union 
    select distinct trim(ASS_DGN) as CODE_CIM from T_MCOaaD d
/
  ])
  
  create_table(ZZ_TEMP)
  select distinct * from ZZ_ALL_DIAGS
/

  rename_table(ZZ_TEMP, ZZ_ALL_DIAGS)
  
  create_table(ZZ_SOUGHT_DIAGS)
  select distinct  CODE_CIM
     ,            DESCRIPTION
  from         ZZ_ALL_DIAGS ad
  inner join   ARG_DGN_CIM dc
    on         ad.CODE_CIM like dc.PREFIXE_CIM || '%'
/    
       
  drop_table(ZZ_ALL_DIAGS)

])


define([diags_MCO], [
  define([ARG_ANO_PSA], $1)
  define([ARG_DGN_CIM], $2)
  define([ARG_DTE_DBT], $3)
  define([ARG_DTE_FIN], $4)
  define([ARG_OUT_TBL], $5)
  
  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
   select_sought_diags()
   create_ARG_TBL()
   diags_MCO_DP()
   diags_MCO_DR()
   diags_MCO_DAS()
   diags_MCO_DP_RUM()
   diags_MCO_DR_RUM()
   drop_table(ZZ_SOUGHT_DIAGS)

])
