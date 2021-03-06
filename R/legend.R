



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create a single line legend
#'
#' @param scale A colour scale object compatible with \code{ggplot2} e.g.
#'        \code{ggplot2::scale_colour_viridis_c()}
#' @param values Vector of values
#' @param label label name to prefix legend. default NULL
#' @inheritParams as_character_inner
#'
#' @noRd
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_legend_string <- function(
  scale,
  values,
  label       = NULL,
  full_colour = FALSE,
  dark_mode   = TRUE,
  mode        = 'ansi'
) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity checks
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  stopifnot(all(scale$aesthetics %in% c('colour', 'color', 'fill')))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Prep and train the scale.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  scale$reset()
  scale$train(values)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Ask the scale for all the breaks it wants to display
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (inherits(scale, 'ScaleContinuous')) {
    key_vals <- scale$break_info()$minor_source
  } else if (inherits(scale, 'ScaleDiscrete')) {
    key_vals <- scale$get_breaks()
  }
  key_cols <- scale$map(key_vals)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Prepare a character representation of the breaks
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  key_vals <- format(key_vals)
  key_vals <- paste0(" ", key_vals)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Assemble spaces to put ANSI text and fill codes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  text <- rep(NA, length(key_vals))
  fill <- key_cols

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Insert label at front if provided
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (!is.null(label)) {
    stopifnot(length(label) == 1)
    label <- sprintf("%s: ", label)
    key_vals <- c(label, key_vals)
    text <- c(NA, text)
    fill <- c(NA, key_cols)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Always use contrasting text for the legend
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  text <- calc_contrasting_text(fill, text_contrast = 1, dark_mode = dark_mode)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # After each cell we will add the ansi RESET code to revert
  # text and fill attributes to the terminal default
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (mode == 'ansi') {
    end <- rep(reset_ansi, length(key_vals))
  } else if (mode == 'html') {
    end <- rep(reset_html, length(key_vals))
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Convert matrices of R colours to matrices of ANSI codes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (mode == 'ansi') {
    if (isTRUE(full_colour)) {
      text[] <- col2text_ansi24(text)
      fill[] <- col2fill_ansi24(fill)
    } else {
      text[] <- col2text_ansi(text)
      fill[] <- col2fill_ansi(fill)
    }
  } else if (mode == 'html') {
    text[] <- col2text_html(text)
    fill[] <- col2fill_html(fill)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Assemble
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ansi_vec <- paste0(text, fill, key_vals, end)

  paste(ansi_vec, collapse = '')
}


if (FALSE) {

  suppressPackageStartupMessages({
    library(ggplot2)
  })

  scale <- scale_colour_viridis_c()
  values <- runif(20)
  scale$reset()
  scale$train(values)

  cat(create_legend_string(scale, values, label = "hello"), "\n")


  scale  <- scale_colour_viridis_d()
  values <- sample(c('alpha', 'beta', 'gam', 'epsilon'), 20, T)
  scale$reset()
  scale$train(values)

  cat(create_legend_string(scale, values, label = 'cyl'), "\n")



}
