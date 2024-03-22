#!/usr/bin/perl

%sender_list = ();  #ip list

chdir "/var/log";
for (glob 'zimbra.log*')
#for (glob 'zimbra.log')
{

  #print "***** Opening file $_","\n";
  if ($_ eq 'zimbra.log')
  {
     $audit_log = 1;
     open (IN, sprintf("cat %s |", $_))
       or die("Can't open pipe from command 'zcat $filename' : $!\n");
  }
  else
  {
     $audit_log = 0;
     open (IN, sprintf("zcat %s |", $_))
       or die("Can't open pipe from command 'zcat $filename' : $!\n");
  }

  while (<IN>)
  {
   if (m#RelayedOutbound#)
   {
      my $recipcnt = 0;

      next if (m#dkim_s#);   # messasges are listed twice (first via clamav then dkim signed)

      ($sender, $recipients) = m#[^<]+<([^>]+)>[^<]+(.*)\s+Queue-ID#;
                $recipcnt = $recipients =~ tr/,/,/;
      $sender_list{$sender} += $recipcnt;   # count number or recipients

      #print "sender $sender, recipients $recipients count: $sender_list{$sender}\n";
   }
   }
close (IN);
}

# print out totals per sender
printSenders();

sub printSenders
{
   my $sender = ();

   for $sender (sort {$sender_list{$b} <=> $sender_list{$a}} keys %sender_list)
   {
      print "$sender sent: $sender_list{$sender}\n";
   }
}
