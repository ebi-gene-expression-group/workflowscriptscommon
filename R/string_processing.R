# Split a string to a character vector

#' Split a string to a character vector
#'
#' A trivial wrapper around strsplit() so it returns a clean character vector
#'
#' @param x String to be split
#' @param sep Separator character
#'
#' @return Character vector
#' @export
#'
#' @examples
#' > split_string('one,two')
#' "one" "two"

wsc_split_string <- function(x, sep=','){
  unlist(strsplit(x, sep))
}
