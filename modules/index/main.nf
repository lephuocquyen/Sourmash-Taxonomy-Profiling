process SOURMASH_INDEX {
    tag "$name"
    label 'process_single'
    publishDir params.outdir + "/index", mode:'copy'

    conda "bioconda::sourmash=4.6.1"
    container "docker pull quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0"
/*
    conda "bioconda::sourmash=4.6.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"
 */

    input:
    tuple val(name), path(signatures)

    output:
    tuple val(name), path("*.sbt.zip"), emit: signatures_index
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // --ksize needs to be specified with the desired k-mer size to be selected in ext.args
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${name}"
    """
    sourmash index \\
        $args \\
        '${prefix}.sbt.zip' \\
        $signatures

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}