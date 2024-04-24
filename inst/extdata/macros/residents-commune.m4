dnl ##########################################################
dnl #                                                        #
dnl # Cette macro produit une nouvelle table des BEN_NIR_ANO #
dnl # résidant dans une commune à une date donnée            #
dnl #                                                        #
dnl # ------------------------------------------------------ #
dnl #                                                        #
dnl # Cette macro doit être appelé avec 4 arguments :        #
dnl #                                                        #
dnl # residents_commune(TABLE_COMMUNES,                      #
dnl #                   '31122015',  -- date de résidence    #
dnl #                   TABLE_SORTIE)                        #
dnl #                                                        #
dnl ##########################################################

define([residents_commune],

[dnl

  define([RC_TABLE_COMMUNES], $1)
  define([RC_DATE_RESIDENCE], date_oracle($2))
  define([RC_TABLE_OUTPUT], $3)

  create_table(RC_ANO_AYANT_VECU)
  (select        ben.BEN_IDT_ANO
   from          IR_BEN_R ben
   inner join    RC_TABLE_COMMUNES rtc
   on            ben.BEN_RES_DPT = rtc.CODE_DPT
     and         ben.BEN_RES_COM = rtc.CODE_COM)

  union

  (select        ben.BEN_IDT_ANO
   from          IR_BEN_R_ARC ben
   inner join    RC_TABLE_COMMUNES rtc
   on            ben.BEN_RES_DPT = rtc.CODE_DPT
     and         ben.BEN_RES_COM = rtc.CODE_COM)
/

  create_table(RC_HIST_RES_RAW)
    (select     b.BEN_IDT_ANO
       ,        BEN_RES_DPT
       ,        BEN_RES_COM
       ,        BEN_DTE_MAJ
     from       IR_BEN_R b
     inner join RC_ANO_AYANT_VECU av
       on       b.BEN_IDT_ANO = av.BEN_IDT_ANO)

    union

    (select     b.BEN_IDT_ANO
       ,        BEN_RES_DPT
       ,        BEN_RES_COM
       ,        BEN_DTE_MAJ
     from       IR_BEN_R_ARC b
     inner join RC_ANO_AYANT_VECU av
       on       b.BEN_IDT_ANO = av.BEN_IDT_ANO)
/

  define([RC_NUMBERING_ADDRESSES], [
    (select BEN_IDT_ANO
      ,    BEN_RES_DPT
      ,    BEN_RES_COM
      ,    BEN_DTE_MAJ
      ,    row_number() over(
             partition by BEN_IDT_ANO
                 order by BEN_IDT_ANO, BEN_DTE_MAJ) as N
    from   RC_HIST_RES_RAW)
  ])

  create_table(RC_HIST_RES_BEFORE_DATE)
  select *
  from
  (select * from RC_HIST_RES_RAW
    union
  select BEN_IDT_ANO
    ,    BEN_RES_DPT
    ,    BEN_RES_COM
    ,    date_oracle('01011900') as BEN_DTE_MAJ
  from RC_NUMBERING_ADDRESSES
  where N = 1)
  where BEN_DTE_MAJ <= RC_DATE_RESIDENCE
  order by BEN_IDT_ANO, BEN_DTE_MAJ
/

  create_table(RC_TABLE_OUTPUT)
  select distinct  BEN_IDT_ANO
            ,      rtc.COMMUNE
  from       RC_HIST_RES_BEFORE_DATE a
  inner join RC_TABLE_COMMUNES rtc
    on        a.BEN_RES_DPT = rtc.CODE_DPT
    and       a.BEN_RES_COM = rtc.CODE_COM

  where a.BEN_DTE_MAJ = (
             select max(BEN_DTE_MAJ) as BEN_DTE_MAJ
             from RC_HIST_RES_BEFORE_DATE b
             where a.BEN_IDT_ANO = b.BEN_IDT_ANO)
/

drop_table(RC_ANO_AYANT_VECU)
drop_table(RC_HIST_RES_RAW)
drop_table(RC_HIST_RES_BEFORE_DATE)
])
