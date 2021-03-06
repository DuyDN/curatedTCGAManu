## comparing subtypes between TCGAbiolinks and curatedTCGAData

library(curatedTCGAData)
library(TCGAutils)

## check OV status
ov <- curatedTCGAData::curatedTCGAData("OV", "RNASeqGene", FALSE)
getSubtypeMap(ov)
## need sever for further investigation
## spreadsheet in drive?

coad <- curatedTCGAData("COAD", "*", FALSE)
subtypeNames <- getSubtypeMap(coad)[["COAD_subtype"]]

coad_stypes <-
    colData(coad)[, subtypeNames[subtypeNames %in% names(colData(coad))]]

xtabs(~ .,
    data = colData(coad)[, c("histological_type.x", "histological_type.y")])

library(TCGAbiolinks)
bioco <- TCGAquery_subtype("COAD")

biolink <- bioco[, c("patient", "MSI_status", "methylation_subtype",
    "expression_subtype", "histological_type")]

biop <- biolink[biolink$patient %in% coad_stypes$patientID, ]

coadp <- coad_stypes[coad_stypes$patientID %in% biolink$patient, ]

## full agreement (all 3 below)
t1 <- table(biop$MSI_status, coadp$MSI_status)
table(biop$methylation_subtype, coadp$methylation_subtype)
table(biop$expression_subtype, coadp$expression_subtype)

## partial agreement
t4 <- table(biop$histological_type,
    colData(coad)[coad_stypes$patientID %in% biolink$patient, "histological_type.x"])

## full agreement
t5 <- table(biop$histological_type,
    colData(coad)[coad_stypes$patientID %in% biolink$patient, "histological_type.y"])

getAccuracy <- function(tab) {
    dimnames(tab) <- lapply(dimnames(tab), tolower)
    commonNames <- Reduce(intersect, lapply(dimnames(tab), tolower))
    ntab <- tab[commonNames, commonNames]
    cmat <- caret::confusionMatrix(as.table(ntab))
    cmat$overall[["Accuracy"]]
}

getAccuracy(t4)

## find what subtypes are available in TCGAbiolinks but not in curatedTCGAData
data("diseaseCodes")

dx <- setNames(diseaseCodes[["Study.Abbreviation"]],
    diseaseCodes[["Study.Abbreviation"]])

sublist <- lapply(dx, function(sub) {
    try(TCGAbiolinks::TCGAquery_subtype(sub))
})

sublist <- sublist[!vapply(sublist, is, logical(1L), "try-error")]

headlist <- lapply(sublist, function(stype) {
    head(
    stype[, grepl("cluster|subtype", ignore.case = TRUE, names(stype))]
    )
})

## Cancer codes in both where subtypes are available
intersect(
    names(headlist),
)

## Cancer codes where TCGAbiolinks has subtype info and curatedTCGA does not
setdiff(names(headlist),
    diseaseCodes[diseaseCodes$SubtypeData == "Yes", "Study.Abbreviation"]
)
