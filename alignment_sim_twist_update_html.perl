#!/usr/bin/perl

#########################################################################
#									#
#  alignment_sim_twist_update_html.perl: update sim twist html pages	#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Jul 07, 2005					#
#									#
#########################################################################

#
#---- set output directory
#

$twist_www = '/data/mta_www/mta_sim_twist/';

#
#----  update the html page
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year  = 1900   + $uyear;
$month = $umon  + 1;

$line = "<br><br><H3> Last Update: $month/$umday/$year</H3><br>";

open(OUT, ">./date_file");
print OUT "\n$line\n";
close(OUT);

$lyear     = $year -1;
$last_year = 'sim_twist_'."$lyear".'.html';
$this_year = 'sim_twist_'."$year".'.html';

$check = `ls /data/mta/www/mta_sim_twist/*html`;
if($check !~ /$this_year/){
	open(FH,  "/data/mta/www/mta_sim_twist/$last_year");
	open(OUT, ">/data/mta/www/mta_sim_twist/$this_year");
	while(<FH>){
		chomp $_;
		$line = $_;
		$line =~ s/$last_year/$this_year/g;
		print OUT "$line\n";
	}
	close(OUT);
	close(FH);
	for($qtr = 0; $qtr < 4; $qtr++){
		$file1 = 'twist_plot_'."$this_year".'_'."$qtr".'.gif';
		$file2 = 'dtheta_plot_'."$this_year".'_'."$qtr".'.gif';
		system("cp /data/mta/www/mta_sim_twist/Plots/no_data.gif /data/mta/mta_sim_twist/Plots/$file1");
		system("cp /data/mta/www/mta_sim_twist/Plots/no_data.gif /data/mta/mta_sim_twist/Plots/$file2");
	}
	$lchk = "Year $lyear";
	@save = ();
	open(FH, "/data/mta/www/mta_sim_twist/sim_twist.html");
	while(<FH>){
		chomp $_;
		if($_ =~ /$lchk/){
			push(@save, $_);
			$line = "<a href='./sim_twist_"."$year".".html'> Plots for Year "."$year"."</a><br>";
			push(@save, $line);
		}else{
			push(@save, $_);
		}
	}
	close(FH);
	open(OUT, ">/data/mta/www/mta_sim_twist/sim_twist.html");
	foreach $ent (@save){
		print OUT "$ent\n";
	}
	close(OUT);
}
	

system("cat $twist_www/house_keeping/fid_light_drift.html ./date_file > $twist_www/fid_light_drift.html");
system("cat $twist_www/house_keeping/sim_twist.html ./date_file > $twist_www/sim_twist.html");

system("rm ./date_file");

