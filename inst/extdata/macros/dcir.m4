define([add_month], [define([year],  substr([$1], [0], [4]))dnl
define([month], substr([$1], [4], [2]))dnl
define([new_year],  ifelse(month, [12], incr(year), [year]))dnl
define([new_month],  [00])dnl
define([new_month], ifelse(month, [01], [02], [new_month]))dnl
define([new_month], ifelse(month, [02], [03], [new_month]))dnl
define([new_month], ifelse(month, [03], [04], [new_month]))dnl
define([new_month], ifelse(month, [04], [05], [new_month]))dnl
define([new_month], ifelse(month, [05], [06], [new_month]))dnl
define([new_month], ifelse(month, [06], [07], [new_month]))dnl
define([new_month], ifelse(month, [07], [08], [new_month]))dnl
define([new_month], ifelse(month, [08], [09], [new_month]))dnl
define([new_month], ifelse(month, [09], [10], [new_month]))dnl
define([new_month], ifelse(month, [10], [11], [new_month]))dnl
define([new_month], ifelse(month, [11], [12], [new_month]))dnl
define([new_month], ifelse(month, [12], [01], [new_month]))dnl
new_year[]new_month[]01])dnl

define([add_months], [define([current_month], $1)dnl
forloop([i], [1], [$2], [define([current_month], add_month(current_month))])dnl
current_month])

define([ARC_from_FLX], [define([ARCV], [ifelse(eval($1 <= DCIR_AN1), [1], substr($1, [0], [4]), 0)])dnl
ifelse(len(ARCV), 4, [define([ARCV], ifelse(substr($1, [4], [2]), [01], decr(ARCV), ARCV))])dnl
ifelse(ARCV, [0], , _[]ARCV)])dnl

define([FLX_LOOP],
  dnl ##########################################################
  dnl # Usage: this macro will define two variables for you    #
  dnl # ARC and FLX_IDX that you can use in your query...      #
  dnl # ------------------------------------------------------ #
  dnl # define([beginning_date], 20080101)                     #
  dnl # define([nb_month_flx],   24)                           #
  dnl # FLX_LOOP(begininnig_date, nb_month_flx, output_table, [#
  dnl # select *                                               #
  dnl # from ER_PRS_R[]ARC prs                                 #
  dnl # where prs.FLX_IDX])                                    #
  dnl ##########################################################

  [
  define([FLX_IDX], [FLX_DIS_DTD = to_date('17890714', 'YYYYMMDD')])

    create_table(ZZZ_TEMP)
    $4
/
    create_table(ZZZ_STATS)
    select count(*) as N
      ,    to_date('17890714', 'YYYYMMDD') as FLX_DIS_DTD
      ,    CURRENT_TIMESTAMP as END
    from ZZZ_TEMP
/

    create_table($3)
    select * from ZZZ_TEMP
/

    forloop([NM_FLX], [1], [$2], [
      define([FLX_YYYYMMDD], [add_months($1, NM_FLX)])
      define([ARC], ARC_from_FLX(FLX_YYYYMMDD))dnl
      define([FLX_IDX], [FLX_DIS_DTD = to_date(FLX_YYYYMMDD, 'YYYYMMDD')])

      create_table(ZZZ_TEMP)
      $4
/
      insert into ZZZ_STATS
      select count(*) as N
      ,      to_date(FLX_YYYYMMDD, 'YYYYMMDD') as FLX_DIS_DTD
      ,    CURRENT_TIMESTAMP as END
      from ZZZ_TEMP
/
      insert into $3
      select * from ZZZ_TEMP
/
    ])

    create_table(ZZZ_STATS_PROPER)
    select FLX_DIS_DTD
    ,      N
    ,      END - lag(END) over(order by END) as DURATION
    from ZZZ_STATS
/
    create_table($3_STATS)
    select *
    from ZZZ_STATS_PROPER
    where FLX_DIS_DTD <> to_date('17890714', 'YYYYMMDD')
/
    drop table ZZZ_TEMP
/
    drop table ZZZ_STATS
/
    drop table ZZZ_STATS_PROPER
/
])

define([j9k], [dnl
$1.DCT_ORD_NUM=$2.DCT_ORD_NUM
and $1.FLX_DIS_DTD=$2.FLX_DIS_DTD
and $1.FLX_EMT_ORD=$2.FLX_EMT_ORD
and $1.FLX_EMT_NUM=$2.FLX_EMT_NUM
and $1.FLX_EMT_TYP=$2.FLX_EMT_TYP
and $1.FLX_TRT_DTD=$2.FLX_TRT_DTD
and $1.ORG_CLE_NUM=$2.ORG_CLE_NUM
and $1.PRS_ORD_NUM=$2.PRS_ORD_NUM
and $1.REM_TYP_AFF=$2.REM_TYP_AFF])


