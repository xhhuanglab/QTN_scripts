## Transform vcf format to bed for vcfs of 12chrs
for ((i=1;i<13;++i)); do nohup perl vcf2plink_bed.pl Chr$i.MSUv7_404lines_SNP.filtered.vcf Apop_Chr$i & done

## Generate MBfiles
for ((i=1;i<13;++i)); do echo "/data/home/qiujie/Rice_Navigation_project/GWAS_QTG_analysis/1_400Rice_NaturalPop/387_17_samples_genotyping/plink_bed_files/Apop_Chr$i" >> Apop_MBfiles; done

## Generate GRM file
gcta64 --mbfile Apop_MBfiles --make-grm --thread-num 20 --out A_population_GRM

## PCA
gcta64  --grm A_population_GRM --pca 20  --out A_population.pca

## Generate Genetic Relationship Matrix (GRM)
gcta64 --grm A_population_GRM --make-bK-sparse 0.05 --out A_population_GRM_SP

