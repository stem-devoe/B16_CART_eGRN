set -eu

# Paths and parameters
# consensus peaks
consensdir='/Scottbrowne/members/smd/Projects/SD031/scenicplus/B16_CART/ATAC/consensus_peak_calling'
# output
outdir='/Scottbrowne/members/smd/Projects/SD031/scenicplus/B16_CART/cistarget_database' 
# Identifier
tag='SD031_B16_CART'
# reference genome
genomefa='/opt/genomes/cellranger/refdata-cellranger-arc-mm10-2020-A-2.0.0/fasta/genome.fa'
# cluster buster directory for the .cb motif files
cbdir='/scratch2/devoes/SD031_scenicplus/HOCOMOCOv11/'
# set path to find scripts cloned from github repo
create_cistarget_databases_dir='/Scottbrowne/members/smd/reference_datasets/create_cisTarget_databases'

ncpu=16

# Create outdir
if [ ! -d $outdir ]
then
	    mkdir -p $outdir
fi

# List of motifs names - they want the file names of the .cb files
motif_list='/scratch2/devoes/SD031_scenicplus/HOCOMOCOv11/names.tsv' 

# Activate environment
source /home/devoes/miniconda3/etc/profile.d/conda.sh
conda activate create_cistarget_databases

# Get fasta sequences of consensus peaks #### - already done when we did partial cb list
echo "Extracting FASTA ..."
bedtools getfasta -fi $genomefa -bed $consensdir/consensus_regions.bed > $consensdir/consensus_regions.fa
echo "Done."

## Create scores DB 
echo "Creating scores DB files ..."
# Score the motifs in 1 chunks; we will use the non-redundant db here
${create_cistarget_databases_dir}/create_cistarget_motif_databases.py \
	-f $consensdir/consensus_regions.fa \
	-M $cbdir \
	-m $motif_list \
	-o $outdir/$tag \
	-t $ncpu \
	-l

echo "Done."


## Create rankings
echo "Creating rankings DB files ..."
${create_cistarget_databases_dir}/convert_motifs_or_tracks_vs_regions_or_genes_scores_to_rankings_cistarget_dbs.py -i ${outdir}/${tag}.motifs_vs_regions.scores.feather -s 555
echo "Done."
echo "ALL DONE."
