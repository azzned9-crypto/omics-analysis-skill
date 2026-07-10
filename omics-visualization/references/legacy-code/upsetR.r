
#UpnetR
	library(UpSetR)
	setwd("F:/26.HighAltitude/05.转录组数据祛样分析/16.GSE_Prune")
	P1 <- as.character(unlist(read.table("Pattern1GeneList.txt", header = FALSE, sep = "\t")))
	P2 <- as.character(unlist(read.table("Pattern2GeneList.txt", header = FALSE, sep = "\t")))
	P2HUB <- as.character(unlist(read.table("Pattern2Hub20.txt", header = FALSE, sep = "\t")))
	P1HUB <- as.character(unlist(read.table("Pattern1Hub5.txt", header = FALSE, sep = "\t")))
	SADEG <- as.character(unlist(read.table("SA_DEGlist.txt", header = FALSE, sep = "\t")))
	HADEG <- as.character(unlist(read.table("HA_DEGlist.txt", header = FALSE, sep = "\t")))
#构建基因列表
	GENE <- list(P1 =P1, P2 = P2, P2HUB = P2HUB, P1HUB = P1HUB, SADEG = SADEG, HADEG = HADEG)
#绘制UpSet图
	upset(fromList(GENE),
      nsets = 6,  #图中数据集的数量（底部横条）
      nintersects=20,#图中数据集的数量（顶部纵条）
      order.by = "freq",
      main.bar.color = "black",#纵向柱状的颜色
      point.size = 3,
      text.scale = 1.2,
      matrix.color = "black", #点的颜色
      sets.bar.color = "#2ecc71" #横向柱状的颜色
	)
