define([actes_MCO], [dnl

  define([ARG_ANO_PSA], $1)
  define([ARG_ACT_CCAM], $2)
  define([ARG_DTE_DBT], $3)
  define([ARG_DTE_FIN], $4)
  define([ARG_OUT_TBL], $5)

  define([VAR_ANNEE_DBT], substr(ARG_DTE_DBT, 5, 4))
  define([VAR_ANNEE_FIN], substr(ARG_DTE_FIN, 5, 4))
  
  create_empty(ZZ_SOUGHT_ACTS)
  (CODE_CCAM varchar2(7),
   DESCRIPTION varchar2(40))
/

  forloop([ANNEE], VAR_ANNEE_DBT, VAR_ANNEE_FIN, [
  insert into ZZ_SOUGHT_ACTS
  select distinct CDC_ACT as CODE_CCAM
    ,             DESCRIPTION
  from            T_MCOaaA a
  inner join      ARG_ACT_CCAM ac
    on            a.CDC_ACT like ac.PREFIXE_CCAM || '%'
/
  ])
  
  create_table(ZZ_TMP)
  select distinct CODE_CCAM, DESCRIPTION from ZZ_SOUGHT_ACTS
/
  rename_table(ZZ_TMP, ZZ_SOUGHT_ACTS)
  
  define([ANNEE], 2015) dnl random year to create empty table
  
  create_table(ARG_OUT_TBL)
  select     ap.BEN_IDT_ANO
    ,        sa.*
    ,        '01010000' as ENT_DAT
    ,        '31129999' as SOR_DAT
    ,        c.ETA_NUM
    ,        c.RSA_NUM
    ,        1 as [ANNEE]
  from       T_MCOaaA a
  inner join ZZ_SOUGHT_ACTS sa
    on       sa.CODE_CCAM = a.CDC_ACT
    and      sa.CODE_CCAM = 'Non existing act'
  inner join T_MCOaaC c
    on       j2k(a, c)
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
      ,        sa.*
      ,        VAR_DTE_ENT as ENT_DAT
      ,        VAR_DTE_SOR as SOR_DAT
      ,        c.ETA_NUM
      ,        c.RSA_NUM
      ,        ANNEE as [ANNEE]
    from       T_MCOaaA a
    inner join ZZ_SOUGHT_ACTS sa 
      on       a.CDC_ACT = sa.CODE_CCAM
      and      (a.ACV_ACT = '1' or a.ACV_ACT = ' ')
    inner join T_MCOaaC c
      on       j2k(a, c)
      and      date_oracle(VAR_DTE_SOR) >= date_oracle(ARG_DTE_DBT)
      and      date_oracle(VAR_DTE_SOR) <= date_oracle(ARG_DTE_FIN)
    inner join ARG_ANO_PSA ap
      on       ap.BEN_NIR_PSA = c.NIR_ANO_17
    inner join T_MCOaaB b
      on       j2k(b, c)
      nettoyage_sejours(b)
/


  ])
  
  drop_table(ZZ_SOUGHT_ACTS)
  
drop table FLUSH_INSERTIONS
/
])