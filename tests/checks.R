source("R/analysis.R")

out <- tempfile()

dir.create(out)

r <- run_analysis(normalizePath("."), out)

stopifnot(r$train_rows + r$test_rows == 200, r$positive == "counterfeit", abs(r$manual_trapezoid_auc - 
    r$metrics$roc_auc) < 1e-10)

cat("Validation passed\n")

