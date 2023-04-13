
process SOURMASH_TAX_METAGENOME {
    tag "$name"
    label 'process_medium'
//    publishDir params.outdir + "/taxmetagenome", mode:'copy'
    
    conda "bioconda::sourmash=4.6.1"
    container "quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"
//    container "docker pull quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"

    input:
    tuple val(name), path(result_gather)
    path(taxonomysheet)
    val save_csv_summary       
    val save_lineage_summary  
    val save_krona            
    val save_kreport      

    output:
    tuple val(name), path('*.summarized.csv')        , optional:true,  emit: summarized
    tuple val(name), path('*.lineage_summary.tsv')   , optional:true,  emit: leneage
    tuple val(name), path('*.krona.tsv')             , optional:true,  emit: krona
    tuple val(name), path('*.kreport.txt')           , optional:true,  emit: kreport
    path "versions.yml"                                             ,  emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args    =  task.ext.args    ?: ''
    def prefix  =  task.ext.prefix  ?: "${name}"

    def csv_summary       = save_csv_summary       ? "--output-format csv_summary"                      : ''
    def lineage_summary   = save_lineage_summary   ? "--output-format lineage_summary --rank species"   : ''
    def krona             = save_krona             ? "--output-format krona --rank species"             : ''
    def kreport           = save_kreport           ? "--output-format kreport --rank species"           : ''
    """
    sourmash tax metagenome \\
        $args \\
        --gather-csv $result_gather \\
        --taxonomy $taxonomysheet \\
        ${csv_summary} \\
        ${lineage_summary} \\
        ${krona} \\
        ${kreport} \\
        -o ${prefix}_tax

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}