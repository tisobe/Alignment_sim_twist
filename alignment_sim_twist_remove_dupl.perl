#!/usr/bin/perl

#########################################################################
#									#
#	alignment_sim_twist_remove_dupl.perl: this script removes 	#
#				duplicated data line from data		#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Aug 16, 2005					#
#									#
#########################################################################

############################################################
#---- set directries

$web_dir       = '/data/mta_www/mta_sim_twist/';
$bin_dir       = '/data/mta/MTA/bin/';
$data_dir      = '/data/mta/MTA/data/';
$house_keeping = '/house_keeping/';

############################################################


$list = `ls $web_dir/Data/*`;
@list = split(/\s+/, $list);

foreach $file (@list){
	open(FH, "$file");
	@orig = ();
	while(<FH>){
		chomp $_;
		push(@orig, $_);
	}
	close(FH);
	$first = shift(@orig);
	@new = ($first);
	OUTER:
	foreach $ent (@orig){
		foreach $comp (@new){
			if($ent eq $comp){
				next OUTER;
			}
		}
		push(@new, $ent);
	}

	open(OUT, ">$file");
	foreach $ent (@new){
		print OUT "$ent\n";
	}
}
