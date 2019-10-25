if (getRversion() >= "2.15.1") {
    utils::globalVariables(c("BSgenome.Hsapiens.UCSC.hg19",
                            "mapp_hg19", "mapp_hg38"))
}
#' @title Compute GC content
#' @name get_gc
#'
#' @description Compute GC content for each bin
#'
#' @param ref GRanges object returned from \code{get_bam_bed}
#' @param genome by default, \code{genome = BSgenome.Hsapiens.UCSC.hg19}.
#' To calculate GC content for hg38, specify
#' \code{genome = BSgenome.Hsapiens.UCSC.hg38}
#'
#' @return
#'   \item{gc}{Vector of GC content for each bin/target}
#'
#' @examples
#' library(WGSmapp)
#' bamfolder <- system.file('extdata', package = 'WGSmapp')
#' bamFile <- list.files(bamfolder, pattern = '*.dedup.bam$')
#' bamdir <- file.path(bamfolder, bamFile)
#' sampname_raw <- sapply(strsplit(bamFile, '.', fixed = TRUE), '[', 1)
#' bambedObj <- get_bam_bed(bamdir = bamdir,
#'                             sampname = sampname_raw)
#' bamdir <- bambedObj$bamdir
#' sampname_raw <- bambedObj$sampname
#' ref_raw <- bambedObj$ref
#'
#' gc <- get_gc(ref_raw, genome = BSgenome.Hsapiens.UCSC.hg19)
#'
#' @author Rujin Wang \email{rujin@email.unc.edu}
#' @import BSgenome.Hsapiens.UCSC.hg19
#' @importFrom IRanges IRanges Views
#' @importFrom GenomeInfoDb mapSeqlevels seqnames
#' @importFrom BiocGenerics start end
#' @importFrom Biostrings unmasked alphabetFrequency
#' @export
get_gc <- function (ref, genome = NULL){
    if (is.null(genome)) {
        genome = BSgenome.Hsapiens.UCSC.hg19
    }
    gc <- rep(NA, length(ref))
    for (chr in unique(seqnames(ref))) {
        message("Getting GC content for chr ", chr, sep = "")
        chr.index <- which(as.matrix(seqnames(ref)) == chr)
        ref.chr <- IRanges(start = start(ref)[chr.index],
            end = end(ref)[chr.index])
        if (chr == "X" | chr == "x" | chr == "chrX" | chr == "chrx") {
            chrtemp <- "chrX"
        }
        else if (chr == "Y" | chr == "y" | chr == "chrY" | chr == "chry") {
            chrtemp <- "chrY"
        }
        else {
            chrtemp <- as.numeric(mapSeqlevels(as.character(chr), "NCBI")[1])
        }
        if (length(chrtemp) == 0)
            message("Chromosome cannot be found in NCBI
                Homo sapiens database!")
            chrm <- unmasked(genome[[chrtemp]])
            seqs <- Views(chrm, ref.chr)
            af <- alphabetFrequency(seqs, baseOnly = TRUE, as.prob = TRUE)
            gc[chr.index] <- round((af[, "G"] + af[, "C"]) * 100, 2)
    }
    gc
}