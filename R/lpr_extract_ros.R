#' Extract original response codes and labels
#'
#' Reads dataset dictionaries and haven labels before considering factor levels.
#' Factor positions are never substituted for the original survey codes.
#' @param data A data frame imported with readstata13 or haven.
#' @param lang_id Requested dictionary language, e.g. "en", "es", or "pt".
#'   `NULL` or `""` uses the variable's `val.labels` link, then the dataset's
#'   active language. A sole unambiguous dictionary is a final fallback.
#'   For haven vectors without language metadata, their attached labels are used.
#' @param include_special Include tagged missing codes and explicitly labelled
#'   nonresponses. Valid codes are not excluded merely because they exceed 1000.
#' @param restrict_to_present Keep only observed options. For questionnaire
#'   inventories use `FALSE`, so unobserved response options are retained.
#' @param one_row_per_var Collapse into one row per variable with code-label pairs.
#' @param pair_sep Separator between collapsed pairs.
#' @param attr_name Preferred dictionary attribute. Even when `"levels"` is
#'   requested, an available original code dictionary takes precedence.
#' @param special_values Additional response codes to exclude when
#'   `include_special = FALSE`.
#' @return A tibble with `variable_name`, `value`, and `answer_text`, or just
#'   `variable_name` and `answer_text` when collapsed. Numeric codes remain numeric
#'   (including haven tagged NAs). If a dictionary has character codes, `value`
#'   is character. Empty variables have genuine NA cells. Plain factors without
#'   a code dictionary return their labels with unknown (`NA`) codes and a warning.
#' @examples
#' toy <- data.frame(x = c(0, 1))
#' attr(toy, "label.table") <- list(x_en = c(No = 0, Yes = 1, Other = 152501))
#' lpr_extract_ros(toy, restrict_to_present = FALSE)
#' lpr_extract_ros(toy, restrict_to_present = FALSE, one_row_per_var = TRUE)
#' @export
lpr_extract_ros <- function(data, lang_id = "en", include_special = FALSE,
                            restrict_to_present = TRUE, one_row_per_var = FALSE,
                            pair_sep = " | ", attr_name = "label.table",
                            special_values = NULL) {
  stopifnot(is.data.frame(data), length(attr_name) == 1L)
  if (!is.null(lang_id) && (length(lang_id) != 1L || is.na(lang_id))) {
    stop("lang_id must be NULL or one language code.")
  }
  explicit_language <- !is.null(lang_id) && nzchar(lang_id)
  characteristics <- lpr_extract_notes(data, include_dataset = TRUE)
  characteristic <- function(variable, id) {
    z <- unique(characteristics$note_value[characteristics$variable_name == variable &
                                           characteristics$note_id == id])
    z <- z[!is.na(z) & nzchar(z)]
    if (length(z) > 1L) stop("Conflicting characteristic ", id, " for ", variable)
    if (length(z)) z else NA_character_
  }
  active_language <- characteristic("_dta", "_lang_c")
  dictionary <- attr(data, attr_name)
  if (!is.list(dictionary)) dictionary <- attr(data, "label.table")
  if (!is.list(dictionary)) dictionary <- list()
  links <- attr(data, "val.labels")
  variables <- names(data)
  from_stata <- !is.null(attr(data, "version")) && !is.null(attr(data, "label.table"))

  # readstata13 represents Stata's . and .a-.z by reserved integer values.
  restore_missing <- function(x) {
    if (!is.numeric(x) || !from_stata) return(x)
    k <- !is.na(x) & x >= 2147483621 & x <= 2147483647
    if (any(k)) {
      offset <- as.integer(x[k] - 2147483621)
      restored <- rep(NA_real_, length(offset))
      tagged <- offset > 0L
      restored[tagged] <- haven::tagged_na(letters[offset[tagged]])
      x[k] <- restored
    }
    x
  }
  value_text <- function(x) {
    if (!is.numeric(x)) return(as.character(x))
    result <- as.character(x)
    result[is.na(x)] <- "."
    tags <- haven::na_tag(as.double(x))
    tagged <- !is.na(tags)
    result[tagged] <- paste0(".", tags[tagged])
    result
  }
  nonresponse <- function(label) {
    text <- trimws(gsub("\\[[^]]*\\]", "", label))
    pattern <- paste0("^(no sabe|no responde|nao sabe|nao responde|não sabe|não responde|",
                       "declined? to answer|don't know|do not know|no answer|",
                       "prefer not to answer|no desea responder|no contesta|",
                       "pa konnen|pa reponn|ne sait pas|pas de reponse|pas de réponse|",
                       "refused|refusal|ns/nr|ns|nr|dk|dk/na)$")
    !is.na(text) & grepl(pattern, text, ignore.case = TRUE)
  }
  empty <- function(variable) tibble::tibble(variable_name = variable,
                                            value = NA_real_, answer_text = NA_character_)
  link_for <- function(i) {
    if (length(links) == length(variables)) return(unname(links[i]))
    if (!is.null(names(links)) && variables[i] %in% names(links)) return(links[[variables[i]]])
    NA_character_
  }
  resolve <- function(variable, i) {
    if (is.null(names(dictionary))) return(NA_character_)
    if (explicit_language) {
      candidates <- c(characteristic(variable, paste0("_lang_l_", lang_id)),
                      paste0(variable, "_", lang_id))
      if (!is.na(active_language) && lang_id == active_language) {
        candidates <- c(candidates, link_for(i), variable)
      }
    } else {
      candidates <- link_for(i)
      if (!is.na(active_language)) {
        candidates <- c(candidates, characteristic(variable, paste0("_lang_l_", active_language)),
                        paste0(variable, "_", active_language))
      }
      candidates <- c(candidates, variable)
    }
    found <- candidates[!is.na(candidates) & candidates %in% names(dictionary)]
    if (length(found)) return(found[1L])
    if (!explicit_language) {
      # Do not silently choose a language when more than one dictionary fits.
      suffix <- substring(names(dictionary), nchar(variable) + 2L)
      alternatives <- names(dictionary)[startsWith(names(dictionary), paste0(variable, "_")) &
                                          grepl("^[A-Za-z]{2,3}$", suffix)]
      if (length(alternatives) == 1L) return(alternatives)
      if (length(alternatives) > 1L && is.na(active_language)) {
        warning("Ambiguous label language for ", variable, "; supply lang_id.", call. = FALSE)
      }
    }
    NA_character_
  }
  read_dictionary <- function(labels) {
    if (is.null(names(labels))) return(NULL)
    if (is.numeric(labels)) {
      return(list(value = restore_missing(unname(labels)), label = names(labels)))
    }
    if (is.character(labels)) {
      codes <- names(labels)
      # Stata-style named label vectors: names are codes, values are texts.
      numeric_codes <- suppressWarnings(as.numeric(codes))
      tagged <- grepl("^\\.[a-z]$", codes)
      numeric_codes[tagged] <- haven::tagged_na(substring(codes[tagged], 2L))
      if (all(!is.na(numeric_codes) | codes == "." | tagged)) {
        return(list(value = restore_missing(numeric_codes), label = unname(labels)))
      }
      # haven_labelled character vectors: names are texts, values are codes.
      return(list(value = unname(labels), label = names(labels)))
    }
    NULL
  }

  result <- lapply(seq_along(variables), function(i) {
    variable <- variables[i]
    x <- data[[i]]
    table_name <- resolve(variable, i)
    entry <- if (!is.na(table_name)) read_dictionary(dictionary[[table_name]]) else NULL
    known_codes <- TRUE
    if (is.null(entry)) {
      # A requested translation must not fall back to a known different language.
      wrong_language <- explicit_language && !is.na(active_language) && lang_id != active_language
      if (wrong_language) return(empty(variable))
      labels <- attr(x, attr_name)
      if (is.null(labels) || is.null(names(labels))) labels <- attr(x, "labels")
      entry <- read_dictionary(labels)
      if (is.null(entry) && is.factor(x)) {
        warning("Original codes unavailable for factor ", variable,
                "; returning labels with unknown codes. Import its label dictionary.", call. = FALSE)
        entry <- list(value = rep(NA_real_, nlevels(x)), label = levels(x))
        known_codes <- FALSE
      }
    }
    if (is.null(entry) || !length(entry$value)) return(empty(variable))
    keep <- rep(TRUE, length(entry$value))
    if (!include_special) {
      keep <- !nonresponse(entry$label)
      if (known_codes) keep <- keep & !is.na(entry$value)
      if (length(special_values)) keep <- keep & !value_text(entry$value) %in% value_text(special_values)
    }
    if (restrict_to_present) {
      if (is.factor(x)) {
        # Translate observed native factor labels through their original codes.
        native_name <- link_for(i)
        native <- if (!is.na(native_name) && native_name %in% names(dictionary)) {
          read_dictionary(dictionary[[native_name]])
        } else NULL
        observed_labels <- as.character(x[!is.na(x)])
        if (!is.null(native) && known_codes) {
          observed_codes <- native$value[native$label %in% observed_labels]
          keep <- keep & value_text(entry$value) %in% value_text(observed_codes)
        } else {
          keep <- keep & entry$label %in% observed_labels
        }
      } else if (known_codes) {
        present <- restore_missing(x)
        keep <- keep & value_text(entry$value) %in% value_text(present)
      }
    }
    if (!any(keep)) return(empty(variable))
    values <- entry$value[keep]
    texts <- entry$label[keep]
    order_by_code <- order(values, na.last = TRUE)
    values <- values[order_by_code]
    texts <- texts[order_by_code]
    if (one_row_per_var) {
      codes <- value_text(values)
      pair <- if (known_codes) paste0("(", codes, ")", ifelse(is.na(texts) | texts == "", "", paste0(" ", texts))) else texts
      return(tibble::tibble(variable_name = variable, answer_text = paste(pair, collapse = pair_sep)))
    }
    tibble::tibble(variable_name = variable, value = values, answer_text = texts)
  })
  if (!length(result)) {
    out <- tibble::tibble(variable_name = character(), value = numeric(), answer_text = character())
  } else {
    if (one_row_per_var) result <- lapply(result, function(x) x[, c("variable_name", "answer_text")])
    else if (any(vapply(result, function(x) is.character(x$value), logical(1)))) {
      result <- lapply(result, function(x) {
        placeholder <- is.na(x$value) & is.na(x$answer_text)
        x$value <- value_text(x$value)
        x$value[placeholder] <- NA_character_
        x
      })
    }
    out <- dplyr::bind_rows(result)
  }
  if (one_row_per_var) out <- out[, c("variable_name", "answer_text")]
  out[order(out$variable_name), , drop = FALSE]
}
