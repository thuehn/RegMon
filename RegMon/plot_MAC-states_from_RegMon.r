#!/usr/bin/Rscript --vanilla

library(ggplot2)
library(plyr)
library(reshape2)
library(magrittr)

label_wrap <- function(variable, value) {
    laply(strwrap(as.character(value), width=5, simplify=FALSE), paste, collapse="\n")
}

all_mac <- read.csv(file="stdin",header = T, sep = " ", dec='.')
all_mac <- melt(all_mac, id=c("ktime"), measure=c("d_tx","d_rx","d_idle","d_others"),variable_name = "mac_states")

max_x <- max(all_mac$ktime/1000000000)

p1 = ggplot(data=all_mac, aes (x=ktime/1000000000)) +
    geom_histogram(aes(fill=factor(variable), weight=abs(value)), position="fill") +
    scale_y_continuous( breaks = seq(0, 1, by = 0.25),  minor_breaks = seq(0, 1, by = 0.1)) +
    scale_x_continuous(limits=c(0,max_x), breaks = seq(0, max_x, by = 20),  minor_breaks = seq(0, max_x, by = 10)) +
    labs(x = "Time [s]", y = "relative dwell time [%]") +
    geom_vline(xintercept = seq(0,200,20), color="grey50", linetype="dashed", size=0.3) +
    geom_hline(yintercept = seq(0,1,0.1), color="grey50", linetype="dashed", size=0.3) +
    theme_bw() +
    labs(title = "MAC-state distribution") +
    theme(strip.text.x = element_text(size=12),
        strip.text.y = element_text(size=9),
        axis.text.x = element_text(size = 12, colour = "black"),
        axis.text.y = element_text(size = 8, colour = "black"),
        plot.title=element_text(colour="black", face="plain", size=13, vjust = 1.5, hjust = 0.5),
        plot.title = element_text(size = 14),
        strip.background = element_rect(colour='grey30', fill='grey80'),
        legend.title=element_text(colour="black", size=11, hjust=-.1, face="plain"),
        legend.text=element_text(colour="black", size=10, face="plain"),
        legend.background = element_rect(),
        axis.title.y = element_text(angle = 90, vjust = 0.2, hjust = 0.5, size = 15, colour = "black", face="plain"),
        axis.title.x = element_text(vjust = 0.2, hjust = 0.5, size = 15, colour = "black", face="plain")
    ) +
    scale_fill_manual(values=c("#F55A5A", "#32B2FF", "#F5DA81", "#DA81F5"),name="MAC\nstates",labels=c("tx-busy", "rx-busy", "idle", "others"))

ggsave(p1, file="RegMon.png", width=11, height=8, dpi=600)
