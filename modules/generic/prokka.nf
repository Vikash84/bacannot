process prokka {
    publishDir "${params.outdir}/${prefix}", mode: 'copy', saveAs: { filename ->
      if (filename.indexOf("_version.txt") > 0) "tools_versioning/$filename"
      else if (filename == "annotation") "$filename"
      else null
    }
    tag "Executing generic annotation with Prokka"
    label 'main'

    input:
    file(assembly)

    output:
    // Grab all outputs
    file "annotation/${prefix}.*"
    // Outputs must be linked to each prefix (tag)
    tuple val(prefix), file("annotation/${prefix}.gff") // annotation in gff format
    tuple val(prefix), file("annotation/${prefix}.gbk") // annotation in gbk format
    tuple val(prefix), file("annotation/${prefix}.fna") // renamed genome
    tuple val(prefix), file("annotation/${prefix}.faa") // gene aa sequences
    tuple val(prefix), file("annotation/${prefix}.ffn") // gene nt sequences
    file('prokka_version.txt') // Save prokka version

    script:
    prefix  = "${params.prefix}"
    kingdom = (params.prokka_kingdom)      ? "--kingdom ${params.prokka_kingdom}"        : ''
    gcode   = (params.prokka_genetic_code) ? "--gcode ${params.prokka_genetic_code}"     : ''
    rnammer = (params.prokka_use_rnammer)  ? "--rnammer"                                 : ''
    """
    source activate PROKKA ;

    # Save Prokka version
    prokka -v &> prokka_version.txt ;

    # Run prokka
    prokka $kingdom $gcode $rnammer --outdir annotation \
    --cpus ${params.threads} --mincontiglen 200 --prefix ${prefix} $assembly
    """
}