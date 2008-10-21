#!/usr/bin/perl

#########################################################################
#									#
#	alignment_sim_twist_remove_dupl.perl: this script removes 	#
#				duplicated data line from data		#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Oct 21, 2008					#
#									#
#########################################################################

############################################################
#---- set directries

$web_dir       = '/data/mta_www/mta_sim_twist/';
$bin_dir       = '/data/mta/MTA/bin/';
$data_dir      = '/data/mta/MTA/data/';
$house_keeping = '/house_keeping/';

############################################################

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
$umon++;
$year = $uyear + 1900;

if($umon <= 1){
	$year--;
}
$name  = 'data_*_'."$year";

$list = `ls $web_dir/Data/H-* $web_dir/Data/I-* $web_dir/Data/S-* $web_dir/Data/$name`;
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
