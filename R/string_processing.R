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

#' Read a named vector from a file stored as two-column text (label and value)
#'
#' @param filename
#' @param sep
#'
#' @return named vector
#' @export

wsc_read_vector <- function(filename, sep=','){
  vector_table <- read.table(filename, header = FALSE, stringsAsFactors = FALSE, sep=sep)
  structure(vector_table$V2, names = vector_table$V1)
}

#' Read a named vector to a file as two-column text (label and value)
#'
#' @param vector
#' @param filename
#' @param sep
#'
#' @return
#' @export

wsc_write_vector <- function(vector, filename, sep=','){
  write.table(data.frame(V1=names(vector), V2=vector), col.names = FALSE, file = filename, quote = FALSE, sep = ',', row.names = FALSE)
}
