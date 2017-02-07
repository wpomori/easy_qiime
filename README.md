# cvbioinfo2017
Scripts análises Qiime v.1.0 Omori

#                (EM CONSTRUÇÃO. ÚLTIMA ATUALIZAÇÃO 06/02/2017 ÀS 17:45H)

Pipeline de análises no QIIME v.1.9.1 construído em Shell Script.
Programas usados neste pipeline:

\t-Perl v.5.18
\t-Python v.2.7.8
\t-Usearch v.8.1.1861_i86linux32 (pode ser alterado para o 64 bits no script uparse.sh, linha 68)
\t-FastQC v.0.11.3
\t-Prinseq-lite v.0.20.4
\t-Cutadapt v.1.11
\t-Qiime v.1.9.1





Sintaxe para ajuda: ./qiime2_testes.sh -h OU ./qiime2_testes.sh --help

Sintaxe uso com dados single-read: ./qiime2_testes.sh fastq_raw/ qiime_analysis_test primers.fa --single 400


ONDE: "./" equivale a diretório corrente/atual onde está o script ./qiime2_testes.sh


FAZENDO DOWNLOAD DOS ARQUIVOS NO SEU DIRETÓRIO DE ANÁLISE:

$wget https://github.com/wpomori/cvbioinfo2017/archive/master.zip && unzip master.zip && rm -f master.zip


Dando perMissão de execução para os arquivos:
chmod 755 cvbioinfo2017-master/qiime2_testes.sh
chmod 755 cvbioinfo2017-master/uparse.sh
