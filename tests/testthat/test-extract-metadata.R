testthat::test_that("notes have a stable schema and preserve their identifiers", {
  x <- data.frame(q = 1)
  testthat::expect_named(lpr_extract_notes(x), c("variable_name", "note_id", "note_value"))
  testthat::expect_equal(nrow(lpr_extract_notes(x)), 0L)
  fields <- list(c("_dta", "_lang_c", "pt"), c("q", "note1", "Pergunta?"),
                 c("q", "qword_en", "Question?"), c("malformed", "pair"))
  attr(x, "expansion.fields") <- fields
  testthat::expect_equal(lpr_extract_notes(x)$note_id, c("note1", "qword_en"))
  testthat::expect_equal(lpr_extract_notes(fields), lpr_extract_notes(x))
  testthat::expect_equal(nrow(lpr_extract_notes(x, include_dataset = TRUE)), 3L)
  testthat::expect_equal(lpr_extract_notes(x, note_ids = "qword_en")$note_value, "Question?")
})

testthat::test_that("linked dictionaries preserve zero, gaps, high and unobserved codes", {
  x <- data.frame(q = c(0, 1))
  attr(x, "val.labels") <- "labels999"
  attr(x, "label.table") <- list(labels999 = c(No = 0, Yes = 1, Other = 77,
                                              Party = 152501, "NS/NR" = 1000))
  long <- lpr_extract_ros(x, lang_id = NULL, restrict_to_present = FALSE)
  testthat::expect_equal(long$value, c(0, 1, 77, 152501))
  testthat::expect_equal(long$answer_text, c("No", "Yes", "Other", "Party"))
  testthat::expect_equal(lpr_extract_ros(x, lang_id = NULL)$value, c(0, 1))
  collapsed <- lpr_extract_ros(x, lang_id = NULL, restrict_to_present = FALSE, one_row_per_var = TRUE)
  testthat::expect_equal(collapsed$answer_text, "(0) No | (1) Yes | (77) Other | (152501) Party")
  testthat::expect_true(1000 %in% lpr_extract_ros(x, lang_id = NULL,
                                  restrict_to_present = FALSE, include_special = TRUE)$value)
})

testthat::test_that("active and explicit languages resolve to the intended dictionary", {
  x <- data.frame(q = c(0, 1))
  attr(x, "expansion.fields") <- list(c("_dta", "_lang_c", "pt"))
  attr(x, "label.table") <- list(q_en = c(No = 0, Yes = 1), q_pt = c(Nao = 0, Sim = 1))
  testthat::expect_equal(lpr_extract_ros(x, lang_id = NULL)$answer_text, c("Nao", "Sim"))
  testthat::expect_equal(lpr_extract_ros(x, lang_id = "en")$answer_text, c("No", "Yes"))
  testthat::expect_true(is.na(lpr_extract_ros(x, lang_id = "es", one_row_per_var = TRUE)$answer_text))
  # An explicit Stata language link may name a table unrelated to the variable.
  attr(x, "expansion.fields") <- c(attr(x, "expansion.fields"), list(c("q", "_lang_l_es", "translated")))
  attr(x, "label.table")$translated <- c(No = 0, Si = 1)
  testthat::expect_equal(lpr_extract_ros(x, lang_id = "es")$answer_text, c("No", "Si"))
})

testthat::test_that("factor filtering does not use integer positions or confuse translated labels", {
  x <- data.frame(q = factor("Sim", levels = c("Nao", "Sim")))
  attr(x, "val.labels") <- "q_pt"
  attr(x, "expansion.fields") <- list(c("_dta", "_lang_c", "pt"))
  attr(x, "label.table") <- list(q_en = c(No = 0, Yes = 1), q_pt = c(Nao = 0, Sim = 1))
  testthat::expect_equal(lpr_extract_ros(x, lang_id = NULL, attr_name = "levels")$value, 1)
  testthat::expect_equal(lpr_extract_ros(x, lang_id = "en")$answer_text, "Yes")
  testthat::expect_equal(lpr_extract_ros(x, lang_id = "en")$value, 1)
  testthat::expect_equal(lpr_extract_ros(x, lang_id = NULL, attr_name = "levels",
                                      restrict_to_present = FALSE)$value, c(0, 1))
})

testthat::test_that("unlabelled intermediate scale values do not erase endpoint labels", {
  x <- data.frame(q = 2:6)
  attr(x, "label.table") <- list(q_en = c(Nothing = 1, Everything = 7))
  testthat::expect_equal(lpr_extract_ros(x, restrict_to_present = FALSE)$value, c(1, 7))
  testthat::expect_true(is.na(lpr_extract_ros(x, one_row_per_var = TRUE)$answer_text))
  # Empty labels may still describe real codes, as in CAN_2026 scales.
  attr(x, "label.table") <- list(q_en = stats::setNames(1:3, c("Low", "", "High")))
  testthat::expect_equal(lpr_extract_ros(x, restrict_to_present = FALSE,
                  one_row_per_var = TRUE)$answer_text, "(1) Low | (2) | (3) High")
})

testthat::test_that("missing options remain NA and pure factors do not invent codes", {
  x <- data.frame(q = 1, empty = NA_real_)
  out <- lpr_extract_ros(x, one_row_per_var = TRUE)
  testthat::expect_equal(nrow(out), 2L)
  testthat::expect_true(all(is.na(out$answer_text)))
  testthat::expect_true(all(is.na(lpr_extract_ros(x, lang_id = NULL, one_row_per_var = TRUE)$answer_text)))
  testthat::expect_named(lpr_extract_ros(data.frame()), c("variable_name", "value", "answer_text"))
  testthat::expect_named(lpr_extract_ros(data.frame(), one_row_per_var = TRUE), c("variable_name", "answer_text"))
  factor_only <- data.frame(q = factor("Yes", levels = c("No", "Yes")))
  testthat::expect_warning(long <- lpr_extract_ros(factor_only, restrict_to_present = FALSE), "Original codes unavailable")
  testthat::expect_true(all(is.na(long$value)))
  testthat::expect_equal(long$answer_text, c("No", "Yes"))
  testthat::expect_warning(flat <- lpr_extract_ros(factor_only, one_row_per_var = TRUE), "Original codes unavailable")
  testthat::expect_equal(flat$answer_text, "Yes")
})

testthat::test_that("haven numeric codes, decimals and tagged missing codes are preserved", {
  x <- data.frame(q = haven::labelled(c(0, 1.5, haven::tagged_na("a")),
                    labels = c(No = 0, Some = 1.5, "Don't know" = haven::tagged_na("a"))))
  testthat::expect_equal(lpr_extract_ros(x, restrict_to_present = FALSE)$value, c(0, 1.5))
  flat <- lpr_extract_ros(x, include_special = TRUE, restrict_to_present = FALSE, one_row_per_var = TRUE)
  testthat::expect_equal(flat$answer_text, "(0) No | (1.5) Some | (.a) Don't know")
  testthat::expect_equal(lpr_extract_ros(x, special_values = 1.5)$value, 0)
})

testthat::test_that("readstata13 reserved missing integers are restored before serialization", {
  x <- data.frame(q = c(0, 2147483622))
  attr(x, "version") <- 118L
  attr(x, "label.table") <- list(q_en = c(No = 0, "Don't know" = 2147483622,
                                          "No answer" = 2147483623))
  testthat::expect_equal(lpr_extract_ros(x, restrict_to_present = FALSE)$value, 0)
  flat <- lpr_extract_ros(x, include_special = TRUE, restrict_to_present = FALSE, one_row_per_var = TRUE)
  testthat::expect_equal(flat$answer_text, "(0) No | (.a) Don't know | (.b) No answer")
  testthat::expect_true(haven::is_tagged_na(lpr_extract_ros(x, include_special = TRUE)$value[2L], "a"))
})

testthat::test_that("nonresponse detection retains substantive options with similar wording", {
  x <- data.frame(q = 1)
  attr(x, "label.table") <- list(q_en = c("Other answer" = 77, "Other responses" = 1001,
                    "[PA LI REPONS LA] Pa konnen" = 888888,
                    "[PA LI REPONS LA] Pa reponn" = 988888,
                    "[NÃO LER] Não sabe" = 88, "Decline to answer" = 98))
  testthat::expect_equal(lpr_extract_ros(x, restrict_to_present = FALSE)$value, c(77, 1001))
})

testthat::test_that("character haven codes and mixed datasets are not coerced to factor positions", {
  x <- data.frame(q = haven::labelled(c("Y", "N"), labels = c(Yes = "Y", No = "N")),
                  numeric_q = haven::labelled(c(0, 1), labels = c(No = 0, Yes = 1)),
                  unlabelled = c(1, 2))
  out <- lpr_extract_ros(x, restrict_to_present = FALSE)
  testthat::expect_equal(out$value[out$variable_name == "q"], c("N", "Y"))
  testthat::expect_equal(out$value[out$variable_name == "numeric_q"], c("0", "1"))
  testthat::expect_true(is.na(out$value[out$variable_name == "unlabelled"]))
})
