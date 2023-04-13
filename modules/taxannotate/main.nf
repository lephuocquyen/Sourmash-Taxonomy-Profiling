process SOURMASH_TAX_ANNOTATE {
    tag "$name"
    label 'process_medium'

    conda "bioconda::sourmash=4.6.1"
    container "quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"

    input:
    tuple val(name), path(result_gather)
    path(taxonomysheet)

    output:
    tuple val(name), path("*.with-lineages.csv"), optional:true,  emit: result
    path "versions.yml"                                        ,  emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args    =  task.ext.args    ?: ''
    def prefix  =  task.ext.prefix  ?: "${name}"

    """
    sourmash \\
        tax annotate \\
        $args \\
        --gather-csv $result_gather \\
        --taxonomy $taxonomysheet \\
        --output-dir "."
        
    ## Compress output
    ## gzip --no-name *.with-lineages.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
