define([ttt_ucd], [

  define([ARG_ANO_PSA], $1)
  define([ARG_TTT_ATC], $2)
  define([ARG_DTE_DBT], $3)
  define([ARG_NB_MOIS], $4)
  define([ARG_OUT_TBL], $5)
  
  create_table(UCD_ATC)
    select [substr](PHA_ATC_CLA, 1, 7) as PHA_ATC_C07
      ,    ta.*
      ,    PHA_ATC_L03
      ,    lpad(PHA_CIP_UCD, 13, '0') as UCD_UCD_COD
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
     ,    ucd.UCD_DLV_NBR
   from       ARG_ANO_PSA p
   inner join ER_PRS_F prs
     on       p.BEN_NIR_PSA  = prs.BEN_NIR_PSA
     and      prs.FLX_DIS_DTD = to_date(16000101, 'YYYYMMDD')
   inner join ER_UCD_F ucd
      on      j9k(prs, ucd)
     and      ucd.FLX_DIS_DTD = to_date(16000101, 'YYYYMMDD')
   inner join UCD_ATC map
      on      map.UCD_UCD_COD = ucd.UCD_UCD_COD
/

  
  FLX_LOOP(ARG_DTE_DBT, ARG_NB_MOIS, [dnl
   insert into ARG_OUT_TBL
   select   p.BEN_IDT_ANO
     ,    map.*
     ,    prs.PSP_SPE_COD
     ,    prs.FLX_DIS_DTD
     ,    prs.EXE_SOI_DTD
     ,    ucd.UCD_DLV_NBR
   from  ARG_ANO_PSA p
   inner join ER_PRS_F[]ARC prs
     on    p.BEN_NIR_PSA  = prs.BEN_NIR_PSA
     and prs.FLX_IDX
   inner join ER_UCD_F[]ARC ucd
      on j9k(prs, ucd)
      and ucd.FLX_IDX
   inner join UCD_ATC map
      on      map.UCD_UCD_COD = ucd.UCD_UCD_COD
/
])
  
dnl  drop_table(UCD_ATC)
  
  drop table FLUSH_INSERTIONS
/
])

