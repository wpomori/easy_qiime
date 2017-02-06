#!/bin/bash
############ [ Ficha Técnica: ] ##################################################
#										 #
# qiime2_testes.sh - versão 1.0							 #
#										 #
# Escrito por: Wellington Pine Omori						 #
#										 #
# Criado em: 10/01/2017								 #
#										 #
# Última Atualização: 02/02/2017						 #
#										 #
#										 #
############ [ Sintaxe: ] ########################################################
#										 #
# ./qiime2_testes.sh ../amostragem_fastq ./out ./primers.fa --single 150	 #
#										 #
#										 #
############ [ Descrição: ] ######################################################
#										 #
# Programa semiautomático escrito em shell-script para trimagem de dados single- #
# read e paired-end usando Cutadapt e Prinseq. Gráficos de qualidade para dados  #
# brutos trimados são gerados por FastQC.					 #
#										 #
#										 #
############ [ Legenda dos comentários: ] ########################################
#										 #
# - Comentários agrupados por parenteses "#( comentário )...#" , servem		 #
#   para especificar o agrupamento de comandos, por exemplo: variáveis,		 #
#   testes, funções, cases...etc.						 #
#										 #
#										 #
# - Comentários agrupados por chaves "#[ comentário ]...#", servem para		 #
#   mostrar o que um trecho do código faz.					 #
#										 #
#										 #
############ [ Evolução: ] #######################################################
#										 #
# Versão 0.1 - Simplesmente gerava as análises básicas do Qiime ( Identificações #
# taxonômicas com RDP, tabela de OTUs, PCoA 2 e 3D, índices de diversidade	 #
# (Simpson, Shannon, Equitabilidade) e riqueza (Chao1, Ace, Espécies Observadas) #
#										 #
#										 #
# Versão 1.0 - Além de deixar o programa amigável a várias versões de Shell e	 #
# plataformas Linux (), foi melhorado o modo de declarar as variáveis de	 #
# arquivos e programas.								 #
#										 #
#										 #
############ [ Observações: ] ####################################################
#										 #
# Script versão 1.0 feito para o II Curso de Verão de Bioinformática,		 #
# Janeiro-Fevereiro de 2017, FCAV-UNESP de Jaboticabal-SP.			 #
# Terminado dia 10/01/2017 ás 15:52h. Parte deste shell script foi baseado	 #
# em um script para QIIME da distribuição Biolinux 8 (UBUNTU 14.04 LTS,		 #
# http://environmentalomics.org/bio-linux/). 					 #
#										 #
# Testado em Ubuntu 12.04 LTS, Ubuntu 14.04 LTS e CentoS 7.			 #
# Testado em Shell bash version 4.3.11(1)-release (GNU bash			 #
# (x86_64-pc-linux-gnu), em Shell bash version 4.2.46(1)-release (GNU bash,	 #
# (x86_64-redhat-linux-gnu)), em Shell bash version 4.2.10(1)-release		 #
# (GNU bash, (x86_64-pc-linux-gnu)) e zsh version 5.0.2 (x86_64-pc-linux-gnu).	 #
#										 #
# Confira todos os scripts de QIIME em: http://qiime.org/scripts/ 		 #
#										 #
#										 #
##################################################################################

#( Texto que será impresso no terminal do usuário quando pedido ajuda )..........#
#( Texto que será impresso caso o usuário peça ajuda ao programa )...............#

	data="02/02/2017"
	version="1.0"

	#[ Variável que recebe o pedido de ajuda do teclado ]....................#
	help="$1"

        if [ "${help}" = --help ] || [ "${help}" = \-h ]
        then
		clear
		echo "${data}"
                echo "$0 versão ${version}"
		echo ""
		echo " Script versão beta desenvolvido como material de aula teórica e prática"
		echo "do II Curso de Verão de Bioinformática realizado na UNESP/FCAV na cidade"
		echo "de Jaboticabal-SP de 30/01/2017 à 10/02/2017."
		echo ""
		echo " Este script foi desenvolvido por Wellington Pine Omori e seu uso é de"
		echo "inteira responsabilidade do usuário e está sobre os termos de licença"
		echo "do projeto GNU (GNU General Public License)."
		echo ""
		echo "                        e-mail: wpomori@gmail.com"
		echo ""
		echo " Este script deve ser usado após as etapas de trimagem dos dados de"
		echo "sequenciamento (Illumina MiSeq, Ion Torrent PGM/Próton, etc) e o arquivo"
		echo "single-read deverá estar no formato fastq. Modo de uso:"
		echo ""
		echo ""
		echo "        ./qiime2_testes.sh <fq> <out> <pr> <s/g> <lg> <lt>"
#		echo "		./qiime2_testes.sh ../amostragem_fastq ./out ./primers.fa --single 150"
		echo ""
		echo "	Onde:"
		echo "	     <fq>: diretório que contém os dados fastq single-read OU "
		echo "		   paired-end (brutos)."
		echo ""
		echo "	     <out>: nome diretório de saída das análises do QIIME."
		echo ""
		echo "	     <pr>: caminho onde se encontra o arquivo fasta contendo "
		echo "	           as sequências de nucleotídeos (IUPCA) dos primers."
		echo ""
		echo "	     <s/g>: informar se os dados são single-read ou paired-end."
		echo ""
		echo "	     <lg>: comprimento do amplicon."
		echo ""
		echo "	     <lt>: se os dados forem paired-end, informe o caminho para"
		echo "		   o arquivo de lista contendo os nomes dos arquivos "
		echo "		   sem a string *R1*/*R2*. Exemplo: os arquivos tem"
		echo "		   o nome de teste.R1.fq e teste.R2.fq usar somente"
		echo "		   o primeiro nome:"
		echo ""
		echo "			teste."
		echo "			teste."
		echo ""
		echo ""
		echo "        Orientação de uso: Certifíque-se do caminho absoluto/relativo para"
		echo "                           os arquivos single-read (fasta) e se os arquivos"
		echo "                           map_file.txt e custom_parameters.txt estão no"
		echo "                           diretório corrente de análise."
		echo ""
		##sleep 1;
	exit;
	fi;


#( Texto que será impresso no terminal caso o usuário não informe nenhum ).......#
#( diretório de entrada e saída e dados. ).......................................#

	#[ Quantidade de processadores disponíveis na máquina ]..................#
	proc_number=$(grep -c '^processor' /proc/cpuinfo)

	#[ Utilizar 90% dos processadores ]......................................#
	proc_percent=90

	#[ Número de threads disponíveis para os processos ].....................#
	#[ Seria mais fácil determinar que o número vai de 0-1 para threads e ]..#
	#[ usar a linha a seguir ]...............................................#
	#[ bc sem o l ao dividir por 1 ele trunca o valor decimal, deixando-o ]..#
	#[ somente a parte inteira ].............................................#
	#[ threads=$( echo "(${proc_number} * 0.9)/1" | bc ) ]...................#
	#[ Mas só para deixar um pouco mais complicado, além disso, ]............#
	#[ arredondando o valor e não truncando-o ]..............................#
	threads=$( echo "(${proc_number} * (${proc_percent}/100))" | bc -l | xargs printf "%.0f" )

	#[ Sintaxe de uso do programa ]..........................................#
	sintaxe_prog="<dir_fq> <out> <primers> <single/paired> <mean_leng_reads>"

	#[ Caminho relativo para o diretório contendo os dados single- ].........#
	#[ end trimados a priori ]...............................................#
	dir_trim_data="$1"

	#[ Caminho relativo para o diretório onde serão armazenados os ].........#
	#[ dados processados ]...................................................#
	proc="$2"

	#[ Arquivo tipo fasta contendo uma lista de primers para Cutadapt ]......#
	primers="$3"

	#[ Informando se os dados são single ou paired-end ].....................#
	data="$4"

	#[ Comprimento mínimo e máximo das reads ]...............................#
	comprimento_read=$5
	calc="${comprimento_read}*30/100"
	calc2="${comprimento_read} + 50"
	#https://www.vivaolinux.com.br/topico/Sed-Awk-ER-Manipulacao-de-Textos-Strings/Raiz-quadrada-em-ShellScript/
	#$var = `echo "4 ^ 2" | bc`
	porc_len=`echo "${comprimento_read} - ${calc}" | bc`
	maior_len=`echo "${calc2}" | bc`
	##echo "${porc_len}"
	##echo "${maior_len}"
	##sleep 2;

	#[ Caminho para arquivo lista das sequências paired-end ]................#
	#[ O Pandaseq usa este arquivo ].........................................#
	list="$6"



##	if [[ "$#" < 5 ]]; then
##		clear
##		echo ""
##		echo "Por favor, informe o diretório que contém os arquivos fasta (single-read ou"
##		echo "concatenados com Pandaseq ou similar) e o diretório onde serão enviados"
##		echo "os dados processados, respectivamente. Os dados devem estar trimados."
##		echo ""
##		echo ""
##		echo "Para maiores informações, consulte a ajuda do programa."
##		echo "		$0 -h"
##		echo "	OU"
##		echo "		$0 --help"
##		echo ""
##		echo "Visite também: http://qiime.org/"
##		echo ""
##		echo ""
##	exit;
##	fi;


#( Verificando se a variável $QIIME_CONFIG está ativa. Ver mais em: )............#
#( http://qiime.org/install/qiime_config.html )..................................#

	#[ Quit on erros ].......................................................#
	set -e
		clear
		echo "Total de ${threads} processadores disponíveis!!!"
		echo "Sequências menores que ${porc_len} pb serão eliminadas ... "
		echo "Sequências maiores que ${maior_len} pb serão eliminadas ... "
		echo ""
		echo -n "Executando em: ";
			pwd
		echo ""
	sleep 1;


#( Verificando se o diretório "trim_data" está criado. Em caso negativo, ).......#
#( ele será criado ).............................................................#

	#[ Diretório atual ].....................................................#
	base_dir="."

	#[ input = diretório trim_data, para onde serão movidos os arquivos ]....#
	#[ fastq, map_file.txt e custom_parameters.txt ].........................#
	input="${base_dir}/trim_data"

	#[ Página 223 livro Programação Shell Linux, Cap. Liberdade ]............#
	#[ Condicional, autor Júlio Cezar Nevess, 10ª edição, 2015 ].............#
	#[ Verificando a existência do diretório ${input}, caso ele não ]........#
	#[ exista, o shell o criará ]............................................#

	if [ ! -d "${input}" ]; then
		mkdir ${input} && echo "Criando trim_data ( ${input} ) ... "
	  	echo ""
		sleep 2;
	fi;


#( Variáveis que indicam a localização de arquivos e diretórios usados: )........#
#( pelo QIIME. Dependendo da configuração de seu sistema, elas podem ser ).......#
#( alteradas )...................................................................#

	#[ Caminho relativo para o arquivo map_file.txt ].......................#
	map="${base_dir}/trim_data/map_file.txt"

	#[ Caminho relativo para o arquivo map_file.txt ].......................#
	cust="${base_dir}/trim_data/custom_parameters.txt"

	#[ Caminho relativo para diretório contendo os dados trimados ].........#
	trim="${base_dir}/trim_data/fastq_fna_dir"

	#[ Caminho para o diretório onde serão armazenados os dados para ]......#
	#[ bactérias ]..........................................................#
	bact="${proc}/bact"

	#[ Caminho relativo para o diretório onde serão registrados os ]........#
	#[ logs de erro e mensagens de execução dos scripts do QIIME ]..........#
	logs="${base_dir}/logs"

	#[ Caminho relativo para o arquivo de log onde será registrado ]........#
	#[ todas as etapas de execução dos scripts do QIIME ]...................#

	fix=`date +%d_%m_%Y%%H:%M:%S`
	log="${base_dir}/logs/qiime_${fix}.log"
	#log="${base_dir}/logs/qiime`date +%Y-%m-%d`.log"

	#[ Diretório final para onde as análises trimagem serão movidas ].......#
        final="${base_dir}/proces"

	#[ graph1_out - Caminho para o diretório onde serão criados ]...........#
	#[ os gráficos de qualidade dos dados brutos por FastQC ]...............#
	graph1_out="${final}/graphs/qualidade_raw"

	#[ cutadapt_out - Caminho para o diretório de saída dos dados ].........#
	#[ processados por Cutadapt ]...........................................#
	cutadapt_out="${final}/cutadapt"

	#[ prinseq_out - Caminho para o diretório de saída dos dados ]..........#
	#[ processados por Prinseq ]............................................#
	prinseq_out="${final}/prinseq"

	#[ graph2_out - Caminho para o diretório onde FastQC irá criar ]........#
	#[ os gráficos de qualidade dos dados trimados por Cutadapt e ].........#
	#[ Prinseq ]............................................................#
	graph2_out="${final}/graphs/qualidade_trim"

	#[ Diretório base onde estão os adaptadores ]...........................#
	adapt_barc_primer_path="/data/cvbioinfo/refs"

	#[ cutadapt_adapters_5p_R1_path - caminho para o arquivo contendo ].....#
	#[ os adaptadores 5p para R1 ]..........................................#
	#[ cutadapt_adapters_5p_R2_path - caminho para o arquivo contendo ].....#
	#[ os adaptadores 5p para R2 ]..........................................#
	#[ (de acordo com o protocolo/tecnologia de sequenciamento) para o ]....#
	#[ programa scythe ]....................................................#
	cutadapt_adapters_5p_path="${adapt_barc_primer_path}/nextera_illumina_5p_adapt_R1.fa"

	#[ Caminho para os arquivos de mapeamento e de parâmetros customizados ]#
	ma="${base_cir}/map_file.txt"
	cus="${base_dir}/custom_parameters.txt"

	#[ Caminho para o diretório das análises do microbioma core ]...........#
	core="${base_dir}/${proc}/bact/core_microbiome"

	#[ Caminho para os índices de diversidade e riqueza ]...................#
	index="${proc}/bact/index_diversity"

	#[ Diretório onde serão criados os arquivos processados por ]...........#
	#[ Pandaseq ]...........................................................#
	pandaseq_out="${final}/pandaseq"

	#[ Caminho relativo onde serão armazenados os arquivos trimados ].......#
	#[ após a concatenação ]................................................#
	conc="${base_dir}/trim_data/combined_fasta"

	#[ Caminho absoluto para o banco de dados do RDP II versão de 14 ]......#
	#[ de 03/2015. ]........................................................#
	rdp_fas="/data/db/mothur/rdp/trainset14_032015.rdp.fasta"
	rdp_tax="/data/db/mothur/rdp/trainset14_032015.rdp.tax"

	#[ Caminho absoluto para o banco de dados do SILVA verssão 119 ]........#
	#[ (o mais atual até 27/04/2016. Visite: ]..............................#
	#[ https://www.arb-silva.de/documentation/release-119/) ]...............#
	silva="/data/db/mothur/silva/silva.nr_v119.align"
	green_aln="/usr/lib/python2.7/site-packages/qiime_test_data/align_seqs/core_set_aligned.fasta.imputed"

	#[ Caminho relativo para o diretório onde serão armazenados os ]........#
	#[ dados de beta diversidade ]..........................................#
	beta="${base_dir}/${proc}/bact/beta_even"

	#[ Caminho relativo para o diretório onde serão armazenados os ]........#
	#[ dados da alfa diversidade ]..........................................#
	alfa="${base_dir}/${proc}/bact/alpha"

	#[ Caminho relativo para o diretório onde serão armazenados os ]........#
	#[ dados da análise Jackkniffe ]........................................#
	jack="${base_dir}/${proc}/bact/jack"

	#[ Caminho relativo para o diretório que contém os arquivos OTU ].......#
	#[ table ]..............................................................#
	otu_table="${base_dir}/${proc}/final_otu_tables"

	#[ Caminho para diretório rep_set ].....................................#
	rep="${conc}/rep_set"

	#[ Caminho para o diretório dos índices de diversidade e riqueza ]......#
	index="${base_dir}/${proc}/bact/index_diversity"



#( Verificando se os arquivos de entrada estão no formato *.fastq. Em caso ).....#
#( negativo, uma mensagem de erro será impressa )................................#

	#[ Verificando se os arquivos de entrada estão com a extenção *.fasta ]..#
	#[ Em caso negativo, uma mensagem de aviso será impressa ]...............#

	if [ ! `ls ${dir_trim_data}/*.fastq` ] &> /dev/null ; then
		echo "O programa espera arquivos com extenção *.fastq. Por favor,"
		echo "  verifique a existência de seus arquivos no diretório     "
		echo "  ${dir_trim_data} ou altere a extenção de seus arquivos!!!"
		echo ""
		echo "ABORTANDO PIPELINE ---------------------------------------> "
		echo ""
		echo "Sintaxe correta: $0 ${sintaxe_prog}"
		echo "	Verifique a ajuda do programa para maiores informações!"
		echo ""
		sleep 1;
	exit;
	fi;


#[ Verificando se os arquivos map_file.txt e custom_parameters.txt estão no ]....#
#[ diretório atual. Em caso negativo, uma mensagem de erro será impressa ].......#

##	if [ ! -f "${cus}" ] && [ ! -f "${ma}" ]; then
##		echo " Arquivos ${cust} e ${map} não encontrados. "
##		#Visite http://qiime.org/documentation/file_formats.html#metadata-mapping-files
##		#e http://qiime.org/documentation/qiime_parameters_files.html para maiores informações.
##		sleep 1;
##		exit;

		if [ -f ${input}/map_file.txt -a -f ${input}/custom_parameters.txt ]; then
			echo "Arquivos ${input}/map_file.txt e ${input}/custom_parameters.txt estão no diretório correto ... ABORTANDO ... "
		elif [ ! -f "${cus}" ] && [ ! -f "${ma}" ]; then
			echo " Arquivos ${cust} e ${map} não encontrados. "
		sleep 1;
		exit;
	fi;


#[ Removendo diretórios/subdiretórios usados pelo pipeline em outras ]...........#
#[ execuções ]...................................................................#

	echo ""
	echo "Removendo diretórios antigos ... "
	  echo " ( ${base_dir}/${proc} ) ... "
	  echo " ( ${logs} ) ... "
	  echo " ( ${conc} ) ... "
	  echo " ( ${alfa} ) ... "
	  echo " ( ${jack} ) ... "
	  echo " ( ${beta} ) ... "
	  echo ""
	  ##rm -rf ${proc} ${logs} ${conc} ${alfa} ${jack} ${beta} ${trim}
          #rm -rf ${rep}/rep_set.tre
	  #rm -rf ${conc}/adiv_chao1_pd.txt
          #rm -rf ${input}/map_file.txt
          #rm -rf ${input}/custom_parameters.txt
          #rm -rf ${proc}/bact/jack
          #rm -rf ${proc}/bact/beta_even
          #rm -rf ${proc}/bact/ucrC97
          #rm -rf ${proc}/bact/otu_table.biom
	  #rm -rf ${alfa}/PD_dmax_parametric
	  #rm -rf ${alfa}/chao1_parametric
	  #rm -rf ${alfa}/observed_otus_parametric
	  #rm -rf ${alfa}/alpha_curv_raref
	  #rm -rf ${alfa}/alpha_curv_raref
	  #rm -rf ${alfa}/ANOVA_group_signif.txt
	sleep 1;


#[ Criando diretórios/subdiretórios usados pelo pipeline ].......................#

	echo ""
	echo "Criando diretórios onde serão processados os dados pelos programas ... "
	  echo " ${graph1_out} ... "
	  echo " ${cutadapt_out} ... "
	  echo " ${prinseq_out} ... "
	  echo " ${graph2_out} ... "
	  echo " ${otu_table} ... "
	  echo " ${final} ... "
	  echo " ${index} ... "
	  echo " ${core} ... "
	  echo " ${logs} ... "
	  echo " ${trim} ... "
	echo ""
	  if [ ! -d ${graph1_out} ]; then
	  mkdir -p ${graph1_out}
	  #else
		#echo "123"
	  fi;
	  if [ ! -d ${cutadapt_out} ]; then
	  mkdir -p ${cutadapt_out}
	  #else
		#echo "456"
	  fi;
	  if [ ! -d ${prinseq_out} ]; then
	  mkdir -p ${prinseq_out}
	  #else
		#echo "789"
	  fi;
	  if [ ! -d ${graph2_out} ]; then
	  mkdir -p ${graph2_out}
	  #else
		#echo "101112"
	  fi;
	  if [ ! -d ${otu_table} ]; then
	  mkdir -p ${otu_table}
	  #else
		#echo "131415"
	  fi;
	  if [ ! -d ${final} ]; then
	  mkdir -p ${final}
	  #else
		#echo "161718"
	  fi;
	  if [ ! -d ${index} ]; then
	  mkdir -p ${index}
	  #else
		#echo "192021"
	  fi;
	  if [ ! -d ${core} ]; then
	  mkdir -p ${core}
	  #else
		#echo "222324"
	  fi;
	  if [ ! -d ${logs} ]; then
	  mkdir -p ${logs}
	  #else
		#echo "232425"
	  fi;
	  if [ ! -d ${trim} ]; then
	  mkdir -p ${trim}
	  #else
		#echo "262728"
	  fi;


#( Identificando o caminho absoluto para os programas do QIIME ).................#

	panda=`which pandaseq`
	prins=`which prinseq-lite.pl`
	cut=`which cutadapt`
	fastqc=`which fastqc`
        validate=`which validate_mapping_file.py`
        label=`which add_qiime_labels.py`
        taxonomy=`which assign_taxonomy.py`
        align=`which align_seqs.py`
        filter=`which filter_alignment.py`
        phylogeny=`which make_phylogeny.py`
        table=`which make_otu_table.py`
        filter_taxa=`which filter_taxa_from_otu_table.py`
        m_rarefaction=`which multiple_rarefactions.py`
        alpha_div=`which alpha_diversity.py`
        collate=`which collate_alpha.py`
        rarefaction_plot=`which make_rarefaction_plots.py`
        sort_biom=`which sort_otu_table.py`
        beta_div=`which beta_diversity.py`
        p_coordinates=`which principal_coordinates.py`
        m_emperor=`which make_emperor.py`
        m_plots=`which make_2d_plots.py`
        sum_tx=`which summarize_taxa.py`
        plot_tx_sum=`which plot_taxa_summary.py`
        alpha_div=`which alpha_diversity.py`
        c_core_mic=`which compute_core_microbiome.py`
	uparse=`which uparse.sh`
	bmp_map=`which bmp-map2qiime.py`
##	bmp_map="/home/softwares/BMP-master/bmp-map2qiime.py"


#( Criando arquivo de log dos programas em qiime.log )...........................#

        echo ""
        echo "Criando arquivo de log dos programas QIIME!!!"
        echo "Iniciado em: `date +%d/%m/%Y-%H:%M:%S` ... "
        inicio="`date +%d/%m/%Y-%H:%M:%S`"
        echo ""
        touch ${log}
        echo ${inicio} >> ${log}
        echo "" >> ${log}
        echo "#-------------------------------------------------------------#" >> ${log}
        echo "#                      INÍCIO ANÁLISES QIIME                   " >> ${log}
        echo "#-------------------------------------------------------------#" >> ${log}
        echo "---------------------                     ---------------------" >> ${log}
        echo "---------------------                     ---------------------" >> ${log}
        echo "" >> ${log}


#( Pipeline de trimagem de dados single-read com Cutadapt e Prinseq )............#
#( Gráficos gerados com FastQC ).................................................#

	if [ "${data}" = --single ]; then
		sing="single-read"

		echo ""
		echo "Dados tipo ${sing} ... "
		echo "Processando arquivos single-read que estão em ${dir_trim_data} ... "
		echo ""

		echo "" >> ${log}
		echo "DADOS TIPO ${sing} ... " >> ${log}
		echo "PROCESSANDO ARQUIVOS single-read QUE ESTÃO EM ${dir_trim_data} ... " >> ${log}
		echo "" >> ${log}

		  #[ Executando o programa FastQC para análise dos dados brutos ]..................#

		  for single in `ls ${dir_trim_data}/*.fastq` ; do
		  fqname=`basename ${single} .fastq`

		  echo ""
		  echo "	Criando gráficos dos dados brutos com FastQC ... "
		  echo "	Passo 1 de 5 ... "
		  echo "	  ${fqname} "
		  echo ""
		  echo "        CRIANDO GRÁFICOS DOS DADOS BRUTOS COM FASTQC ... " >> ${log}
		  echo "        PASSO 1 DE 5 ... " >> ${log}
		  echo "          ${fqname} " >> ${log}
		  echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
		  echo "   PROGRAMA ${fastqc} " >> ${log}

		  if [ ! -f ${graph1_out}/${fqname}_fastqc.html ]; then

		  ${fastqc} -t ${threads} ${single} -o ${graph1_out} &>> ${log}
		  echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
		  echo "" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "" >> ${log}

		  else
		  	echo "Arquivo ${graph1_out}/${fqname}.fastq existente ... ABORTANTO ... "
		  fi;


		  	echo ""
		  	echo "	Trimagem de adaptadores e primers com Cutadapt ... "
		  	echo "	Passo 2 de 5 ... "
		  	echo "	  ${fqname} ... "
		  	echo ""
		  	echo "	TRIMAGEM DE ADAPTADORES E PRIMERS COM CUTADAPT ... " >> ${log}
		  	echo "	PASSO 2 DE 5 ... " >> ${log}
		  	echo "	  ${fqname} ... " >> ${log}
		  	echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
		  	echo "   PROGRAMA ${cut} " >> ${log}

			if [ ! -f ${cutadapt_out}/${fqname}.cutadapt5p.fastq ]; then

		  	${cut} --format=fastq -a file:${cutadapt_adapters_5p_path} -b file:${primers}  \
			--error-rate=0.1 --times=2 --overlap=10 --minimum-length=15                    \
			--output=${cutadapt_out}/${fqname}.cutadapt5p.fastq ${single} &>> ${log}
			echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
			echo "" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "" >> ${log}

			else
				echo "Arquivo ${cutadapt_out}/${fqname}.cutadapt5p.fastq existente ... ABORTANDO ... "
			fi;


			echo ""
			echo "	Executando Prinseq => formato *.fasta ... "
			echo "	Eliminado sequências menores que ${porc_len} pb e maiores que ${maior_len} pb ... "
			echo "	Passo 3 de 5 ... "
			echo "	  ${fqname} ... "
			echo ""
			echo "	EXECUTANDO PRINSEQ => FORMATO *.FASTA ... " >> ${log}
			echo "	ELIMINANDO SEQUÊNCIAS MENORES QUE ${porc_len} PB E MAIORES QUE ${maior_len} PB ... " >> ${log}
			echo "	PASSO 3 DE 5 ... " >> ${log}
			echo "	  ${fqname} ... " >> ${log}
			echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
			echo "   PROGRAMA ${prins} " >> ${log}

			if [ ! -f ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fasta ]; then

			${prins} -verbose -fastq ${cutadapt_out}/${fqname}.cutadapt5p.fastq             \
			-out_format 1 -out_good ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq    \
			-out_bad null -min_len ${porc_len} -max_len ${maior_len} -ns_max_p 25 -noniupac \
			-trim_tail_left 5 -max_qual_score 25 -trim_tail_right 5 -trim_qual_right 25     \
			-trim_qual_type mean -trim_qual_rule lt -trim_qual_window 3 -trim_qual_step 1   \
			-lc_method dust -lc_threshold 30 &>> ${log}					

			echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
			echo "" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "" >> ${log}

			else
				echo "Arquivo ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fasta existente ... ABORTANDO ... "
			fi;


			echo ""
			echo "	Executando Prinseq => formato *.fastq ... "
			echo "	Eliminado sequências menores que ${porc_len} pb e maiores que ${maior_len} pb ... "
			echo "	Passo 4 de 5 ... "
			echo "	  ${fqname} ... "
			echo ""
			echo "	EXECUTANDO PRINSEQ => FORMATO *.FASTQ ... " >> ${log}
			echo "	ELIMINANDO SEQUÊNCIAS MENORES QUE ${porc_len} PB E MAIORES QUE ${maior_len} PB ... " >> ${log}
			echo "	PASSO 4 DE 5 ... " >> ${log}
			echo "	  ${fqname} ... " >> ${log}
			echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
			echo "   PROGRAMA ${prins} " >> ${log}

			if [ ! -f ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fastq ]; then

			${prins} -verbose -fastq ${cutadapt_out}/${fqname}.cutadapt5p.fastq             \
			-out_format 3 -out_good ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq    \
			-out_bad null -min_len ${porc_len} -max_len ${maior_len} -ns_max_p 25 -noniupac \
			-trim_tail_left 5 -max_qual_score 25 -trim_tail_right 5 -trim_qual_right 25     \
			-trim_qual_type mean -trim_qual_rule lt -trim_qual_window 3 -trim_qual_step 1   \
			-lc_method dust -lc_threshold 30 -no_qual_header &>> ${log}
			echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
			echo "" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "---------------------			---------------------" >> ${log}
			echo "" >> ${log}

			else
				echo "Arquivo ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fastq existente ... ABORTANDO ... "
			fi;


		  echo ""
		  echo "	Criando gráficos para dados trimados com FastQC ..."
		  echo "	Passo 5 de 5 ... "
		  echo "	  ${fqname} ... "
		  echo ""
		  echo "	CRIANDO GRÁFICOS PARA DADOS TRIMADOS COM FASTQC ... " >> ${log}
		  echo "	PASSO 5 DE 5 ... " >> ${log}
		  echo "	  ${fqname} ... " >> ${log}
		  echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
		  echo "   PROGRAMA ${fastqc} " >> ${log}

		  if [ ! -f ${graph2_out}/${fqname}.cutadapt5p.filtered.prinseq_fastqc.html ]; then

		  ${fastqc} -o ${graph2_out} -t ${threads} ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fastq &>> ${log}
		  echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
		  echo "" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "" >> ${log}

		  else
			 echo "Arquivo ${graph2_out}/${fqname}.cutadapt5p.filtered.prinseq_fastqc.html existente ... ABORTANDO ... "
		fi;
		done;



		elif [ "${data}" = --paired ]; then
                pair="paired-end"

#		  for listagem in `ls ${base_dir}`
#
#		  if [ -f ${list}/list.txt ]; then
#			  clear
#			  echo "Por favor, informe o arquivo list.txt (contém lista com nomes dos arquivos R1 2 R2) !!!"
#			  echo "Para ajuda, digite:"
#			  echo ""
#			  echo "			qiime1.sh -h"
#			  echo "		     OU"
#			  echo "			qiime1.sh --help"
#			  echo ""
#			  exit;
#		  	else
#			  	echo "Arquivo com ${list}/list.txt identificado!!!!"
#		  fi;


		  if [ ! -d "${pandaseq_out}" ]; then
		          echo "Fazendo o diretório ${pandaseq_out} ... "
		          mkdir -p ${pandaseq_out}
		  fi;

                echo ""
                echo "Dados tipo ${pair} ... "
                echo "Processando arquivos paired-end ${dir_trim_data} ... "
                echo ""

                echo "" >> ${log}
                echo "DADOS TIPO ${pair} ... " >> ${log}
                echo "PROCESSANDO ARQUIVOS PAIRED-END ${dir_trim_data} ... " >> ${log}
                echo "" >> ${log}

		  #[ Executando o programa FastQC para análise dos dados brutos ]..................#

		  for paired in `ls ${dir_trim_data}/*.fastq` ; do
		  fqname=`basename ${paired} .fastq`

		  echo ""
		  echo "        Criando gráficos dos dados brutos com FastQC ... "
		  echo "        Passo 1 de 6 ... "
		  echo "          ${fqname} "
		  echo ""
		  echo "        CRIANDO GRÁFICOS DOS DADOS BRUTOS COM FASTQC ... " >> ${log}
		  echo "        PASSO 1 DE 6 ... " >> ${log}
		  echo "          ${fqname} " >> ${log}
		  echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
		  echo "   PROGRAMA ${fastqc} " >> ${log}
		  ${fastqc} -t ${threads} ${paired} -o ${graph1_out} 1>> ${log}
		  echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
		  echo "" >> ${log}
		  echo "---------------------                   ---------------------" >> ${log}
		  echo "---------------------                   ---------------------" >> ${log}
		  echo "" >> ${log}
		done;


		#( Executando Pandaseq para junção das extremidades 3' do R1 com a 5' do R2 )....#
		#( As configurações foram usadas conforme sugestão a seguir )....................#
		#( As configurações foram usadas conforme sugestão a seguir )....................#
		#https://github.com/edamame-course/2015-tutorials/blob/master/final/2015-06-23-QIIME1.md

		#( use pandaseq to merge reads - requires name list (file <list.txt> in same )...#
		#( folder as this script) of forward and reverse reads to be merged using )......#
		#( the panda-seq program ).......................................................#

		  for file in $(<list.txt); do
		  echo ""
		  echo "	Iniciando junção das 'reads' com Pandaseq ... "
		  echo "	Juntando extremidades 3' R1 ( ${file}R1.fastq ) a 5' do "
		  echo "	R2 ( ${file}R2.fastq ) ... "
		  echo "	Passo 2 de 6 ... "
		  echo "	${fqname} "
		  echo ""
		  echo "	INICIANDO JUNÇÃO DAS 'READS' COM PANDASEQ ... " >> ${log}
		  echo "	JUNTANDO EXTREMIDADES 3' R1 ( ${file}R1.fastq ) a 5' DO " >> ${log}
		  echo "	R2 ( ${file}R2.fastq ) ... " >> ${log}
		  echo "	PASSO 2 DE 6 ... " >> ${log}
		  echo "	${fqname} ... " >> ${log}
		  echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
		  echo "   PROGRAMA ${panda} " >> ${log}
		  #( Para saber mais sobre Pandaseq, visite: ).....................................#
		  # http://neufeldserver.uwaterloo.ca/~apmasell/pandaseq_man1.html
		  ${panda} -f ${dir_trim_data}/${file}R1.fastq -r ${dir_trim_data}/${file}R2.fastq        \
		  -w ${pandaseq_out}/${file}merged.fastq -g ${pandaseq_out}/${file}merged.log             \
		  -o 10 -T ${threads} -B -F -A simple_bayesian
		  echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
		  echo "" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "---------------------			---------------------" >> ${log}
		  echo "" >> ${log}

		done;


			for paired in `ls ${pandaseq_out}/*.fastq`; do
			fqname=`basename ${paired} .fastq`

			echo ""
			echo "  Trimagem de adaptadores e primers com Cutadapt ... "
			echo "  Passo 3 de 6 ... "
			echo "    ${fqname} ... "
			echo ""
			echo "  TRIMAGEM DE ADAPTADORES E PRIMERS COM CUTADAPT ... " >> ${log}
			echo "  PASSO 3 DE 6 ... " >> ${log}
			echo "    ${fqname} ... " >> ${log}
			echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
			echo "   PROGRAMA ${cut} " >> ${log}
			${cut} --format=fastq -a file:${cutadapt_adapters_5p_path} -b file:${primers}  \
			--error-rate=0.1 --times=2 --overlap=10 --minimum-length=15                    \
			--output=${cutadapt_out}/${fqname}.cutadapt5p.fastq ${paired} &>> ${log}
			echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
			echo "" >> ${log}
			echo "---------------------                     ---------------------" >> ${log}
			echo "---------------------                     ---------------------" >> ${log}
			echo "" >> ${log}


			echo ""
			echo "  Executando Prinseq => formato *.fasta ... "
			echo "  Eliminado sequências menores que ${porc_len} pb e maiores que ${maior_len} pb ... "
			echo "  Passo 4 de 6 ... "
			echo "    ${fqname} ... "
			echo ""
			echo "  EXECUTANDO PRINSEQ => FORMATO *.FASTA ... " >> ${log}
			echo "  ELIMINANDO SEQUÊNCIAS MENORES QUE ${porc_len} PB E MAIORES QUE ${maior_len} PB ... " >> ${log}
			echo "  PASSO 4 DE 6 ... " >> ${log}
			echo "    ${fqname} ... " >> ${log}
			echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
			echo "   PROGRAMA ${prins} " >> ${log}
			${prins} -verbose -fastq ${cutadapt_out}/${fqname}.cutadapt5p.fastq            \
			-out_format 1 -out_good ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq   \
			-out_bad null -min_len ${porc_len} -max_len ${maior_len} -ns_max_p 25 -noniupac -trim_tail_left 5    \
			-max_qual_score 25 -trim_tail_right 5 -trim_qual_right 25 -trim_qual_type mean -trim_qual_rule lt \
			-trim_qual_window 3 -trim_qual_step 1 -lc_method dust -lc_threshold 30 &>> ${log}
			echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
			echo "" >> ${log}
			echo "---------------------                     ---------------------" >> ${log}
			echo "---------------------                     ---------------------" >> ${log}
			echo "" >> ${log}


                        echo ""
                        echo "  Executando Prinseq => formato *.fastq ... "
                        echo "  Eliminado sequências menores que ${porc_len} pb e maiores que ${maior_len} pb ... "
                        echo "  Passo 5 de 6 ... "
                        echo "    ${fqname} ... "
                        echo ""
                        echo "  EXECUTANDO PRINSEQ => FORMATO *.FASTQ ... " >> ${log}
                        echo "  ELIMINANDO SEQUÊNCIAS MENORES QUE ${porc_len} PB E MAIORES QUE ${maior_len} PB ... " >> ${log}
                        echo "  PASSO 5 DE 6 ... " >> ${log}
                        echo "    ${fqname} ... " >> ${log}
                        echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
                        echo "   PROGRAMA ${prins} " >> ${log}
                        ${prins} -verbose -fastq ${cutadapt_out}/${fqname}.cutadapt5p.fastq     \
                        -out_format 3 -out_good ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq   \
                        -out_bad null -min_len ${porc_len} -max_len ${maior_len} -ns_max_p 25 -noniupac -trim_tail_left 5    \
                        -max_qual_score 25 -trim_tail_right 5 -trim_qual_right 25 -trim_qual_type mean -trim_qual_rule lt \
                        -trim_qual_window 3 -trim_qual_step 1 -lc_method dust -lc_threshold 30         \
                        -no_qual_header &>> ${log}
                        echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
                        echo "" >> ${log}
                        echo "---------------------                     ---------------------" >> ${log}
                        echo "---------------------                     ---------------------" >> ${log}
                        echo "" >> ${log}


                  echo ""
                  echo "        Criando gráficos para dados trimados com FastQC ..."
                  echo "        Passo 6 de 6 ... "
                  echo "          ${fqname} ... "
                  echo ""
                  echo "        CRIANDO GRÁFICOS PARA DADOS TRIMADOS COM FASTQC ... " >> ${log}
                  echo "        PASSO 6 DE 6 ... " >> ${log}
                  echo "          ${fqname} ... " >> ${log}
                  echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
                  echo "   PROGRAMA ${prins} " >> ${log}
                  ${fastqc} -o ${graph2_out} -t ${threads} ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fastq &>> ${log}
                  echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
                  echo "" >> ${log}
                  echo "---------------------                   ---------------------" >> ${log}
                  echo "---------------------                   ---------------------" >> ${log}
                  echo "" >> ${log}

		done;
		fi;


#( Iniciando o pipeline do QIIME )...............................................#
#( Movendo os arquivos fasta, map_file.txt e custom_parameters.txt para os seus )#
#( respectivos diretórios )......................................................#

	echo ""
	echo "........................ PASSO 01 ........................"
	echo "Movendo os arquivos map_file.txt e custom_parameters para "
	echo " ${input} ..."
	echo ""
	echo "........................ PASSO 01 ........................" >> ${log}
	echo "MOVENDO ARQUIVOS map_file.txt E custom_parameters.txt PARA" >> ${log}
	echo " ${input} ..." >> ${log}
	echo " ${input} ..." >> ${log}
	echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}

#	if [ ! -f ${input}/map_file.txt -a ! -f ${input}/custom_parameters.txt ]; then

	mv ${base_dir}/map_file.txt ${input} 2>> ${log}
	mv ${base_dir}/custom_parameters.txt ${input} 2>> ${log}
	echo "TERMINADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivos ${input}/map_file.txt e ${input}/custom_parameters.txt estão no diretório correto ... ABORTANDO ... "
#	fi;



	echo ""
	echo "........................ PASSO 02 ........................"
	echo "Validando o arquivo map_file.txt ..."
	echo ""
	echo "........................ PASSO 02 ........................" >> ${log}
	echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${validate} " >> ${log}
        #echo "		Quando checado com estas opções, um error irá aparecer. Isto é
        #          	normal. O aviso diz que este tipo de formatação do arquivo só irá
        #          	funcionar com o script qiime add_qiime_labels.py. Para saber mais:
        #          	http://qiime.org/documentation/file_formats.html#metadata-mapping-files "

#	if [ ! -d ${proc}/check_id_output ]; then

	${validate} -m ${map} -o ${proc}/check_id_output -p -b &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
        echo "" >> ${log}
        echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Diretório ${proc}/check_id_output existente ... ABORTANTO ... "
#	fi;


        for fasta in `ls ${prinseq_out}/*.cutadapt5p.filtered.prinseq.fasta`; do
        # fqname - string com o nome do arquivo fasta
        fqname=`basename ${fasta} .cutadapt5p.filtered.prinseq.fasta`
	echo ""
	echo "........................ PASSO 03 ........................"
	echo "Reconhecendo o nome dos arquivos e delimitando a string do nome ... "
        echo "   ${fqname} ..."
	echo ""
	echo "........................ PASSO 03 ........................" >> ${log}
	echo "RECONHECENDO O NOME DOS ARQUIVOS E DELIMITANDO A STRING DO NOME ..." >> ${log}
	echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   ${fqname} ..." >> ${log}

#	if [ ! -f ${trim}/${fqname}.fna ]; then

        cp ${prinseq_out}/${fqname}.cutadapt5p.filtered.prinseq.fasta ${trim}/${fqname}.fna &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${trim}/${fqname}.fna estão no diretório correto ... ABORTANDO ... "
#	fi;
	sleep 1;
done;


	echo ""
	echo "........................ PASSO 04 ........................"
        echo "Adicionando cabeçalho nas sequências (fasta OU fna) recém convertidas ... "
	echo ""
	echo "........................ PASSO 04 ........................" >> ${log}
	echo "Adicionando cabeçalho das sequências fasta (fna) recém convertidos ... " >> ${log}
	echo "INICIADO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${label}" >> ${log}
        #echo "Fazer o arquivo map_file.txt no LibryOffice Calc sem os barcodes e
        #      primerlinker. Salve em CSV, com tabulação. No diretório do arquivo
        #      salvo, retire da extenção .CSV e deixe map_file.txt. Esta estratégia
        #      funciona somente com o comando add_qiime_labels.py. "

#	if [ ! -f ${conc}/combined_seqs.fna ]; then

        ${label} -i ${trim} -m ${map} -c InputFileName -n 1 -o ${conc} &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Aquivo ${conc}/combined_seqs.fna existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 05 ........................"
        echo "Renomeando o arquivo concatenado ( ${conc}/combined_seqs.fna )"
	echo " para ( ${conc}/all.fna ) ... "
	echo ""
	echo "........................ PASSO 05 ........................" >> ${log}
	echo "RENOMEANDO O ARQUIVO CONCATENADO ( ${conc}/combined_seqs.fna ) ..." >> ${log}
	echo "PARA ${conc}/all.fna ) ..." >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}

#	if [ ! -f ${conc}/all.fna ]; then

        mv ${conc}/combined_seqs.fna ${conc}/all.fna 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${conc}/all.fna existente ... ABORTANDO ... "
#	fi;


	    echo ""
	    echo "........................ PASSO 06 ........................"
            echo "Chamando scripts do uparse (via usearch) e uchime para identificação"
	    echo " e remoção de sequências quimeras ... "
	    echo ""
	    echo "........................ PASSO 06 ........................" >> ${log}
	    echo "CHAMANDO SCRIPTS DO UPARSE (VIA USEARCH) E UCHIME PARA IDENTIFICAÇÃO" >> ${log}
	    echo " E REMOÇÃO DE SEQUÊNCIAS QUIMERAS ..." >> ${log}
	    echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	    echo "   PROGRAMA ${uparse}" >> ${log}

#	    if [ ! -f ${conc}/all_otu_map.uc -a ! -f ${conc}/all_derep.fa ]; then

            ${uparse} 1>> ${logs}/uparse_out.txt 2>> ${logs}/uparse_err.txt
	    echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
            echo "" >> ${log}
	    echo "---------------------			---------------------" >> ${log}
	    echo "---------------------			---------------------" >> ${log}
	    echo "" >> ${log}

#	    else
#		echo "Arquivos ${conc}/all_otu_map.uc e ${conc}/all_derep.fa existentes ... ABORTANDO ... "
#	    fi;



	echo ""
	echo "........................ PASSO 07 ........................"
        echo "Classificação taxonômica (97% de confiança) das sequências usando"
	echo " mothur e bancos de dados ${rdp_fas}"
	echo "e ${rdp_tax} ... "
	echo ""
	echo "........................ PASSO 07 ........................" >> ${log}
	echo "CLASSIFICAÇÃO TAXONÔMICA (97% DE CONFIANÇA) DAS SEQUÊNCIAS USANDO" >> ${log}
	echo "MOTHUR E BANCOS DE DADOS ${rdp_fas}" >> ${log}
	echo "E ${rdp_tax} ..." >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${taxonomy}" >> ${log}
        #echo "          Para ver outros bancos de dados que podem ser usados por QIIME,
        #                visite: http://qiime.org/home_static/dataFiles.html "

#	if [ ! -f ${conc}/assign_tax/otus_tax_assignments.txt ]; then

        ${taxonomy} -i ${conc}/otus.fa -m mothur -c 0.80 -r ${rdp_fas} -t ${rdp_tax} -o ${conc}/assign_tax &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${conc}/assign_tax existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 08 ........................"
        #echo "Alinhando as sequências com MUSCLE ... "
	echo "Alinhando as sequências com PyNAST ... "
	echo ""
	echo "........................ PASSO 08 ........................" >> ${log}
	#echo "ALINHANDO AS SEQUÊNCIAS COM MUSCLE ... " >> ${log}
	echo "ALINHANDO AS SEQUÊNCIAS COM PYNAST ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${align}" >> ${log}
        #${align} -m muscle -i ${conc}/otus.fa -o ${rep}/rep_set_align -t ${silva} -p 0.80 &>> ${log}





#	if [ ! -f ${rep}/rep_set_align/otus_failures.fasta ]; then

	${align} -m pynast -i ${conc}/otus.fa -t ${green_aln} -o ${rep}/rep_set_align -p 0.80 &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${rep}/rep_set_align/otus_failures.fasta existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 09 ........................"
        echo "Filtrando o alinhamento ... "
	echo ""
	echo "........................ PASSO 09 ........................" >> ${log}
	echo "FILTRANDO O ALINHAMENTO ..." >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${filter}" >> ${log}


#	if [ ! -d ${rep}/filtered_alignment/otus_aligned_pfiltered.fasta ]; then

        ${filter} -i ${rep}/rep_set_align/otus_aligned.fasta --remove_outliers -o ${rep}/filtered_alignment &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${rep}/filtered_alignment/otus_aligned_pfiltered.fasta existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 10 ........................"
        echo "Construindo a árvore guia ... "
	echo ""
	echo "........................ PASSO 10 ........................" >> ${log}
	echo "CONSTRUINDO A ÁRVORE GUIA ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${phylogeny}" >> ${log}

#	if [ ! -f ${rep}/rep_set.tre ]; then

        ${phylogeny} -i ${rep}/filtered_alignment/otus_aligned_pfiltered.fasta -o ${rep}/rep_set.tre &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${rep}/rep_set.tre existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 11 ........................"
        echo "Convertendo arquivo UC para otu-table.txt ( ${otu_table}/otu_table.txt ) ... "
        echo "Usando ${bmp_map} para converter "
	echo "${conc}/all_otu_map.uc para "
	echo "${otu_table}/otu_table.txt ... "
	echo ""
	echo "........................ PASSO 11 ........................" >> ${log}
	echo "CONVERTENDO ARQUIVO UC PARA otu-table.txt ( ${otu_table}/otu_table.txt ) ... " >> ${log}
	echo "USANDO ${bmp_map} PARA CONVERTER " >> ${log}
	echo "${conc}/all_otu_map.uc PARA " >> ${log}
	echo "${otu_table}/otu_table.txt ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${bmp_map}" >> ${log}
	#( O arquivo all_otu_map.uc contém 10 colunas: ).................................#
	#( 1) Contém caracteres do tipo S, H, C ou N (ver abaixo). ).....................#
	#( 2) Número de custers formados (baseado em 0). )...............................#
	#( 3) Comprimento da sequência (S, N e H) ou tamanho do cluster (C). )...........#
	#( 4) O caracter H representa o percentual de identidade das sequências. ).......#
	#( 5) Para informar o tipo de molécula, o caracter H deve ter em strand: + ).....#
	#( ou - para nucleotídeos, . para proteínas. )...................................#
	#( 6) Não utilizado, os analistas devem ignorar este campo, embora ele deva ser )#
	#( incluído apenas para fins de compatibilidade de versões anteriores. ).........#
	#( 7) Idem observação acima. )...................................................#
	#( 8) Alinhamento comprimido ou símbolo "=" (igual). O = indica que a sequência )#
	#( de entrada (query) é 100% identica a sequência alvo (campo 10). ).............#
	#( 9) Identificação da sequência de entrada (query, sempre presente). )..........#
	#( 10) Identificação da sequência alvo (somente para o caracter H). )............#

#	if [ ! -f ${otu_table}/otu_table.txt ]; then

        python ${bmp_map} ${conc}/all_otu_map.uc > ${otu_table}/otu_table.txt 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${otu_table}/otu_table.txt existente ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 12 ........................"
        echo "Convertendo arquivo ${otu_table}/otu_table.txt para"
	echo "${otu_table}/otu-table.biom ... "
	echo ""
	echo "........................ PASSO 12 ........................" >> ${log}
	echo "CONVERTENDO ARQUIVO ${otu_table}/otu_table.txt PARA" >> ${log}
	echo "${otu_table}/otu-table.biom ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${table}" >> ${log}
#	if [ ! -f ${otu_table}/otu_table.biom ]; then

        ${table} -i ${otu_table}/otu_table.txt -t ${conc}/assign_tax/otus_tax_assignments.txt -o ${otu_table}/otu_table.biom &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${otu_table}/otu_table.biom não encontrado ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 13 ........................"
	echo "Resumo da OTU table sem normalização para determinar o número"
	echo "de sequências por amostra ... "
	echo ""
	echo "........................ PASSO 13 ........................" >> ${log}
	echo "RESUMO DA OTU TABLE SEM NORMALIZAÇÃO PARA DETERMINAR O NÚMERO" >> ${log}
	echo "DE SEQUÊNCIAS POR AMOSTRA ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	#( Resumindo informações da tabela de OTU sem normalizar ).......................#

#	if [ ! -f ${otu_table}/otu_table.biom_summary.txt ]; then

	biom summarize-table -i ${otu_table}/otu_table.biom -o ${otu_table}/otu_table.biom_summary.txt 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${otu_table}/otu_table.biom_summary.txt existente ... ABORTANDO ... "
#	fi;



#( Filtrando sequências de Archaea, mitocôndria e cloroplasto )..................#

	echo ""
	echo "........................ PASSO 14 ........................"
        echo "Reservando sequências de Bacteria ... "
	echo ""
	echo "........................ PASSO 14 ........................" >> ${log}
	echo "RESERVANDO SEQUÊNCIAS DE BACTÉRIAS ..." >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${filter_taxa}" >> ${log}
	# Filtragem positiva (opção -p)

#	if [ ! ${otu_table}/otu_table_bact_only.biom ]; then

        ${filter_taxa} -i ${otu_table}/otu_table.biom -o ${otu_table}/otu_table_bact_only.biom -p Bacteria &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivo ${otu_table}/otu_table_bact_only.biom encontrado ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 15 ........................"
	echo "Remoção de sequências relacionadas a Archaea, Chloroplast"
	echo "e Mitochondria ... "
	echo ""
	echo "........................ PASSO 15 ........................" >> ${log}
	echo "REMOÇÃO DE SEQUÊNCIAS RELACIONADAS A ARCHAEA, CHLOROPLAST" >> ${log}
	echo "E MITOCHONDRIA ..." >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${filter_taxa}" >> ${log}
	#( Filtragem negativa (opção -n) )...............................................#

#	if [ ! -f ${otu_table}/otu_table_bact2_only.biom ]; then

	${filter_taxa} -i ${otu_table}/otu_table_bact_only.biom -o ${otu_table}/otu_table_bact2_only.biom -n Archaea,Chloroplast,Mitochondria &>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Aquivo ${otu_table}/otu_table_bact2_only.biom encontrado ... ABORTANDO ... "
#	fi;


	echo ""
	echo "........................ PASSO 16 ........................"
	echo "Resumindo informações da tabela de OTU para Bacteria ... "
	echo ""
	echo "........................ PASSO 16 ........................" >> ${log}
	echo "RESUMINDO INFORMAÇÕES DA TABELA DE OTU PARA BACTERIA ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	#( Resumindo informações da tabela de OTU para Bacteria )........................#


#	if [ ! -f ${otu_table}/otu_table_bact_only.txt -a ${otu_table}/otu_table_bact2_only.txt ]; then

        biom summarize-table -i ${otu_table}/otu_table_bact_only.biom -o ${otu_table}/otu_table_bact_only.txt 2>> ${log}
        biom summarize-table -i ${otu_table}/otu_table_bact2_only.biom -o ${otu_table}/otu_table_bact2_only.txt 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

#	else
#		echo "Arquivos ${otu_table}/otu_table_bact_only.txt e ${otu_table}/otu_table_bact2_only.txt encontrado ... ABORTANDO ... "
#	fi;


	#( Normalização por profundidade )...............................................#

	echo ""
	echo "........................ PASSO 17 ........................"
	echo "Copiando arquivos importantes para QIIME no diretório atual ... "
	echo " ${otu_table}/otu_table_bact2_only.biom ... "
	echo " ${map} ... "
	echo " ${cust} ... "
	echo ""
	echo "........................ PASSO 17 ........................" >> ${log}
	echo "COPIANDO ARQUIVOS IMPORTANTES PARA QIIME NO DIRETÓRIO ATUAL ... " >> ${log}
	echo " ${otu_table}/otu_table_bact2_only.biom ... " >> ${log}
	echo " ${map} ... " >> ${log}
	echo " ${cust} ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	ln -s -f ${otu_table}/otu_table_bact2_only.biom ${base_dir} 2>> ${log}
	ln -s -f ${map} ${base_dir} 2>> ${log}
	ln -s -f ${cust} ${base_dir} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}
	sleep 1;














	echo ""
	echo "........................ PASSO 18 ........................"
	echo "Normalização considerando a mesma profundidade entre as amostras ... "
	echo ""
	echo "........................ PASSO 18 ........................" >> ${log}
	echo "NORMALIZAÇÃO CONSIDERANDO A MESMA PROFUNDIDADE ENTRE AS AMOSTRAS ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}

	#( Para executar análises bootstrap, jackknife e rarefação, a tabela de OTU )....#
	#( deve ser sub-amostrada (rarefeita). Esse script rarifica, ou subamostra, )....#
	#( uma tabela de OTU. Isto não proporciona curvas de diversidade por número )....#
	#( de sequências numa amostra. Em vez disso, cria uma tabela de OTU )............#
	#( subamostrada usando amostragem aleatória (sem substituição) da tabela OTU )...#
	#( de entrada )..................................................................#

	cat ${otu_table}/otu_table_bact2_only.txt | perl -e 'while(<>){if(/Min: (\d+)/){system(`single_rarefaction.py -i otu_table_bact2_only.biom -o otu_table_equal_deep.biom -d ${1}`)}}' 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 19 ........................"
	echo "Movendo o arquivo ${base_dir}/otu_table_equal_deep.biom para o diretório "
	echo "${otu_table} ... "
	echo ""
	echo "........................ PASSO 19 ........................" >> ${log}
	echo "MOVENDO O ARQUIVO ${base_dir}/otu_table_equal_deep.biom PARA O DIRETÓRIO " >> ${log}
	echo "${otu_table} ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	mv ${base_dir}/otu_table_equal_deep.biom ${otu_table} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}
	sleep 1;


	echo ""
	echo "........................ PASSO 20 ........................"
	echo "Resumo da OTU table normalizada por profundidade para determinar"
	echo "o número de sequências por amostra ... "
	echo ""
	echo "........................ PASSO 20 ........................" >> ${log}
	echo "RESUMO DA OTU TABLE NORMALIZADA POR PROFUNDIDADE PARA DETERMINAR" >> ${log}
	echo "O NÚMERO DE SEQUÊNCIAS POR AMOSTRA ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	biom summarize-table -i ${otu_table}/otu_table_equal_deep.biom -o ${otu_table}/otu_table_equal_deep_norm.biom_summary.txt 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}



	#( Alfa rarefação usando biom normalizado para profundidade )....................#
	#( (Alfa diversidade) )..........................................................#


	echo ""
	echo "........................ PASSO 21 ........................"
	echo "Fazendo subamostragens aleatórias para análises de alfa-diversidade ... "
	echo "Amostragem por rarefação ... "
	echo ""
	echo "........................ PASSO 21 ........................" >> ${log}
	echo "FAZENDO SUBAMOSTRAGEM ALEATÓRIAS PARA ANÁLISES DE ALFA-DIVERSIDADE ... " >> ${log}
	echo "AMOSTRAGEM POR RAREFAÇÃO ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${m_rarefaction}" >> ${log}

	#( Para executar análises bootstrap, jackknife e rarefação, a OTU table deve )...#
	#( ser subamostrada (rarefeita). Isto não proporciona curvas de diversidade por )#
	#( número de sequências numa amostra. Em vez disso, cria uma série de tabelas )..#
	#( OTU subamostadas por amostragem aleatória (sem substituição) da OTU table )...#
	#( de entrada (menos sequências). O gerador de números pseudo-aleatórios usado ).#
	#( para rarefação da subamostragem é o padrão do NumPy - uma implementação do )..#
	#( Mersenne twister PRNG. )......................................................#

##	${m_rarefaction} -i ${otu_table}/otu_table_equal_deep.biom -m 400 -x 10000 -s 160 -n 90 -o ${alfa}/rarefied_otu_tables_prof &>> ${log}

	#( Este comando é somente para testes. O comando de cima é o que vale! ).........#
	${m_rarefaction} -i ${otu_table}/otu_table_equal_deep.biom -m 40 -x 1000 -s 16 -n 9 -o ${alfa}/rarefied_otu_tables_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 22 ........................"
	echo "Calculando a alfa-diversidade para cada amostra ..."
	echo "Amostragem por rarefação ... "
	echo ""
	echo "........................ PASSO 22 ........................" >> ${log}
	echo "CALCULANDO A ALFA-DIVERSIDADE PARA CADA AMOSTRA ... " >> ${log}
	echo "AMOSTRAGEM POR RAREFAÇÃO ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${alpha_div}" >> ${log}
	${alpha_div} -i ${alfa}/rarefied_otu_tables_prof -o ${alfa}/adiv_default_prof -t ${rep}/rep_set.tre 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}

	echo ""
	echo "........................ PASSO 23 ........................"
	echo "Ao realizar amostragem por rarefação, muitos arquivos são produzidos."
	echo "Estes arquivos precisam ser concatenados em um único arquivo para gerar"
	echo "as análises de alfa-diversidade ... "
	echo "Amostragem por rarefação ... "
	echo ""
	echo "........................ PASSO 23 ........................" >> ${log}
	echo "AO REALIZAR AMOSTRAGEM POR RAREFAÇÃO, MUITOS ARQUIVOS SÃO PRODUZIDOS." >> ${log}
	echo "ESTES ARQUIVOS PRECISAM SER CONCATENADOS EM UM ÚNICO ARQUIVO PARA GERAR" >> ${log}
	echo "AS ANÁLISES DE ALFA-DIVERSIDADE ... " >> ${log}
	echo "AMOSTRAGEM POR RAREFAÇÃO ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${collate}" >> ${log}
	${collate} -i ${alfa}/adiv_default_prof -o ${alfa}/collated_alpha_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 24 ........................"
	echo "Construindo curvas de rarefação ... "
	echo "Amostragem por rarefação ... "
	echo ""
	echo "........................ PASSO 24 ........................" >> ${log}
	echo "CONSTRUINDO CURVAS DE RAREFAÇÃO ... " >> ${log}
	echo "AMOSTRAGEM POR RAREFAÇÃO ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${rarefaction_plot}" >> ${log}
	${rarefaction_plot} -i ${alfa}/collated_alpha_prof -m ${map} -o ${alfa}/final_rarefaction_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 25 ........................"
	echo "Ordenando OTU Table por contagem de OTUs ... "
	echo "Amostragem por rarefação ... "
	echo ""
	echo "........................ PASSO 25 ........................" >> ${log}
	echo "ORDENANDO OTU TABLE POR CONTAGEM DE OTUS ... " >> ${log}
	echo "AMOSTRAGEM POR RAREFAÇÃO ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sort_biom}" >> ${log}
	#( Sort OTU Table command )......................................................#

	${sort_biom} -i ${otu_table}/otu_table_equal_deep.biom -o ${otu_table}/otu_table_equal_deep_sort.biom 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	#( PCoA plots 2D/3D usando biom normalizado para profundidade )..................#
	#( Beta diversidade )............................................................#
	#( Para ver um tutorial mais detalhado: )........................................#
	#( http://qiime.org/tutorials/tutorial.html )....................................#
	#( Para aprender mais sobre PCoA http://ordination.okstate.edu/ )................#

	echo ""
	echo "........................ PASSO 26 ........................"
	echo "Criando matrix de distância para métrica Unifrac (weighted_unifrac) ... "
	echo "Parte 1/4 ... "
	echo ""
	echo "........................ PASSO 26 ........................" >> ${log}
	echo "CRIANDO MATRIX DE DISTÂNCIA PARA MÉTRICA UNIFRAC (WEIGHTED_UNIFRAC) ... " >> ${log}
	echo "PARTE 1/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${beta_div}" >> ${log}
	# multiple_rarefactions.py -i ./out_analysis/final_otu_tables/otu_table_equal_deep.biom -m 400 -x 10000 -s 160 -n 90 -o ./out_analysis/bact/alpha/rarefied_otu_tables_prof
	${beta_div} -i ${alfa}/rarefied_otu_tables_prof -m weighted_unifrac -o ${beta}/plots_2d/weighted_unifrac/beta_diversity_results_prof -t ${rep}/rep_set.tre 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 27 ........................"
	echo "Criando gráficos 2D PCoA "weighted_unifrac" ... "
	echo "Parte 2/4 ... "
	echo ""
	echo "........................ PASSO 27 ........................" >> ${log}
	echo "CRIANDO GRÁFICOS 2D PCOA "WEIGHTED_UNIFRAC" ... " >> ${log}
	echo "PARTE 2/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${p_coordinates}" >> ${log}
	${p_coordinates} -i ${beta}/plots_2d/weighted_unifrac/beta_diversity_results_prof -o ${beta}/plots_2d/weighted_unifrac/principal_coordinates_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 28 ........................"
	echo "Criando gráficos 2D PCoA "weighted_unifrac" ... "
	echo "Parte 3/4 ... "
	echo ""
	echo "........................ PASSO 28 ........................" >> ${log}
	echo "CRIANDO GRÁFICOS 2D PCOA "WEIGHTED_UNIFRAC" ... " >> ${log}
	echo "PARTE 3/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${m_plots}" >> ${log}
	${m_plots} -i ${beta}/plots_2d/weighted_unifrac/principal_coordinates_prof -m ${map} -o ${beta}/plots_2d/graphs_2d_weighted_unifrac_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 29 ........................"
	echo "Criando gráfico PCoA 3D (weighted_unifrac) ... "
	echo "Parte 4/4 ... "
	echo ""
	echo "........................ PASSO 29 ........................" >> ${log}
	echo "CRIANDO GRÁFICO PCOA 3D (WEIGHTED_UNIFRAC) ... " >> ${log}
	echo "PARTE 4/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${m_emperor}" >> ${log}
	${m_emperor} -i ${beta}/plots_2d/weighted_unifrac/principal_coordinates_prof -m ${map} -o ${beta}/plots_3d/plots_3D_weighted_unifrac_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}



	echo ""
	echo "........................ PASSO 30 ........................"
	echo "Criando matrix de distância para métrica Unifrac (unweighted_unifrac) ... "
	echo "Parte 1/4 ... "
	echo ""
	echo "........................ PASSO 30 ........................" >> ${log}
	echo "CRIANDO MATRIX DE DISTÂNCIA PARA MÉTRICA UNIFRAC (UNWEIGHTED_UNIFRAC) ... " >> ${log}
	echo "PARTE 1/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${beta_div}" >> ${log}
	${beta_div} -i ${alfa}/rarefied_otu_tables_prof -m unweighted_unifrac -o ${beta}/plots_2d/unweighted_unifrac/beta_diversity_results_prof -t ${rep}/rep_set.tre 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 31 ........................"
	echo "Criando gráficos 2D PCoA "unweighted_unifrac" ... "
	echo "Parte 2/4 ... "
	echo ""
	echo "........................ PASSO 31 ........................" >> ${log}
	echo "CRIANDO GRÁFICOS 2D PCOA "UNWEIGHTED_UNIFRAC" ... " >> ${log}
	echo "PARTE 2/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${p_coordinates}" >> ${log}
	${p_coordinates} -i ${beta}/plots_2d/unweighted_unifrac/beta_diversity_results_prof -o ${beta}/plots_2d/unweighted_unifrac/principal_coordinates_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 32 ........................"
	echo "Criando gráficos 2D PCoA "unweighted_unifrac" ... "
	echo "Parte 3/4 ... "
	echo ""
	echo "........................ PASSO 32 ........................" >> ${log}
	echo "CRIANDO GRÁFICOS 2D PCOA "UNWEUGHTED_UNIFRAC" ... " >> ${log}
	echo "PARTE 3/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${m_emperor}" >> ${log}
	${m_emperor} -i ${beta}/plots_2d/unweighted_unifrac/principal_coordinates_prof -m ${map} -o ${beta}/plots_3d/plots_3D_unweighted_unifrac_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 33 ........................"
	echo "Criando gráfico PCoA 3D (unweighted_unifrac) ... "
	echo "Parte 4/4 ... "
	echo ""
	echo "........................ PASSO 33 ........................" >> ${log}
	echo "CRIANDO GRÁFICO PCOA 3D (UNWEIGHTED_UNIFRAC) ... " >> ${log}
	echo "PARTE 4/4 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${m_plots}" >> ${log}
	${m_plots} -i ${beta}/plots_2d/unweighted_unifrac/principal_coordinates_prof -m ${map} -o ${beta}/plots_2d/graphs_2d_unweighted_unifrac_prof 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}



	#( Normalização por profundidade e análises de taxonomia ).......................#

	#( A melhor normalização para DM1 foi a CSS, isso baseado nas análises UNIFRAC ).#
	#( com e sem peso. Porém, ele perde muitos dados, onde escolhemos a )............#
	#( normalização por PROFUNDIDADE )...............................................#
	#( A maior parte das espécies bacterianas devem estar presentes tanto no CTL )...#
	#( quanto nos DM1. Devido as pequenas diferenças, provavelmente poucas ).........#
	#( espécies estão relacionadas a estas diferenças. Por isso tenho que filtrar )..#
	#( aqueles que estão diferencialmente abundântes usando o p-value, e tentar )....#
	#( gerar os gráficos de PCA, etc, usando espécies e outros níveis )..............#
	#( Gerar gráficos no PCA no servidor on-line e também no STAMP. )................#
	#( Não precisa criar o diretório de saída )......................................#

	#summarize_taxa_through_plots.py -i out_analysis/final_otu_tables/otu_table_equal_deep.biom -o out_analysis/bact/taxa_summary_deep -m trim_data/map_file.txt -c NewSampleID2


	echo ""
	echo "........................ PASSO 34 ........................"
	echo "Criando gráfico de abundância taxonômica: FILO ... "
	echo "Parte 1/6 ... "
	echo ""
	echo "........................ PASSO 34 ........................" >> ${log}
	echo "CRIANDO GRÁFICO DE ABUNDÂNCIA TAXONÔMICA: FILO ... " >> ${log}
	echo "PARTE 1/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}

	#( Dois passos para gerar gráficos de filo, abordagem diferentes dessa de cima ).#

	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 2 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>> ${log}

	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L2.txt -l phylum -c pie,bar,area -o ${proc}/bact/taxa_summaries/phylum_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 35 ........................"
	echo "Criando gráfico de abundância taxonômica: CLASSE ... "
	echo "Parte 2/6 ... "
	echo ""
	echo "........................ PASSO 35 ........................" >> ${log}
	echo "CRIANDO GRÁFICO DE ABUNDÂNCIA TAXONÔMICA: CLASSE ... " >> ${log}
	echo "PARTE 2/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}
	#( Dois passos para gerar gráficos de classe )...................................#

	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 3 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>>${log}

	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L3.txt -l class -c pie,bar,area -o ${proc}/bact/taxa_summaries/class_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 36 ........................"
	echo "Criando gráfico de abundância taxonômica: ORDEM ... "
	echo "Parte 3/6 ... "
	echo ""
	echo "........................ PASSO 36 ........................" >> ${log}
	echo "CRIANDO GRÁFICO DE ABUNDÂNCIA TAXONÔMICA: ORDEM ... " >> ${log}
	echo "PARTE 3/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}
	#( Dois passos para gerar gráficos de ordens )...................................#
	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 4 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>> ${log}

	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L4.txt -l order -c pie,bar,area -o ${proc}/bact/taxa_summaries/order_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 37 ........................"
	echo "Criando gráfico de abundância taxonômica: FAMÍLIA ... "
	echo "Parte 4/6 ... "
	echo ""
	echo "........................ PASSO 37 ........................" >> ${log}
	echo "CRIANDO GRÁFICO DE ABUNDÂNCIA TAXONÔMICA: FAMÍLIA ... " >> ${log}
	echo "PARTE 4/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}
	#( Dois passos para gerar gráficos de família )..................................#
	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 5 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>> ${log}

	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L5.txt -l family -c pie,bar,area -o ${proc}/bact/taxa_summaries/family_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 38 ........................"
	echo "Criando gráfico de abundância taxonômica: GÊNERO ... "
	echo "Parte 5/6 ... "
	echo ""
	echo "........................ PASSO 38 ........................" >> ${log}
	echo "CRIANDO GRÁFICO DE ABUNDÂNCIA TAXONÔMICA: GÊNERO ... " >> ${log}
	echo "PARTE 5/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}
	#( Dois passos para gerar gráficos de gênero )...................................#
	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 6 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>> ${log}
	
	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L6.txt -l genus -c pie,bar,area -o ${proc}/bact/taxa_summaries/genus_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 39 ........................"
	echo "Criando gráficos de abundância taxonômica: GÊNERO ... "
	echo "Parte 6/6 ... "
	echo ""
	echo "........................ PASSO 39 ........................"
	echo "CRIANDO GRÁFICOS DE ABUNDÂNCIA TAXONÔMICA: GÊNERO ... " >> ${log}
	echo "PARTE 6/6 ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${sum_tx}" >> ${log}
	echo "   PROGRAMA ${plot_tx_sum}" >> ${log}
	#( Dois passos para gerar gráficos de espécie )..................................#
	${sum_tx} -i ${otu_table}/otu_table_equal_deep_sort.biom -L 7 -o ${proc}/bact/taxa_summaries 1>> ${log} 2>> ${log}

	${plot_tx_sum} -i ${proc}/bact/taxa_summaries/otu_table_equal_deep_sort_L7.txt -l species -c pie,bar,area -o ${proc}/bact/taxa_summaries/species_charts 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 40 ........................"
	echo "Criando análises dos índices de diversidade e riqueza ... "
	echo ""
	echo "........................ PASSO 40 ........................" >> ${log}
	echo "CRIANDO ANÁLISES DOS ÍNDICES DE DIVERSIDADE E RIQUEZA ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${alpha_div}" >> ${log}
	${alpha_div} -i ${otu_table}/otu_table_equal_deep.biom -m chao1,ace,equitability,goods_coverage,simpson,shannon,observed_species -o ${index}/index_diversity.txt -t ${rep}/rep_set.tre 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo ""
	echo "........................ PASSO 41 ........................"
	echo "Computando o core microbiome entre as amostras ... "
	echo ""
	echo "........................ PASSO 41 ........................" >> ${log}
	echo "COMPUTANDO O CORE MICROBIOME ENTRE AS AOSTRAS ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	echo "   PROGRAMA ${c_core_mic}" >> ${log}
	${c_core_mic} -i ${otu_table}/otu_table_equal_deep.biom -o ${core} 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}


	echo "Compactando alguns arquivos importantes ... "
	echo " ${otu_table}/otu_table_equal_deep.biom ... "
	echo " ${otu_table}/otu_table.biom ... "
	echo " ${core} ... "
	gzip -9 ${otu_table}/otu_table_equal_deep.biom 2>> ${log}
	gzip -9 ${otu_table}/otu_table.biom 2>> ${log}
	zip -r ${proc}/bact/core_microbiome.zip ${core} 2>> ${log}
	

	echo ""
	echo "........................ PASSO 42 ........................"
	echo "Removendo arquivos temporários ... "
	echo " ${base_dir}/otu_table_bact2_only.biom ... "
	echo " ${base_dir}/map_file.txt ... "
	echo " ${base_dir}/custom_parameters.txt ... "
	echo ""
	echo "........................ PASSO 42 ........................" >> ${log}
	echo "REMOVENDO ARQUIVOS TEMPORÁRIOS ... " >> ${log}
	echo " ${base_dir}/otu_table_bact2_only.biom ... " >> ${log}
	echo " ${base_dir}/map_file.txt ... " >> ${log}
	echo " ${base_dir}/custom_parameters.txt ... " >> ${log}
	echo "INICIANDO EM: `date +%d/%m/%Y-%H:%M:%S`" >> ${log}
	rm -f ${base_dir}/otu_table_bact2_only.biom 1>> ${log} 2>> ${log}
	rm -f ${base_dir}/map_file.txt 1>> ${log} 2>> ${log}
	rm -f ${base_dir}/custom_parameters.txt 1>> ${log} 2>> ${log}
	echo "FINALIZADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
	echo "" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "---------------------			---------------------" >> ${log}
	echo "" >> ${log}
	sleep 2;


	#( Finalizando a inserção de log dos programas no arquivo qiime.log )............#

	echo ""
	echo "...................... PASSO FINAL ......................."
        echo "Finalizando análises com QIIME ..."
	echo "Iniciado em: ${inicio}"
	echo "Terminado em: `date +%d/%m/%Y-%H:%M:%S`"
	echo "...................... PASSO FINAL ......................." >> ${log}
	echo "INICIADO EM: ${inicio}" >> ${log}
        echo "TERMINADO EM: `date +%d/%m/%Y-%H:%M:%S` ... " >> ${log}
        echo "" >> ${log}
        echo "#-------------------------------------------------------------#" >> ${log}
        echo "#             FINALIZANDO ANÁLISES COM QIIME                   " >> ${log}
        echo "#-------------------------------------------------------------#" >> ${log}
        echo "" >> ${log}

