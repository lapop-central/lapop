###############################################################

# LAPOP Extract Variables Labels from AmericasBarometer Notes #

###############################################################

#' Extract Notes from AmericasBarometer Attributes
#'
#' Extracts notes stored in a dataset's attributes and organizes them into a tidy data frame.
#' This function is particularly useful for processing Stata datasets imported into R that
#' contain variable notes in their attributes.
#'
#' @param data A dataset (data frame) containing notes in its attributes. The notes should
#'        be stored as a list where each element is a vector of length 3 containing:
#'        (1) variable name, (2) note ID, and (3) note text.
#'
#' @return A data frame with three columns:
#' \describe{
#'   \item{variable_name}{Name of the variable the note belongs to}
#'   \item{note_id}{Identifier for the note}
#'   \item{note_value}{The actual note text}
#' }
#'
#' @details
#' This function processes the attributes of a dataset to extract notes that are typically
#' stored in a specific format. It skips any notes associated with "_dta" (dataset-level notes)
#' and only returns variable-specific notes. The function expects the notes to be organized
#' as a list where each element contains exactly three components: variable name, note ID,
#' and note value.
#'
#' @examples
#' # Extract the notes
#' notes <- lpr_extract_notes(df)
#' print(notes)
#'
#' @export

lpr_extract_notes <- function(data) {
  notes_df <- data.frame(variable_name = character(), noteid = character(), note_value = character(), stringsAsFactors = FALSE)
  
  for (i in seq_along(data)) {
    sublist <- data[[i]]
    
    if (length(sublist) == 3) {
      variable_name <- sublist[[1]]
      noteid <- sublist[[2]]
      note_value <- sublist[[3]]
      
       if (variable_name!="_dta") {
        # Add the row to notes_df
        notes_df <- rbind(notes_df, data.frame(variable_name = variable_name, note_id = noteid, note_value = note_value, stringsAsFactors = FALSE))
      }
    }
  }
  notes_df<-subset(notes_df, variable_name!="_dta")
  return(notes_df)
}
