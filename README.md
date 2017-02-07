# cvbioinfo2017
Scripts de análises no Qiime v.1.9.1 construído por Wellington Pine Omori e apresentado como sugestão de pipeline para análises de diversidade de comunidades bacterianas usando o gene 16S ribosomal RNA. Este script foi construído usando Shell Script e tem como objetivo facilitar a introdução de interessados em iniciar análises básicas de bioinformatica que envolvam estudos de microbiomas. Este material faz parte do II Curso de Verão em Bioinformática que foi realizado na Faculdade de Ciências Agrárias e Veterinárias (UNESP-FCAV) de Jaboticabal-SP dutante 30/01/2017 à 10/02/17. Para outras informações: http://www.fcav.unesp.br/#!/cvbioinfo/2017/main/.


# Programas usados neste pipeline:

    -Perl v.5.18
    -Python v.2.7.8
    -Usearch v.8.1.1861_i86linux32 (pode ser alterado para o 64 bits no script uparse.sh, linha 68)
    -FastQC v.0.11.3
    -Prinseq-lite v.0.20.4
    -Cutadapt v.1.11
    -FASTX Toolkit v.0.0.14 (no script usa-se somente fasta_formatter)
    -Qiime v.1.9.1
    -bmp-otuName.pl
    -bmp-map2qiime.py

# Linhas que precisam ser alteradas para funcionamento dos scripts em diferentes computadores
-qiime2_testes.sh:

    -Linha 294: informar caminho absoluto do diretório que contém o arquivo no formato fasta contendo as sequências dos adaptadores usado durante o sequenciamento;
    
    -Linha 302: nome do arquivo no formato fasta que contém as sequências de adaptadores usados no sequenciamento;
    
    -Linha 324: caminho absoluto para o arquivo no formato fasta do banco de dados do Ribosomal Database Project (RDP II) (default, pode ser alterado par Greengenes);
    
    -Linha 325: caminho absoluto para o arquivo de taxonomia das sequências do banco de dados do RDP II (default, pode ser alterado para o Greengenes);
    
    -Linha 330: caminho absoluto para o banco de dados Silva pré-alinhado (opcional);
    
    -Linha 331: caminho absoluto para o banco de dados do Greengenes pré-alinhado (default, usado pelo PyNAST durante o alinhamento);
    
    -Linha 521: caso o script uparse.sh não esteja no PATH, informe o caminho absoluto/relativo para este script.
    
    
-uparse.sh:

    -Linha 85: caminho absoluto para o arquivo do banco de dados gold.fa (usado para remoção de quimeras pelo Uchime após execução do protocolo UPARSE);
    
    -Linha 88: caminho absoluto para o executável do Usearch (default é a versão 64 bits, pode ser alterado para a versão livre de 32 bits).
    
    
# Pedindo ajuda ao programa    
    
    ./qiime2_testes.sh -h
    
    OU
    
    ./qiime2_testes.sh --help


# Sintaxe de uso do programa para dados single-read:

    ./qiime2_testes.sh fastq_raw/ qiime_analysis_test primers.fa --single 400

# ONDE:

    -"./" equivale ao diretório corrente/atual onde está o script ./qiime2_testes.sh (caso no esteja no PATH);
    -fastq_raw: caminho absoluto/relativo para o diretório onde se encontram os arquivos no formato fastq que serão trimados e analisados com o script;
    -qiime_analysis_test: caminho absoluto/relativo para o diretório onde serão gerados os resultados processados pelo QIIME;
    -primers.fa: caminho absoluto para o arquivo no formato fasta contendo as sequências dos primers usados na PCR;
    -"-- single": string para informar ao programa que os dados de entrada são single-read. A opção --paired ainda não está devidamente configurada;
    -400: tamanho do amplicons obtidos na PCR (sem adaptadores, primers ou outas estruturas que não o amplicon).
    
OBS: para executar o pipeline, no diretório corrente/atual deve conter os arquivos primers.fa (nome opcional), map_file.txt e custom_parameters.txt (esses dois devem ser nomeados como estão escritos neta linha). Desde que as linhas dos scripts qiime2_testes.sh e uparse.sh estejam corretamente configuras (Ver "Linhas que precisam ser alteradas para funcionamento dos scripts em diferentes computadores"), basta isto para que o pipeline seja totalmente executado.
Interrupções inesperados do script estão relacionadas a quantidade de dados muito pequeno em algumas amostras, o que causa discrepâncias nas análises de alfa- e beta-diversidade (principlamente PCoA). Isto ocorre devido a etapa de normalização por profundidade (usando rarefação, segundo nossos testes este método foi mais sensível do que DESeq2 e CSS) entre as amostras considerando a menor amostra.


# Configurando o computador para execução do pipeline

Fazer download dos scripts:

$wget https://github.com/wpomori/cvbioinfo2017/archive/master.zip && unzip master.zip && rm -f master.zip


Dando permissão de execução para os arquivos executáveis:

$chmod 755 cvbioinfo2017-master/qiime2_testes.sh
$chmod 755 cvbioinfo2017-master/uparse.sh

OBS: se preferir, use permissão de superusuário para mover os scripts para o PATH (pode ser em /usr/bin ou /usr/local/bin).
