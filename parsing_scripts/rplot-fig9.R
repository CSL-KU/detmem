#!/usr/bin/env Rscript

library(ggplot2)
library(scales)

hitrate_cr_1bzip2 <- read.csv("../results/fig9-be-effect/csv/hit-rate-cr-1bzip2.csv")
cache_occ_1bzip2 <- read.csv("../results/fig9-be-effect/csv/cache-occ-1bzip2.csv")

hitrate_cr_1bzip2$co.runners <- factor(hitrate_cr_1bzip2$co.runners,as.character(hitrate_cr_1bzip2$co.runners))
hitrate_cr_1bzip2$Benchmark <- factor(hitrate_cr_1bzip2$Benchmark,as.character(hitrate_cr_1bzip2$Benchmark))
ggplot(hitrate_cr_1bzip2,aes(Benchmark,y=slowdown,fill=co.runners)) + geom_bar(width=0.6,stat="identity",position="dodge",color="black") + theme_bw()+scale_fill_grey(start = 0, end = .9)+theme(axis.text.x=element_text(angle=-30,hjust=0,size=25),axis.title.x = element_blank(),axis.text.y=element_text(size=25),axis.title.y=element_text(size=25),legend.position="top",legend.direction="horizontal",legend.title=element_blank(),legend.text=element_text(size=27))+ ylab("Hit Rate")+ coord_cartesian(ylim = c(0, 1))  + scale_y_continuous(labels=percent)
ggsave("../results/figs/fig9a-hit-rate-cr-1bzip2.pdf",width=9, height=5.5)

cache_occ_1bzip2$co.runners <- factor(cache_occ_1bzip2$co.runners,as.character(cache_occ_1bzip2$co.runners))
cache_occ_1bzip2$Benchmark <- factor(cache_occ_1bzip2$Benchmark,as.character(cache_occ_1bzip2$Benchmark))
ggplot(cache_occ_1bzip2,aes(Benchmark,y=slowdown,fill=co.runners)) + geom_bar(width=0.6,stat="identity",position="dodge",color="black") + theme_bw()+scale_fill_grey(start = 0, end = .9)+theme(axis.text.x=element_text(angle=-30,hjust=0,size=25),axis.title.x = element_blank(),axis.text.y=element_text(size=25),axis.title.y=element_text(size=25),legend.position="top",legend.direction="horizontal",legend.title=element_blank(),legend.text=element_text(size=27))+ ylab("Cache Occupancy")+ coord_cartesian(ylim = c(0, 1.001)) + scale_y_continuous(labels=percent)
ggsave("../results/figs/fig9b-cache-occ-1bzip2.pdf",width=9, height=5.5)
