process GENEBRIDGE {
    container "${ workflow.containerEngine == 'singularity' ?
        'docker://docker.io/jvfe/genebridge:v0.99.2':
        'docker.io/jvfe/genebridge:v0.99.2' }"

    input:
        path species_list
        path clade_names
        path string_eukaryotes
        path geneplast_data
        path protein_info

    output:
        path "results/", emit: csv_results

    script: 
    """
    01_root_genes.R \\
        $species_list \\
        $clade_names \\
        $string_eukaryotes \\
        $geneplast_data \\
        $protein_info
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
    GENEBRIDGE (
        file(params.species_list),
        file(params.clade_names),
        file(params.string_eukaryotes),
        file(params.geneplast_data),
        file(params.protein_info)
    )

    DB_CREATION (
        GENEBRIDGE.out.csv_results
    )
}