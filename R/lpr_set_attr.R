##############################################################

# LAPOP Set Variable Attributes from AmericasBarometer Notes # 

##############################################################

#' Set Variable Attributes from AmericasBarometer Notes
#'
#' Applies notes stored in a data frame object as attributes to corresponding variables
#' in AmericasBarometer dataset. This is particularly useful for setting variable labels, 
#' question wording, or other metadata from extracted notes.
#'
#' @param data A data frame whose variables will receive new attributes
#' @param notes A data frame containing notes information, typically produced by
#'        \code{\link{lpr_extract_notes}}. Must contain columns: variable_name,
#'        note_id, and note_value.
#' @param noteid Character string specifying which note ID to extract from the
#'        notes data frame (e.g., "label" for variable labels, "qtext" for question text).
#' @param attribute_name Character string specifying the attribute name to set
#'        (e.g., "label", "qwording", "roslabel").
#'
#' @return The input data frame with specified attributes added to relevant variables
#'
#' @details
#' This function:
#' \itemize{
#'   \item Filters the notes data frame to only include rows matching the specified `noteid`
#'   \item Loops through each matching note and applies it as an attribute to the corresponding
#'         variable in the data frame
#'   \item Issues warnings for variables in the notes that don't exist in the data
#' }
#'
#' The function is designed to work in tandem with \code{lpr_extract_notes}, creating
#' a workflow for managing variable metadata in AmericasBarometer data.
#'
#' @examples
#' # First extract notes from dataset attributes
#' notes <- lpr_extract_notes(data)
#'
#' # Set variable question wording
#' data <- lpr_set_attr(data, notes, noteid = "note4", attribute_name = "question_wording")
#' attr(data$ing4, "question_wording")
#'
#'
#' @seealso \code{\link{lpr_extract_notes}} for extracting notes from AmericasBarometer dataset attributes
#' @export

lpr_set_attr <- function(data, notes, noteid = character(), attribute_name = character()) {
  # Filter notes for rows with the specified note_id
  
  note_subset <- subset(notes, note_id == noteid)
  
  # Loop through each row in the filtered subset
  for (i in 1:nrow(note_subset)) {
    # Get the variable name and note value for the specified note_id
    variable_name <- note_subset$variable_name[i]
    text_label <- note_subset$note_value[i]
    
    # Check if variable_name exists in data
    if (variable_name %in% names(data)) {
      # Set the specified attribute name using the text_label
      attr(data[[variable_name]], attribute_name) <- text_label
    } else {
      warning(paste("Variable", variable_name, "not found in data."))
    }
  }
  
  # Return the modified data
  return(data)
}
