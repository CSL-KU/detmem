#!/usr/bin/perl

use warnings;
use Getopt::Long;

my $stats_dir;
my $out_dir;

GetOptions("input=s" => \$stats_dir, "output=s" => \$out_dir) or die;

@bench_names = ('disparity', 'mser', 'sift', 'svm', 'texture_synth', 'aifftr01', 'aiifft01', 'matrix01');
@configs = ('solo', 'NoP', 'WP', 'DM(A)', 'DM(T98)', 'DM(T90)');

my @stat_files = (
#solo
"disparity-itr2-sim-3b683-solo-mdu", "mser-itr2-sim-3b683-solo-mdu", "sift-itr2-sim-3b683-solo-mdu", "svm-itr2-sim-3b683-solo-mdu", "texture_synthesis-itr2-sim-3b683-solo-mdu", "aifftr01-3b683-solo-mdu", "aiifft01-3b683-solo-mdu", "matrix01-3b683-solo-mdu",
#NoP
"disparity-itr2-sim-3b683-nop-mdu", "mser-itr2-sim-3b683-nop-mdu", "sift-itr2-sim-3b683-nop-mdu", "svm-itr2-sim-3b683-nop-mdu", "texture_synthesis-itr2-sim-3b683-nop-mdu", "aifftr01-3b683-nop-mdu", "aiifft01-3b683-nop-mdu", "matrix01-3b683-nop-mdu",
#WP
"disparity-itr2-sim-3b683-wp-mdu", "mser-itr2-sim-3b683-wp-mdu", "sift-itr2-sim-3b683-wp-mdu", "svm-itr2-sim-3b683-wp-mdu", "texture_synthesis-itr2-sim-3b683-wp-mdu", "aifftr01-3b683-wp-mdu", "aiifft01-3b683-wp-mdu", "matrix01-3b683-wp-mdu",
#DM(A)
"disparity-itr2-sim-3b683-dma-mdu", "mser-itr2-sim-3b683-dma-mdu", "sift-itr2-sim-3b683-dma-mdu", "svm-itr2-sim-3b683-dma-mdu", "texture_synthesis-itr2-sim-3b683-dma-mdu", "aifftr01-3b683-dma-mdu", "aiifft01-3b683-dma-mdu", "matrix01-3b683-dma-mdu",
#DM(T98)
"disparity-itr2-sim-3b683-dmt98-mdu", "mser-itr2-sim-3b683-dmt98-mdu", "sift-itr2-sim-3b683-dmt98-mdu", "svm-itr2-sim-3b683-dmt98-mdu", "texture_synthesis-itr2-sim-3b683-dmt98-mdu", "aifftr01-3b683-dmt98-mdu", "aiifft01-3b683-dmt98-mdu", "matrix01-3b683-dmt98-mdu",
#DM(T90)
"disparity-itr2-sim-3b683-dmt90-mdu", "mser-itr2-sim-3b683-dmt90-mdu", "sift-itr2-sim-3b683-dmt90-mdu", "svm-itr2-sim-3b683-dmt90-mdu", "texture_synthesis-itr2-sim-3b683-dmt90-mdu", "aifftr01-3b683-dmt90-mdu", "aiifft01-3b683-dmt90-mdu", "matrix01-3b683-dmt90-mdu"
);

my %all_benches;

foreach my $i (0 .. $#configs) {
    foreach my $j (0 .. $#bench_names) {
        $all_benches{$configs[$i]}{$bench_names[$j]}{stat_file} = $stat_files[$i * @bench_names + $j];
    }
}

foreach my $config (@configs) {
    foreach my $bench (@bench_names) {
        $bench_path = $stats_dir.'/'.$all_benches{$config}{$bench}{stat_file}.'.txt';
        open(my $stats_handle, "<", $bench_path) or die "Can't open < $bench_path: $!";
        
        $dmp_count = 0;
        while (<$stats_handle>) {
            if ($_ eq "---------- Begin Simulation Statistics ----------\n") {
                $dmp_count++;
                if ($dmp_count == 2) {
                    last;
                }
            }
        }
        
        $all_benches{$config}{$bench}{inst_hit} = 0;
        $all_benches{$config}{$bench}{inst_miss} = 0;
        $all_benches{$config}{$bench}{data_miss} = 0;
        if ($config eq 'DM(T90)' || $config eq 'DM(T98)') {
            $all_benches{$config}{$bench}{dm_util_inst} = 0;
        }
        while (<$stats_handle>) {
            my @spl = split ' ';
            if (defined($spl[0]) && $spl[0] eq 'sim_seconds') {
                $all_benches{$config}{$bench}{sim_seconds} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.overall_misses::switch_cpu3.inst') {
                $all_benches{$config}{$bench}{inst_miss} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.overall_misses::switch_cpu3.data') {
                $all_benches{$config}{$bench}{data_miss} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.overall_hits::switch_cpu3.inst') {
                $all_benches{$config}{$bench}{inst_hit} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.overall_hits::switch_cpu3.data') {
                $all_benches{$config}{$bench}{data_hit} = $spl[1];
            }
            
            if ($config eq 'DM(T90)'|| $config eq 'DM(T98)' || $config eq 'DM(A)') {
                if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.avg_determ_blks::switch_cpu3.inst') {
                    $all_benches{$config}{$bench}{dm_util_inst} = $spl[1];
                }
                if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.avg_determ_blks::switch_cpu3.data') {
                    $all_benches{$config}{$bench}{dm_util_data} = $spl[1];
                }
            }
        }
        close($stats_handle);
    }
}

# compute and write to the CSV files
my $hit_rate_path = $out_dir.'/hit-rate.csv';
open(my $hit_rate_handle, ">", $hit_rate_path) or die "Can't open > $hit_rate_path: $!";
printf $hit_rate_handle "Benchmark,co-runners,slowdown\n";

my $slowdown_path = $out_dir.'/slowdown.csv';
open(my $slowdown_handle, ">", $slowdown_path) or die "Can't open > $slowdown_path: $!";
printf $slowdown_handle "Benchmark,co-runners,slowdown\n";

my $dm_util_path = $out_dir.'/dm-util.csv';
open(my $dm_util_handle, ">", $dm_util_path) or die "Can't open > $dm_util_path: $!";
printf $dm_util_handle "Benchmark,co-runners,slowdown\n";


my %average;

foreach my $config (@configs) {
    $average{$config}{hit_rate} = 0;
    $average{$config}{slowdown} = 0;
    $average{$config}{dm_util} = 0;
}

foreach my $bench (@bench_names) {
    foreach my $config (@configs) {
        if ($config ne 'solo') {
            my $bench_ref = $all_benches{$config}{$bench};
            
            my $bench_miss = $bench_ref->{inst_miss} + $bench_ref->{data_miss};
            my $bench_hit = $bench_ref->{inst_hit} + $bench_ref->{data_hit};
            
            my $bench_miss_rate = $bench_miss / ($bench_miss + $bench_hit);
            my $bench_hit_rate = $bench_hit / ($bench_miss + $bench_hit);
            
            $average{$config}{hit_rate} = $average{$config}{hit_rate} + $bench_hit_rate;
            
            printf $hit_rate_handle "%s,%s,%.3f\n", $bench, $config, $bench_hit_rate;
 
            # slowdown
            my $bench_solo_sim_sec = $all_benches{solo}{$bench}{sim_seconds};
            my $bench_sim_sec = $bench_ref->{sim_seconds};
            my $bench_slowdown = $bench_sim_sec / $bench_solo_sim_sec;
            
            $average{$config}{slowdown} = $average{$config}{slowdown} + $bench_slowdown;
            
            printf $slowdown_handle "%s,%s,%.3f\n", $bench, $config, $bench_slowdown;
        }
        if ($config eq 'DM(T90)'|| $config eq 'DM(T98)' || $config eq 'DM(A)') {
            my $bench_dm_util = ($all_benches{$config}{$bench}{dm_util_inst} + $all_benches{$config}{$bench}{dm_util_data}) / 8192;
            $average{$config}{dm_util} = $average{$config}{dm_util} + $bench_dm_util;
            
            printf $dm_util_handle "%s,%s,%.3f\n", $bench, $config, $bench_dm_util;
        }
    }
}

# write average
foreach my $config (@configs) {
    if ($config ne 'solo') {
        printf $hit_rate_handle "avg,%s,%.3f\n", $config, $average{$config}{hit_rate} / @bench_names;
        printf $slowdown_handle "avg,%s,%.3f\n", $config, $average{$config}{slowdown} / @bench_names;
    }
    if ($config eq 'DM(T90)'|| $config eq 'DM(T98)' || $config eq 'DM(A)') {
        printf $dm_util_handle "avg,%s,%.3f\n", $config, $average{$config}{dm_util} / @bench_names;
    }
}
