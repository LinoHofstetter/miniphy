.PHONY: all help clean cleanall test report testreport format rmstats edit conda

SHELL=/usr/bin/env bash -eo pipefail

.SECONDARY:

.SUFFIXES:


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!! WARNING: !! TOPLEVEL_DIR changes to .. when run from .test/ !!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TOPLEVEL_DIR  = .

# test if this is run from the .test/ directory
ifeq ($(strip $(TOPLEVEL_DIR)),..)
	SNAKEMAKE_PARAM_DIR = --snakefile ../workflow/Snakefile --show-failed-logs
else
	SNAKEMAKE_PARAM_DIR =
endif

CONDA_DIR     = $(shell grep "^conda_dir:" config.yaml | awk '{print $$2}')
ifeq ($(CONDA_DIR),)
    $(error 'conda_dir' not found in the configuration)
endif

USE_CONDA     = $(shell grep "^use_conda:" config.yaml | awk '{print $$2}')
ifeq ($(USE_CONDA),)
    $(error 'use_conda' not found in the configuration)
endif

CONDA_DIR_ADJ = $(TOPLEVEL_DIR)/$(CONDA_DIR)

ifeq ($(strip $(USE_CONDA)),True)
	CONDA_PARAMS  =	--use-conda --conda-prefix="$(CONDA_DIR_ADJ)"
endif


#############
# FOR USERS #
#############

all: ## Run everything
	snakemake -j $(CONDA_PARAMS) -p --rerun-incomplete $(SNAKEMAKE_PARAM_DIR)

help: ## Print help message
	@echo "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\1:\2/' | column -c2 -t -s : | sort)"

conda: ## Create the conda environments
	snakemake -p -j -d .test $(CONDA_PARAMS) --conda-create-envs-only

clean: ## Clean
	rm -fvr {.,.test}/{intermediate,output}/*

cleanall: clean ## Clean all

rmstats: ## Remove stats
	find output .test/output -name 'stats*.tsv' | xargs rm -fv
	find output .test/output -name '*.summary' | xargs rm -fv


##################
# FOR DEVELOPERS #
##################

test: ## Run the workflow on test data
	#snakemake -d .test -j $(CONDA_PARAMS) -p --show-failed-logs --rerun-incomplete
	$(MAKE) -C .test TOPLEVEL_DIR=..

testreport: ## Create html report for the test
	$(MAKE) -C .test TOPLEVEL_DIR=.. report
	#snakemake -d .test -j 1 $(CONDA_PARAMS) -p --show-failed-logs --report test_report.html

report: ## Create html report
	snakemake $(CONDA_PARAMS) --report report.html $(SNAKEMAKE_PARAM_DIR)

format: ## Reformat all source code (developers)
	snakefmt workflow
	yapf -i --recursive workflow

checkformat: ## Check source code format (developers)
	snakefmt --check workflow
	yapf --diff --recursive workflow

edit:
	nvim -p workflow/Snakefile workflow/rules/*.smk
