# Make plot of autosomal het. versus ROH length sums
# Make plot of short, medium, long ROH numbers


args=commandArgs(TRUE)

# ROH data
# The sample Name is the one defined on your VCF/BAM file
# You can get the sample name with: `zcat <VCFfile> | grep 'POS'`
# usage: Rscript <nameOfTheScript> <FileROH.hom> <SampleName>

FileROH = args[1]
samplename= as.character(args[2])
pdfName =as.character(args[3])
rohdata=read.table(FileROH, header=T)

shorts=rohdata[rohdata$POS2-rohdata$POS1>=100000 & rohdata$POS2-rohdata$POS1<1000000,]
meds=rohdata[rohdata$POS2-rohdata$POS1>=1000000 & rohdata$POS2-rohdata$POS1<5000000,]
longs=rohdata[rohdata$POS2-rohdata$POS1>=5000000,]


shortsums=NULL
shortnums=NULL
for (i in 1:length(samplename)){
	rohs=shorts[shorts$IID==samplename[i],]
	shortsums[i]=sum(rohs$POS2-rohs$POS1)	
	shortnums[i]=dim(rohs)[1]
}

medsums=NULL
mednums=NULL
for (i in 1:length(samplename)){
	rohs=meds[meds$IID==samplename[i],]
	medsums[i]=sum(rohs$POS2-rohs$POS1)	
	mednums[i]=dim(rohs)[1]
}

longsums=NULL
longnums=NULL
for (i in 1:length(samplename)){
	rohs=longs[longs$IID==samplename[i],]
	longsums[i]=sum(rohs$POS2-rohs$POS1)	
	longnums[i]=dim(rohs)[1]
}


#############################################################################################################

# Orde has to be the same as in the header
# Make data table


#mydf=data.frame(samplename, nocalls, calls, homRs, homAs, hets, autohet, shortnums, mednums, longnums, shortsums, medsums, longsums)
mydf=data.frame(samplename, shortnums, mednums, longnums, shortsums, medsums, longsums)

# Write table for ROH length sums

write.csv(mydf,"ROH.Sum.csv", row.names = FALSE)


# Make a plot
getwd()
pdf(paste("ROH","_",samplename,"_",pdfName, ".pdf", sep=""), width=3.28, height=4.92, pointsize=8)

b2=barplot(rbind(mydf$shortsums/1e6, mydf$medsums/1e6, mydf$longsums/1e6), space=0,
           las=2, horiz=T, axes=F, xlim=c(0,2500), col=rev(c("darkgreen","darkseagreen","darkseagreen1")))
title("ROH", xlab="ROH Length Sum (Gb)", line=2)
legend(2000, 1, legend=c("[0.1, 1) Mb","[1, 10) Mb","[10, 100) Mb"), fill=rev(c("darkgreen","darkseagreen","darkseagreen1")), bty="n")
axis(side=1, at=seq(0,2500, by=500), labels=seq(0,2.5, by=.5), las=1, line=-.5)
mtext(text = mydf$mylabels, side = 1, at = b2, line = 3.5, las=1, adj=.5, font=mydf$myfonts)

dev.off()
