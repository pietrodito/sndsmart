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
define([j2k_ssr], [$1.ETA_NUM = $2.ETA_NUM and $1.RHA_NUM = $2.RHA_NUM])
define([j2k_rip], [$1.ETA_NUM_EPMSI = $2.ETA_NUM_EPMSI and $1.RIP_NUM  = $2.RIP_NUM])
define([j2k_had], [$1.ETA_NUM_EPMSI = $2.ETA_NUM_EPMSI and $1.RHAD_NUM = $2.RHAD_NUM])

define([GHM_CHIRURGICAL], [[substr]($1.GRG_GHM, 3, 1) = 'C'])

define([nettoyage_sejours], [
   define([prefixe], [$1])

   and prefixe[].ETA_NUM
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
     and (prefixe[].SEJ_TYP is null or prefixe[].SEJ_TYP <> 'B')
])

define([nettoyage_chainage], [
  define([prefixe], [$1])

  and (prefixe[].NIR_RET = '0' and prefixe[].NAI_RET = '0' and
       prefixe[].SEX_RET = '0' and prefixe[].SEJ_RET = '0' and
       prefixe[].FHO_RET = '0' and prefixe[].PMS_RET = '0' and
       prefixe[].DAT_RET = '0')
])


dnl #########################################################
dnl #  You must define ANNEE macro in ./sql/user_macros.m4  #
dnl #  eg:                                                  #
dnl #                                                       #
dnl #  define([ANNEE], [2015])                              #
dnl #########################################################

define([ANNEE_2_DIGITS], [substr(ANNEE, [2], [2])])
define([T_MCOaaA],  [T_MCO[]ANNEE_2_DIGITS[]A])
define([T_MCOaaB],  [T_MCO[]ANNEE_2_DIGITS[]B])
define([T_MCOaaC],  [T_MCO[]ANNEE_2_DIGITS[]C])
define([T_MCOaaD],  [T_MCO[]ANNEE_2_DIGITS[]D])
define([T_MCOaaUM], [T_MCO[]ANNEE_2_DIGITS[]UM])
define([T_MCOaaMED], [T_MCO[]ANNEE_2_DIGITS[]MED])

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

define([T_RIPaaS],  [T_RIP[]ANNEE_2_DIGITS[]S])
define([T_RIPaaC],  [T_RIP[]ANNEE_2_DIGITS[]C])

define([T_HADaaS],  [T_HAD[]ANNEE_2_DIGITS[]S])
define([T_HADaaC],  [T_HAD[]ANNEE_2_DIGITS[]C])
