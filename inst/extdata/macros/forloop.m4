define([forloop_arg], [ifelse(eval([($1) <= ($2)]), [1],
  [_forloop([$1], eval([$2]), [$3(], [)])])])dnl
define([forloop], [ifelse(eval([($2) <= ($3)]), [1],
  [pushdef([$1])_forloop(eval([$2]), eval([$3]),
    [define([$1],], [)$4])popdef([$1])])])dnl
define([_forloop],
  [$3[$1]$4[]ifelse([$1], [$2], [],
    [$0(incr([$1]), [$2], [$3], [$4])])])dnl