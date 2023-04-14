#!/bin/bash
#SBATCH --partition=batch
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=6G
#SBATCH --job-name=FASTqc_PE
#SBATCH --output=FASTqcscript_0.1.0.array_Mopen_%A_%a.out
#SBATCH --error=FASTqcscript_0.1.0.array_Mopen_%A_%a.out
#SBATCH --array=1 #job array IDs
##################################################################
#%A becomes job ID
#%a becomes array ID
##################################################################
#submit script from within scratch/gds44474/MIMULUS/rna_seq/outfiles: sbatch /scratch/gds44474/MIMULUS/rna_seq/scripts/rnaseq_script_0.2.0.array_Mopen_FASTQC_TRIM_FASTQC2_PE.sh
##################################################################
# Print the task id.
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
##
## pseudoreference pipeline for Mimulus endosperm project: rnaseq_script_0.2.0.array_Mopen_FASTQC_TRIM_FASTQC2_PE.sh
## Run FastQC & Trimmomatic on PE fastq files
## AUTHOR: Makenzie Whitener 
## ADAPTED FROM: G. Sandstedt
##
##################################################################
echo -e "\n["$(date)"]\n Load FastQC v0.11.7 ...\n"
# Load necessary tools
module purge
module load FastQC/0.11.9-Java-11
module load Trimmomatic/0.39-Java-1.8.0_144

# Set working directory. This is where temporary files and any output files that have not been explicitly directed elsewhere will go.
cd $SLURM_SUBMIT_DIR

#Specify output fastq file directory, make sure fastqs are in PE directory
echo -e "\n["$(date)"]\n Specify output fastq file directory ...\n"
PEdir=/scratch/mrw16987/new_SRA
mkdir -p $PEdir

echo -e "\n["$(date)"]\n Create list of samples..."
echo -e "IMPO
" >$PEdir/Mopen_sample_PE_list_2022.txt

# Specify list of input files
echo -e "\n["$(date)"]\n Specify PE file list...\n"
list=$PEdir/Mopen_sample_PE_list_2022.txt

##################################################################
##
##      FastQC (~30 sec/Gb or ~15 min)
##
##################################################################
#Create directories for output files
echo -e "\n["$(date)"]\n Specify FastQC directory for raw fastq file reports ...\n"
qcDir=/scratch/mrw16987/new_SRA/FastQC
mkdir -p $qcDir

# Specify input file name for each array task

echo -e "\n["$(date)"]\n Specify compressed fastq name for each array task ...\n"
R1=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_1.fastq.gz
echo -e "\n["$(date)"]\n File name is "$R1"...\n"

echo -e "\n["$(date)"]\n Specify compressed fastq name for each array task ...\n"
R2=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_2.fastq.gz
echo -e "\n["$(date)"]\n File name is "$R2"...\n"

## Run FastQC on PE reads

echo -e "\n["$(date)"]\n Run FastQC on fastq file "$R1" ...\n"
time fastqc -o $qcDir --noextract $PEdir/$R1
echo -e "\n["$(date)"]\n FastQC round 1 finished ...\n"

echo -e "\n["$(date)"]\n Run FastQC on fastq file "$R2" ...\n"
time fastqc -o $qcDir --noextract $PEdir/$R2
echo -e "\n["$(date)"]\n FastQC round 1 finished ...\n"

##################################################################
##
##      Trimmomatic (~10 min/Gb)
##
##################################################################
#Create directories for output files
echo -e "\n["$(date)"]\n Specify Trimmomatic directory for trimmed fastq files ...\n"
outDir=/scratch/mrw16987/new_SRA/trim
mkdir -p $outDir

#Specify output file names on input files
echo -e "\n["$(date)"]\n Specify trimmed fastq output file name ...\n"
outPE_1=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R1.trim.fq.gz
outPE_2=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R1.trim.unpaired.fq.gz
outPE_3=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R2.trim.fq.gz
outPE_4=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R2.trim.unpaired.fq.gz

## Run trimmomatic on PE reads / move paired_end.fa file to working directory
echo -e "\n["$(date)"]\n Run Trimmomatic on raw fastq file "$R1" and "$R2" ...\n"
time java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 4 -phred33 $PEdir/$R1 $PEdir/$R2 $outDir/$outPE_1 $outDir/$outPE_2 $outDir/$outPE_3 $outDir/$outPE_4 ILLUMINACLIP:/apps/eb/Trimmomatic/0.39-Java-1.8.0_144/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

echo -e "\n["$(date)"]\n Trimmomatic finished ...\n"
##################################################################
##
##      FastQC (~30 sec/Gb or ~15 min)
##
##################################################################
#Create directories for output files
echo -e "\n["$(date)"]\n Specify FastQC directory for trimmed fastq file reports ...\n"
qcTrimDir=/scratch/mrw16987/new_SRA/trim/FastQC
mkdir -p $qcTrimDir

## assign reads for second round FastQC on PE reads

echo -e "\n["$(date)"]\n Specify compressed fastq name for each array task ...\n"
R1=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R1.trim.fq.gz
echo -e "\n["$(date)"]\n File name is "$R1"...\n"

echo -e "\n["$(date)"]\n Specify compressed fastq name for each array task ...\n"
R2=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list)_R2.trim.fq.gz
echo -e "\n["$(date)"]\n File name is "$R2"...\n"

## Run FastQC on PE reads
echo -e "\n["$(date)"]\n Run FastQC on fastq file "$R1" ...\n"
time fastqc -o $qcTrimDir --noextract $outDir/$R1
echo -e "\n["$(date)"]\n FastQC round 2 finished ...\n"

echo -e "\n["$(date)"]\n Run FastQC on fastq file "$R2" ...\n"
time fastqc -o $qcTrimDir --noextract $outDir/$R2
echo -e "\n["$(date)"]\n FastQC round 2 finished ...\n"

