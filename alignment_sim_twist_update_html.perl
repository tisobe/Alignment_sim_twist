#!/usr/bin/perl

#########################################################################
#									#
#  alignment_sim_twist_update_html.perl: update sim twist html pages	#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#									#
#	last update: Jan 05, 2005					#
#									#
#########################################################################

############################################################
#---- set directries

$web_dir       = '/data/mta_www/mta_sim_twist/';
$bin_dir       = '/data/mta/MTA/bin/';
$data_dir      = '/data/mta/MTA/data/';
$house_keeping = '/house_keeping/';

############################################################

#
#----  update the html page
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year  = 1900   + $uyear;
$month = $umon  + 1;

$date_line = "<br><br><H3> Last Update: $month/$umday/$year</H3><br>";

$lyear     = $year -1;
$last_year = 'sim_twist_'."$lyear".'.html';
$this_year = 'sim_twist_'."$year".'.html';

$check = `ls $web_dir/*html`;
if($check !~ /$this_year/){
	open(FH,  "$web_dir/$last_year");
	open(OUT, ">$web_dir/$this_year");
	while(<FH>){
		chomp $_;
		$line = $_;
		$line =~ s/$lyear/$year/g;
		print OUT "$line\n";
	}
	close(OUT);
	close(FH);
	for($qtr = 0; $qtr < 4; $qtr++){
		$file1 = 'twist_plot_'."$this_year".'_'."$qtr".'.gif';
		$file2 = 'dtheta_plot_'."$this_year".'_'."$qtr".'.gif';
		system("cp $data_dir/no_data.gif $web_dir/Plots/$file1");
		system("cp $data_dir/no_data.gif $web_dir/Plots/$file2");
	}
	$lchk = "year: $lyear";
	@save = ();
	open(FH, "$web_dir/sim_twist.html");
	while(<FH>){
		chomp $_;
		if($_ =~ /$lchk/){
			push(@save, $_);
			$line = "<a href='./sim_twist_"."$year".".html'> Plots for year: "."$year"."</a><br>";
			push(@save, $line);
		}else{
			push(@save, $_);
		}
	}
	close(FH);

	open(OUT, ">$web_dir/sim_twist.html");
	foreach $ent (@save){
		print OUT "$ent\n";
	}
	close(OUT);
}
	
#
#--- update sim html page
#

print_sim_page();

#
#--- update the reneal date
#

open(FH, "$web_dir/fid_light_drift.html");
@save = ();
while(<FH>){
	chomp $_;
	if($_ =~ /Last Update/){
		push(@save, $date_line);
	}else{
		push(@save, $_);
	}
}
close(FH);

open(OUT, ">$web_dir/fid_light_drift.html");
foreach $ent (@save){
	print OUT "$ent\n";
}
close(OUT);


#open(FH, "$web_dir/sim_twist.html");
#@save = ();
#while(<FH>){
#	chomp $_;
#	if($_ =~ /Last Update/){
#		push(@save, $date_line);
#	}else{
#		push(@save, $_);
#	}
#}
#close(FH);
#
#open(OUT, ">$web_dir/sim_twist.html");
#foreach $ent (@save){
#	print OUT "$ent\n";
#}
#close(OUT);


########################################################################
########################################################################
########################################################################

sub print_sim_page{
	open(OUT, ">$web_dir/sim_twist.html");

	print OUT '<html>',"\n";
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="yellow" VLINK="yellow" ALINK="yellow", background ="./stars.jpg">',"\n";
	print OUT '<h2>SIM Shift and Twist Trends</h2>',"\n";
	print OUT '<p>',"\n";
	print OUT 'This page shows trends of SIM shifts (dy and dz) and twist (dtheta). All quantities are directly taken from',"\n";
	print OUT 'pcaf*_asol1.fits files. The units are mm for dy and dz, and second  for dtheta.',"\n";
	print OUT 'We fit three lines separated before (Days of Mission)= 1400 (May 21, 2003),',"\n";
	print OUT 'between 1400 and 2700 (Dec 11, 2006), and after 2700.',"\n";
	print OUT 'The unit of slopes are mm per day or second per day.',"\n";
	print OUT '<p> These sudden shifts were due to fid light drift',"\n";
	print OUT ' (see a memo by Aldocroft<a href=',"\n";
	print OUT '"http://cxc.harvard.edu/mta/ASPECT/fid_drift/"> fiducial light drfit</a>).',"\n";
	print OUT '<br><br>',"\n";
	print OUT "<img src='./Plots/twist_plot.gif' width='600' height='600'>","\n";
	print OUT '<br><br>',"\n";
	print OUT '<p>For dtheta, data are further devided into smaller groups according to which instrument was used (',"\n";
	print OUT 'ACIS-I, ACIS-S,',"\n";
	print OUT 'HRC-I, and HRC-S)<br><br>',"\n";
	print OUT "<img src='./Plots/dtheta_plot.gif' width='600' height='600'>","\n";




	print OUT '<p> Followings are similar plots for each year',"\n";
	print OUT '<br><br>';
	for($iyr = 1999; $iyr <= $year; $iyr++){
		print OUT "<a href='./sim_twist_$iyr",'.html';
		print OUT "'> Plots for year:  $iyr";
		print OUT "</a><br>","\n";
	}




	print OUT '<p> Followings are ASCII data tables for the data plotted above. The entires are time in seconds from',"\n";
 	print OUT 'Jan 1, 1998, dy, dz, and dtheta. All entires are 5 min avaerage.<br><br>',"\n";
	for($iyr = 1999; $iyr <= $year; $iyr++){
		print OUT "<a href='./Data/data_extracted_$iyr";
		print OUT "'> ASCII Data for year:  $iyr";
		print OUT "</a><br>","\n";
	}
	print OUT '<p>',"\n";
	print OUT 'From the same fits files, we also collected sim_x,y, and z postions, pitch amps, and yaw amps of dithers',"\n";
	print OUT '<br><br>',"\n";
	print OUT "<img src='./Plots/sim_plot.gif' width='600' height='600'>","\n";
	print OUT '<br><br>',"\n";
	print OUT '<p>Followings are ASCII data tables for the data plotted above. The entries are Fits file name,',"\n";
 	print OUT 'tstart, tstop, sim_x, sim_y, sim_z, pitchamp, and yawamp.<br><br>',"\n";
	for($iyr = 1999; $iyr <= $year; $iyr++){
		print OUT "<a href='./Data/data_info_$iyr";
		print OUT "'> ASCII Data for year:  $iyr";
		print OUT "</a><br>","\n";
	}

	print OUT '<br><br>';
	print OUT "$date_line\n";
	print OUT '</body>',"\n";
	print OUT '</html>',"\n";

	close(OUT);
}

