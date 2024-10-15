dnl **********************************
dnl * j2k                            *
dnl *--------------------------------*
dnl * Facilite la jointure entre 2   *
dnl * tables du PMSI MCO             *
dnl *--------------------------------*
dnl * usage :                        *
dnl *                                *
dnl *   select *                     *
dnl *   from       T_MCO22B b        *
dnl *   inner join T_MCO22C c        *
dnl *     on j2k(b, c)               *
dnl *                                *
dnl *--------------------------------*
dnl * Au préalable b et c sont des   *
dnl * alisas de tables               *
dnl **********************************
define([j2k], [$1.ETA_NUM = $2.ETA_NUM and $1.RSA_NUM = $2.RSA_NUM])

dnl **********************************
dnl * j2k_ssr                        *
dnl *--------------------------------*
dnl * Facilite la jointure entre 2   *
dnl * tables du PMSI SSR             *
dnl **********************************
define([j2k_ssr], [$1.ETA_NUM = $2.ETA_NUM and $1.RHA_NUM = $2.RHA_NUM])

dnl **********************************
dnl * j2k_rip                        *
dnl *--------------------------------*
dnl * Facilite la jointure entre 2   *
dnl * tables du PMSI PSY             *
dnl **********************************
define([j2k_rip], [$1.ETA_NUM_EPMSI = $2.ETA_NUM_EPMSI and $1.RIP_NUM  = $2.RIP_NUM])

dnl **********************************
dnl * j2k_had                        *
dnl *--------------------------------*
dnl * Facilite la jointure entre 2   *
dnl * tables du PMSI HAD             *
dnl **********************************
define([j2k_had], [$1.ETA_NUM_EPMSI = $2.ETA_NUM_EPMSI and $1.RHAD_NUM = $2.RHAD_NUM])

define([GHM_CHIRURGICAL], [[substr]($1.GRG_GHM, 3, 1) = 'C'])

dnl **********************************
dnl * nettoyage_sejours              *
dnl *--------------------------------*
dnl * suit recommendations :         *
dnl * - dédoublonne FINESS GÉO       *
dnl * - supprime GHM en erreur       *
dnl * - supprime les séances         *
dnl * - supprime préstations         *
dnl *   inter-établissements         *
dnl **********************************
define([nettoyage_sejours], [
   define([prefixe], [$1])

   prefixe[].ETA_NUM
                not in ('130780521', '130783236', '130783293', '130784234',
                        '130804297', '600100101', '750041543', '750100018',
                        '750100042', '750100075', '750100083', '750100091',
                        '750100109', '750100125', '750100166', '750100208',
                        '750100216', '750100232', '750100273', '750100299',
                        '750801441', '750803447', '750803454', '910100015',
                        '910100023', '920100013', '920100021', '920100039',
                        '920100047', '920100054', '920100062', '930100011',
                        '930100037', '930100045', '940100027', '940100035',
                        '940100043', '940100050', '940100068', '950100016',
                        '690783154', '690784137', '690784152', '690784178',
                        '690787478', '830100558')
     and prefixe[].GRG_GHM not like '90%'
     and prefixe[].GRG_GHM not like '28%'
     and (prefixe[].SEJ_TYP is null or prefixe[].SEJ_TYP <> 'B')
])

dnl **********************************
dnl * nettoyage_chainage             *
dnl *--------------------------------*
dnl * ignore séjours non chainables  *
dnl * - utile en épidémiologie       *
dnl * - inutile pour activité étab.  *
dnl **********************************
define([nettoyage_chainage], [
  define([prefixe], [$1])

      (prefixe[].NIR_RET = '0' and prefixe[].NAI_RET = '0' and
       prefixe[].SEX_RET = '0' and prefixe[].SEJ_RET = '0' and
       prefixe[].FHO_RET = '0' and prefixe[].PMS_RET = '0' and
       prefixe[].DAT_RET = '0')
])


dnl *****************************************
dnl *  Pour utiliser les macros ci-dessous, *
dnl *  Vous devez définir ANNEE             *
dnl *                                       *
dnl *  define([ANNEE], [2015])              *
dnl *****************************************

define([ANNEE_2_DIGITS], [substr(ANNEE, [2], [2])])
define([T_MCOaaA],     [T_MCO[]ANNEE_2_DIGITS[]A])
define([T_MCOaaB],     [T_MCO[]ANNEE_2_DIGITS[]B])
define([T_MCOaaC],     [T_MCO[]ANNEE_2_DIGITS[]C])
define([T_MCOaaD],     [T_MCO[]ANNEE_2_DIGITS[]D])
define([T_MCOaaUM],    [T_MCO[]ANNEE_2_DIGITS[]UM])
define([T_MCOaaMED],   [T_MCO[]ANNEE_2_DIGITS[]MED])
define([T_MCOaaFMSTC], [T_MCO[]ANNEE_2_DIGITS[]FMSTC])

define([T_MCOabA],  [T_MCO[]incr(ANNEE_2_DIGITS)[]A])
define([T_MCOabB],  [T_MCO[]incr(ANNEE_2_DIGITS)[]B])
define([T_MCOabC],  [T_MCO[]incr(ANNEE_2_DIGITS)[]C])
define([T_MCOabD],  [T_MCO[]incr(ANNEE_2_DIGITS)[]D])
define([T_MCOabUM], [T_MCO[]incr(ANNEE_2_DIGITS)[]UM])

define([T_MCOzzA],  [T_MCO[]decr(ANNEE_2_DIGITS)[]A])
define([T_MCOzzB],  [T_MCO[]decr(ANNEE_2_DIGITS)[]B])
define([T_MCOzzC],  [T_MCO[]decr(ANNEE_2_DIGITS)[]C])
define([T_MCOzzD],  [T_MCO[]decr(ANNEE_2_DIGITS)[]D])
define([T_MCOzzUM], [T_MCO[]decr(ANNEE_2_DIGITS)[]UM])


define([T_SSRaaB],  [T_SSR[]ANNEE_2_DIGITS[]B])
define([T_SSRaaC],  [T_SSR[]ANNEE_2_DIGITS[]C])


define([T_HADaaS],  [T_HAD[]ANNEE_2_DIGITS[]S])
define([T_HADaaC],  [T_HAD[]ANNEE_2_DIGITS[]C])

define([T_RIPaaC],           [T_RIP[]ANNEE_2_DIGITS[]C])
define([T_RIPaaCCAM],        [T_RIP[]ANNEE_2_DIGITS[]CCAM])
define([T_RIPaaCSTC],        [T_RIP[]ANNEE_2_DIGITS[]CSTC])
define([T_RIPaaE],           [T_RIP[]ANNEE_2_DIGITS[]E])
define([T_RIPaaFA],          [T_RIP[]ANNEE_2_DIGITS[]FA])
define([T_RIPaaFB],          [T_RIP[]ANNEE_2_DIGITS[]FB])
define([T_RIPaaFC],          [T_RIP[]ANNEE_2_DIGITS[]FC])
define([T_RIPaaFH],          [T_RIP[]ANNEE_2_DIGITS[]FH])
define([T_RIPaaFI],          [T_RIP[]ANNEE_2_DIGITS[]FI])
define([T_RIPaaFL],          [T_RIP[]ANNEE_2_DIGITS[]FL])
define([T_RIPaaFM],          [T_RIP[]ANNEE_2_DIGITS[]FM])
define([T_RIPaaFP],          [T_RIP[]ANNEE_2_DIGITS[]FP])
define([T_RIPaaISOCONT_CTL], [T_RIP[]ANNEE_2_DIGITS[]ISOCONT_CTL])
define([T_RIPaaR3A],         [T_RIP[]ANNEE_2_DIGITS[]R3A])
define([T_RIPaaR3AD],        [T_RIP[]ANNEE_2_DIGITS[]R3AD])
define([T_RIPaaRSA],         [T_RIP[]ANNEE_2_DIGITS[]RSA])
define([T_RIPaaRSAD],        [T_RIP[]ANNEE_2_DIGITS[]RSAD])
define([T_RIPaaS],           [T_RIP[]ANNEE_2_DIGITS[]S])
define([T_RIPaaSTC],         [T_RIP[]ANNEE_2_DIGITS[]STC])
define([T_RIPaaSUP_DSC],     [T_RIP[]ANNEE_2_DIGITS[]SUP_DSC])
define([T_RIPaaSUP_IUM],     [T_RIP[]ANNEE_2_DIGITS[]SUP_IUM])
define([T_RIPaaSUP_TIE],     [T_RIP[]ANNEE_2_DIGITS[]SUP_TIE])
define([T_RIPaaSUP_VAC],     [T_RIP[]ANNEE_2_DIGITS[]SUP_VAC])
define([T_RIPaaTP],          [T_RIP[]ANNEE_2_DIGITS[]TP])
define([T_RIPaaTP_CTL],      [T_RIP[]ANNEE_2_DIGITS[]TP_CTL])
define([T_RIPaaTRPT],        [T_RIP[]ANNEE_2_DIGITS[]TRPT])
define([T_RIPaaTRPT_CTL],    [T_RIP[]ANNEE_2_DIGITS[]TRPT_CTL])

