#!/usr/bin/perl


my $hapmapfile = shift or die "Hapmapfile?";

open IN, $hapmapfile;
open OUT, ">$hapmapfile.faststructure.str";

my %num2id;
my @sortednames;

my %base2num = (
  'A' => '1',
  'T' => '2',
  'C' => '3',
  'G' => '4',
  '-' => '-9'
);

my $line;
my $count;

while(<IN>){
  chomp;
  $line++;
  my @tmp = split/\t/;
  if($line == 1){
  	for my $i (11..$#tmp){
      $num2id{$i} = $tmp[$i];
      push @sortednames,$tmp[$i];
    }
  }else{
    for my $i (11..$#tmp){
      push @{$num2id{$i}},$tmp[$i];	
    }
  }
}

foreach my $id (@sortednames){
	   $count++;
	my $nums1 = '';
	my $nums2 = '';
  foreach my $bases (@{$id}){
     my $firstbase = substr($bases,0,1);
     my $secondbase = substr($bases,1,1);
     my $num1 = $base2num{$firstbase};
     my $num2 = $base2num{$secondbase};
      $nums1 .= $num1."\t";
      $nums2 .= $num2."\t";
  }	
  chop $nums1;
  chop $nums2;
  print OUT "$count\t$nums1\n";
  print OUT "$count\t$nums2\n";
}