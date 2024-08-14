#!/usr/bin/perl

die "perl $0 <all_pairs.sam> <region_chr> <region_start> <region_end>\n" if(@ARGV != 4);
my $contact_sam=shift;
my $chr=shift;
my $start=shift;
my $end=shift;

open(TGTJ,">junction_site_inTarget.bed") || die;

open(CS,$contact_sam) || die;
while(my $frag_a=<CS>){
	if($frag_a=~/^@/){
		print $frag_a;
		next;
	}
	my $frag_b=<CS>;
	my @sub_a=split/\s+/,$frag_a;
	my @sub_b=split/\s+/,$frag_b;
	my $judge_a=good($frag_a);
	my $judge_b=good($frag_b);
	if($judge_a=~/good/ and $judge_b=~/good/){	#both
		next;
	}
	elsif($judge_a=~/good/ and $judge_b=~/bad/){
		print $frag_a;
		print $frag_b;
		
                $sub_b[1]=$sub_b[1] >= 256 ? $sub_b[1] - 256 : $sub_b[1];
                if($sub_b[1] == 0){
                        print TGTJ $sub_b[2],"\t",$sub_b[3]-1,"\t",$sub_b[3],"\t";
                        print TGTJ $sub_b[0],"\t255\t+\n";
                }
                elsif($sub_b[1] == 16){
                        $sub_b[5]=~/(\d+)M/;
                        my $match_of_b=$1;
                        my $end_of_b=$sub_b[3]+$match_of_b-1;
                        print TGTJ $sub_b[2],"\t",$end_of_b-1,"\t",$end_of_b,"\t";
                        print TGTJ $sub_b[0],"\t255\t-\n";
                }
                else{
                        die "wrong strand flag\n";
                }
	}
	elsif($judge_a=~/bad/ and $judge_b=~/good/){
		print $frag_a;
		print $frag_b;
                $sub_a[1]=$sub_a[1] >= 256 ? $sub_a[1] - 256 : $sub_a[1];
                if($sub_a[1] == 16){
                        print TGTJ $sub_a[2],"\t",$sub_a[3]-1,"\t",$sub_a[3],"\t";
                        print TGTJ $sub_a[0],"\t255\t-\n";
                }
                elsif($sub_a[1] == 0){
                        $sub_a[5]=~/(\d+)M/;
                        my $match_of_a=$1;
                        my $end_of_a=$sub_a[3]+$match_of_a-1;
                        print TGTJ $sub_a[2],"\t",$end_of_a-1,"\t",$end_of_a,"\t";
                        print TGTJ $sub_a[0],"\t255\t+\n";
                }
                else{
                        die "wrong strand flag\n";
                }
	}
	else{
		next;
	}
}
	


sub good{
	my $frag=shift;
	my @arr=split/\s+/,$frag;
	if($arr[2] ne $chr){
		return "bad";
	}
	my $len=length($arr[9]);
	if($arr[3]+$len < $start){
		return "bad";
	}
	if($arr[3] > $end){
		return "bad";
	}
	return "good";
}
