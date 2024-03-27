define([drop_table], [
drop table $1
/
])

define([create_empty], [
/* !! Requête DROP automatisée */
/* !! Erreur attendue si table inexistante */
drop_table($1)
create table $1])

define([create_table], [
create_empty($1) as])

define([count_lines], [
  select count(*) as N
  from $1
/
])

define([export],[
 select * from $1
/
])

define([export_first],[
 select * from $2
 where rownum <= $1
/
])

define([rename_table], [dnl
drop_table($2)dnl
rename $1 to $2
/])

define([copy_table], [dnl
drop_table($2)
create_table($2)
select * from $1
/
])

define([date_oracle], [to_date($1, 'DDMMYYYY')])
