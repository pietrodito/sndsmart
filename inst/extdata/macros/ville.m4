define([praticiens_ville], [dnl

  define([ARG_ANO_PSA],        $1)
  define([ARG_SPE_PRATICIENS], $2)
  define([ARG_DTE_DBT],        $3)
  define([ARG_NB_MOIS],        $4)
  define([ARG_OUT_TBL],        $5)

  create_table(ZZ_PRATICIENS)
  select distinct PFS_PFS_NUM
    ,             PFS_PRA_SPE
    ,             PFS_SPA_LIB
  from            DA_PRA_R pra
  inner join      ARG_SPE_PRATICIENS pfs
  on              pra.PFS_PRA_SPE = pfs.PFS_SPA_COD
    and           pfs.SELECTION = 1
/

  create_table(ZZ_PRATICIENS_UNIQUE_SPE)
  select a.*
  from   ZZ_PRATICIENS a
  inner join (select   PFS_PFS_NUM
                ,      max(PFS_PRA_SPE) MAX_SPE
              from     ZZ_PRATICIENS
              group by PFS_PFS_NUM) b
  on  b.PFS_PFS_NUM = a.PFS_PFS_NUM
    and a.PFS_PRA_SPE = b.MAX_SPE
/

   create_table(ARG_OUT_TBL)
   select      aap.BEN_IDT_ANO
     ,         prs.EXE_SOI_DTD
     ,         prs.BSE_PRS_NAT
     ,         nat.PRS_NAT_LIB
     ,         spe.PFS_SPA_LIB
   from        ER_PRS_F prs
   inner join  ZZ_PRATICIENS_UNIQUE_SPE spe
     on        spe.PFS_PFS_NUM = prs.PFS_EXE_NUM
     and       prs.FLX_DIS_DTD = '01011900'
   inner join  ARG_ANO_PSA aap
     on        aap.BEN_NIR_PSA = prs.BEN_NIR_PSA
   inner join IR_NAT_V nat
     on       nat.PRS_NAT = prs.BSE_PRS_NAT
/

  FLX_LOOP(ARG_DTE_DBT, ARG_NB_MOIS, [dnl
   insert into ARG_OUT_TBL
   select      aap.BEN_IDT_ANO
     ,         prs.EXE_SOI_DTD
     ,         prs.BSE_PRS_NAT
     ,         nat.PRS_NAT_LIB
     ,         spe.PFS_SPA_LIB
   from        ER_PRS_F[]ARC prs
   inner join  ZZ_PRATICIENS_UNIQUE_SPE spe
     on        spe.PFS_PFS_NUM = prs.PFS_EXE_NUM
     and       prs.FLX_IDX
   inner join  ARG_ANO_PSA aap
     on        aap.BEN_NIR_PSA = prs.BEN_NIR_PSA
   inner join IR_NAT_V nat
     on       nat.PRS_NAT = prs.BSE_PRS_NAT
/
])
  ])
