process DOWNLOAD_DATA {
    container "${ workflow.containerEngine == 'singularity' ?
        'docker://docker.io/jvfe/genebridge:v0.99.5':
        'docker.io/jvfe/genebridge:v0.99.5' }"

    publishDir "${baseDir}/data", mode: 'copy'

    output:
        path "COG.mappings.v11.0.txt.gz", emit: cog_map
        path "protein.info.v11.0.txt.gz", emit: prot_info
        path "gpdata_string_v11.RData", emit: gp_data

    script:
    """
    wget https://stringdb-static.org/download/COG.mappings.v11.0.txt.gz
    wget https://stringdb-static.org/download/protein.info.v11.0.txt.gz
    download_gpdata.R
    """
}

process GENEBRIDGE {
    container "${ workflow.containerEngine == 'singularity' ?
        'docker://docker.io/jvfe/genebridge:v0.99.5':
        'docker.io/jvfe/genebridge:v0.99.5' }"

    input:
        path species_list
        path clade_names
        path string_eukaryotes
        path gp_data
        path cog_map
        path prot_info

    output:
        path "results/", emit: csv_results

    script:
    """
    01_root_genes.R \\
        $species_list \\
        $clade_names \\
        $string_eukaryotes \\
        $gp_data \\
        $cog_map \\
        $prot_info
    """
}

process DB_CREATION {

    container "${ workflow.containerEngine == 'singularity' ?
        'docker://docker.io/jvfe/sqlite-nf:latest':
        'docker.io/jvfe/sqlite-nf:latest' }"

    input:
        path csv_results

    output:
        path "orthoguide_data.db", emit: db

    script:
    """
    02_create_db.sh \\
        $csv_results
    """
}

workflow {
    if (params.download_references) {
        DOWNLOAD_DATA ()
        gp_data_ch = DOWNLOAD_DATA.out.gp_data
        cog_map_ch = DOWNLOAD_DATA.out.cog_map
        prot_info_ch = DOWNLOAD_DATA.out.prot_info
    } else {
        gp_data_ch = file(params.geneplast_data)
        cog_map_ch = file(params.cogdata_table)
        prot_info_ch = file(params.protein_info)
    }

    GENEBRIDGE (
        file(params.species_list),
        file(params.clade_names),
        file(params.string_eukaryotes),
        gp_data_ch,
        cog_map_ch,
        prot_info_ch
    )

    DB_CREATION (
        GENEBRIDGE.out.csv_results
    )
}
