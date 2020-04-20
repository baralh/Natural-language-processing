#!/usr/bin/ perl

#Heman Baral
#Assignment 3



use Data::Dumper;
$taggerFile = $ARGV[1];
open(DATA, $taggerFile) or die "Couldn't open file file.txt, $!";
my @tag_word_key;
my @predicted_tag;
my %confusion_mat;


#In this step it takes sentence and spliting the key file
while(<DATA>) {

  ($testword = $_)=~ s/\[\s|\s\]//g;
  @word_split =split(/\s+/,$testword);
  foreach my $i (@word_split) {
    %word_tag = ($i =~ /(.+)\/(.+)/g);

  #taking words and putting into an array
    push @tag_word_key, %word_tag;

   }
}

$tester = $ARGV[0];
open(DATA, $tester) or die "Couldn't open file file.txt, $!";

#Tagger output file
while(<DATA>) {

  chomp ;
  @word_split =split(/ /,$_);
  foreach my $i (@word_split) {

#Tagger array.
    push @predicted_tag, $i;



 }
}

#calc accuracy and confution matrix.
$total =0 ;
$correct = 0;
$accuracy = 0 ;

for (my $i = 1; $i<$#predicted_tag; $i=$i+2){

  $confusion_mat{$tag_word_key[$i]}{$predicted_tag[$i]}++;
  $total++;
  if($predicted_tag[$i] eq $tag_word_key[$i]){
    $correct++;
  }

}
# printing the accuracy of the confution matrix.
printf ("total : %d , correct : %d , accuracy %0.2f \n\n", $total, $correct, $correct/$total);
print "Confusion Matrix\n\n";
print Dumper(\%confusion_mat);