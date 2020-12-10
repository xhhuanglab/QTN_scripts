#!/usr/bin/perl
use FindBin;

my $cfg;
my $sample_bam;
my $prefix;

if(@ARGV < 3){
  die "Usage: perl $0 <RiceNavi-QTNpick.cfg> <Sample_BAM (e.g. Huanghuazhan.realign.bam)> <Prefix>";	
}else{
  ($cfg,$sample_bam,$prefix) = @ARGV;	
}

open CFG, $cfg;
my ($samtools,$sambamba_soft,$GATK4,$GATK3,$configManta,$bam2fastq);
my ($Ref_genome,$non_Nip_QTG_ref,$var_sites);
while(<CFG>){
  chomp;
  s/\s+//g;
  $samtools = $1 if /samtools=(.+)/;
  $sambamba_soft = $1 if /sambamba_soft=(.+)/;
  $GATK4 = $1 if /GATK4=(.+)/;
  $GATK3 = $1 if /GATK3=(.+)/;
  $configManta = $1 if /configManta=(.+)/;
  $bam2fastq = $1 if /bam2fastq=(.+)/;
  
  $Ref_genome = $1 if /Ref_genome=(.+)/;
  $non_Nip_QTG_ref = $1 if /non_Nip_QTG_ref=(.+)/;
  $var_sites = $1 if /var_sites=(.+)/;
}


my $script_dir = $FindBin::Bin;
my $non_Nip_QTG_ref_file = $script_dir."/".$non_Nip_QTG_ref;
my $var_sites_file = $script_dir."/".$var_sites;
my $gatk4_intervals = $script_dir."/".$var_sites.".GATK4.intervals";
my $gatk3_intervals = $script_dir."/".$var_sites.".GATK3.intervals";
my $sambamba_bed = $script_dir."/".$var_sites.".depthcall.bed";

my $GATK4_gvcf_output = $prefix.'/'.$prefix.'.1_GATK4.gvcf';
my $GATK3_vcf_output = $prefix.'/'.$prefix.'.2_GAKT3.vcf';
my $depthcall_outfile = $prefix.'/'.$prefix.'.3_sambamba.depth';

mkdir $prefix;

############################################
## SNP & INDEL calling by GATK4 and GATK3 ##
############################################


system(qq(samtools index $sample_bam)) if (! -f "$sample_bam.bai");

system(qq(java -jar $GATK4 HaplotypeCaller -R $Ref_genome --emit-ref-confidence GVCF -I $sample_bam -L $gatk4_intervals -O $GATK4_gvcf_output));

system(qq(java -jar $GATK3 -T UnifiedGenotyper -R $Ref_genome -I $sample_bam -o $GATK3_vcf_output -L $gatk3_intervals -glm BOTH --output_mode EMIT_ALL_SITES));


#############################
## depthcalling by Sambamba #
#############################
system(qq($sambamba_soft depth region $sample_bam -L $sambamba_bed -o $depthcall_outfile));

###################################
## run Manta to detect large SVs ##
###################################
print "Start detecting SV by Manta..";
mkdir "$prefix/$prefix.Manta";
system(qq(configManta.py --bam $sample_bam --referenceFasta $Ref_genome --runDir $prefix/$prefix.Manta));
system(qq(python2 $prefix/$prefix.Manta/runWorkflow.py));
system(qq(cp $prefix/$prefix.Manta/results/variants/candidateSV.vcf.gz $prefix/$prefix.4_manta.SV.gz));
system(qq(gunzip -f $prefix/$prefix.4_manta.SV.gz));


######################################################################################################
## extract unmapped reads for mapping to alleles not present in Nipponbare reference (non-Nip-QTGs) ##
######################################################################################################


my $non_Nip_QTG_ref_index = $1 if $non_Nip_QTG_ref_file =~ /(.+)\.fa/;
mkdir "$prefix/$prefix.unaligned";
system(qq($bam2fastq -o $prefix/$prefix.unaligned/$prefix\#.fq -f --unaligned --no-aligned --no-filter $sample_bam));


my $fq1 = "$prefix/$prefix.unaligned/$prefix\_1.fq"; my $fq2 = "$prefix/$prefix.unaligned/$prefix\_2.fq";

system(qq(bowtie2 -p 30 -x $non_Nip_QTG_ref_index -1 $fq1 -2 $fq2 --rg-id $prefix --rg "PL:ILLUMINA" --rg "SM:$prefix" -S $prefix/$prefix.unaligned/$prefix.unaligned.sam));
system(qq($samtools view -bS $prefix/$prefix.unaligned/$prefix.unaligned.sam > $prefix/$prefix.unaligned/$prefix.unaligned.bam));
system(qq($samtools sort --threads 20 -o $prefix/$prefix.unaligned/$prefix.unaligned.sorted.bam $prefix/$prefix.unaligned/$prefix.unaligned.bam));
system(qq($samtools index $prefix/$prefix.unaligned/$prefix.unaligned.sorted.bam));
system(qq($samtools depth $prefix/$prefix.unaligned/$prefix.unaligned.sorted.bam > $prefix/$prefix.unaligned/$prefix.unaligned.depth));


my %nonnip_seq; my $tit;
my %count_len;
open COVERAGE, ">$prefix/$prefix.5_nonNip_QTG.coverage";
open NONNIP, $non_Nip_QTG_ref_file or die;
while(<NONNIP>){
  chomp;
  if(/>(\S+)/){
    $tit = $1;	
  }else{
    $nonnip_seq{$tit} .= $_;	
  }
}
close NONNIP;

open DEPTH, "$prefix/$prefix.unaligned/$prefix.unaligned.depth";
while(<DEPTH>){
  chomp;
  $count_len{$1}++ if /(.+?)\t/;
}
close DEPTH;

foreach (sort keys%nonnip_seq){
	my $sample_gene_len = $count_len{$_} || 0;
  my $coverage = sprintf("%.4f",$sample_gene_len/length $nonnip_seq{$_});
  print COVERAGE "$_\t$coverage\n";
}






#########################
### Combine Genotypes ###

my $sample_out_geno = "$prefix/$prefix.RiceNavi_Causal_Var.site.geno";
open OUT, ">$sample_out_geno";


my $gatk4_gvcf = $prefix.'/'.$prefix.'.1_GATK4.gvcf';
my $gatk3_vcf = $prefix.'/'.$prefix.'.2_GAKT3.vcf';
my $sambamba_depth = $prefix.'/'.$prefix.'.3_sambamba.depth';
my $manta_SV = $prefix.'/'.$prefix.'.4_manta.SV';
my $nonNip_QTG = $prefix.'/'.$prefix.'.5_nonNip_QTG.coverage';



my %gatk4_geno;
open GATK4, $gatk4_gvcf;

while(<GATK4>){
  chomp;
  next if /^\#/;
  my @tmp = split/\t/;
  my ($chrom,$site,$refbase,$geno) = @tmp[0,1,3,-1];
  my $altbase; my @altbases;
  my @alleles = ();
  if($tmp[4] eq '<NON_REF>'){
  	if($tmp[9] =~ /^(.+?)\:(.+?)\:/){
  		if($2 >= 1){
  	    $gatk4_geno{$chrom."\t".$site} = '0|0'; 	
  	  }else{
  	    $gatk4_geno{$chrom."\t".$site} = '.|.'; 	
  	  }
  	}
    
  }
  elsif($tmp[4] =~ /(.+)\,/){
  	@altbases = split/\,/,$1 if $tmp[4] =~ /(.+)\,<NON_REF\>/;
    @alleles = ($refbase,@altbases);
    my ($vcf_num1,$vcf_num2) = ($1,$2) if $geno =~ /(\d+)[\/\|](\d+)\:/;
    $gatk4_geno{$chrom."\t".$site} = $alleles[$vcf_num1].'|'.$alleles[$vcf_num2];    
  }
}
close GATK4;


my %gatk3_geno;
open GATK3, $gatk3_vcf;

while(<GATK3>){
  chomp;
  next if /^\#/;
  my @tmp = split/\t/;
  my ($chrom,$site,$refbase,$altbase,$geno) = @tmp[0,1,3,4,-1];
  my @alleles = ($refbase,$altbase);
  if($geno =~ /(\d+)[\/\|](\d+)\:/){
    my ($vcf_num1,$vcf_num2) = ($1,$2);
    $gatk3_geno{$chrom."\t".$site} = $alleles[$vcf_num1].'|'.$alleles[$vcf_num2];
  }else{
    $gatk3_geno{$chrom."\t".$site} = '.|.';
  }
}
close GATK3;



my %sambamba_geno;
open SAMBAMBA, $sambamba_depth;
my $sambamba_header = <SAMBAMBA>;
while(<SAMBAMBA>){
  chomp;
  my @tmp = split/\t/;
  my $range = "$tmp[0]\t$tmp[1]\-$tmp[2]";
  if($tmp[-2] < 1){
    $sambamba_geno{$range} = '1|1';
  }else{
    $sambamba_geno{$range} = '0|0';	
  }
}
close SAMBAMBA;

my %manta_geno;
open MANTA, $manta_SV;
while(<MANTA>){
  chomp;
  next if /^\#/;
  my @tmp = split/\t/;
  my $sv_info = $1.'|'.$2 if /SVTYPE=(.+?);SVLEN=(.+?);/;
  $manta_geno{$tmp[0]."\t".$tmp[1]} = $sv_info;
}
close MANTA;

my %nonNip_geno;
my %threshold;

open NONQTG, $nonNip_QTG;
while(<NONQTG>){
  chomp;
  my @tmp = split/\t/;
  my ($gene,$threshold) = ($1,$2) if $tmp[0] =~ /(.+?)\|(.+)/;
  if($tmp[1] < $threshold){
    $nonNip_geno{$gene} = '0|0';
  }else{
    $nonNip_geno{$gene} = '1|1';	
  }
}
close NONQTG;

system(qq(dos2unix $var_sites_file));
open SITES, $var_sites_file or die "RiceNavi_Causal_Var.sites is not available..";
my $site_header = <SITES>; chomp $site_header;

print OUT "Chr\tPos_7.0\tMethod_Genotyping\tAlt_Allele_Func\tGeneName\t$prefix\n";
while(<SITES>){
  chomp;
  my $sample_geno;
  my @tmp = split/\t/;
  my $interval = $tmp[0]."\t".$tmp[1];
  my $site_info = $tmp[0]."\t".$tmp[1]."\t".$tmp[2]."\t".$tmp[5]."\t".$tmp[6];
  if(/nonNip/){
    $sample_geno = $nonNip_geno{$tmp[1]} || '0|0';
  }
  elsif(/Manta/){
    $sample_geno = $manta_geno{$interval} || '|';
  }
  elsif(/depthcall/){
    $sample_geno = $sambamba_geno{$interval};
  }
  elsif(/GATK4/){
  	$sample_geno = '.|.';
    my $GATK4_base = $gatk4_geno{$interval};
    if($GATK4_base eq '0|0'){
      $sample_geno = $GATK4_base;
    }else{
      my @site_alleles = split/\,/,$tmp[3].','.$tmp[4];
      for my $j (0..$#site_alleles){
        for my $k (1..$#site_alleles){
          if($site_alleles[$j].'|'.$site_alleles[$k] eq $GATK4_base){
            $sample_geno = $j.'|'.$k;
            last;
          }
        }
      }     	
    }
  }
  elsif(/GATK3/){
  	$sample_geno = '.|.';
    my $GATK3_base = $gatk3_geno{$interval};
   # print "$GATK3_base\n";
    if($GATK3_base eq '0|0'){
      $sample_geno = $GATK3_base;
    }else{
      my @site_alleles = split/\,/,$tmp[3].','.$tmp[4];
      for my $j (0..$#site_alleles){
        for my $k (0..$#site_alleles){
          if($site_alleles[$j].'|'.$site_alleles[$k] eq $GATK3_base){
          	#print "1\n";
            $sample_geno = $j.'|'.$k;
            last;
          }
        }
      }    	
    }

  }
  print OUT "$site_info\t$sample_geno\n";
}
close SITES;


#################################
### Remove intermediate files ###
`rm -rf $prefix/$prefix.Manta`;
`rm -rf $prefix/$prefix.unaligned`;
  	
print localtime() ." Job Causative variants calling for $prefix finished!\n";
