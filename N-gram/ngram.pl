# use warnings;

#Heman baral
#CMSC416
#Assignment 2

#This program will learn an N-gram language model from an arbitrary number of plain text files.

#It take 3 command line arguements

#First is n-gram model, second is number of words and third being text files that your want to read

print "Heman Baral.\n\n";
print "This program generates random sentences based on an Ngram model.\n\n\n";



@files = @ARGV[2..$#ARGV]; #Taking the input file name from Command line

$numOutput = $ARGV[1]; #Taking no. of words frm Command line


$n = $ARGV[0];# n-grams Commandline

$start = "<S>" ; # initiate token
$end = "<E>";# end token
$begain = "";

foreach my $i (0..($n-1)){
    $begain .= "$start ";
}
%unigrams;
%rawFreq;
%relativeFreq;

# handle each file in filenames as corpus
foreach $file (@files){


    # Storing each text
    $store = ""; 
    @sents  =(); #sentences
    #open file
    open($fn, $file)
        or die "Could not open file '$file' $!";

    while ($line = <$fn>){


        chomp $line ;
        $store .= $line;


    }

    #Parsing all the text into sentences and finding those sentences
    @sents = $store =~ /[^?!.:]*[.?!:]['`’]*/gm; 

    foreach $sent (@sents) {




      
        #Making everything lower case
        $sent = lc $sent; 
        #Adding spaces between all punctuations
        $sent =~ s/([\(\).,;!?:]|[^\w]+[']|^['"]|['"][^\w])/ $1 /g; 
        # Adding start and end tokens
        $sent =~ s/(^)(.*)($)/$1 $begain $2 $end $3/g; 

        # Parsing tokens
        @tokens = ($sent =~ /([^\s]+)/g); 


        #Generating unigram
        foreach (@tokens){
        $unigrams{$_} = defined $unigrams{$_}? $unigrams{$_}+1: 1;
        }


        #current offset value
        $c = 0;

        while ($c+$n-1 < (0+@tokens) ){

            $history = join ' ',@tokens[$c..$c+$n-2];
            $current = $tokens[$c+$n-1];
            $rawFreq{$history}{$current} = defined $rawFreq{$history}{$current}? $rawFreq{$history}{$current}+1 : 1 ;
            $rawFreq{$history}{"#TOT#"}++;
            $c++;

        }
        chomp $sent;








    }
    #Calculate thee relative probability
        foreach $history ( keys %rawFreq){
            foreach $cur ( keys %{$rawFreq{$history}}){
                if ($cur ne "#TOT#"){
                    $relativeFreq{$history}{$cur} = $rawFreq{$history}{$cur}/$rawFreq{$history}{"#TOT#"};
                }
            }

        }


}







# Generating a sentence using Relative frequency table model

foreach my $i (0..$numOutput){

    my @sentence = qw(<S> <S>);
    my $next = "";
    my $r = rand();
    $sum = 0 ;

    #This step selects starting of a sentence
    foreach my $cur (keys %{$relativeFreq{"<S> <S>"}}){
        $sum += $relativeFreq{"<S> <S>"}{$cur};

        #We've found the corresponding probability
        if ($sum > $r){
            $next = $cur;
            push @sentence, $next;
            last;
        }

    }

    #Generating next words until end of the sentence is reached
   
    $k=0;
    while ($next ne "<E>"){
        $sum = 0;
        $r = rand();
        $lastwords = join " " ,@sentence[($#sentence-($n-1)+1)..$#sentence];
        foreach my $cur (keys %{$relativeFreq{$lastwords}}){
            # print $cur;
            $sum += $relativeFreq{$lastwords}{$cur};
            if ($sum > $r){
                $next = $cur;
                push @sentence, $next;
                last;
            }

        }



    }
   #Processes of printing the result
    $result = join " ",@sentence;
    $result =~ s/(^["']|(?<=[\s])['"]|["'](?=[\s])|\s+(?=[.,;:!?]))//g; #This fixes the punctuations
    $result =~ s/(<S>\s*|\s<E>)//g;
    print $result."\n";
}