
$mbfile = "/path_to_MBfiles/Apop_MBfiles";
$sparse_GRM = "/path_to_GRM_SP/A_population_GRM_SP";
$pca_file = "/path_to_PCA/A_population.pca.eigenvec";
$pheno_dir = "/path_to_phenotypes";

while(<DATA>){
	chomp;
	next if /^\#/;
	$outprefix = $_;
	$phenofile = "$pheno_dir/$outprefix";
	$count++;
	if($count%3 == 0){
    system(qq(gcta64 --mbfile $mbfile --grm-sparse $sparse_GRM --fastGWA-mlm-exact --pheno $phenofile --qcovar $pca_file --threads 30 --maf 0.05 --out $outprefix));
  }else{
   	system(qq(gcta64 --mbfile $mbfile --grm-sparse $sparse_GRM --fastGWA-mlm-exact --pheno $phenofile --qcovar $pca_file --threads 30 --maf 0.05 --out $outprefix &));
  }
}

__DATA__
Final_Apop_pheno.AwnLength
Final_Apop_pheno.CulmLength
Final_Apop_pheno.FlagLeafLength
Final_Apop_pheno.FlagLeafWidth
Final_Apop_pheno.HeadingDate
Final_Apop_pheno.PanicleLength
Final_Apop_pheno.PanicleNumber
Final_Apop_pheno.PlantHeight
A_population_pheno.AmyloseContent
A_population_pheno.GrainLengthWith
A_population_pheno.HeadingDate
A_population_pheno.HullColor
A_population_pheno.LeafHair
A_population_pheno.PanicleLen
A_population_pheno.PhenolReaction
A_population_pheno.ProteinContent
A_population_pheno.pubescence
A_population_pheno.YieldPerPlant
