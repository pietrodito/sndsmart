define([ald], [

    define([ARG_ANO_PSA], $1)
    define([ARG_NUM_ALD], $2)
    define([ARG_OUT_TBL], $3)
    
    create_table(ARG_OUT_TBL)
     select   p.BEN_IDT_ANO
     ,      imb.IMB_ALD_NUM
     ,      trim(imb.MED_MTF_COD) as ALD_COD_CIM
     ,      dc.DESCRIPTION
     ,      imb.IMB_ALD_DTD
     ,      imb.IMB_ALD_DTF
     from       ARG_ANO_PSA p
     inner join IR_IMB_R imb
       on       p.BEN_NIR_PSA = imb.BEN_NIR_PSA
    inner join ARG_NUM_ALD dc
       on      imb.IMB_ALD_NUM = dc.ALD_NUM
       
/
])
  
define([ald_cim], [

    define([ARG_ANO_PSA], $1)
    define([ARG_DGN_CIM], $2)
    define([ARG_OUT_TBL], $3)
    
    create_table(ARG_OUT_TBL)
     select   p.BEN_IDT_ANO
     ,      imb.IMB_ALD_NUM
     ,      trim(imb.MED_MTF_COD) as ALD_COD_CIM
     ,      dc.DESCRIPTION
     ,      imb.IMB_ALD_DTD
     ,      imb.IMB_ALD_DTF
     from       ARG_ANO_PSA p
     inner join IR_IMB_R imb
       on       p.BEN_NIR_PSA = imb.BEN_NIR_PSA
    inner join ARG_DGN_CIM dc
       on      trim(imb.MED_MTF_COD) like dc.PREFIXE_CIM || '%' 
/
])
  
