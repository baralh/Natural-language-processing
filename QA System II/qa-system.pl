
#Heman Baral
#Programming Assignment 6

#Command : perl qa-system.pl mylogfile.txt
#Improved QA system



use strict;
use Data::Dumper;
use WWW::Wikipedia;

use open ":std", ":encoding(UTF-8)";

#look for auxilary verb.
my %auxilary ;


my @aritcal ;
# collect  all data for current que
my %currentQ; 
# collect all reword for current que
my %rewordQ; 
#open the log file from comand line argumant.
my $filename = $ARGV[0];

open (my $fh, '>' ,$filename) or die "Could not open file '$filename' $!";

print "This is a QA system by Heman Baral. It will try to answer questions that start with Who, What, When or Where. 
\nEnter \"exit\" to leave the program.\n \n=?> ";

#main loop.read the question and print the question.
while(<STDIN>){

    my $currentQ = $_;
    chomp;
    exit if $_ eq "exit";
    print "=> ";
    print findAnswer($currentQ),"\n";

}

#findind solution to the question

sub findAnswer{
    #initial  question.
    undef %currentQ ;
    $currentQ{'sub'} = ();
    $currentQ{'rewordQ'} = ();
    $currentQ{'wiki_texts'}= ();
    $currentQ{'comparees'}=();

    my $result ;
    my $answered = 0 ;

    #labeling found answer
    my $stringQ = shift;
    print $fh "\n\n\n $stringQ\n";
    my @symbol = tokenize($stringQ);
    costume_rewordQ();
    currentQReformulation();

    foreach my $subject (@{$currentQ{'sub'}}){
        my $wiki_text = "";
        currentQWiki($subject);
    }
    compare();

    if(defined $currentQ{'comparees'}){

        my @successor= sort {$b->{'value'} <=> $a->{'value'}} @{$currentQ{'comparees'}};

        my %compr = %{@successor[0]};
        $result = "(Weight".($compr{'value'}/10).")<=>".$compr{'sentence'};
    }else{
        $result = "Sorry I don't know this Question  answer.";
    }
    print $fh Dumper(\%currentQ);
    return $result;
}

sub compare{
    # compare the answer.
    foreach my $rewordQ (@{$currentQ{'rewordQ'}}){
        foreach my $sentence (@{$currentQ{'wiki_texts'}}){
            my %rewordQFile = %{$rewordQ};
            my $rewrite = $rewordQFile{'rewordQ'};
            if ( $sentence =~ /$rewrite/gm ){
                print $fh "$rewordQ $sentence \n";
                my $word  = $rewordQFile{'value'};
                my $compare = { };
                $compare->{'value'} = $word;
                $compare->{'rewordQ'} = $rewrite;
                $compare->{'sentence'} = $sentence;
                push @{$currentQ{'comparees'}}, $compare;

            }
        }
      }
}

# rewordQ the question
sub currentQReformulation(){

    #permutation of orginal words
    pergenerator(4,@{$currentQ{'symbol'}});

   
    if (scalar @{$currentQ{'symbol'}} >1){
        pergenerator(4,grep($_ ne @{$currentQ{'sub'}}[0], @{$currentQ{'symbol'}}));

        #permutations w/o stop word
        {
        my %rewordQ ;
        $rewordQ{'format'} = join (' ', @{$currentQ{'symbol'}}) ;
        $rewordQ{'value'} = 2;
        $rewordQ{'position'} = 'n';
        my $pattern = $rewordQ{'format'};
        $rewordQ{'rewordQ'} = qr/$pattern/;
        push @{$currentQ{'rewordQ'}}, \%rewordQ;
        }

        {
        #collecting back off
        my %rewordQ ;
        $rewordQ{'format'} = join ('(.*\s*)', @{$currentQ{'symbol'}}) ;
        $rewordQ{'value'} = 1;
        $rewordQ{'position'} = 'n';
        my $pattern = $rewordQ{'format'};
        $rewordQ{'rewordQ'} = qr/$pattern/;
        push @{$currentQ{'rewordQ'}}, \%rewordQ;
        }
    }
}

#Possible Permutation from the given word list
sub pergenerator{
    my ($weight,@words,) = @_;
    my @res;

    # looking for the location of a verb
    my $verbLocation ;
    for $verbLocation (0..$#words+1){
        my %rewordQ ;
        my @comWords = @words;
        splice @comWords, $verbLocation, 0, $currentQ{'vrb'} ;
        $rewordQ{'position'} = 'r';
        $rewordQ{'value'} = $weight;
        $rewordQ{'format'} = join ' ',@comWords;
        $rewordQ{'rewordQ'} = qr/$rewordQ{'format'}/;
        if ($verbLocation == 0){
            $rewordQ{'position'} = 'l';
            $rewordQ{'rewordQ'} = qr/$rewordQ{'format'}/;
        }
        push @{$currentQ{'rewordQ'}}, \%rewordQ;
    }


}

#Grab the soulution from wiki page
sub currentQWiki{
    my $stringQ = shift;
    my $wiki_text;
    my $wiki = WWW::Wikipedia->new(clean_html => 1 );
    my $result = $wiki->search($stringQ);
    if (defined $result){
        if ( $result->text() ) {
        $wiki_text = $result->text_basic();

       #Print wiki text and reorganize.
        $wiki_text =~ s/\}\}&nbsp;\x{2013}/-/gs;
        $wiki_text =~ s/<\/?.*?>//gs;
        $wiki_text =~ s/\R/ /g;
        $wiki_text =~ s/\s+/ /g;
        #remove info box
        $wiki_text =~ s/\{\{.*\}\}//g;
        $wiki_text =~ s/([\.?!]+)/$1\n/g;
        # print $wiki_text;
        my @wikis = split "\n",$wiki_text;
        push @{$currentQ{'wiki_texts'}}, @wikis ;
        }
    }

}

# tokenize the que return symbol as a list of string 

sub tokenize{
    my $stringQ = shift;
    $currentQ{'currentQ'} = $stringQ;

    # extract subject
    my @vr = ($stringQ =~ /((?<!^)[A-Z][^\s!?,]+)/g);
    my $sub =  (join " ",@vr);
    push @{$currentQ{'sub'}}, $sub;
    $stringQ = ($stringQ =~ s/(<S>[\s!?.])+/<S> /rg);
    $stringQ = ($stringQ =~ s/((?<!^)[A-Z][^\s!?,]+)/<S>/rg);

    my @symbol = ($stringQ =~ /\s?([^,!?\s]+)/g);

   
    $currentQ{'type'}= lc $symbol[0];
 
    if ($currentQ{'type'} eq 'what'){
        if (exists($auxilary{$symbol[1]})){

          #auxilarry verb exists
            $currentQ{'axvrb'} = $symbol[1];
            $currentQ{'vrb'} = $symbol[$#symbol];
        
            @symbol = grep($_ ne $currentQ{'axvrb'}, @symbol );
        }else{
            $currentQ{'vrb'} = $symbol[1];
        }
    }elsif ($currentQ{'type'} eq 'when'){
        if (exists($auxilary{$symbol[1]})){
           # if there is an aux verb
            $currentQ{'axvrb'} = $symbol[1];
            $currentQ{'vrb'} = $symbol[$#symbol];
        
            @symbol = grep($_ ne $currentQ{'axvrb'}, @symbol );
    }elsif ($currentQ{'type'} eq 'who'){
            $currentQ{'vrb'} = $symbol[1];

    }elsif ($currentQ{'type'} eq 'where'){
          #add location
        if (exists($auxilary{$symbol[1]})){
          #if there is an aux verb
             $currentQ{'axvrb'} = $symbol[1];
             $currentQ{'vrb'} = $symbol[$#symbol];
             @symbol = grep($_ ne $currentQ{'axvrb'}, @symbol );
        }else{
            $currentQ{'vrb'} = $symbol[1];
        }
    }else{

            $currentQ{'vrb'} = $symbol[1];
        }
    }

    # remove verb, type, aux from tokes
    @symbol = grep(lc $_ ne $currentQ{'vrb'}, @symbol );
    @symbol = grep(lc $_ ne $currentQ{'type'}, @symbol );
    @symbol = map {$_ eq '<S>'? $sub : $_} @symbol;
    $currentQ{'symbol'} = \@symbol;
    return @symbol;

}

sub costume_rewordQ{

    #who question
    if (lc $currentQ{'type'} eq "who"){
                my $verb = $currentQ{'vrb'};
                my $stringQ = { };
                $stringQ->{'rewrite'} = qr/(?i) $verb ((?:a[n]? |the )[^.]*)[.,!?]/;
                $stringQ->{'format'} = qr/(?i) $verb ((?:a[n]? |the )[^.]*)[.,!?]/;
                $stringQ->{'value'} = 8;

                $stringQ->{'position'} = '';
                push @{$currentQ{'rewordQ'}},  $stringQ;

    }
    # what question 
    elsif (lc $currentQ{'type'} eq "what"){
            my $verb = $currentQ{'vrb'};
            my $stringQ = { };
                my %stringQ = ('rewordQ'=>qr/(?i) $verb ((?:a[n]? |the |)[^.]*)[.,!?]/,'format'=>qr/(?i) $verb ((?:a[n]? |the |)[^.]*)[.,!?]/ , 'value'=>8);
                push @{$currentQ{'rewordQ'}}, \%stringQ;

      # when question
    } elsif (lc $currentQ{'type'} eq "when"){

                #checking for auxiliary verb
                my $verb = $currentQ{'vrb'};
                my $sub = $currentQ{'subject'};
                my $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i)((?:celebrated (?:on )|taking place (?:on ))[^.,!?]*)/;
                $stringQ->{'format'} = qr/(?i)((?:celebrated (?:on )|taking place (?:on ))[^.,!?]*)/;
                $stringQ->{'value'} = 8;
                push @{$currentQ{'rewordQ'}}, $stringQ;

                $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i) date of the $sub $verb ((?:before |after |on |during | )[^.]*)[.,!?]/;
                $stringQ->{'format'} = qr/(?i) date of the $sub $verb ((?:before |after |on |during | )[^.]*)[.,!?]/;
                $stringQ->{'value'} = 8;
                push @{$currentQ{'rewordQ'}}, $stringQ;

                # where  queestion
    }elsif (lc $currentQ{'type'} eq "where"){

                #checking for auxiliary verb
                my $verb = $currentQ{'vrb'};
                my $sub = $currentQ{'subject'};
                my $stringQ = { };

                $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i)((?:located (?:in |at )?|placed (?:in )?)[^.,!?]*)/;
                $stringQ->{'format'} = qr/(?i)((?:located (?:in |at )?|placed (?:in )?)[^.,!?]*)/;
                $stringQ->{'value'} = 8;
               push @{$currentQ{'rewordQ'}}, $stringQ;
               $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i).*?_location_?.*? = ((?:in )\w*(:?\s\w*)?(?:, \w*)?)/;
                $stringQ->{'format'} = qr/(?i).*?_location_?.*? = ((?:in )\w*(:?\s\w*)?(?:, \w*)?)/;
                $stringQ->{'value'} = 8;
                $stringQ->{'add'} = "in";
                push @{$currentQ{'rewordQ'}}, $stringQ;
                $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i)location ((?:in )\w*(:?\s\w*)?(?:, \w*)?)/;
                $stringQ->{'format'} = qr/(?i)location ((?:in )\w*(:?\s\w*)?(?:, \w*)?)/;
                $stringQ->{'value'} = 7;
                push @{$currentQ{'rewordQ'}}, $stringQ;
                $stringQ = { };
                $stringQ->{'rewordQ'} = qr/(?i) is.*?((?:in )[^.,!?]*)/;
                $stringQ->{'format'} = qr/(?i) is.*?((?:in )[^.,!?]*)/;
                $stringQ->{'value'} = 3;
                push @{$currentQ{'rewordQ'}}, $stringQ;
    }

}


sub compareAnswer{
    my ($rewordQ, $text) = @_;
    my %stringQ= %{$rewordQ};
  
    # process raw text from wikipedia
    my $solution = 0 ;
    my $rewordQ = $stringQ{'q'};
    ($solution) = $text =~ m/$rewordQ/gm;
    return  $solution;

}

 close $fh;
