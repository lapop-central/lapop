# # -----------------------------------------------------------------------
# FUNCTION TO EXTRACT NOTES
# # -----------------------------------------------------------------------
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
