#!/usr/bin/perl

#Heman Baral
#Programming Assignment 4
#Scorer.pl


# run command: perl scorer.pl my-line-answers.txt line-key.txt

#socrer will take as input your sense tagged output and compare it with the gold standard "key" data which I have placed in the Files section of our group.

use Data::Dumper;

#Command line for files
$f0 = @ARGV[0];
$f1 = @ARGV[1];


#opening the files 

open(my $outputs, '<:encoding(UTF-8)', $f0)
 or die "coult not open file '$f0' $!";

#key file open
open(my $keys, '<:encoding(UTF-8)', $f1)
 or die "coult not open file '$f1' $!";

#reading key file
my @key;
while (my $line=<$keys>){
    chomp $line;
    @arr = split/\>\</, $line;
    push @key, @arr;}

#read output file;
while (my $row=<$outputs>){
    chomp $row;
    @arr = split/\>\</,$row;
    push @output, @arr;
}


# keeping only senses by cleaning file
for my $i(0 .. $#key+1){
    $p = @key[$i];
    $p=~m/senseid="(.*)"/;
    @key[$i] = $1;
}


# compare key file to senses from output file
for my $i(0 .. $#output+1){

    $p = @output[$i];
    $p=~m/senseid="(.*)"/;
    if ($1 eq @key[$i]){
        $c++;
    }
    $confusion{@key[$i]}{$1}++;
}

#determine and print score
$score = $c/($#key+1);
print "$score\n\n\n";

#print matrix headers
my @tags;

print "       ";
while (my $key = each(%confusion)){
    if ($key=~m/.+/){
        push(@tags, $key);

        print "$key | "; 
    }
}
print "\n";

#printing the mextix
for $i (0 .. $#tags){

    #printing sense
    print "$tags[$i]  |  ";
    for $j (0 .. $#tags){
        if (exists $confusion{$tags[$i]}{$tags[$j]}){

        #if true get each assigned sense and key sense
            print  $confusion{$tags[$i]}{$tags[$j]};
        }
        else{

    
            print "0";
        }
        print "  |  "; 
    }
    print "\n";
}

