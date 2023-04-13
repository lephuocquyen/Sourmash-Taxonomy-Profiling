
// params.reads           =  "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/samplesheet/samplesheet.csv"
// params.database        =  "/media/bio03/DATA/quyen/INTERNSHIP/sourmash/database/GTDB_R07-RS207_allgenomes/gtdb-rs207.genomic.k51.zip"
// params.taxonomysheet   =  "/media/bio03/DATA/quyen/INTERNSHIP/sourmash/database/Taxonomy_spreadsheet/gtdb-rs207.taxonomy.sqldb"
// params.outdir   =  "results"
//params.outdir_gather   =  "results/gather"
//params.outdir_tax      =  "results/tax"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
include {SOURMASH_SKETCH           }     from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/sketch/main.nf"
include {SOURMASH_GATHER           }     from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/gather/main.nf"
//include {SOURMASH_INDEX}               from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/index/main.nf"
include {SOURMASH_TAX_METAGENOME   }     from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/taxmetagenome/main.nf"
include {SOURMASH_TAX_ANNOTATE     }     from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/taxannotate/main.nf"
include {KRONA_KTIMPORTTEXT        }     from "/media/bio03/DATA/quyen/INTERNSHIP/nextflow/sourmash_official/modules/krona/main.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow TAXSOURMASH {
    // Channel
    ch_samplesheet = Channel.fromPath( params.reads, checkIfExists:true )
    read_pairs_ch = ch_samplesheet.splitCsv(header:true).map {
        r1 = it['r1']
        sample = it['sample']
        name = [sample, [r1]]
    }
    read_pairs_ch.view()

    /*
        MODULE: SOURMASH_SKETCH
    */  
    // Create the sketch
    SOURMASH_SKETCH ( read_pairs_ch )

    /*
        MODULE: SOURMASH_GATHER
    */
    // Search a metagenome signature against database
     save_unassigned    = false
     save_matches_sig   = true
     save_prefetch      = false
     save_prefetch_csv  = false

    SOURMASH_GATHER (
        SOURMASH_SKETCH.out.signatures, 
        params.database,
        save_unassigned,
        save_matches_sig,
        save_prefetch,
        save_prefetch_csv
    )

     /*
         MODULE: SOURMASH_TAX_METAGENOME
     */   
     // summarizes gather results for each query metagenome by taxonomic lineage
    save_csv_summary      = true  
    save_lineage_summary  = true
    save_krona            = true
    save_kreport          = true

    SOURMASH_TAX_METAGENOME (
        SOURMASH_GATHER.out.results, 
        params.taxonomysheet,
        save_csv_summary,
        save_lineage_summary,
        save_krona,
        save_kreport
    )

     /*
         MODULE: SOURMASH_TAX_ANNOTATE
     */  
     //
    SOURMASH_TAX_ANNOTATE (
        SOURMASH_GATHER.out.results,
        params.taxonomysheet,
    )

     /*
         MODULE: KRONA_KTIMPORTTEXT
     */ 
    KRONA_KTIMPORTTEXT (
        SOURMASH_TAX_METAGENOME.out.krona
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/