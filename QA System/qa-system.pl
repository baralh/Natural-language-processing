#Heman Baral
#Assignment 5

#command: perl qa-system.pl mylogfile.txt


use warnings;
use WWW::Wikipedia;
use open ':std', ':encoding(UTF-8)';

  # my $question ;
my $filename = $ARGV[0];#taking the

#writing in a filename provided by the user
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

print "This is a QA system by Heman Baral. This system will answer Who, What, When or Where questions.
\nEnter \"exit\" to leave the program.\n \n ";

while(<STDIN>){

    my $question = $_;

    chomp;
    exit if $_ eq "exit";


#this is a question type
my $string1;
#for verb
my $string2;
#article
my $string3;
#questions sense
my $string4;
my $string5;


#Using regular expression to get the sense of the question and sending to Wikipedia

  if($question=~m/(Who|what) (was|is|were|are) (the |an? )?(.*)\?/i){

    #this is a question type
    $string1=$1;
    #for verb
    $string2=$2;
    #article
    $string3=$3;
    #question sence.
    $string4=$4;
    #using ucfirst to make first letter Uppercase
    $string5 = ucfirst($string4);


    #sending only the keyword to wiki
    my $wiki = WWW::Wikipedia->new(clean_html =>1);
    my $result=$wiki->search($string4);
      if($result){
        my $word= $result ->text();
        $word=~s/\'//g;
        $word=~s/\(.*?\)//g;
        $word=~s/\s+/ /g;

        #find the match of the question.
          if ($word =~ / (?:is|was|were|are) ((a|an|the)[^.]*)./gm){
            print "$string5 $string2 $1.\n";
            }
        }else{
          print "I'm sorry, I don't know.\n";
        }

  }


#Using regular expression to get the sense of the question and sending to Wikipedia
  elsif($question=~m/(where) (was|is|were|are) (the |an? )?(.*)\?/i){
   
    #this is a question type
    $string1=$1;
    #for verb
    $string2=$2;
    #article
    $string3=$3;
    #question sence.
    $string4=$4;
    #using ucfirst to make first letter Uppercase
    $string5 = ucfirst($string4);

   #sending key word to wiki
   my $wiki = WWW::Wikipedia->new(clean_html =>1);
   my $result=$wiki->search($string4);
     if($result){
      my $word= $result ->text();
       $word=~s/\'//g;
       $word=~s/\(.*?\)//g;
       $word=~s/\s+/ /g;

       #using regular expression to get the exact answer.
          if ($word =~ / (?:is|was|were|are) ((a|an|the)[^.]*)./gm){
            $answer="$string5 $string2 $1";
            print "$answer.\n";
          }
     }else{#if the question answer doesnt match
      print "I'm sorry, I don't know.\n";
     }
  }

   #Using regular expression to get the sense of the question and sending to Wikipedia
   elsif($question= ~m/(When) (was|is|were|are) (the |an? )?(.*)\?/i){

         #this is a question type
    $string1=$1;
    #for verb
    $string2=$2;
    #article
    $string3=$3;
    #question sence.
    $string4=$4;
    #using ucfirst to make first letter Uppercase
    $string5 = ucfirst($string4);

    #sending key word to wiki
    my $wiki = WWW::Wikipedia->new(clean_html =>1);
    my $result=$wiki->search($string4);
      if($result){

        my $word= $result ->text();
        $word=~s/\'//g;
        $word=~s/\(.*?\)//g;
        $word=~s/\s+/ /g;

          #using regular expression to get the exact answer.
           if ($word =~ / (?:is|was|were|are) ((a|an|the)[^.]*)./gm){

             #if find the match.
               $answer="$string5 $string2 $1";
               print "$answer.\n";
             }
      }else{

      #if the question answer doesnt match
      print "I'm sorry, I don't know.\n";
      }

    }

    else{#defalt.if none of the question condition matches.
    print "I'm sorry, I don't know.\n";
    }




}