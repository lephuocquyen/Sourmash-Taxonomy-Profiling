
process SOURMASH_GATHER {
    tag "$name"
    label 'process_medium'
//    publishDir params.outdir + "/gather", mode:'copy'

    conda "bioconda::sourmash=4.6.1"
    container "quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"
//    container "docker pull quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"

    input:
    tuple val(name), path(signature)
    path(database)
    val save_unassigned
    val save_matches_sig
    val save_prefetch
    val save_prefetch_csv

    output:
    tuple val(name), path('*_gather.csv.gz')      , optional:true, emit: results
    tuple val(name), path('*_unassigned.sig.zip') , optional:true, emit: unassigned
    tuple val(name), path('*_matches.sig.zip')    , optional:true, emit: matches
    tuple val(name), path('*_prefetch.sig.zip')   , optional:true, emit: prefetch
    tuple val(name), path('*_prefetch.csv.gz')    , optional:true, emit: prefetchcsv
    path "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${name}"
    def unassigned  = save_unassigned   ? "--output-unassigned ${prefix}_unassigned.sig.zip" : ''
    def matches     = save_matches_sig  ? "--save-matches ${prefix}_matches.sig.zip"         : ''
    def prefetch    = save_prefetch     ? "--save-prefetch ${prefix}_prefetch.sig.zip"       : ''
    def prefetchcsv = save_prefetch_csv ? "--save-prefetch-csv ${prefix}_prefetch.csv.gz"    : ''

    """
    sourmash gather \\
        $args \\
        --output ${prefix}_gather.csv.gz \\
        ${unassigned} \\
        ${matches} \\
        ${prefetch} \\
        ${prefetchcsv} \\
        ${signature} \\
        ${database}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
