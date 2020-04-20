#!/usr/local/bin/perl -w
#CMSC 416
#Assignment 1
#Heman Baral



#Eliza is a pattern matching automated psychiatrist.
#it recognize user input phrases and generate relevant psychobabble responses. 

$end="";#This is the variable for end input
print "Hi, I'm Eliza.A psychotherapist. What is your name?","\n";
$end="name"; #Name variable
while (<STDIN>)#while loop 
{

  chomp;# This chops new line from the input

  die "Thank you. Nice talking to you.\n" unless $_;# End statement if user press enter

  $sen = $_;#this puts the input inside of a variable.
if ( $end eq "name" && $sen =~ /(.*)(My name is|I am|I'm)(.*)/gi){
  #get the name from user input
  print "Hi,$3 "; #Prints Hi, Name.
  print "How can i help you?\n"; #print " How can i help you?\n ";
  $name=$3;
}


elsif( $end eq  $sen){
  #Checking if user is repeating 
  print "Why do you repeat your self\n";
    $end = $sen;#changes current to end
}


elsif($sen =~ /I am (.*)/gi){
  #regular expression to check the name
  print "Did you come to me because you are $1?\n";
  $end = $sen;

}
elsif($sen =~ /I (.*) you(.*)/gi){
  #regular expression to check the name
  print "Do you really  \n";
  $end = $sen;

}
elsif($sen =~ /I (.*)./gi){
  #regular expression to check the name
  print "why do you $1 ?\n";
  $end = $sen;


}
elsif( $sen=~/(yes|so|no|now|anything|ok|but|how|why|what|don't know)/gi){
  #when the above condition meets output this line
  print"Tell me more please.\n";
    $end = $sen;

}


  elsif($sen=~/(why are you|are you|do you|Did you|you are) (.*)/gi){
  #when the above condition meets output this line
    print"Am i really $2.\n";
      $end = $sen;
   }

   elsif($sen=~/(Thank )(.*)|Thanks/gi){
     # when the above condition meets output this line
     print"It is my pleasure .\n";
       $end = $sen;
    }
   elsif( $sen=~/(can you|Are you going to)(.*)(me)/gi){
  #when the above condition meets output this line
     print"What you need $2 with.\n";
       $end = $sen;
    }
   elsif($sen=~/who is the (.*)|what is your age?|How older you?|what are you do?/gi){
     #when the above condition meets output this line
     print"What answer would please you the most.\n ";
       $end = $sen;
    }

  elsif($sen =~ /how are you?|are you ok?|i want to(.*)/gi){
    #when the above condition meets output this line
  print "why are you interested in that?\n";
   $end = $sen;
  }
  elsif( $sen =~ /(.*)(.*)you./gi){
    #when the above condition meets output this line
    print "i see\n";
     $end = $sen;
    }


  elsif( $end eq $sen =~ /(.*)you|you(.*)/gi){
    # if this condition met then get input and responsing  by this function.
      print "I see.Are you sure?\n";
       $end = $sen;
      }


  elsif($sen =~ /Do you think you are(.*)?/gi){
    # when the above condition meets output this line
    print "why are you interested in wheather or not i am $1\n";

    }


else{
  #if the condition doesnt meet then this line will be outputed
  print "Sorry I didn't quite undersand what you saying ";
  print "Can you say it diffrent way ";#asking if they can say it in a different way
  if($name){
    print ",$name";

  }
  print ("\n");#Printing new line
}
}
