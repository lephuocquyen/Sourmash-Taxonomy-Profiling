
process SOURMASH_SKETCH {
    tag "$name"
    label 'process_medium'
    //publishDir params.outdir + "/sketch", mode:'copy'

    conda "bioconda::sourmash=4.6.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0'}"

    input:
    tuple val(name), path(sequence)

    output:
    tuple val(name), path("*.sig"), emit: signatures
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = task.ext.args ?: "dna --param-string 'scaled=1000,k=51,abund'"
    def prefix = task.ext.prefix ?: "${name}"

    """
    sourmash sketch \\
        $args \\
        --output '${prefix}.sig' \\
        $sequence

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
    sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}

