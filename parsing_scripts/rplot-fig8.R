#!/usr/bin/env Rscript

library(ggplot2)
library(scales)

hitrate <- read.csv("../results/fig8-rt-effect/csv/hit-rate.csv")
dmutil <- read.csv("../results/fig8-rt-effect/csv/dm-util.csv")

hitrate$co.runners <- factor(hitrate$co.runners,as.character(hitrate$co.runners))
hitrate$Benchmark <- factor(hitrate$Benchmark,as.character(hitrate$Benchmark))
ggplot(hitrate,aes(Benchmark,y=slowdown,fill=co.runners)) + geom_bar(width=0.6,stat="identity",position="dodge",color="black") + theme_bw()+scale_fill_grey(start = 0, end = .9)+theme(axis.text.x=element_text(angle=-30,hjust=0,size=25),axis.title.x = element_blank(),axis.text.y=element_text(size=25),axis.title.y=element_text(size=25),legend.position="top",legend.direction="horizontal",legend.title=element_blank(),legend.text=element_text(size=27))+ ylab("Hit Rate")+ coord_cartesian(ylim = c(0, 1.01)) + scale_y_continuous(labels=percent)
ggsave("../results/figs/fig8a-hit-rate.pdf",width=9, height=5.5)

dmutil$co.runners <- factor(dmutil$co.runners,as.character(dmutil$co.runners))
dmutil$Benchmark <- factor(dmutil$Benchmark,as.character(dmutil$Benchmark))
ggplot(dmutil,aes(Benchmark,y=slowdown,fill=co.runners)) + geom_bar(width=0.6,stat="identity",position="dodge",color="black") + theme_bw()+scale_fill_grey(start = 0, end = .9)+theme(axis.text.x=element_text(angle=-30,hjust=0,size=25),axis.title.x = element_blank(),axis.text.y=element_text(size=25),axis.title.y=element_text(size=25),legend.position="top",legend.direction="horizontal",legend.title=element_blank(),legend.text=element_text(size=27))+ ylab("Partition Utilization")+ coord_cartesian(ylim = c(0, 1.001)) + scale_y_continuous(labels=percent)
ggsave("../results/figs/fig8b-dm-util.pdf",width=9, height=5.5)
