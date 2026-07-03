# =============================================================================
# Bulk RNA-seq QC 参考代码
# =============================================================================
# 用途：供 AI 模型在编写 bulk RNA-seq QC 代码时参考
# 依据：workflow-bulk-RNA.md
# 依赖：edgeR, biomaRt, dplyr, ggplot2, pheatmap, ComplexHeatmap (可选)
# 参考文献见 workflow-bulk-RNA.md 末节
#
# 核心原则：
#   1. 不主动剔除任何样本，只识别和报告风险
#   2. 默认输出 CPM 矩阵（非 log2）和 log2CPM 矩阵
#   3. 基因过滤使用 filterByExpr（自适应样本量）
#   4. Normalization 使用 TMM
# =============================================================================


# -----------------------------------------------------------------------------
# 0. 加载包
# -----------------------------------------------------------------------------
library(edgeR)
library(biomaRt)   # Ensembl ID -> Gene Symbol
library(dplyr)     # distinct, %>%
library(ggplot2)   # 可视化
# library(ComplexHeatmap)  # 相关性热图（可选，也可用 pheatmap）


# -----------------------------------------------------------------------------
# 1. 读取数据
# -----------------------------------------------------------------------------
# 输入：raw integer count 矩阵，行为基因，列为样本
Counts <- read.csv("GeneCounts.csv", row.names = 1)

# 检查是否为 integer（raw counts）
if (!all(Counts == floor(Counts), na.rm = TRUE)) {
  warning("检测到非整数值，当前矩阵可能不是 raw counts。请确认输入层级。")
}

# 样本分组信息（根据实际修改）
group <- factor(c("H","H","H","H","H","H","N","N","N","N","N","N"),
                levels = c("N", "H"))

# 样本名与矩阵列名核对
stopifnot(length(group) == ncol(Counts))
# 若有 metadata 表，此处应做映射核对


# -----------------------------------------------------------------------------
# 2. 基因 ID 注释（Ensembl -> Gene Symbol）
# -----------------------------------------------------------------------------
# 仅当行名为 Ensembl ID（ENSG 开头）时执行
if (all(grepl("^ENS[GT]\\d+", rownames(Counts)))) {

  ensembl <- useEnsembl("ensembl")
  human <- useDataset("hsapiens_gene_ensembl", mart = ensembl)

  # 获取 ID -> Symbol 映射
  gene_map <- getBM(
    attributes = c("ensembl_gene_id", "external_gene_name"),
    filters    = "ensembl_gene_id",
    values     = rownames(Counts),
    mart       = human,
    uniqueRows = TRUE
  )

  Counts$GSB <- gene_map$external_gene_name[match(rownames(Counts), gene_map$ensembl_gene_id)]

  # 记录冲突：多个 Ensembl ID 映射到同一 Symbol
  conflict_count <- sum(duplicated(Counts$GSB[!is.na(Counts$GSB)]))
  message(sprintf("基因 ID 注释：共 %d 个 Ensembl ID，其中 %d 个 Symbol 冲突（去重时保留首次出现）",
                  nrow(Counts), conflict_count))

  # 去除重复 Symbol，保留第一次出现
  Counts <- Counts %>% distinct(GSB, .keep_all = TRUE)

  # NA 的 Symbol 回退为原始 Ensembl ID
  Counts$GSB <- ifelse(is.na(Counts$GSB), rownames(Counts), Counts$GSB)
  rownames(Counts) <- Counts$GSB
  Counts$GSB <- NULL

} else {
  message("行名非 Ensembl ID，跳过 ID 注释步骤。")
}


# -----------------------------------------------------------------------------
# 3. 构建 DGEList 并执行基因过滤
# -----------------------------------------------------------------------------
y <- DGEList(counts = Counts, genes = rownames(Counts))

# --- 记录过滤前基因数 ---
n_genes_before <- nrow(y)

# --- 基因过滤：filterByExpr（自适应样本量）---
# filterByExpr 会根据 design 矩阵中的分组结构和样本量自动计算过滤阈值
# 这比固定阈值 rowSums(cpm(y) > 1) >= 3 更稳健，
# 后者在小样本量（如每组 3 例）时过于严苛
design <- model.matrix(~group)
keep <- filterByExpr(y, design)

# 过滤后重新计算 library size（keep.lib.sizes = FALSE）
y <- y[keep, , keep.lib.sizes = FALSE]

# --- 记录过滤后基因数 ---
n_genes_after <- nrow(y)
message(sprintf("基因过滤：filterByExpr，过滤前 %d 基因 -> 过滤后 %d 基因（剔除 %d, %.1f%%）",
                n_genes_before, n_genes_after,
                n_genes_before - n_genes_after,
                (1 - n_genes_after / n_genes_before) * 100))


# -----------------------------------------------------------------------------
# 4. TMM 归一化
# -----------------------------------------------------------------------------
y <- calcNormFactors(y, method = "TMM")

# 检查 normalization factor 分布
norm_factors <- y$samples$norm.factors
message(sprintf("TMM normalization factor: 范围 [%.3f, %.3f], 中位数 %.3f",
                min(norm_factors), max(norm_factors), median(norm_factors)))

# 标记异常 size factor（0.5-2 为合理范围）
risk_normfactor <- names(norm_factors)[norm_factors < 0.5 | norm_factors > 2]
if (length(risk_normfactor) > 0) {
  warning(sprintf("以下样本 normalization factor 超出 0.5-2 范围: %s",
                  paste(risk_normfactor, collapse = ", ")))
}


# -----------------------------------------------------------------------------
# 5. 输出 CPM 矩阵和 log2CPM 矩阵（默认必须交付）
# -----------------------------------------------------------------------------

# CPM 矩阵（未 log2 转换）
# 用途：CIBERSORT 输入（要求非 log2）、表达量概览
CPM <- cpm(y, normalized.lib.sizes = TRUE)
write.csv(CPM, "GeneCpm.csv")

# log2CPM 矩阵
# 用途：WGCNA、PCA、聚类、热图、相关性分析
EXP <- log2(CPM + 1)
write.csv(EXP, "GeneExpr.csv")

message("已输出: GeneCpm.csv (CPM 矩阵), GeneExpr.csv (log2CPM 矩阵)")


# -----------------------------------------------------------------------------
# 6. 样本风险识别（只报告，不剔除）
# -----------------------------------------------------------------------------
risk_samples <- data.frame(
  sample     = character(),
  group      = character(),
  dimension  = character(),
  value      = numeric(),
  threshold  = character(),
  level      = character(),
  note       = character(),
  stringsAsFactors = FALSE
)

sample_names <- colnames(y$counts)
lib_sizes <- y$samples$lib.size
lib_median <- median(lib_sizes)

# 6.1 Library size 异常
lib_ratio <- lib_sizes / lib_median
for (s in sample_names) {
  r <- lib_ratio[s]
  if (r < 0.5 || r > 2.0) {
    level <- if (r < 0.33 || r > 3.0) "高" else "中"
    risk_samples <- rbind(risk_samples, data.frame(
      sample = s, group = as.character(group[sample_names == s]),
      dimension = "Library size", value = r,
      threshold = "0.5 - 2.0 (ratio to median)",
      level = level,
      note = sprintf("Library size = %.2fM, 中位数 = %.2fM", lib_sizes[s]/1e6, lib_median/1e6)
    ))
  }
}

# 6.2 组内相关性
# 计算样本间 Pearson 相关性
cor_mat <- cor(EXP, method = "pearson")
for (g in levels(group)) {
  g_samples <- sample_names[group == g]
  if (length(g_samples) >= 2) {
    for (s in g_samples) {
      others <- setdiff(g_samples, s)
      mean_r <- mean(cor_mat[s, others])
      if (mean_r < 0.80) {
        level <- if (mean_r < 0.70) "高" else "中"
        risk_samples <- rbind(risk_samples, data.frame(
          sample = s, group = g,
          dimension = "组内相关性", value = mean_r,
          threshold = "r >= 0.80",
          level = level,
          note = sprintf("与同组样本平均 r = %.3f", mean_r)
        ))
      }
    }
  }
}

# 6.3 零值比例
zero_pct <- colSums(Counts == 0) / nrow(Counts) * 100
zero_iqr <- IQR(zero_pct)
zero_upper <- median(zero_pct) + 2 * zero_iqr
for (s in sample_names) {
  z <- zero_pct[s]
  if (z > zero_upper || z > 60) {
    level <- if (z > 70) "高" else "中"
    risk_samples <- rbind(risk_samples, data.frame(
      sample = s, group = as.character(group[sample_names == s]),
      dimension = "零值比例", value = z,
      threshold = sprintf("%.1f%% (median + 2*IQR 或 60%%)", zero_upper),
      level = level,
      note = sprintf("零值比例 = %.1f%%", z)
    ))
  }
}

# 6.4 PCA 离群
pca_res <- prcomp(t(EXP), scale. = TRUE)
for (g in levels(group)) {
  g_samples <- sample_names[group == g]
  if (length(g_samples) >= 3) {
    pc1_mean <- mean(pca_res$x[g_samples, 1])
    pc1_sd   <- sd(pca_res$x[g_samples, 1])
    pc2_mean <- mean(pca_res$x[g_samples, 2])
    pc2_sd   <- sd(pca_res$x[g_samples, 2])
    for (s in g_samples) {
      dist <- sqrt(((pca_res$x[s, 1] - pc1_mean) / pc1_sd)^2 +
                   ((pca_res$x[s, 2] - pc2_mean) / pc2_sd)^2)
      if (dist > 2) {
        level <- if (dist > 3) "高" else "中"
        risk_samples <- rbind(risk_samples, data.frame(
          sample = s, group = g,
          dimension = "PCA 离群", value = dist,
          threshold = "同组 PC1/PC2 距离 <= 2 SD",
          level = level,
          note = sprintf("PC1/PC2 空间距同组中心 %.2f SD", dist)
        ))
      }
    }
  }
}

# 6.5 Normalization factor 异常
for (s in sample_names) {
  nf <- y$samples$norm.factors[s]
  if (nf < 0.5 || nf > 2.0) {
    level <- if (nf < 0.33 || nf > 3.0) "高" else "中"
    risk_samples <- rbind(risk_samples, data.frame(
      sample = s, group = as.character(group[sample_names == s]),
      dimension = "Normalization factor", value = nf,
      threshold = "0.5 - 2.0",
      level = level,
      note = sprintf("TMM factor = %.3f", nf)
    ))
  }
}

# 输出风险样本清单
if (nrow(risk_samples) > 0) {
  # 汇总每个样本的风险等级
  risk_summary <- risk_samples %>%
    group_by(sample) %>%
    summarise(
      n_dimensions = n(),
      max_level = case_when(
        any(level == "高") ~ "高",
        any(level == "中") ~ "中",
        TRUE ~ "低"
      ),
      dimensions = paste(dimension, collapse = "; ")
    )

  message("=== 风险样本清单 ===")
  print(risk_summary)
  write.csv(risk_samples, "risk_samples.csv", row.names = FALSE)
  write.csv(risk_summary, "risk_samples_summary.csv", row.names = FALSE)
} else {
  message("未发现风险样本。")
}


# -----------------------------------------------------------------------------
# 7. QC 可视化
# -----------------------------------------------------------------------------

# 7.1 Library size barplot
lib_df <- data.frame(
  sample = sample_names,
  lib_size = lib_sizes / 1e6,
  group = group,
  risk = sample_names %in% risk_samples$sample
)
p_lib <- ggplot(lib_df, aes(x = reorder(sample, lib_size), y = lib_size, fill = group)) +
  geom_col() +
  geom_col(data = subset(lib_df, risk), fill = "red", alpha = 0.5) +
  coord_flip() +
  labs(title = "Library Size", x = "Sample", y = "Library Size (M reads)") +
  theme_bw()
ggsave("qc_library_size.png", p_lib, width = 8, height = 6)

# 7.2 PCA
pca_df <- data.frame(
  PC1 = pca_res$x[, 1],
  PC2 = pca_res$x[, 2],
  group = group,
  sample = sample_names,
  risk = sample_names %in% risk_samples$sample
)
pca_var <- pca_res$sdev^2 / sum(pca_res$sdev^2) * 100
p_pca <- ggplot(pca_df, aes(PC1, PC2, color = group)) +
  geom_point(size = 3) +
  ggrepel::geom_text_repel(
    data = subset(pca_df, risk),
    aes(label = sample), color = "red", size = 3
  ) +
  labs(title = "PCA",
       x = sprintf("PC1 (%.1f%%)", pca_var[1]),
       y = sprintf("PC2 (%.1f%%)", pca_var[2])) +
  theme_bw()
ggsave("qc_pca.png", p_pca, width = 7, height = 6)

# 7.3 样本相关性热图
# 使用 pheatmap 或 ComplexHeatmap
# png("qc_correlation_heatmap.png", width = 1200, height = 1200)
# pheatmap(cor_mat,
#          display_numbers = TRUE,
#          number_format = "%.2f",
#          annotation_col = data.frame(group = group, row.names = sample_names),
#          main = "Sample Correlation (Pearson)")
# dev.off()

# 7.4 RLE (Relative Log Expression) plot
rle_mat <- sweep(log2(CPM + 1), 1, rowMedians(as.matrix(log2(CPM + 1))))
# 注意：rowMedians 来自 matrixStats 包
# 也可用 apply(rle_mat, 1, median) 替代
rle_df <- as.data.frame(rle_mat) %>%
  mutate(gene = rownames(.)) %>%
  tidyr::pivot_longer(-gene, names_to = "sample", values_to = "rle") %>%
  mutate(group = group[match(sample, sample_names)])
p_rle <- ggplot(rle_df, aes(sample, rle, fill = group)) +
  geom_boxplot(outlier.size = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "RLE Plot", x = "Sample", y = "Relative Log Expression") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("qc_rle.png", p_rle, width = 10, height = 6)


# -----------------------------------------------------------------------------
# 8. 审计报告
# -----------------------------------------------------------------------------
audit <- list(
  date = as.character(Sys.Date()),
  n_samples = length(sample_names),
  n_groups = length(levels(group)),
  gene_filter = list(
    method = "filterByExpr",
    design = "model.matrix(~group)",
    keep_lib_sizes = FALSE,
    n_before = n_genes_before,
    n_after = n_genes_after,
    n_removed = n_genes_before - n_genes_after,
    pct_removed = (1 - n_genes_after / n_genes_before) * 100
  ),
  normalization = list(
    method = "TMM",
    factors = norm_factors,
    factor_range = c(min(norm_factors), max(norm_factors)),
    risk_samples = risk_normfactor
  ),
  outputs = c("GeneCpm.csv", "GeneExpr.csv"),
  risk_samples = risk_samples,
  risk_summary = if (exists("risk_summary")) risk_summary else NULL
)

# 保存审计报告
# write.json(audit, "qc_audit.json")  # 或用 yaml::write.yaml(audit, "qc_audit.yaml")


# -----------------------------------------------------------------------------
# 9. 放行结论
# -----------------------------------------------------------------------------
# 根据风险样本数量和等级判断：
#   - 无高风险样本 -> 可进入下游
#   - 有中/高风险样本 -> 可进入下游但需用户评估是否剔除
#   - 多个高风险样本或上游严重异常 -> 不建议继续

high_risk <- risk_samples[risk_samples$level == "高", ]
n_high_risk_samples <- length(unique(high_risk$sample))

if (n_high_risk_samples == 0) {
  conclusion <- "可以直接进入下游分析"
} else if (n_high_risk_samples <= length(sample_names) * 0.2) {
  conclusion <- sprintf(
    "可以进入下游分析，但存在 %d 个高风险样本，建议用户评估是否剔除: %s",
    n_high_risk_samples,
    paste(unique(high_risk$sample), collapse = ", ")
  )
} else {
  conclusion <- sprintf(
    "存在 %d 个高风险样本（占总样本 %.0f%%），不建议直接进入下游分析",
    n_high_risk_samples,
    n_high_risk_samples / length(sample_names) * 100
  )
}

message(sprintf("=== 放行结论 ===\n%s", conclusion))


# -----------------------------------------------------------------------------
# 10. CIBERSORT（可选，使用 CPM 矩阵）
# -----------------------------------------------------------------------------
# library(CIBERSORT)
# data(LM22)
# # CIBERSORT 输入必须是非 log2 的表达矩阵（此处使用 CPM）
# results <- cibersort(sig_matrix = LM22, mixture_file = CPM, perm = 1000, QN = FALSE)
# write.csv(results, "cibersort_results.csv")
