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
		$line =~ s/$last_year/$this_year/g;
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


open(FH, "$web_dir/sim_twist.html");
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

open(OUT, ">$web_dir/sim_twist.html");
foreach $ent (@save){
	print OUT "$ent\n";
}
close(OUT);

