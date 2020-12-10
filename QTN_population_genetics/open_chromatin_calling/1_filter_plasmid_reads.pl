$rmdup_bam = shift or die "rmdup_bam?";
$out_prefix = $1 if $rmdup_bam =~ /(.+?)\./;

system(qq(samtools view -h -q 1 $rmdup_bam | grep -v \"mitochondrion\\\|Chloroplast\" | samtools view -bS - > $out_prefix.last.bam));

