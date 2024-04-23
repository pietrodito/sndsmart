define([ttt], [

  define([ARG_ANO_PSA], $1)
  define([ARG_TTT_ATC], $2)
  define([ARG_DTE_DBT], $3)
  define([ARG_NB_MOIS], $4)
  define([ARG_OUT_TBL], $5)
  
  create_table(CIP7_ATC)
    select [substr](PHA_ATC_CLA, 1, 7) as PHA_ATC_C07
      ,    ta.*
      ,    PHA_ATC_L03
      ,    [substr](PHA_CIP_C13, 6, 7) as PHA_CIP_C07
      ,    trim(PHA_PRD_LIB1) as BOITE
    from IR_PHA_R
    inner join ARG_TTT_ATC ta
      on    [substr](PHA_ATC_CLA, 1, 7) like ta.PREFIXE_ATC || '%'
/

  create_table(ARG_OUT_TBL)
   select   p.BEN_IDT_ANO
     ,    map.*
     ,    prs.PSP_SPE_COD
     ,    prs.FLX_DIS_DTD
     ,    prs.EXE_SOI_DTD
     ,    pha.PHA_PRS_C13
     ,    pha.PHA_ACT_QSN
     ,    pha.PHA_PRS_IDE
   from       ARG_ANO_PSA p
   inner join ER_PRS_F prs
     on       p.BEN_NIR_PSA  = prs.BEN_NIR_PSA
     and      prs.FLX_DIS_DTD = to_date(16000101, 'YYYYMMDD')
   inner join ER_PHA_F pha
      on      j9k(prs, pha)
     and      pha.FLX_DIS_DTD = to_date(16000101, 'YYYYMMDD')
   inner join CIP7_ATC map
      on      (map.PHA_CIP_C07 = pha.PHA_PRS_IDE
                 or
               map.PHA_CIP_C07 = [substr](PHA_PRS_C13, 6, 7))
/

  
  FLX_LOOP(ARG_DTE_DBT, ARG_NB_MOIS, [dnl
   insert into ARG_OUT_TBL
   select   p.BEN_IDT_ANO
     ,    map.*
     ,    prs.PSP_SPE_COD
     ,    prs.FLX_DIS_DTD
     ,    prs.EXE_SOI_DTD
     ,    pha.PHA_PRS_C13
     ,    pha.PHA_ACT_QSN
     ,    pha.PHA_PRS_IDE
   from  ARG_ANO_PSA p
   inner join ER_PRS_F[]ARC prs
     on    p.BEN_NIR_PSA  = prs.BEN_NIR_PSA
     and prs.FLX_IDX
   inner join ER_PHA_F[]ARC pha
      on j9k(prs, pha)
      and pha.FLX_IDX
   inner join CIP7_ATC map
      on      (map.PHA_CIP_C07 = pha.PHA_PRS_IDE
                or
               map.PHA_CIP_C07 = [substr](PHA_PRS_C13, 6, 7))
/
])
  
  drop_table(CIP7_ATC)
  
  drop table FLUSH_INSERTIONS
/
])


