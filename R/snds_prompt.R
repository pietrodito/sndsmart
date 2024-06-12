#'@export
snds_prompt <- function() {
 options(prompt =
            glue::glue(
              "{user_details_string()} {options('prompt')}"))
}
