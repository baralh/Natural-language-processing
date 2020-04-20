#!/usr/bin/perl

#Heman Baral
#Programming Assignment 4
#decision-list.pl

#run command: perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt > my-line-answers.txt

#This program generates myDecision list from line-train.txt and apply that myDecision list 
#to each of the sentences found in line-test.txt in order to assign a sense to the word line. 





use Data::Dumper;

#Command line arguments for files

$f0 = @ARGV[0];

$f1 = @ARGV[1];

$f2 = @ARGV[2];


#command to open line-train file
open(my $trainfile, '<:encoding(UTF-8)', $f0)
 or die "File couldn't be open '$f0' $!";

#command to open testfile file
open(my $testfile, '<:encoding(UTF-8)', $f1)
 or die "File couldn't be open '$f1' $!";
 
#lets us write 
open(my $dlist, '>', $f2)
 or die "Could not open file '$f2' $!";
 
my @Corpusdata;

#building Corpusdata by chomping, removing white spaces and adding 
while (my $r = <$trainfile>) {
    chomp $r;
    $r =~s/[,'"@]|(--)//g;

    @line = split/ +/, $r;

    push @Corpusdata, @line;
}


my %myDecision;
my $sense;
%word_senses;



#gathering all the contex and word word_senses
for my $i (0 .. $#Corpusdata+1){
    $word = @Corpusdata[$i];

    if ($word=~m/senseid=(.*)\/\>/){
        $sense = $1;
        $word_senses{$sense}++;
    }
    if ($word=~m/\<head\>line(s)?\<\/head\>/i){

        $t0 = "$Corpusdata[$i-2] $Corpusdata[$i-1] line";
        $t1 = "$Corpusdata[$i-1] line $Corpusdata[$i+1]";
        $t2 = "line $Corpusdata[$i+1] $Corpusdata[$i+2]";
        $t3 = "line $Corpusdata[$i+1]";
        $t4 = "$Corpusdata[$i-1] line";

        $myDecision{$t0}{$sense}++;
        $myDecision{$t1}{$sense}++;
        $myDecision{$t2}{$sense}++;
        $myDecision{$t3}{$sense}++;
        $myDecision{$t4}{$sense}++;
    }
    
}


# making Decision tree
my @log_likelihood;

foreach my $k (keys %myDecision){

    my $counter = 0;
    my $countsense = "";
    my $countvalue=0;
    while (my($key, $value) = each %{ $myDecision{$k}}){

        if ($value > $countvalue){
            $countvalue = $value;
            $countsense = $key;
        }
       
        $counter++;
    
    }
    
    if ($counter == 1){
        $entry = "99999||$countsense||$k";
        push @log_likelihood, $entry;
    }
    
    #retreving log of each context and corresponding sense
    if ($counter == 2){
        my @t;
        while (my($key, $value) = each %{ $myDecision{$k}}){
            push @t, $value;
        }       
        $total = @t[0] + @t[1];
        $p0 = @t[0]/$total;        
        $p1 = @t[1]/$total;
        $log_likelihoodike = abs(log($p0/$p1));

        if ($log_likelihoodike == 0){
            $log_likelihoodike = "0.000";
        }
        $entry = "$log_likelihoodike||$countsense||$k";
        push @log_likelihood, $entry;
    }
}
#sort Decision list by log-likelihood
@log_likelihood = reverse (sort @log_likelihood);

#print myDecision list
print $dlist Dumper (\@log_likelihood);



# sense with the highest freq
$maxfreq = 0;
$default = "";
while (my ($key, $value) = each %word_senses){

    if ($value>$maxfreq){
        $maxfreq = $value;
        $default = $key;
    }
}


#creating a text file
while (my $r = <$testfile>) {

    chomp $r;
    $r =~s/[,'"@]|(--)//g;
    @line = split/ +/, $r; 
    push @text, @line;
}


my $instance;
for my $i (0..$#text+1){
    $word = @text[$i];

    
    if ($word=~m/id=line-n(.*)\>/){
        $instance = $1;
    }
    
    if ($word=~m/\<head\>line(s)?\<\/head\>/i){
    
        
        #collecting all the context

        $t0 = "$text[$i-2] $text[$i-1] line";
        $t1 = "$text[$i-1] line $text[$i+1]";
        $t2 = "line $text[$i+1] $text[$i+2]";
        $t3 = "line $text[$i+1]";
        $t4 = "$text[$i-1] line";


        my $curlog = -1;
        my $cursense = $default;
        
        #check every context

        for my $j (0..$#log_likelihood){
            @entry = split/\|\|/, @log_likelihood[$j];
            if (@entry[2] eq $t1){
                if (@entry[0] > $curlog){
                    $curlog = @entry[0];
                    $cursense = @entry[1];
                }
                last;
            }
        }
        for my $j (0..$#log_likelihood){
            @entry = split/\|\|/, @log_likelihood[$j];
            if (@entry[2] eq $t2){
                if (@entry[0] > $curlog){
                    $curlog = @entry[0];
                    $cursense = @entry[1];
                }
                last;
            }
        }
        for my $j (0..$#log_likelihood){
            @entry = split/\|\|/, @log_likelihood[$j];
            if (@entry[2] eq $t3){
                if (@entry[0] > $curlog){
                    $curlog = @entry[0];
                    $cursense = @entry[1];
                }
                last;
            }
        }       
        for my $j (0..$#log_likelihood){
            @entry = split/\|\|/, @log_likelihood[$j];
            if (@entry[2] eq $t4){
                if (@entry[0] > $curlog){
                    $curlog = @entry[0];
                    $cursense = @entry[1];
                }
                last;
            }
        }       
        for my $j (0..$#log_likelihood){
            @entry = split/\|\|/, @log_likelihood[$j];
            if (@entry[2] eq $p5){
                if (@entry[0] > $curlog){
                    $curlog = @entry[0];
                    $cursense = @entry[1];
                }
                last;
            }
        }

        #printing al the sense

        print "<answer instance=\"line-$instance\" senseid=\"$cursense\"/>";
    }
    
    
}