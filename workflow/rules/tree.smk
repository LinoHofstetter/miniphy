##
## Tree inference
##


# get a cleaned tree and all auxiliary files
rule tree_sorted:
    output:
        nw=fn_tree_sorted(_batch="{batch}"),
        leaves=fn_leaves_sorted(_batch="{batch}"),
    input:
        nw=fn_tree_mashtree(_batch="{batch}"),
    params:
        script=snakemake.workflow.srcdir("../scripts/postprocess_tree.py"),
    threads: 8
    shell:
        ## how to execute scripts?
        """
        {params.script} -l {output.leaves} {input.nw} {output.nw}

        """


# infer a phylogenetic tree from the assemblies of a given batch
rule tree_newick_mashtree:
    output:
        nww=fn_tree_mashtree(_batch="{batch}"),
    input:
        w_batch_asms,
    threads: 8
    shell:
        """
        mashtree \\
            --numcpus {threads} \\
            --seed 42  \\
            --sort-order ABC \\
            {input} \\
            | tee {output.nww}
        """
