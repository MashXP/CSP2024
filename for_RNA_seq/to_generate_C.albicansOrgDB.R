#########################Katharina 2023July11###########

###download annotation file from: https://fungidb.org/common/downloads/Current_Release/CalbicansSC5314/gaf/
#then read downloaded file
# UPDATED: Using FungiDB-68 as it is the current available version
finch <- read.delim("SC5314_fungiDB/FungiDB-68_CalbicansSC5314_GO.gaf", skip = 1, header = F)

#in the file there are a lot of blank line --> I just remove
finch <- finch[finch$V2!="",]

#then choose the one we need for annotation following below
fSym <- finch[,c(2,3,10)] 
fSym <- fSym[fSym[,2]!="-",]
fSym <- fSym[fSym[,3]!="-",]
colnames(fSym) <- c("GID","SYMBOL","GENENAME")

#GO table
fGO <- finch[,c(2,5,1)]
colnames(fGO) <- c("GID","GO","EVIDENCE")

#change data type to match requirement format
fSym$GID <- as.character(fSym$GID)
fGO$GID <- as.character(fGO$GID)

library(dplyr)
fSym <- dplyr::distinct(fSym, .keep_all = TRUE) #subset unique data
fGO <- dplyr::distinct(fGO, .keep_all = TRUE) #subset unique data

fSym <- as.data.frame(fSym) #make sure it is dataframe
fGO <- as.data.frame(fGO) #make sure it is dataframe

fGO<- fGO[is.na(fGO$GO)==FALSE, ] #remove NA value

library(AnnotationForge)  #to make org database

# UPDATED: Use version 68.0
makeOrgPackage(gene_info=fSym, go=fGO,
               version="68.0",
               maintainer="Trinh Phan <phancanht99@univie.ac.at>",
               author="Trinh Phan <phancanht99@univie.ac.at>",
               outputDir = ".",
               tax_id="5314",
               genus="Candida",
               species="albicans.Eupath.v68",
               goTable="go")

# Install the generated package
install.packages("./org.Calbicans.Eupath.v68.eg.db/", repos = NULL, type = "source")

####now try the package
library(org.Calbicans.Eupath.v68.eg.db)

# Use some genes from fSym to test
some_genes <- c("C2_08510W_A","CR_04760C_A","C3_03360W_A","C6_03030W_A","C3_06320W_A","C7_01420W_A",
                "C1_12680W_A","C3_04730C_A","C4_00990W_A","C7_03580C_A","C5_00830C_A","C1_00650C_A",
                "C1_09810W_A","C2_01440C_A","C1_02500W_A","C1_05430W_A","C1_10300W_A","C4_04870C_A","C7_01810W_A",
                "C2_02430W_A","C5_05110C_A","C4_00540C_A","C2_06870C_A","CR_04510W_A","C4_02640C_A","C1_07860W_A",
                "C2_07470W_A","C3_01420C_A","C1_08390C_A","CR_08370W_A","C4_01930C_A","C1_09950C_A","C1_08470W_A",
                "C4_01510W_A","CR_04020C_A","C1_10060C_A","C2_08650W_A","C1_02640C_A","CR_00070W_A","CR_00080W_A",
                "C7_02090C_A","C6_03570W_A","C4_02570C_A","C3_00190W_A","CR_06100C_A","C1_14290C_A","C5_00220W_A",
                "C4_02800W_A","CR_03610C_A","C1_06380C_A","C1_02440C_A","C3_01490W_A","C4_05850C_A","C3_06770W_A",
                "C2_01730W_A","C3_06230W_A","C1_08540C_A","C1_02370C_A","C1_06540C_A","C2_04330C_A","C1_07470C_A",
                "CR_00930W_A","C3_02360C_A","C1_13510C_A","C1_13200C_A","C2_03130W_A","C6_00540W_A",
                "C7_02640W_A","C4_07200C_A","C3_03600C_A","C3_02580C_A","C1_10280C_A","C7_03300C_A","C1_08260C_A",
                "C4_04640C_A","C4_04830W_A","C3_07880C_A","C1_14570C_A","CR_01990C_A","C1_13840W_A","C1_04840C_A",
                "C4_03090W_A","C1_08990C_A","C4_05670W_A","C7_02570C_A","C2_03260W_A","C4_04040W_A","C1_02330C_A",
                "C7_02260W_A","C3_01130C_A","C5_00640C_A","C5_00530W_A","C1_11090C_A","C4_03480C_A","C2_07020C_A",
                "C2_00650W_A","CR_04030W_A","C1_07040C_A","C4_02320C_A","C3_07160W_A","C5_02500C_A","C1_13070C_A",
                "C1_06080C_A","CR_05830C_A","C2_05750W_A","C1_05820C_A","C4_00020W_A","C4_06740C_A","C2_07890W_A",
                "C3_05580C_A","C5_03790W_A","C3_03470W_A","C1_07660W_A","C1_06450C_A","C5_02520W_A","CR_09790W_A",
                "C3_02640C_A","CR_01110W_A","C4_05750C_A","CR_03480W_A","CM_00440W","C2_07590W_A","CR_05430W_A","C4_05380C_A",
                "C5_02340C_A","C2_00080C_A","CR_08310C_A","CR_07310W_A","C1_02950W_A","C1_08010W_A","C5_03940C_A","C2_07130C_A",
                "C5_02900W_A","C1_12190W_A","C2_00460W_A","C4_01870C_A","C1_07630W_A","C1_01010W_A","C1_09270W_A","CR_10290C_A",
                "C1_02030C_A","C6_02510C_A","C1_10850W_A","CR_05910W_A","C4_04290W_A","C5_02080C_A","C1_03000W_A","C2_05720C_A",
                "C1_00020C_A","CR_07370W_A","C4_04580W_A","C4_00490W_A","C1_00210C_A","C4_06290W_A","C1_12220W_A","C6_03410C_A",
                "CR_05100W_A","C1_00170W_A","C3_01790C_A","C5_05340W_A","C5_02180C_A","C2_08740W_A","C6_00100C_A","C6_02140W_A",
                "C1_05540C_A","C2_09960W_A","C4_00190W_A","C7_00790W_A","C1_05280W_A","C2_04550C_A","C1_11910W_A","C3_01760W_A",
                "C3_06050C_A","C5_05190W_A","C7_03910W_A","C3_01320C_A","C5_02600W_A","C3_04890W_A","C1_03940W_A","C4_02410C_A",
                "C3_03710W_A","C2_06550W_A","C7_03850W_A","C5_04610W_A","C3_03830W_A","C1_00410C_A","C1_01900C_A","C1_01530C_A",
                "C1_08950W_A","C7_02920W_A","C1_00270W_A","C1_04170C_A","C5_00880C_A","CR_09650W_A","C4_01450W_A","C2_05140W_A",
                "C6_02900C_A","C2_01260W_A","CR_01220W_A","C7_01010W_A","C5_04210C_A","C3_02210C_A","C4_05650W_A","C4_07260W_A",
                "C4_03200C_A","C2_06540C_A","C2_03250W_A","C5_04770W_A","CR_06850C_A","C2_00890W_A","CR_07220C_A","C2_02780C_A",
                "C7_00770W_A","C7_00610C_A","C2_08200W_A","C7_03020C_A","C3_02910W_A","C1_08530W_A","CR_04660C_A","C1_05500W_A",
                "C2_10730W_A","C1_06750W_A","C5_05280C_A","C6_00900C_A","C4_04350W_A","C5_04750C_A","C3_02850C_A","C3_04680W_A",
                "CR_10360C_A","C7_04090C_A","C1_00350C_A","C1_11490C_A","CR_09740W_A","CR_09920W_A","C5_03780C_A","C3_01520C_A",
                "C2_05540C_A","CR_08600C_A","C4_02110W_A","C7_02790C_A","C3_02020W_A","CR_03830C_A","C3_07360W_A","C2_04440W_A",
                "CR_07190W_A","C1_02240W_A","C1_03070C_A","CR_05050W_A","C2_03800C_A","C2_01800W_A","C1_12490W_A","C3_00430W_A",
                "C7_02490W_A","CR_04350C_A","C5_03670C_A","C7_00110W_A","CR_07950W_A","C3_05910W_A","C4_01980C_A","C6_01000C_A",
                "CM_00520W","C2_00610C_A","C1_02040C_A","C1_05920W_A","C1_03960C_A","C6_02550W_A","C5_03770C_A","C2_07770C_A",
                "C4_05340W_A","C1_14340C_A","C2_00380C_A","C6_03010W_A","CR_09710W_A","C5_00860W_A","C4_01400W_A","C1_09080C_A",
                "C1_14310W_A","CR_05750W_A","C5_05160C_A","CM_00250W","C3_00980W_A","C1_04320W_A","CR_01170W_A","C3_07070C_A",
                "C4_04510W_A","C4_07220C_A","C2_10530C_A","C3_03510C_A","C5_04270C_A","C5_00070W_A","C7_01720W_A","C3_00170C_A",
                "C1_14460W_A","C1_13350W_A","C2_08040C_A","C1_14130W_A","C3_01700W_A","C6_02500C_A","C4_03820C_A","C3_06370C_A",
                "C7_03560W_A","C6_04270W_A","C2_04300C_A","C3_03120C_A","C6_04330W_A","C1_12580W_A","C1_10530W_A","C1_06420C_A",
                "C3_04830C_A","C2_08600W_A","C1_06130C_A","C2_09970C_A","C2_05940C_A","CR_06660W_A","C1_01940C_A","C1_12950W_A",
                "C1_12850W_A","CR_04460C_A","C2_04400W_A","C2_09890W_A","C5_02530W_A","C1_00760W_A","C1_11450C_A","C7_03570W_A",
                "C2_09140C_A","C7_04040C_A","C4_06840W_A","C2_09920W_A","C1_01610C_A","C4_03930C_A","C5_02110W_A","C1_11270W_A",
                "C5_02440C_A","C3_01640C_A","C5_01920C_A","C4_06660W_A","C2_01090C_A","C2_08610W_A","C1_14270W_A","C7_01330C_A",
                "C1_02110C_A","C3_02550C_A","C1_11990W_A","C5_04860C_A","C5_04480C_A","C2_01450C_A","C7_00190W_A","C1_04270C_A",
                "C1_13810W_A","C4_03140C_A","C2_06990W_A","CR_04090C_A","C4_02210W_A","CR_09480W_A","C5_04070C_A","C2_02010C_A",
                "C1_09010W_A","C5_00240W_A","C4_04070C_A","C5_03480C_A","C1_06280C_A","C5_01410C_A","C3_01900C_A","C4_02270C_A",
                "C3_07010W_A","C3_00760W_A","C5_04540C_A","C5_00200C_A","C2_00280C_A","C4_04420W_A","C3_05810C_A","C5_04930C_A",
                "C4_03760W_A","C6_02460C_A","C4_03670W_A","CR_04480C_A","C1_03480C_A","C1_10550C_A","C7_01560C_A","C2_03230C_A",
                "C6_01290C_A","C5_02140C_A","C4_06560W_A","CR_09070C_A","C5_04200W_A","C2_03550C_A","C1_13770C_A","C1_02090C_A",
                "C1_13990W_A","C3_05000W_A","CR_02650C_A","C1_11210C_A","C1_00590W_A","C2_02440W_A","CR_03730C_A","C4_01700C_A",
                "CR_06810W_A","C1_04660W_A","C2_09310C_A","C7_03890C_A","C1_10800C_A","CR_05030W_A","C7_00830C_A","C3_04870W_A",
                "CR_09640C_A","C1_13030C_A","C3_00290W_A","C5_05150C_A","C1_08050W_A","C4_04630C_A","C6_02480W_A","C7_01610W_A",
                "C5_04530W_A","C3_04360W_A","CR_00660W_A","C3_04640W_A","C2_05070W_A","C4_05290W_A","C3_02270W_A","C4_04910C_A",
                "C4_04160W_A","C1_02050C_A","C5_01070C_A","C4_03020W_A","C2_08590W_A","C1_00370W_A","C4_04180C_A","C1_09990W_A","C2_09610W_A","C2_09100C_A","C3_01170W_A","C2_01660C_A","CR_01720W_A","C5_04840C_A","C2_07730W_A","C3_00600W_A","CR_01420W_A","C4_02540W_A","C6_03880W_A","CR_04310C_A","C5_03850W_A","CR_08490W_A","C1_11810W_A","C1_10680C_A","CR_07510W_A","C2_10750C_A","C7_03680W_A","C1_03120W_A","C2_09860C_A","C2_09690C_A","CR_07270C_A","C3_05660C_A","C7_01180W_A","C3_02110W_A","C5_02360C_A","C4_04670C_A","C2_08460C_A","C3_07090W_A","CR_07110C_A","C3_00720W_A","CR_05990C_A","C4_03720C_A","C7_00440C_A","C2_03880C_A","C2_04120C_A","C5_00150C_A","C2_01650W_A","C1_00390W_A","C1_09070W_A","C2_03060W_A","C7_04070C_A","CR_03170W_A","C4_00440C_A","C5_01930W_A","C4_03040W_A","C7_01250W_A","C2_00450C_A","C1_01000C_A","C1_10710C_A","C5_00140C_A","C1_12170C_A","CR_10040W_A","C2_02370C_A","C6_01450C_A","C2_05080C_A","C3_03690W_A","C6_00630W_A","C4_05090C_A","C2_07070W_A","C6_04310W_A","C6_00880W_A","C7_02880C_A","C5_05480W_A","C1_02600W_A","C3_05100C_A","CR_06380C_A","C1_13930W_A","C4_01100C_A","C1_04780C_A","C5_03740W_A")

# UPDATED: Use the correct package name
GO <- clusterProfiler::enrichGO(
  some_genes,
  org.Calbicans.Eupath.v68.eg.db,
  keyType = "GID",
  pvalueCutoff = 1)

pdf("GO_results_v68.pdf")
if (!is.null(GO)) {
  print(enrichplot::cnetplot(GO, showCategory = 5))
  print(barplot(GO))
  print(enrichplot::dotplot(GO))
}
dev.off()
