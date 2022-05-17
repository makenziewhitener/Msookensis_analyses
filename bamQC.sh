echo "Woo"
for x in *_sort_29.bam
do
        name=$(echo $x | cut -f 1)

	echo "#!/bin/bash" > ${name}_QC.sh
	echo "#SBATCH --partition=batch" >> ${name}_QC.sh
	echo "#SBATCH --ntasks=1">> ${name}_QC.sh
	echo "#SBATCH --time=10:00:00">> ${name}_QC.sh
	echo "#SBATCH --mail-user=makenzie.whitener@uga.edu">> ${name}_QC.sh
	echo "#SBATCH --mem=10G">> ${name}_QC.sh
	echo "#SBATCH --mail-type=START,END,FAIL">> ${name}_QC.sh
	echo "#SBATCH --job-name=sel_var" >> ${name}_QC.sh





	echo "ml Qualimap" >> ${name}_QC.sh
        echo "cd /scartch/mrw16987/04_SOOKENSIS/08_FANASSEMBLY/NJ_tree/DATA/FASTQ/new_sook/full_PCA" >> ${name}_QC.sh
        echo "ml SAMtools" >> ${name}_QC.sh
        echo "     " >>${name}_QC.sh
        echo "     " >>${name}_QC.sh
        echo "     " >>${name}_QC.sh
        #echo "samtools index ${x}" >> ${name}_QC.sh
	echo " qualimap bamqc -bam $x " >>${name}_QC.sh

done
