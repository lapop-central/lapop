# # -----------------------------------------------------------------------
# SET ATTRIBUTES
# # -----------------------------------------------------------------------
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
