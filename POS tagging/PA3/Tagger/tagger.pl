#!/usr/bin/perl

#Heman Baral
#Assignment 3

#this program will take as input a training file containing part of speech tagged text, and a file containing text to be part of speech tagged. 

$trainFilename = $ARGV[0];
open(DATA, $trainFilename) or die "Couldn't open file file.txt, $!";

my %words_tagger;
my %words_hash;

while(<DATA>) {
    chomp;

  #taking input file and truncating the [] brackets.
      ($line = $_)=~ s/\[\s|\s\]//g;

#spliting the sentence tag and putting it into the array.
      @split_array =split(/\s+/,$line);
      foreach my $i (@split_array) {

#counting the words and parts of speech tager occurence.
        if ($i=~ m/(.*)\/(.*)/){
        $words_tagger{$1}{$2}++;
          $words_hash{$1}++;

      }
  }
}




$tstFilename = $ARGV[1];
open(DATA, $tstFilename) or die "Couldn't open file file.txt, $!";

while(<DATA>) {
    chomp;
    ($content = $_)=~ s/\[\s|\s\]|^\s//g;

    @split_sentence =split(/\s+/,$content);

    foreach my $i (@split_sentence) {
#comparing the pos-train and pos-test word matching and taking the most frequency word.
if (exists $words_tagger{$i}) {
#finding the max frequency word comparing the hash table and the array by matching words.

  my $max;
  while (my ($key, $value) = each $words_tagger{$i}) {
      if (not defined $max) {
          $max = $key;
          next;
      }
      if ($words_tagger{$max} < $value) {
          $max = $key;

      }

  }
# finding capital leter NN word and  providing proper noun.
  if ($max eq "NN" && (lc($i) ne $i))
    {
      $max = "NNP";
    }

# if NNP is not capitalize use NN.
    if ($max eq "NNP" && (lc($i) eq $i))
      {
        $max = "NN";
      }
  # print "$iz$max\n";
  print STDOUT "$i $max\n";


} else {
  # any word found in the test data but not in training data providing  an NN tag.
print STDOUT "$i NN\n";
}


 }
}