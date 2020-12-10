#!/usr/bin/perl

use strict;
use warnings;

my $genome = shift or die "Genome seq?";
my $gff3 = shift or die "GFF3 file?";
open OUT1, ">$gff3.sep_CDS_region";


my %codons=(
'CTT'=>'L', 'CTC'=>'L', 'CTA'=>'L', 'CTG'=>'L',
'GTT'=>'V', 'GTC'=>'V', 'GTA'=>'V', 'GTG'=>'V',
'TCT'=>'S', 'TCC'=>'S', 'TCA'=>'S', 'TCG'=>'S',
'CCT'=>'P', 'CCC'=>'P', 'CCA'=>'P', 'CCG'=>'P',
'ACT'=>'T', 'ACC'=>'T', 'ACA'=>'T', 'ACG'=>'T',
'GCT'=>'A', 'GCC'=>'A', 'GCA'=>'A', 'GCG'=>'A',
'CGT'=>'R', 'CGC'=>'R', 'CGA'=>'R', 'CGG'=>'R',
'GGT'=>'G', 'GGC'=>'G', 'GGA'=>'G', 'GGG'=>'G'
);


########## reading genome ##########
open GM, $genome;

my $tit;
my %seq;
while(<GM>){
  chomp;
  if(/>(\S+)/){
    $tit = $1;	
  }else{
    $seq{$tit} .= $_;	
  }	
}
close GM;
print "Genome read already\n";

########## reading GFF3 ##########
open GFF, $gff3;

my $mRNA_name;
my %range;
my %mRNAs;
my @mRNAs;
my %mRNA_scaf;
my %mRNA_strand;

while(<GFF>){
  chomp;
  next if /\#/;
  my @tmp = split/\t/;
  if(/\tmRNA(.+)\=(.+)/){
    $mRNA_name = $2;
    $mRNAs{$mRNA_name}++;
    push @mRNAs,$mRNA_name if $mRNAs{$mRNA_name} == 1;
    $mRNA_scaf{$mRNA_name} = $tmp[0];
    $mRNA_strand{$mRNA_name} = $tmp[6];
  }
  elsif(/CDS\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t/){
    my ($start,$end,$strand) = ($1,$2,$4);
    if($strand eq '+'){
      for my $locus ($start..$end){
        push @{$range{$mRNA_name}},$locus;	
      }
    }
    elsif($strand eq '-'){
      for my $locus (reverse $start..$end){
        push @{$range{$mRNA_name}},$locus;	
      } 	
    }
  }
}
close GFF;

print "GFF3 read already\n";


##########

foreach my $mRNA_name (@mRNAs){
	print OUT1 "\#\#\#$mRNA_name\#\#\#\n";
	my $mRNA_scaf_seq = $seq{$mRNA_scaf{$mRNA_name}};
  my $loci_num = scalar @{$range{$mRNA_name}};
  my $num_codon = $loci_num/3;
  if($num_codon > 0){
    for my $i (1..$num_codon){
      my $start_codon_posi = ${$range{$mRNA_name}}[3*$i - 3];
      my $mid_codon_posi = ${$range{$mRNA_name}}[3*$i - 2];
      my $end_codon_posi = ${$range{$mRNA_name}}[3*$i - 1];
      
      my $start_codon_base = substr($mRNA_scaf_seq,$start_codon_posi - 1 ,1);
      my $mid_codon_base = substr($mRNA_scaf_seq,$mid_codon_posi - 1,1);
      my $end_codon_base = substr($mRNA_scaf_seq,$end_codon_posi - 1,1);
      my $codon_bases = $start_codon_base.$mid_codon_base.$end_codon_base;
      
      if($mRNA_strand{$mRNA_name} eq '+'){
      	if(defined $codons{$codon_bases}){
          print OUT1 "$mRNA_name\t$mRNA_scaf{$mRNA_name}\t$end_codon_posi\t$codon_bases\t$mRNA_strand{$mRNA_name}\n";	
        }
      }
      elsif($mRNA_strand{$mRNA_name} eq '-'){
        $codon_bases =~ tr/ATCG/TAGC/;
        if(defined $codons{$codon_bases}){
        	my $genomic_codon_minus = $codon_bases;
        	$genomic_codon_minus =~ tr/ATCG/TAGC/;
        	$genomic_codon_minus = reverse $genomic_codon_minus;
          print OUT1 "$mRNA_name\t$mRNA_scaf{$mRNA_name}\t$end_codon_posi\t$codon_bases\t$genomic_codon_minus\t$mRNA_strand{$mRNA_name}\n";	
        }
      }
    }
   print OUT1 "\n";
  }
}
