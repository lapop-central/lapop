#' Extract Stata variable notes and characteristics
#'
#' Returns the original characteristic identifiers, without assuming that a
#' particular note number is a question or that a variable label is a wording.
#' @param data A data frame with an `expansion.fields` attribute, or that
#'   attribute's list of three-element character vectors.
#' @param note_ids Optional character vector of identifiers to retain.
#' @param include_dataset Include characteristics belonging to `_dta`.
#' @return A data frame with character columns `variable_name`, `note_id`, and
#'   `note_value`. These columns are also present when no notes are available.
#' @examples
#' toy <- data.frame(x = 1)
#' attr(toy, "expansion.fields") <- list(c("x", "note1", "Question?"))
#' lpr_extract_notes(toy)
#' @export
lpr_extract_notes <- function(data, note_ids = NULL, include_dataset = FALSE) {
  fields <- if (is.data.frame(data)) attr(data, "expansion.fields") else data
  if (!is.null(fields) && !is.list(fields)) {
    stop("Expected a data frame or a list of Stata characteristics.")
  }
  out <- data.frame(variable_name = character(), note_id = character(),
                    note_value = character(), stringsAsFactors = FALSE)
  valid <- vapply(fields, function(x) is.atomic(x) && length(x) == 3L &&
                    !is.na(x[1L]) && !is.na(x[2L]), logical(1))
  if (any(valid)) {
    rows <- do.call(rbind, lapply(fields[valid], as.character))
    out <- data.frame(variable_name = rows[, 1L], note_id = rows[, 2L],
                      note_value = rows[, 3L], stringsAsFactors = FALSE)
  }
  if (!include_dataset) out <- out[out$variable_name != "_dta", , drop = FALSE]
  if (!is.null(note_ids)) out <- out[out$note_id %in% note_ids, , drop = FALSE]
  rownames(out) <- NULL
  out
}
