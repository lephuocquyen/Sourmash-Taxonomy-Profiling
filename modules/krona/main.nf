process KRONA_KTIMPORTTEXT {
    tag "$name"
    label 'process_medium'

    conda "bioconda::krona=2.8.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/krona:2.8.1--pl5321hdfd78af_1':
        'quay.io/biocontainers/krona:2.8.1--pl5321hdfd78af_1' }"

    input:
    tuple val(name), path(report)

    output:
    tuple val(name), path ('*.krona.html'),  emit: html
    path "versions.yml"                   ,  emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${name}"

    """
    ktImportText  \\
        $args \\
        -o ${prefix}.krona.html \\
        $report

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        krona: \$( echo \$(ktImportText 2>&1) | sed 's/^.*KronaTools //g; s/- ktImportText.*\$//g')
    END_VERSIONS
    """
}