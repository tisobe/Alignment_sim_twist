#!/usr/bin/perl

#########################################################################
#									#
#	alignment_sim_twist_remove_dupl.perl: this script removes 	#
#				duplicated data line from data		#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Nov 4, 2004					#
#									#
#########################################################################

$list = `ls /data/mta/www/mta_sim_twist/Data/*`;
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
