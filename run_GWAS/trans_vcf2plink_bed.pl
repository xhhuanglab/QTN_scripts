my $vcf = shift or die "vcf file?";
my $outprefix = shift or die "Prefix";

system(qq(plink --vcf $vcf --make-bed --double-id --out $outprefix));