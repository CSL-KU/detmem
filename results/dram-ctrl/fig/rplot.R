#!/usr/bin/env Rscript

library(ggplot2)
library(scales)

slowdown_mc <- read.csv("slowdown-mc.csv")

slowdown_mc$co.runners <- factor(slowdown_mc$co.runners,as.character(slowdown_mc$co.runners))
slowdown_mc$Benchmark <- factor(slowdown_mc$Benchmark,as.character(slowdown_mc$Benchmark))
ggplot(slowdown_mc,aes(Benchmark,y=slowdown,fill=co.runners)) + geom_bar(width=0.6,stat="identity",position="dodge",color="black") + theme_bw()+scale_fill_grey(start = 0, end = .9)+theme(axis.text.x=element_text(angle=-30,hjust=0,size=25),axis.title.x = element_blank(),axis.text.y=element_text(size=25),axis.title.y=element_text(size=25),legend.position="top",legend.direction="horizontal",legend.title=element_blank(),legend.text=element_text(size=27))+ ylab("Slowdown")+ coord_cartesian(ylim = c(0, 6)) + geom_abline(intercept = 1, slope = 0,  linetype="dotted")
ggsave("slowdown-mc.pdf",width=9, height=5.5)
