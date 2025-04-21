# Define the flexible label formatting function
lpr_set_ros <- function(data, lang_id = "en", attribute_name = "roslabel") {
  for (VAR in names(data)) {
    label_table_name <- paste0(VAR, "_", lang_id)
    
    # Check if the label table exists for the given language
    if (label_table_name %in% names(attr(data, "label.table"))) {
      label_table <- attr(data, "label.table")[[label_table_name]]
      valid_labels <- label_table[label_table < 1000]  # Exclude special codes
      
      formatted <- sapply(seq_along(valid_labels), function(i) {
        paste0("(", valid_labels[i], ") ", names(valid_labels)[i])
      })
      
      # Determine the prefix depending on language
      prefix <- switch(lang_id,
                       en = "Response Options: ",
                       es = "Opciones de Respuesta: ",
                       pt = "Opções de Resposta: ",
                       "")  # fallback
      
      attr(data[[VAR]], attribute_name) <- paste0(prefix, paste(formatted, collapse = " "))
    }
  }
  
  return(data)
}