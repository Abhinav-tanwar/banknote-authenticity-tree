# Methodology and limitations

Loads the original mclust banknote dataset through the R package. The positive class is explicitly counterfeit rather than relying on factor order. A stratified 70/30 split is used; tree pruning uses only training cross-validation. ROC points are ordered by increasing false-positive rate before trapezoidal integration. Rank-based and manual AUC must agree. This fixes the potential negative AUC caused by curve orientation in the source.
