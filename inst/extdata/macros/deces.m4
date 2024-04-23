define([deces_mco], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)
  define([ARG_ANN_DEB], $3)
  define([ARG_ANN_FIN], $4)
  
  
  create_table(ARG_OUT_TBL)
  select 
             s.BEN_IDT_ANO
   ,         b.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         2015 as [ANNEE]
  from       ARG_ANO_PSA s
  left join  T_MCO15C c
    on       s.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_MCO15B b
   on        j2k(b, c)
      and    b.SOR_MOD = 'impossible'
/
  
  forloop([year], ARG_ANN_DEB, ARG_ANN_FIN, [
    dead_on_year_mco(year)
  ])
  
  drop_table(FLUSH_INSERTIONS)
  
  select_last_death(ARG_OUT_TBL, MCO)
])



define([dead_on_year_mco], [

  define([ANNEE], $1)
  
  insert into ARG_OUT_TBL
  select distinct
             s.BEN_IDT_ANO
   ,         b.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         $1 as [ANNEE]
  from       ARG_ANO_PSA s
  left join  T_MCOaaC c
    on       s.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_MCOaaB b
   on        j2k(b, c)
      and    b.SOR_MOD = '9'
      nettoyage_sejours(b)
/
])

define([deces_ssr], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)
  define([ARG_ANN_DEB], $3)
  define([ARG_ANN_FIN], $4)
  
  
  create_table(ARG_OUT_TBL)
  select 
             s.BEN_IDT_ANO
   ,         b.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         2015 as [ANNEE]
  from       ARG_ANO_PSA s
  left join  T_SSR15C c
    on       s.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_SSR15B b
   on        j2k_ssr(b, c)
   and       b.SOR_MOD = 'impossible'
/
  
  forloop([year], ARG_ANN_DEB, ARG_ANN_FIN, [
    dead_on_year_ssr(year)
  ])
  
  drop_table(FLUSH_INSERTIONS)
  
  select_last_death(ARG_OUT_TBL, SSR)
])


define([dead_on_year_ssr], [

  define([ANNEE], $1)
  
  insert into ARG_OUT_TBL
  select distinct
             s.BEN_IDT_ANO
   ,         b.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         $1 as [ANNEE]
  from       ARG_ANO_PSA s
  left join  T_SSRaaC c
    on       s.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_SSRaaB b
   on        j2k_ssr(b, c)
   and       b.SOR_MOD = '9'
/
])

define([deces_psy], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)
  define([ARG_ANN_DEB], $3)
  define([ARG_ANN_FIN], $4)
  
  
  create_table(ARG_OUT_TBL)
  select 
             aap.BEN_IDT_ANO
   ,         s.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         2015 as [ANNEE]
  from       ARG_ANO_PSA aap
  left join  T_RIP15C c
    on       aap.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_RIP15S s
   on        j2k_rip(s, c)
   and       s.SOR_MOD = 'impossible'
/
  
  forloop([year], ARG_ANN_DEB, ARG_ANN_FIN, [
    dead_on_year_psy(year)
  ])
  
  drop_table(FLUSH_INSERTIONS)
  
  
  select_last_death(ARG_OUT_TBL, PSY)
])


define([dead_on_year_psy], [

  define([ANNEE], $1)
  
  insert into ARG_OUT_TBL
  select distinct
             aap.BEN_IDT_ANO
   ,         s.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         $1 as [ANNEE]
  from       ARG_ANO_PSA aap
  left join  T_RIPaaC c
    on       aap.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_RIPaaS s
   on        j2k_rip(s, c)
   and       s.SOR_MOD = '9'
/
])

define([deces_had], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)
  define([ARG_ANN_DEB], $3)
  define([ARG_ANN_FIN], $4)
  
  create_table(ARG_OUT_TBL)
  select 
             aap.BEN_IDT_ANO
   ,         s.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         2015 as [ANNEE]
  from       ARG_ANO_PSA aap
  left join  T_HAD15C c
    on       aap.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_HAD15S s
   on        j2k_had(s, c)
   and       s.SOR_MOD = 'impossible'
/
  
  forloop([year], ARG_ANN_DEB, ARG_ANN_FIN, [
    dead_on_year_had(year)
  ])
  
  drop_table(FLUSH_INSERTIONS)
  
  select_last_death(ARG_OUT_TBL, HAD)
  
])


define([dead_on_year_had], [

  define([ANNEE], $1)
  
  insert into ARG_OUT_TBL
  select distinct
             aap.BEN_IDT_ANO
   ,         s.SOR_MOD
   ,         date_oracle(c.SOR_DAT) as DECES
   ,         $1 as [ANNEE]
  from       ARG_ANO_PSA aap
  left join  T_HADaaC c
    on       aap.BEN_NIR_PSA = c.NIR_ANO_17
  inner join T_HADaaS s
   on        j2k_had(s, c)
   and       s.SOR_MOD = '9'
/
])

define([deces_cepi], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)
  
  create_table(ARG_OUT_TBL)
  select distinct
      ap.BEN_IDT_ANO
    , k.BEN_DCD_DTE as DCD_CPI
  from ARG_ANO_PSA ap
  inner join KI_ECD_R k
    on k.BEN_IDT_ANO = ap.BEN_IDT_ANO
/

])


define([deces_ben], [

  define([ARG_ANO_PSA], $1)
  define([ARG_OUT_TBL], $2)

   create_table(ARG_OUT_TBL)
   select BEN_IDT_ANO
     ,    max(BEN_DCD_DTE) as DCD_BEN
   from
       (select distinct
          b.BEN_IDT_ANO
       ,  b.BEN_DCD_DTE
       ,  extract(year from b.BEN_DCD_DTE) as ANNEE_DCD
       from (select BEN_NIR_PSA, BEN_IDT_ANO, BEN_DCD_DTE from IR_BEN_R
               union
             select BEN_NIR_PSA, BEN_IDT_ANO, BEN_DCD_DTE from IR_BEN_R_ARC) b
       inner join ARG_ANO_PSA n
         on       n.BEN_IDT_ANO = b.BEN_IDT_ANO
         and      b.BEN_DCD_DTE <> to_date('01011600', 'DDMMYYYY'))
   group by BEN_IDT_ANO
/

])



define([select_last_death], [

  define([ARG_OUT_TBL], $1)
  define([ARG_FRM_TBL], $2)
  
  create_table(Z_ERR_TMP_DEATH)
  select BEN_IDT_ANO
    ,    max(DECES) as DCD_[]ARG_FRM_TBL
  from     ARG_OUT_TBL
  group by BEN_IDT_ANO
/

  rename_table(Z_ERR_TMP_DEATH, ARG_OUT_TBL)
])