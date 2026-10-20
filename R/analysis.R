score <- function(y, pred, prob) {
    tp <- sum(y == 1 & pred == 1)
    tn <- sum(y == 0 & pred == 0)
    fp <- sum(y == 0 & pred == 1)
    fn <- sum(y == 1 & pred == 0)
    positive <- y == 1
    list(accuracy = mean(pred == y), recall = tp/(tp + fn), precision = if (tp + fp) tp/(tp + 
        fp) else 0, specificity = tn/(tn + fp), roc_auc = (sum(rank(prob)[positive]) - sum(positive) * 
        (sum(positive) + 1)/2)/(sum(positive) * sum(!positive)), confusion = list(actual_0 = c(tn, 
        fp), actual_1 = c(fn, tp)))
}

split_rows <- function(y, p = 0.7, seed = 24) {
    set.seed(seed)
    sort(unlist(lapply(split(seq_along(y), y), function(i) sample(i, floor(p * length(i))))))
}

run_analysis <- function(root, out) {
    data(banknote, package = "mclust")
    d <- banknote
    d$Status <- factor(d$Status, levels = c("genuine", "counterfeit"))
    idx <- split_rows(d$Status)
    train <- d[idx, ]
    test <- d[-idx, ]
    set.seed(24)
    model <- rpart::rpart(Status ~ ., train, method = "class", control = rpart::rpart.control(cp = 0, 
        minsplit = 10, xval = 5))
    cp <- model$cptable[which.min(model$cptable[, "xerror"]), "CP"]
    model <- rpart::prune(model, cp = cp)
    prob <- predict(model, test, type = "prob")[, "counterfeit"]
    y <- as.integer(test$Status == "counterfeit")
    order <- order(prob, decreasing = TRUE)
    thresholds <- c(Inf, sort(unique(prob), decreasing = TRUE), -Inf)
    tpr <- vapply(thresholds, function(t) mean(prob[y == 1] >= t), numeric(1))
    fpr <- vapply(thresholds, function(t) mean(prob[y == 0] >= t), numeric(1))
    manual <- sum(diff(fpr) * (head(tpr, -1) + tail(tpr, -1))/2)
    write.csv(data.frame(fpr, tpr), file.path(out, "roc.csv"), row.names = FALSE)
    png(file.path(out, "tree-roc.png"), 1200, 650)
    par(mfrow = c(1, 2))
    plot(model)
    text(model, use.n = TRUE, cex = 0.7)
    plot(fpr, tpr, type = "l", lwd = 2, xlab = "False positive rate", ylab = "Counterfeit recall")
    abline(0, 1, lty = 2)
    dev.off()
    list(rows = nrow(d), train_rows = nrow(train), test_rows = nrow(test), positive = "counterfeit", 
        selected_cp = cp, metrics = score(y, as.integer(prob >= 0.5), prob), manual_trapezoid_auc = manual)
}

