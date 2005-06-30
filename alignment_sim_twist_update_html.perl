#!/usr/bin/perl

#########################################################################
#									#
#  alignment_sim_twist_update_html.perl: update sim twist html pages	#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Jun 30, 2005					#
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

system("cat $twist_www/house_keeping/fid_light_drift.html ./date_file > $twist_www/fid_light_drift.html");
system("cat $twist_www/house_keeping/sim_twist.html ./date_file > $twist_www/sim_twist.html");

system("rm ./date_file");

