#!/usr/bin/perl
use PGPLOT;

#########################################################################################
#											#
#	alignment_sim_twist_fid_trend_plots.perl: plot aca i and j postion shifts	#
#			  			  for each CCDs				#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#											#
#	last update: Nov 04, 2004							#
#											#
#########################################################################################

#
#--- some initial settings
#--- 	a list of detector names
#---    a number of sub plots for each detector
#--     an approximate mean of each subplots. if -999, no plot (only one plot instead of two)
#---    plot width for acent j
#---    dom stating date.
#

@detector_list  = ('I-1','I-2','I-3','I-4','I-5','I-6','S-1','S-2','S-3','S-4','S-5','S-6');
#@detector_list  = ('I-3');

@sub_plot_cnt   = (2, 2, 1, 2, 1, 1, 2, 2, 1, 2, 1, 1);
@sub_plot_cent1 = (-257.0, -257.0,  206, 206.5,  217, 346.5,-343.5, -344.5, 119.5, 40.0, 37.5, 167.0);
@sub_plot_cent2 = (-163.5, -165.0, -999, 219.0, -999, -999, -88.0,  -86.0, -999,  119.5, -999,-999);

$interval = 6;
$plot_begin = 0;

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
#---- find today's dom
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year = 1900 + $uyear;
$add  = 365 * ($year - 2000) + 163;

if($year > 2000){
	$add++;
}
if($year > 2004){
	$add++;
}
if($year > 2008){
	$add++;
}
if($year > 2012){
	$add++;
}

$dom_today = $uyday + $add;

#
#---- start plottings
#

$det_cnt = 0;
$xmin  = $plot_begin;
$xmax  = $dom_today;
$xdiff = $xmax - $xmin;
$xmid  = $xmin + 0.50 * $xdiff;
$xside = $xmin - 0.10 * $xdiff;
$xside2 = $xmax - 0.20 * $xdiff;
$step  = 0.15 * $xdiff;

foreach $detector (@detector_list){

#print "$detector\n";

#
#---- read data in (I-1, I-2, ....)
#
	$input = '/data/mta/www/mta_sim_twist/Data/'."$detector";

	open(FH, "$input");
	@time   = ();
	@fid    = ();
	@acenti = ();
	@acentj = ();
	@fa     = ();
	@tsc    = ();
	$cnt    = 0 ;

	while(<FH>){
		chomp $_;
		@atemp = split(/\s+/, $_);
		$dom = $atemp[0]/86400 - 567;
		push(@time,   $dom);
		push(@fid,    $atemp[2]);
#		push(@acenti, $atemp[4]);
		push(@acentj, $atemp[5]);
		push(@fa,     $atemp[8]);
		push(@tsc,    $atemp[9]);
		$cnt++;
	}
	close(FH);

	@fid_id = ($fid[0]);
	$fid_no = 1;
	$fid_no1 =2;
	%{fid_color.$fid[0]} = (color =>["$fid_no1"]);
	OUTER:
	for($i = 1; $i< $cnt; $i++){
		foreach $comp (@fid_id){
			if($fid[$i] == $comp){
				next OUTER;
			}
		}
		push(@fid_id, $fid[$i]);
		$fid_no++;
		$fid_no1 += 2;
		%{fid_color.$fid[$i]} = (color =>["$fid_no1"]);
	}
		
	for($i = 0; $i < $sub_plot_cnt[$det_cnt]; $i++){
		$i1 = $i + 1;
		$line = 'sub_plot_cent'."$i1";
		$app_mean = ${$line}[$det_cnt];
		$bot      = $app_mean - 0.5 * $interval;
		$top      = $app_mean + 0.5 * $interval;
		$mean = 0; 
		$mcnt = 0;
		foreach $ent (@acentj){
			if($ent >= $bot && $ent < $top){
				$mean += $ent;
				$mcnt++;
			}
		}
		if($mcnt > 0){
			${mean.$i} = $mean/$mcnt;
		}else{
			${mean.$i} = $app_mean;
		}
	}

	@xbin = @time;
	@ybin = @acentj;
	$total = $cnt;

	pgbegin(0, '"./Sim_twist_temp/pgplot.ps"/cps',1,1);
	pgsch(1);
	pgslw(3);

	@temp = sort{$a<=>$b} @acentj;
	$ymin = $temp[0];
	$ymax = $temp[$cnt -1];
	$ydiff = $ymax - $ymin;
	$ymin -= 0.05 * $ydiff;
	$ymax += 0.05 * $ydiff;

	pgsvp(0.1, 0.9, 0.7, 0.98);
	pgswin($xmin, $xmax, $ymin, $ymax);
	pgbox(ABCST,0.0, 0.0, ABCNSTV, 0.0, 0.0);

	plot_fig();

#	pgptxt($xside,$ymid, 90.0, 0.5, "ACENT J");


	for($l = 0; $l < $sub_plot_cnt[$det_cnt]; $l++){
		$ymin = ${mean.$l} - 0.5 * $interval; 
		$ymax = ${mean.$l} + 0.5 * $interval; 
		$y1 = 0.4  - 0.3 * $l;
		$y2 = 0.68 - 0.3 * $l;
		pgsvp(0.1, 0.9, $y1, $y2);
		pgswin($xmin, $xmax, $ymin, $ymax);
		if($l < $sub_plot_cnt[$det_cnt] -1){
			pgbox(ABCST,0.0, 0.0, ABCNSTV, 0.0, 0.0);
		}else{
			pgbox(ABCNST,0.0, 0.0, ABCNSTV, 0.0, 0.0);
		}
	
		plot_fig();

		$ylin1 = $int + $slope * $xmin;
		$ylin2 = $int + $slope * $xmax;
		pgmove($xmin,$ylin1);
		pgdraw($xmax, $ylin2);

		pgptxt($xside2, $ymark_pos2, 0.0, 0.5, "Slope: $slope");
		$ymark_pos4 = $ymark_pos2 - 0.1 * $ydiff;
		pgptxt($xside2, $ymark_pos4, 0.0, 0.5, "TSC Avg: $tsc_avg +/- $sig");
	}
	pgptxt($xmid, $ybot, 0.0, 0.5, "Time (DOM)");

	pgclos();
	
	$det_cnt++;

	$plot_name = "$detector".'.gif';
	system("echo ''|gs -sDEVICE=ppmraw  -r256x256 -q -NOPAUSE -sOutputFile=-  ./Sim_twist_temp/pgplot.ps|/data/mta4/MTA/bin/pnmcrop | pnmflip -r270 |ppmtogif > /data/mta/www/mta_sim_twist/Plots/$plot_name");
	system("rm ./Sim_twist_temp/pgplot.ps");
}

system("rm -rf ./Sim_twist_temp ./param");


########################################################
### plot_fig: plotting data points on a fig          ###
########################################################

sub plot_fig{
	$ydiff = $ymax - $ymin;
	$ymid  = $ymin + 0.50 * $ydiff;
	$yside = $ymin + 0.50 * $ydiff;
	$ytop  = $ymax + 0.05 * $ydiff;
	$ybot  = $ymin - 0.20 * $ydiff;
	$ymark_pos2 = $ymax - 0.1 * $ydiff;

	for($n = 0; $n < 15; $n++){
		${fid_cnt.$n} = 0;
	}

	@xtemp = ();
	@ytemp = ();
	$tsc_avg = 0;
	$tsc_avg2 = 0;
	$tot  = 0;
        for($m = 0; $m < $total; $m++){
		if($ybin[$m] >= $ymin && $ybin[$m] < $ymax){ 

			$symbol = $fid[$m] + 1;
			${fid_cnt.$fid[$m]}++;

        		pgsci(${fid_color.$fid[$m]}{color}[0]);
                	pgpt(1, $xbin[$m], $ybin[$m], $symbol);

			push(@xtemp, $xbin[$m]);
			push(@ytemp, $ybin[$m]);

			$tsc_avg += $tsc[$m];
			$tsc_avg2 += $tsc[$m] * $tsc[$m];

			$tot++;
		}
        }
        pgsci(1);

	if($tot > 0){
		$tsc_avg /= $tot;
		$sig      = sqrt($tsc_avg2/$tot - $tsc_avg * $tsc_avg);
		$tsc_avg  = sprintf "%3.2f",$tsc_avg;
		$sig      = sprintf "%2.2f",$sig;
	}else{
		$tsc_avg = 'INDEF';
		$sig     = 'INDEF';
	}


	least_fit();

	$next = 0;
        for($n = 0; $n < 15; $n++){
                if(${fid_cnt.$n} > 0){
                        $xpos = $xmin + $next * $step + 0.10 * $step;
                        $xpos2 = $xmin + $next * $step + 0.12 * $step;
                        $mark = $n + 1;
                        $description = ": FID $n";
                        $ymark_pos3 = $ymark_pos2 + 0.025 * $ydiff;
			pgsci(${fid_color.$n}{color}[0]);
                        pgpt(1, $xpos, $ymark_pos3, $mark);
                        pgtext($xpos2, $ymark_pos2, "$description");
			pgsci(1);
                        $next++;
                }
        }
}

####################################################################
### least_fit: least sq. fit routine                             ###
####################################################################

sub least_fit{
        $lsum = 0;
        $lsumx = 0;
        $lsumy = 0;
        $lsumxy = 0;
        $lsumx2 = 0;
        $lsumy2 = 0;

        for($fit_i = 0; $fit_i < $tot;$fit_i++) {
                $lsum++;
                $lsumx += $xtemp[$fit_i];
                $lsumy += $ytemp[$fit_i];
                $lsumx2+= $xtemp[$fit_i]*$xtemp[$fit_i];
                $lsumy2+= $ytemp[$fit_i]*$ytemp[$fit_i];
                $lsumxy+= $xtemp[$fit_i]*$ytemp[$fit_i];
        }

        $delta = $lsum*$lsumx2 - $lsumx*$lsumx;
        if($delta > 0){
                $int   = ($lsumx2*$lsumy - $lsumx*$lsumxy)/$delta;
                $slope = ($lsumxy*$lsum - $lsumx*$lsumy)/$delta;
                $slope = sprintf "%2.4f",$slope;
        }else{
                $int = 999999;
                $slope = 0.0;
        }
}

