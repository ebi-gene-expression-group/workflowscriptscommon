#' Wrap optparse's parse_args() to add support for mandatory arguments
#'
#' @param option_list List of OptionParserOption objects
#' @param mandatory Character vector of mandatory parameters
#'
#' @return a list containing option values, as per parse_args()

wsc_parse_args <- function(option_list, mandatory=c()){

  parser = OptionParser(option_list=option_list)
  opt = parse_args(parser, convert_hyphens_to_underscores = TRUE)

  # Check options

  for (comp in mandatory){
    if (is.na(opt[[comp]])){
      print_help(parser)
      stop(paste0("Mandatory argment '", comp, "' not supplied"))
    }
  }

  opt
}

#' Parse numeric parameters and make sure vectors are the right length
#'
#' Sometimes a comma-separated string field needs to be parsed to a numeric vector.
#'
#' @param opt A list containing option values, as per parse_args()
#' @param varname Variable name to check
#' @param val_for_na Value to replicate to specified length in the case of NA
#' @param length The length of vector we should obtain
#'
#' @return Numeric vector

wsc_parse_numeric <- function(opt, varname, val_for_na=NA, length=1){
  if (is.na(opt[[varname]])){
    return(rep(val_for_na, length))
  }else{
    vals <- wsc_split_string(opt[[varname]])
  }
  
  vals <- suppressWarnings(as.numeric(vals))
  if (any(is.na(vals))) {
    stop("Non-numeric filters supplied")
  } else {
    return(vals)
  }
}

#' Check supplied value is limited to a number of choices
#'
#' Used as a callback function for make_option() to allow putting constraints
#' on the supplied value.
#'
#' @param opt The option S4 object
#' @param arg_name The long flag string
#' @param arg_val The value of the option
#' @param parser The parser S4 object
#' @param choices A vector of values to choose from
#'
#' @return arg_val if arg_val %in% choices, otherwise raise error

wsc_choose_from <- function(opt, arg_name, arg_val, parser, choices) {
    if (length(choices) == 0) stop(paste("choice is empty for ", arg_name))
    if (length(arg_val) != 1) stop(paste(arg_name, "expects a single value")
    if (! arg_val %in% choices) {
        stop(paste0("supplied value ", arg_val, " for ", arg_name,
                    " is not one of c(", paste(x, collapse=","), ")"))
    }
    arg_val
}
