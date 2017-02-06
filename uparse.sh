#!/bin/bash

# Pipeline do UPARSE derivado de:
# https://stamps.mbl.edu/images/0/0b/STAMPS2015_Huse_UParse.pdf

# USEARCH Suite and UPARSE Pipeline
# Susan Huse, Brown University, August 7, 2015

################################    USEARCH   ###################################
#
#  Procura semelhanças entre sua sequência (query) e uma representante no banco
# de dados de sequências referência:
#       GLOBAL: match de todo o comprimento da sequência de entrada (query)
#       LOCAL : ponto (local) de correspondência entre sequências após uma
#               consulta com BLAST
#
#
#       Alta identidade, resultado típico de várias palavras (Adenina,
#       Citosina, Guanina e Timina) em comum:
#
#           Query   ABCDEFGHIJKLMNOPQRSTUVWXYZ
#                   ||||||| || |||| |||||| | |
#           Target  ABCDEFGAIJBLMNOCQRSTUVDXEZ
#                   ___        ___  ___
#                    ___        ___  ___
#                      ___             ___
#                       ___      3MERS EM COMUM
#
#  1) O banco de dados de k-mers é indexado (*.udb);
#  2) O index de k-mer usado prioriza os matches com as sequências referências;
#  3) Para o alinhamento da query e os melhores matches, calcula-se a
#     identidade (mesma %)/total
#  4) Se o ID dentro do threshold = hit, então = rejeitado;
#  5) Parar quando ocorrer muitas rejeições
#
#################################################################################

################################    UPARSE   ####################################
#
#  Porquê usar UPARSE?: O pipeline UPARSE está bem otimizado para reduzir OTUs
#                       suspeitas, minimizando o efeito de erros de
#                       sequenciamento e OTUs muito infladas, ajudando a
#                       refletir a realidade da estrutura e diversidade das
#                       comunidades microbianas.
#
#                       UPARSE reduz dramaticamente o número de OTUs falsas
#                       durante análises de dados de sequenciamento com a
#                       comunidade MOCK.
#
#                       UPARSE PIPELINE
#
#                           /=========\                /======\
#   _____________________   ||  _____||_______________ ||  ___________________
#  / FILTRO DE QUALIDADE \  || /      ABUNDÂNCIA      \|| /   Clusterização   \
#  |                     |  || |                      ||| |                   |
#  | -Remoção de barcode |  || | -Dereplicção         ||| | -Clusterizar OTU  |
#  |                     |  || |  (-derep_fulllength) ||| |  (-cluster_otus)  |
#  | -Filtragem de erros |  || |                      ||| |                   |
#  |                     |  || | -Abundance Sort      ||| | -Filtrar Quimera  |
#  |  máximos esperados  |  || |  (-sortbysize)       ||| |  (-uchime_ref)    |
#  |                     |  || |                      ||| |                   |
#  | -Juntar dados       |  || | -Filtrar Singleton   ||| | -Mapear Reads na  |
#  |  paired-end         |  || |  (-minsize 2)        ||| |  nas UTOs         |
#  \_____________________/  || \______________________/|| |  (-usearch_global)|
#            ||             ||           ||            || |                   |
#            \===============/           \==============/ | -OTU table        |
#                                                         |  (uc2otutab.py)   |
#                                                         \__________________/
#
#  Ver este site para aprender a rodar melhor o UPARSE: 
#  http://drive5.com/usearch/manual/uparse_cmds.html
#
################################################################################

################################# Variáveis ####################################

# Diretório atual
base_dir="."

# Caminho onde serão criados os arquivos concatenados trimados por outros
# programas (Scythe, Cutadapt e Prinseq)
conc="${base_dir}/trim_data/combined_fasta"

# Caminho para o banco de dados gold.fa - remoção de quimeras
gold="/usr/local/bioinfo/microbiomeutil-r20110519/RESOURCES/rRNA16S.gold.fasta"

# Caminho para usearch 32bits
usearch="/usr/local/bin/usearch8.1.1756_i86linux64"

# Caminho para programa fasta_formatter
fast_fm=$(which fasta_formatter)

# Caminho para scripts BMP
name=$(which bmp-otuName.pl)

###############################################################################

############################## SCRIPT PIPELINE ################################

echo "      Derreplicação ... "
# Dereplicação
${usearch} -derep_fulllength ${conc}/all.fna -fastaout ${conc}/all_derep.fa -sizeout

echo "      Removendo singletons ... "
# Removendo singletons antes de criar as OTUs representativas
${usearch} -sortbysize ${conc}/all_derep.fa -fastaout ${conc}/all_sorted_min.fa -minsize 2

echo "      Clusterização de novo ... "
# Clusterização de novo
${usearch} -cluster_otus ${conc}/all_sorted_min.fa -otus ${conc}/all_otu_reps_init.fa -uc ${conc}/all_otu_reps_init.up -relabel OTU_ -sizein -sizeout

echo "      Removendo quimeras usando banco de dados referência ... "
# Remoção de quimera baseado em referência
${usearch} -uchime_ref ${conc}/all_otu_reps_init.fa -db ${gold} -strand plus -nonchimeras ${conc}/all_otu_reps.fa


${fast_fm} -i ${conc}/all_otu_reps.fa -o ${conc}/all_otu_reps_formated.fa

# Download scripts BMP: https://github.com/vpylro/BMP
perl ${name} -i ${conc}/all_otu_reps_formated.fa -o ${conc}/otus.fa 


echo "      Mapeando as reads contra as OTUs representativas ... "
# Mapear as reads contra as OTUs representativas
${usearch} -usearch_global ${conc}/all.fna -db ${conc}/otus.fa -strand plus -id 0.80 -uc ${conc}/all_otu_map.uc

echo "Finalizando pipeline UPARSE ... "
