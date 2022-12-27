#! /usr/bin/env perl
use JSON::XS;
use utf8;
use Encode;
binmode *STDOUT,":utf8";

if ($#ARGV != 1) {
    print STDERR "Usage : $0 json1 json2\n";
    exit(1);
}

open($fh,"<",$ARGV[0]) || die $!;
{local $/; $json1 = <$fh>;}
close($fh);
$dp1 = decode_json($json1);

open($fh,"<",$ARGV[1]) || die $!;
{local $/; $json2 = <$fh>;}
close($fh);
$dp2 = decode_json($json2);

my $chk1 = {};
my $chk2 = {};
json_flatten($dp1,"",$chk1);
json_flatten($dp2,"",$chk2);

foreach $k (sort keys %$chk1){
    if ($chk1->{$k} ne $chk2->{$k}) {
	print "+ $k differ \t";
	print " $chk1->{$k} \t";
	print "-> $chk2->{$k} \n";
    }
}
foreach $k (sort keys %$chk2){
    if (! exists $chk1->{$k}) {
	print "+ $k not found \t";
	print "-> $chk2->{$k} \n";
    }
}



# recursive

sub json_dump {
    my ($dp, $prefix) = @_;
    my $tp = ref($dp);
    if ($tp eq "ARRAY") {
	my $n = scalar(@$dp);
	for (my $i = 0; $i <= $n; $i++){
	    json_dump($dp->[$i], $prefix . sprintf("[%d]", $i));
	}
    }
    elsif ($tp eq "HASH") {
	foreach my $k (keys %$dp){
	    json_dump($dp->{$k}, $prefix . '.' . $k);
	}
    }
    elsif ($tp eq "") {
	print "$prefix\t$dp\n";
    }
    else {
	printf "Huh? %s\n", ref($dp);
    }
}

sub json_flatten {
    my ($dp, $prefix, $outp) = @_;
    my $tp = ref($dp);
    if ($tp eq "ARRAY") {
	my $n = scalar(@$dp);
	for (my $i = 0; $i <= $n; $i++){
	    json_flatten($dp->[$i], $prefix . sprintf("[%d]", $i), $outp);
	}
    }
    elsif ($tp eq "HASH") {
	foreach my $k (keys %$dp){
	    json_flatten($dp->{$k}, $prefix . '.' . $k, $outp);
	}
    }
    elsif ($tp eq "") {
	$outp->{$prefix} = $dp;
    }
}

