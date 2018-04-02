#!/usr/bin/perl

use warnings;
use Getopt::Long;

my $stats_dir;
my $out_dir;

GetOptions("input=s" => \$stats_dir, "output=s" => \$out_dir) or die;

@bench_names = ('disparity', 'mser', 'sift', 'svm', 'texture_synth', 'aifftr01', 'aiifft01', 'matrix01');
@configs = ('NoP', 'WP', 'DM(A)', 'DM(T98)', 'DM(T90)');

my @stat_files = (
# NoP
"3disparity-inf-1bzip2-ei-nop", "3mser-inf-1bzip2-ei-nop", "3sift-inf-1bzip2-ei-nop", "3svm-inf-1bzip2-ei-nop", "3texture_synthesis-inf-1bzip2-ei-nop", "3aifftr01-inf-1bzip2-ei-nop", "3aiifft01-inf-1bzip2-ei-nop", "3matrix01-inf-1bzip2-ei-nop",
# WP
"3disparity-inf-1bzip2-ei-wp", "3mser-inf-1bzip2-ei-wp", "3sift-inf-1bzip2-ei-wp", "3svm-inf-1bzip2-ei-wp", "3texture_synthesis-inf-1bzip2-ei-wp", "3aifftr01-inf-1bzip2-ei-wp", "3aiifft01-inf-1bzip2-ei-wp", "3matrix01-inf-1bzip2-ei-wp",
# DM(A)
"3disparity-inf-1bzip2-ei-dma", "3mser-inf-1bzip2-ei-dma", "3sift-inf-1bzip2-ei-dma", "3svm-inf-1bzip2-ei-dma", "3texture_synthesis-inf-1bzip2-ei-dma", "3aifftr01-inf-1bzip2-ei-dma", "3aiifft01-inf-1bzip2-ei-dma", "3matrix01-inf-1bzip2-ei-dma",
# DM(T98)
"3disparity-inf-1bzip2-ei-dmt98", "3mser-inf-1bzip2-ei-dmt98", "3sift-inf-1bzip2-ei-dmt98", "3svm-inf-1bzip2-ei-dmt98", "3texture_synthesis-inf-1bzip2-ei-dmt98", "3aifftr01-inf-1bzip2-ei-dmt98", "3aiifft01-inf-1bzip2-ei-dmt98", "3matrix01-inf-1bzip2-ei-dmt98",
# DM(T90)
"3disparity-inf-1bzip2-ei-dmt90", "3mser-inf-1bzip2-ei-dmt90", "3sift-inf-1bzip2-ei-dmt90", "3svm-inf-1bzip2-ei-dmt90", "3texture_synthesis-inf-1bzip2-ei-dmt90", "3aifftr01-inf-1bzip2-ei-dmt90", "3aiifft01-inf-1bzip2-ei-dmt90", "3matrix01-inf-1bzip2-ei-dmt90"
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
        
        $all_benches{$config}{$bench}{occ_inst} = 0;
        $all_benches{$config}{$bench}{occ_data} = 0;
        $all_benches{$config}{$bench}{occ_itb} = 0;
        $all_benches{$config}{$bench}{occ_dtb} = 0;
        while (<$stats_handle>) {
            my @spl = split ' ';
            if (defined($spl[0]) && $spl[0] eq 'system.l2.overall_miss_rate::switch_cpu0.data') {
                $all_benches{$config}{$bench}{l2_miss_rate} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.occ_percent::switch_cpu0.inst') {
                $all_benches{$config}{$bench}{occ_inst} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.occ_percent::switch_cpu0.data') {
                $all_benches{$config}{$bench}{occ_data} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.occ_percent::switch_cpu0.itb.walker') {
                $all_benches{$config}{$bench}{occ_itb} = $spl[1];
            }
            if (defined($spl[0]) && $spl[0] eq 'system.l2.tags.occ_percent::switch_cpu0.dtb.walker') {
                $all_benches{$config}{$bench}{occ_dtb} = $spl[1];
            }
        }
        close($stats_handle);
    }
}


# compute and write to the CSV files
my $hit_rate_path = $out_dir.'/hit-rate-cr-1bzip2.csv';
my $cache_occ_path = $out_dir.'/cache-occ-1bzip2.csv';
open(my $hit_rate_handle, ">", $hit_rate_path) or die "Can't open > $hit_rate_path: $!";
open(my $cache_occ_handle, ">", $cache_occ_path) or die "Can't open > $cache_occ_path: $!";
printf $hit_rate_handle "Benchmark,co-runners,slowdown\n";
printf $cache_occ_handle "Benchmark,co-runners,slowdown\n";

my %average;

foreach my $config (@configs) {
    $average{$config}{cache_occ} = 0;
    $average{$config}{hit_rate} = 0;
}

foreach my $bench (@bench_names) {
    foreach my $config (@configs) {
        # miss/hit rate
        my $bench_ref = $all_benches{$config}{$bench};
        my $bench_cache_occ = $bench_ref->{occ_inst} + $bench_ref->{occ_data} + $bench_ref->{occ_itb} + $bench_ref->{occ_dtb};
        my $bench_hit_rate = 1 - $bench_ref->{l2_miss_rate};
        
        printf $hit_rate_handle "%s,%s,%.3f\n", $bench, $config, $bench_hit_rate;
        printf $cache_occ_handle "%s,%s,%.3f\n", $bench, $config, $bench_cache_occ;
        
        $average{$config}{cache_occ} = $average{$config}{cache_occ} + $bench_cache_occ;
        $average{$config}{hit_rate} = $average{$config}{hit_rate} + $bench_hit_rate;
    }
}

# write average
foreach my $config (@configs) {
    printf $cache_occ_handle "avg,%s,%.3f\n", $config, $average{$config}{cache_occ} / @bench_names;
    printf $hit_rate_handle "avg,%s,%.3f\n", $config, $average{$config}{hit_rate} / @bench_names;
}
