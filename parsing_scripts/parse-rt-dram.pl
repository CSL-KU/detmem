#!/usr/bin/perl

use warnings;
use Getopt::Long;

my $stats_dir;
my $out_dir;

GetOptions("input=s" => \$stats_dir, "output=s" => \$out_dir) or die;

@bench_names = ('disparity', 'mser', 'sift', 'svm', 'texture_synth');
@configs = ('solo', 'BA & FR-FCFS', 'DM(A)', 'DM(T98)', 'DM(T90)');

my @stat_files = (
#solo
"disparity-cif-solo", "mser-cif-solo", "sift-cif-solo", "svm-cif-solo", "texture_synthesis-cif-solo",
# Buddy allocator
"disparity-cif-3b4096-budfr", "mser-cif-3b4096-budfr", "sift-cif-3b4096-budfr", "svm-cif-3b4096-budfr", "texture_synthesis-cif-3b4096-budfr",
#WP
# "disparity-cif-3b4096-mdu", "mser-cif-3b4096-mdu", "sift-cif-3b4096-mdu", "svm-cif-3b4096-mdu", "texture_synthesis-cif-3b4096-mdu",
#DM(A)
"disparity-cif-3b4096-dma", "mser-cif-3b4096-dma", "sift-cif-3b4096-dma", "svm-cif-3b4096-dma", "texture_synthesis-cif-3b4096-dma",
#DM(T98)
"disparity-cif-3b4096-dmt98", "mser-cif-3b4096-dmt98", "sift-cif-3b4096-dmt98", "svm-cif-3b4096-dmt98", "texture_synthesis-cif-3b4096-dmt98",
#DM(T90)
"disparity-cif-3b4096-dmt90", "mser-cif-3b4096-dmt90", "sift-cif-3b4096-dmt90", "svm-cif-3b4096-dmt90", "texture_synthesis-cif-3b4096-dmt90"
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

        while (<$stats_handle>) {
            my @spl = split ' ';
            if (defined($spl[0]) && $spl[0] eq 'sim_seconds') {
                $all_benches{$config}{$bench}{sim_seconds} = $spl[1];
            }
        }
        close($stats_handle);
    }
}

# compute and write to the CSV files
my $slowdown_path = $out_dir.'/slowdown-mc.csv';
open(my $slowdown_handle, ">", $slowdown_path) or die "Can't open > $slowdown_path: $!";
printf $slowdown_handle "Benchmark,co-runners,slowdown\n";

my %average;

foreach my $config (@configs) {
    $average{$config}{slowdown} = 0;
}

foreach my $bench (@bench_names) {
    foreach my $config (@configs) {
        if ($config ne 'solo') {
            # miss/hit rate
            my $bench_ref = $all_benches{$config}{$bench};
 
            # slowdown
            my $bench_solo_sim_sec = $all_benches{solo}{$bench}{sim_seconds};
            my $bench_sim_sec = $bench_ref->{sim_seconds};
            my $bench_slowdown = $bench_sim_sec / $bench_solo_sim_sec;
            $average{$config}{slowdown} = $average{$config}{slowdown} + $bench_slowdown;
            
            printf $slowdown_handle "%s,%s,%.3f\n", $bench, $config, $bench_slowdown;
        }
    }
}

# write average
foreach my $config (@configs) {
    if ($config ne 'solo') {
        printf $slowdown_handle "avg,%s,%.3f\n", $config, $average{$config}{slowdown} / @bench_names;
    }
}
