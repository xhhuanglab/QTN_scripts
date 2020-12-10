if(@ARGV < 2){
  die "Usage: perl $0 <Refname> <originVCF>";	
}else{
  ($refname,$originvcf) = @ARGV;	
}
$snpeffdir = '/data/home/qiujie/biosoftwares/SNPEff/snpEff';
$prefix = $1 if $originvcf =~ /(.+?)\.vcf/;
system(qq(java -Xmx200G -jar $snpeffdir/snpEff.jar -ud 0 $refname $originvcf > $prefix.final_snpeff.vcf));