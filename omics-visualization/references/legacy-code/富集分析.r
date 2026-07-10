#差异基因通路富集分析
	library(org.Hs.eg.db)
	library(tidyverse)
	library(clusterProfiler)#bitr
	BiocManager::install("devtools")
	devtools::install_github("dxsbiocc/gground")
	library(gground)
	library(ggprism) #theme_prism
	SIGN <-  read.table("SIGN_genelist.txt")
	ETR <- bitr(SIGN$V1,fromType ='SYMBOL',toType ='ENTREZID', OrgDb ='org.Hs.eg.db')
	#富集分析
		GO <- enrichGO(gene = ETR$ENTREZID,  OrgDb= org.Hs.eg.db, ont ="ALL", readable = TRUE)
		GO <-as.data.frame(GO)#转为数据框
		write.csv(GO,"GOresults.csv")
		KEGG <-enrichKEGG(gene = ETR$ENTREZID, organism ='hsa')
		KEGG <-setReadable(KEGG, OrgDb = org.Hs.eg.db, keyType ="ENTREZID")
		KEGG <-as.data.frame(KEGG)
	#筛选TOP基因
		use_pathway <-
			group_by(GO, ONTOLOGY) %>%
			top_n(5, wt = -p.adjust) %>%#在每 GO术语分组内选择p.adjust最小的前5 个条目。wt =-p.adjust表示按照p.adjust的负值进行排序
			group_by(p.adjust) %>%
			top_n(1, wt = Count) %>% #在每个p.adjust值的分组内，选择 Count最大的那1 个条目
			rbind(top_n(KEGG, 5, -p.adjust) %>%
			group_by(p.adjust) %>%
			top_n(1, wt = Count) %>%
			mutate(ONTOLOGY ='KEGG') ) %>%
			ungroup() %>%
			mutate(ONTOLOGY =factor(ONTOLOGY,levels = rev(c('BP','CC','MF','KEGG')))) %>%
			dplyr::arrange(ONTOLOGY, p.adjust) %>%
			mutate(Description=factor(Description, levels = Description)) %>%
			tibble::rowid_to_column('index')
	#构建左侧标记数据
		width<-0.5 #左侧分类标签和基因数量点图的宽度
		xaxis_max <- max(-log10(use_pathway$p.adjust)) + 1 #X轴长
		#左侧分类标签数据
		rect.data <-
			group_by(use_pathway, ONTOLOGY) %>%
			reframe(n = n()) %>%
			ungroup() %>%
			mutate(xmin = -3* width, xmax = -2* width, ymax = cumsum(n), ymin = lag(ymax, default =0) +0.6, ymax = ymax +0.4)

	#作图
		pal<- c('#7bc4e2','#acd372','#fbb05b','#ed6ca4')
		p<- ggplot(use_pathway, aes(x = -log10(p.adjust), y = Description)) +
			geom_col(aes(fill = ONTOLOGY), width = 0.6, alpha = 0.8) +
			#通路名称标签
			geom_text(aes(x = 0.05, label = Description), hjust = 0, size = 5) +
			#基因列表（斜体）
			geom_text(aes(x = 0.1, label = geneID, color = ONTOLOGY),hjust = 0, vjust = 3, size = 3.5, fontface = 'italic', show.legend = FALSE) +
			#左侧Count点图
			geom_point(aes(x = -width, size = Count), shape = 21, fill = "white") +
			geom_text(aes(x = -width, label = Count), size = 3) +

			#背景色块（用 annotate 避免数据继承问题）
			annotate("rect",
			    xmin = rect.data$xmin, xmax = rect.data$xmax,
			    ymin = rect.data$ymin, ymax = rect.data$ymax,
			    fill = pal[match(rect.data$ONTOLOGY, rev(c("BP", "CC", "MF", "KEGG")))],
			    alpha = 0.2, color = "black") +
			#ONTOLOGY 标签
			annotate("text",
			    x = (rect.data$xmin + rect.data$xmax) / 2,
			    y = (rect.data$ymin + rect.data$ymax) / 2,
			    label = rect.data$ONTOLOGY, fontface = "bold") +
			#X轴参考线
			annotate("segment", x = 0, y = 0, xend = xaxis_max, yend = 0, linewidth = 1.5) +

			#坐标轴与主题
			scale_x_continuous(breaks = seq(0, xaxis_max, 2), expand = expansion(c(0, 0))) +
			scale_fill_manual(name = "Category", values = pal) +
			scale_color_manual(values = pal) +
			scale_size_continuous(name = "Count", range = c(5, 16)) +
			labs(x = "-log10(adjusted p-value)", y = NULL) +
			theme_prism() +
			theme(
			    axis.text.y = element_blank(),
			    axis.line.y = element_blank(),
			    axis.ticks.y = element_blank(),
			    legend.title = element_text()
			  )
		ggsave("Gene_Enrich.pdf",p,width = 10, height = 10)
