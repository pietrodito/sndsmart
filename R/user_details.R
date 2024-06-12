#'@export
user_details = function() {

  (user <- basename("~"))

  list(
    ## TODO Match these values to labels
    partenaire = substr(user,  1,  2),
    region     = substr(user, 14, 15),
    profil     = substr(user, 11, 13),
    id         = substr(user,  3, 10)
  )
}


#'@export
user_details_string = function() {
  d <- user_details()
  glue::glue("{d$partenaire}-{d$region}-{d$id}-{d$profil}")
}
