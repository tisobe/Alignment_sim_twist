#!/usr/bin/perl

#########################################################################
#									#
#	alignment_sim_twist_remove_dupl.perl: this script removes 	#
#				duplicated data line from data		#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Mar 15, 2011					#
#									#
#########################################################################

############################################################
#---- set directries

open(FH, "/data/mta/Script/ALIGNMENT/Sim_twist/house_keeping/dir_list");
@atemp = ();
while(<FH>){
        chomp $_;
        push(@atemp, $_);
}
close(FH);

$bin_dir       = $atemp[0];
$bdata_dir     = $atemp[1];
$web_dir       = $atemp[2];
$data_dir      = $atemp[3];
$house_keeping = $atemp[4];

############################################################

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$umon++;
$year = $uyear + 1900;

if($umon <= 1){
	$year--;
}
$name  = 'data_*_'."$year";

$list = `ls $data_dir/H-* $data_dir/I-* $data_dir/S-* $data_dir/$name`;
@list = split(/\s+/, $list);

foreach $file (@list){
	open(FH, "$file");
	@orig = ();
	while(<FH>){
		chomp $_;
		push(@orig, $_);
	}
	close(FH);
	@sorted_orig = sort{$a<=>$b} @orig;
	$comp = shift(@orig);
	@new = ($comp);
	OUTER:
	foreach $ent (@orig){
		if($ent eq $comp){
			next OUTER;
		}else{
			push(@new, $ent);
			$comp = $ent;
		}
	}

	open(OUT, ">$file");
	foreach $ent (@new){
		print OUT "$ent\n";
	}
}
