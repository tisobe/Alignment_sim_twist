#!/usr/bin/perl
use PGPLOT;

#########################################################################################
#											#
#	extract.perl: extract dy, dz, and dtheta value, and make trend plots		#
#											#
#		author: t. isobe (tisobe@cfa.harvard.edu)				#
#											#
#		last update: Dec 29, 2004						#
#											#
#########################################################################################


#
#---- two possible input; one from a data file telling date interval to compute
#---- another is to get one month interval from the 1st of the last month to
#---- the last day of the last month. Here we assume that the script is run on
#---- the first of the new month.
#

$file = $ARGV[0];		# if you want to use a data file, here is the input

if($file ne ''){
	open(FH, "$file");
	@date_list = ();
	while(<FH>){
		chomp $_;
		push(@date_list, $_);
	}
	close(FH);

#
#---- otherwise, take a month interval
#

}else{

#
#---- find today's date
#---- and set data colleciton interveral--- a last month
#

	($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);
	$umon++;
	$year = $uyear + 1900;

	if($umon < 10){
		$month = "0$umon";
	}else{
		$month = $umon;
	}
	$lmonth = $umon -1;
	if($lmonth < 10){
		$lmonth = "0$lmonth";
	}
	$lyear  = $year;
	if($lmonth < 1){
		$lmonth = 12;
		$lyear  = $year -1;
	}

	$start = "$lyear"."/$lmonth".'/01'.',00:00:00';
	$stop  = "$year"."/$month".'/01'.',00:00:00';
	$line = "$start\t$stop\n";
	@date_list = ("$line");
}


open(FH, "/data/mta4/MTA/data/.hakama");
while(<FH>){
       	chomp $_;
       	$hakama = $_;
       	$hakama =~ s/\s+//g;
}
close(FH);

open(FH, '/data/mta4/MTA/data/.dare');
while(<FH>){
       	chomp $_;
       	$dare = $_;
       	$dare =~ s/\s+//g;
}
close(FH);

#
#---- create a temporary directory for computation, if there is not one.
#

$alist = `ls -d *`;
@dlist = split(/\s+/, $alist);

OUTER:
foreach $dir (@dlist){
	if($dir =~ /param/){
		system("rm ./param/*");
		last OUTER;
	}
}

system('mkdir ./param');

OUTER:
foreach $dir (@dlist){
	if($dir =~ /Sim_twist_temp/){
		system("rm ./Sim_twist_temp/*");
		last OUTER;
	}
}

system('mkdir ./Sim_twist_temp');


#
#--- here we actually start computation
#

foreach $line (@date_list){
	@atemp = split(/\s+/, $line);
	$tstart = $atemp[0];
	$tstop  = $atemp[1];

#
#---- input file for arc4gl
#
	open(OUT, '>./Sim_twist_temp/input_line');
	print OUT "operation=retrieve\n";
	print OUT "dataset=flight\n";
	print OUT "detector=pcad\n";
	print OUT "subdetector=aca\n";
	print OUT "level=1\n";
	print OUT "version=last\n";
	print OUT "filetype=obcsol\n";
	print OUT "tstart=$tstart\n";
	print OUT "tstop=$tstop\n";
	print OUT "go\n";
	close(OUT);

#
#---- here is actual arc4gl to extract data from the archive
#

	system('rm ./Sim_twist_temp/*fits');
	system("cd ./Sim_twist_temp; echo $hakama  |/home/ascds/DS.release/bin/arc4gl -U$dare -Sarcocc -i./input_line"); 
	system('rm ./Sim_twist_temp/input_line');

#
#---- a few house cleanings
#
	system("gzip -d ./Sim_twist_temp/*gz");

	$line = `ls ./Sim_twist_temp/pcadf*_osol1.fits`;
	@list = split(/\s+/, $line);

#
#----- here is actual data extract sub
#
	extract_data();
}


#
#----- plot routine
#

plot_data();
print_html();
system('rm -rf  ./Sim_twist_temp ./param');

###################################################################################
### extract_data: read fits file, and extract needed data columns               ###
###################################################################################

sub extract_data{

	$cnt    = 0;
	$total  = 0;
	@time   = ();
	@dy     = ();
	@dz     = ();
	@dtheta = ();
#
#-------data_extracted contains a list of time, dy, dz, and dtheta
#-------data_info contains the file information, such as sim_position
#
	open(OUT,  '>> /data/mta/www/mta_sim_twist/Data/data_extracted');
	open(OUT2, '>> /data/mta/www/mta_sim_twist/Data/data_info');
###	open(OUT,  '>> ./Data/data_extracted');
###	open(OUT2, '>> ./Data/data_info');

	foreach $file (@list){

#
#---- use fdump to extact the part we need
#

		system("fdump $file ./Sim_twist_temp/zout time,dy,dz,dtheta - clobber=yes");
		open(FH, "./Sim_twist_temp/zout");
		@ttime   = ();
		@tdy     = ();
		@tdz     = ();
		@tdtheta = ();
		$cnt    = 0;
		while(<FH>){
			chomp $_;
			if($_ =~ /DATE-OBS/){
				@btemp = split(/\'/, $_);
				$date_obs = $btemp[1];
			}elsif($_ =~ /DATE-END/){
				@btemp = split(/\'/, $_);
				$date_end = $btemp[1];
			}elsif($_ =~ /SIM_X/){
				@btemp = split(/\s+/, $_);
				$sim_x = $btemp[2];
			}elsif($_ =~ /SIM_Y/){
				@btemp = split(/\s+/, $_);
				$sim_y = $btemp[2];
			}elsif($_ =~ /SIM_Z/){
				@btemp = split(/\s+/, $_);
				$sim_z = $btemp[2];
			}elsif($_ =~ /PITCHAMP/){
				@btemp = split(/\s+/, $_);
				$pitchamp = $btemp[1];
			}elsif($_ =~ /YAWAMP/){
				@btemp = split(/\s+/, $_);
				$yawamp = $btemp[2];
			}
		

			@atemp = split(/\s+/, $_);
			if($atemp[1] =~ /\d/ && $atemp[2] =~ /\d/){
				push(@ttime,  $atemp[2]);
				push(@tdy,    $atemp[3]);
				push(@tdz,    $atemp[4]);
				push(@tdtheta, $atemp[5]);
				$cnt++;
			}
		}
		close(FH);
		system("rm ./Sim_twist_temp/zout");

		@ctemp = split(/\//, $file);
		print OUT2 "$ctemp[2]\t$date_obs\t$date_end\t$sim_x\t$sim_y\t$sim_z\t";
		print OUT2 "$pitchamp\t$yawamp\n";

#
#--- check time sequence so that there is no duplicated lines
#
		if($total  ==  0){
			for($i = 0; $i < $cnt; $i++){
				$time[$i]   = $ttime[$i];
				$dy[$i]     = $tdy[$i];
				$dz[$i]     = $tdz[$i];
				$dtheta[$i] = $tdtheta[$i];
#
#--- print out only when dy, dz, or dtheta have values
#
				if($dy[$i] > 0 || $dz[$i] > 0 || $dtheta[$i]> 0){
					print OUT "$time[$i]\t$dy[$i]\t$dz[$i]\t$dtheta[$i]\n";
#					print  "$time[$i]\t$dy[$i]\t$dz[$i]\t$dtheta[$i]\n";
				}
			}
		$total = $cnt;
		}else{
			for($i = 0; $i < $cnt; $i++){
				if($time[$total -1] < $ttime[$i]){
					$time[$total]   = $ttime[$i];
					$dy[$total]     = $tdy[$i];
					$dz[$total]     = $tdz[$i];
					$dtheta[$total] = $tdtheta[$i];
					$total++;
	
					if($dy[$total] > 0 || $dz[$total] > 0 || $dtheta[$total] > 0){
						print OUT "$time[$total]\t$dy[$total]\t$dz[$total]\t$dtheta[$total]\n";
					}
				}
			}
		}
	}
	close(OUT);
}


##########################################################################
### plot_data: plotting data                                           ###
##########################################################################

sub plot_data{

	open(FH, '/data/mta/www/mta_sim_twist/Data/data_extracted');
###	open(FH, './Data/data_extracted');
	@time   = ();
	@dy     = ();
	@dz     = ();
	@dtheta = ();
	$dcnt   = 0;
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		$dom = $atemp[0]/86400 - 567;
		push(@time,   $dom);
		push(@dy,     $atemp[1]);
		push(@dz,     $atemp[2]);
		push(@dtheta, $atemp[3]);
		$dcnt++;
	}
	close(FH);

	if($dcnt > 0){
		open(OUT, "> ./sim_temp_file");
		print OUT "Sim Twist got non-zero entry. Check: \n";
		print OUT 'http://cxc.harvard.edu/mta_days/mta_sim_twist/fid_light_drift.html',"\n";
		system("cat ./sim_temp_file |mailx -s \"Subject: Sim Twist got NON-ZERO value !!\n\" -r cus\@head.cfa.harvard.edu  isobe\@head.cfa.harvard.edu");
		system("rm ./sim_temp_file");
	}


	open(FH, '/data/mta/www/mta_sim_twist/Data/data_info');
###	open(FH, './Data/data_info');
	@date     = ();
	@sim_x    = ();
	@sim_y    = ();
	@sim_z    = ();
	@pitchamp = ();
	@yawamp   = ();
	$icnt     = 0;
	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		@btemp = split(/T/, $atemp[1]);
		@ctemp = split(/-/, $btemp[0]);
		$year = $ctemp[0];
		$month = $ctemp[1];
		$date  = $ctemp[2];
		@dtemp = split(/:/, $btemp[1]);
		$hour  = $dtemp[0];
		$min   = $dtemp[1];
		$sec   = $dtemp[2];	
		
		$dyear = $year - 2000;
		$year_day = 365 * $dyear + 163;
		if($year > 2000) {
			$year_day++;
		}
		if($year > 2004) {
			$year_day++;
		}
		if($year > 2008) {
			$year_day++;
		}
		if($year > 2012) {
			$year_day++;
		}
		if($month == 1){
			$add = 0;
		}elsif($month == 2){
			$add = 31;
		}elsif($month == 3){
			$add = 59;
		}elsif($month == 4){
			$add = 90;
		}elsif($month == 5){
			$add = 120;
		}elsif($month == 6){
			$add = 151;
		}elsif($month == 7){
			$add = 181;
		}elsif($month == 8){
			$add = 212;
		}elsif($month == 9){
			$add = 243;
		}elsif($month == 10){
			$add = 273;
		}elsif($month == 11){
			$add = 304;
		}elsif($month == 12){
			$add = 333;
		}
		if($year == 2000 || $year == 2004 || $year == 2008 || $year == 2012){
			if($month > 2){
				$add++;
			}
		}
		$add += $year_day;
		$add += $date;
		$add += ($hour/24 + $min/1440 + $sec/86400);

		push(@date,     $add);
		push(@sim_x,    $atemp[3]);
		push(@sim_y,    $atemp[4]);
		push(@sim_z,    $atemp[5]);
		push(@pitchamp, $atemp[6]);
		push(@yawamp,   $atemp[7]);
		$icnt++;
	}
	close(FH);

	$xmin  = $date[0];
	$xmax  = $date[$icnt -1];
	$xdiff = $xmax - $xmin;
	$xmin  = $min - 0.01 * $xdiff;
	if($xmin < 0){
		$xmin = 0;
	}
	$xmax  = $xmax + 0.01 * $xdiff;
	$xmid  = $xmin + 0.50 * $xdiff;
	$xside = $xmin - 0.10 * $xdiff;
			
	@temp        = sort{$a<=>$b} @sim_x;
	$ymin_sim_x  = $temp[0];
	$ymax_sim_x  = $temp[$icnt -1];
	$ydiff       = abs($ymax_sim_x - $ymin_sim_x);
	$ymin_sim_x  = $ymin_sim_x - 0.01 * $ydiff;
	$ymax_sim_x  = $ymax_sim_x + 0.01 * $ydiff;
	$ymid_sim_x  = $ymin_sim_x + 0.50 * $ydiff;
	$yside_sim_x = $ymin_sim_x + 0.50 * $ydiff;
	$ytop_sim_x  = $ymax_sim_x + 0.05 * $ydiff;
	$ybot_sim_x  = $ymin_sim_x - 0.20 * $ydiff;

	@temp        = sort{$a<=>$b} @sim_y;
	$ymin_sim_y  = $temp[0];
	$ymax_sim_y  = $temp[$icnt -1];
	$ydiff       = abs($ymax_sim_y - $ymin_sim_y);
	if($ydiff == 0){
		$ymin_sim_y =-1;
		$ymax_sim_y = 1;
		$ydiff      = 2;
	}
	$ymin_sim_y  = $ymin_sim_y - 0.01 * $ydiff;
	$ymax_sim_y  = $ymax_sim_y + 0.01 * $ydiff;
	$ymid_sim_y  = $ymin_sim_y + 0.50 * $ydiff;
	$yside_sim_y = $ymin_sim_y + 0.50 * $ydiff;
	$ytop_sim_y  = $ymax_sim_y + 0.05 * $ydiff;
	$ybot_sim_y  = $ymin_sim_y - 0.20 * $ydiff;

	@temp        = sort{$a<=>$b} @sim_z;
	$ymin_sim_z  = $temp[0];
	$ymax_sim_z  = $temp[$icnt -1];
	$ydiff       = abs($ymax_sim_z - $ymin_sim_z);
	$ymin_sim_z  = $ymin_sim_z - 0.01 * $ydiff;
	$ymax_sim_z  = $ymax_sim_z + 0.01 * $ydiff;
	$ymid_sim_z  = $ymin_sim_z + 0.50 * $ydiff;
	$yside_sim_z = $ymin_sim_z + 0.50 * $ydiff;
	$ytop_sim_z  = $ymax_sim_z + 0.05 * $ydiff;
	$ybot_sim_z  = $ymin_sim_z - 0.20 * $ydiff;

	@temp           = sort{$a<=>$b} @pitchamp;
	$ymin_pitchamp  = $temp[0];
	$ymax_pitchamp  = $temp[$icnt -3];
	$ydiff          = abs($ymax_pitchamp - $ymin_pitchamp);
	$ymin_pitchamp  = $ymin_pitchamp - 0.01 * $ydiff;
	$ymax_pitchamp  = $ymax_pitchamp + 0.01 * $ydiff;
	$ymid_pitchamp  = $ymin_pitchamp + 0.50 * $ydiff;
	$yside_pitchamp = $ymin_pitchamp + 0.50 * $ydiff;
	$ytop_pitchamp  = $ymax_pitchamp + 0.05 * $ydiff;
	$ybot_pitchamp  = $ymin_pitchamp - 0.20 * $ydiff;

	@temp         = sort{$a<=>$b} @yawamp;
	$ymin_yawamp  = $temp[0];
	$ymax_yawamp  = $temp[$icnt -3];
	$ydiff        = abs($ymax_yawamp - $ymin_yawamp);
	$ymin_yawamp  = $ymin_yawamp - 0.01 * $ydiff;
	$ymax_yawamp  = $ymax_yawamp + 0.01 * $ydiff;
	$ymid_yawamp  = $ymin_yawamp + 0.50 * $ydiff;
	$yside_yawamp = $ymin_yawamp + 0.50 * $ydiff;
	$ytop_yawamp  = $ymax_yawamp + 0.05 * $ydiff;
	$ybot_yawamp  = $ymin_yawamp - 0.20 * $ydiff;

	
	$ymin_dy     = -0.1;
	$ymax_dy     =  0.1;
	$ymin_dz     = -0.1;
	$ymax_dz     =  0.1;
	$ymin_dtheta = -0.1;
	$ymax_dtheta =  0.1;
	$ydiff       =  0.2;

	if($dcnt > 0){
		@temp    = sort{$a<=>$b} @dy;
		$ymin_dy = $temp[0];
		$ymax_dy = $temp[$dcnt -1];
		$ydiff   = abs($ymax_dy - $ymin_dy);
		if($ydiff > 0){
			$ymin_dy = $ymin_dy - 0.01 * $ydiff;
			$ymax_dy = $ymax_dy + 0.01 * $ydiff;
		}

		@temp    = sort{$a<=>$b} @dz;
		$ymin_dz = $temp[0];
		$ymax_dz = $temp[$dcnt -1];
		$ydiff   = $ymax_dz - $ymin_dz;
		if($ydiff > 0){
			$ymin_dz = $ymin_dz - 0.01 * $ydiff;
			$ymax_dz = $ymax_dz + 0.01 * $ydiff;
		}

		@temp        = sort{$a<=>$b} @dtheta;
		$ymin_dtheta = $temp[0];
		$ymax_dtheta = $temp[$dcnt -1];
		$ydiff       = $ymax_dtheta - $ymin_dtheta;
		if($ydiff > 0){
			$ymin_dtheta = $ymin_dtheta - 0.01 * $ydiff;
			$ymax_dtheta = $ymax_dtheta + 0.01 * $ydiff;
		}
	}

	$ymid_dy      = $ymin_dy + 0.50 * $ydiff;
	$yside_dy     = $ymin_dy + 0.50 * $ydiff;
	$ytop_dy      = $ymax_dy + 0.05 * $ydiff;
	$ybot_dy      = $ymin_dy - 0.20 * $ydiff;
	$ymid_dz      = $ymin_dz + 0.50 * $ydiff;
	$yside_dz     = $ymin_dz + 0.50 * $ydiff;
	$ytop_dz      = $ymax_dz + 0.05 * $ydiff;
	$ybot_dz      = $ymin_dz - 0.20 * $ydiff;
	$ymid_dtheta  = $ymin_dtheta + 0.50 * $ydiff;
	$yside_dtheta = $ymin_dtheta + 0.50 * $ydiff;
	$ytop_dtheta  = $ymax_dtheta + 0.05 * $ydiff;
	$ybot_dtheta  = $ymin_dtheta - 0.20 * $ydiff;

	pgbegin(0, '"./Sim_twist_temp/pgplot.ps"/cps',1,1);
	pgsch(1);
	pgslw(3);

	$color  = 2;
	$symbol = 2;

	$total = $icnt;
	@xbin  = @date;

	pgsvp(0.1, 0.8, 0.82,1.0);
	pgswin($xmin, $xmax, $ymin_sim_x, $ymax_sim_x);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_sim_x, 90.0, 0.5, "sim_x");
	@ybin = @sim_x;
	plot_fig();

	$color = 4;

	pgsvp(0.1, 0.8, 0.64,0.82);
	pgswin($xmin, $xmax, $ymin_sim_y, $ymax_sim_y);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_sim_y, 90.0, 0.5, "sim_y");
	@ybin = @sim_y;
	plot_fig();

	$color = 2;

	pgsvp(0.1, 0.8, 0.46,0.64);
	pgswin($xmin, $xmax, $ymin_sim_z, $ymax_sim_z);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_sim_z, 90.0, 0.5, "sim_z");
	@ybin = @sim_z;
	plot_fig();

	$color = 4;

	pgsvp(0.1, 0.8, 0.28,0.46);
	pgswin($xmin, $xmax, $ymin_pitchamp, $ymax_pitchamp);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_pitchamp, 90.0, 0.5, "pitchamp");
	@ybin = @pitchamp;
	plot_fig();

	$color = 2;

	pgsvp(0.1, 0.8, 0.10,0.28);
	pgswin($xmin, $xmax, $ymin_yawamp, $ymax_yawamp);
	pgbox(ABCNSTV,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_yawamp, 90.0, 0.5, "yawamp");
	@ybin = @yawamp;
	plot_fig();

	pgptxt($xmid,$ybot_yawamp, 0.0, 0.5, "Time (DOM)");
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  ./Sim_twist_temp/pgplot.ps|/data/mta4/MTA/bin/pnmcrop| /data/mta4/MTA/bin/pnmcrop| pnmflip -r270 |ppmtogif > /data/mta/www/mta_sim_twist/Plots/sim_plot.gif");

	system("rm ./Sim_twist_temp/pgplot.ps");

	pgbegin(0,'"./Sim_twist_temp/pgplot.ps"/cps',1,1);

	pgsch(1);
	pgslw(3);

	$total = $dcnt;
	$color = 2;

	pgsvp(0.1, 0.8, 0.70,0.95);
	pgswin($xmin, $xmax, $ymin_dy, $ymax_dy);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_dy, 90.0, 0.5, "dy");
	@ybin = @dy;
	plot_fig();

	$color = 4;

	pgsvp(0.1, 0.8, 0.45,0.70);
	pgswin($xmin, $xmax, $ymin_dz, $ymax_dz);
	pgbox(ABCST,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_dz, 90.0, 0.5, "dz");
	@ybin = @dz;
	plot_fig();

	$color = 2;

	pgsvp(0.1, 0.8, 0.20,0.45);
	pgswin($xmin, $xmax, $ymin_dtheta, $ymax_dtheta);
	pgbox(ABCNSTV,0.0 , 0.0, ABCNSTV, 0.0, 0.0);
	pgptxt($xside,$ymid_dtheta, 90.0, 0.5, "dtheta");
	@ybin = @dtheta;
	plot_fig();

	pgptxt($xmid,$ybot_dtheta, 0.0, 0.5, "Time (DOM)");
	pgclos();

	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  ./Sim_twist_temp/pgplot.ps | /data/mta4/MTA/bin/pnmcrop||/data/mta4/MTA/bin/pnmcrop| pnmflip -r270 |ppmtogif > /data/mta/www/mta_sim_twist/Plots/twist_plot.gif");
###	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  ./Sim_twist_temp/pgplot.ps | /data/mta4/MTA/bin/pnmcrop||/data/mta4/MTA/bin/pnmcrop| pnmflip -r270 |ppmtogif > ./Plots/twist_plot.gif");

	system("rm ./Sim_twist_temp/pgplot.ps");
}

########################################################
### plot_fig: plotting data points on a fig          ###
########################################################

sub plot_fig{
        pgsci($color);
        for($m = 0; $m < $total; $m++){
                pgpt(1, $xbin[$m], $ybin[$m], $symbol);
        }
        pgsci(1);
}

########################################################
### print_html: print Sim_twist html page            ###
########################################################


sub print_html{
	open(OUT, '>/data/mta/www/mta_sim_twist/sim_twist.html');
	print OUT '<html>',"\n";
	print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000", background ="./stars.jpg">',"\n";
	print OUT '<h2>SIM Shift and Twist Trends</h2>',"\n";
	print OUT '<p>',"\n";
	print OUT 'This page shows trends of SIM shifts (dy and dz) and twist (dtheta). All quantities are directly taken from',"\n";
	print OUT 'pcaf*_osol1.fits files. The units are mm for dy and dz, and degree for dtheta. At September 22, 2004,',"\n";
	print OUT 'there is no shifts or twiist are observed, and all values are zero.',"\n";
	print OUT '<br><br>',"\n";
	print OUT "<img src='./Plots/twist_plot.gif' width='600' height='600'>","\n";
	print OUT '<br><br>',"\n";
	print OUT "<a href='data_extracted'>ASCII Data --- currently empty</a>","\n";
	print OUT '',"\n";
	print OUT '<p>',"\n";
	print OUT 'From the same fits file, we also collected sim_x,y, and z postions, pitch amp, and yaw amp of dithers.',"\n";
	print OUT '<br><br>',"\n";
	print OUT "<img src='./Plots/sim_plot.gif' width='600' height='600'>","\n";
	print OUT '<br><br>',"\n";
	print OUT "<a href='data_info'>ASCII Data</a>","\n";
	print OUT '</body>',"\n";
	print OUT '</html>',"\n";

	close(OUT);
}

