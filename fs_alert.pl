#!/bin/perl
#
use Sys::Hostname;
use Data::Dumper;
use Time::Local;
#

($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5]; $month +=1;$year +=1900;

if ($day =~ /^\d$/) { $day = "0" . $day;}
if ($min =~ /^\d$/) { $min = "0" . $min;}
if ($sec =~ /^\d$/) { $sec = "0" . $sec;}
if ($hour =~ /^\d$/) { $hour = "0" . $hour;}
if ($month =~ /^\d$/) { $month = "0" . $month;}

my $treshold = 85; ## Change here by the value that will generate the alert
my $fs = "/home,/var/log"; ## Include all FileSystem you want to monitor
my @fs = split /,/, $fs;

my @list = ();

for my $i (0 .. $#fs){
     push @list, qr/^$fs[$i]/;
}


open (COMMAND,"df -h |");
while ($line = <COMMAND>){ 
        chomp $line;
        if ($line =~ /^Filesystem/) {next};
        my @array = split /\s+/, $line;
        $used_perc = @array[4];
        $mount_point = @array[5];
        $used_perc =~s/\%//g;
        if ($mount_point ~~ @list) { 
                if ($used_perc >= $treshold) {
                        $hash{"FileSystem: $mount_point \t| used: $used_perc%"}++;
                }
        }
}

my $mail_file = "mail" .  "_" . $year . $month . $day . $hour . $min . $sec . ".tmp";
open(OUT,">$mail_file") or die "Can't open : $!";

foreach $I ( sort keys %hash) { 
        print OUT "$I\n";
} 
close(OUT);

if ( -z $mail_file ) {
        unlink $mail_file;
} else {
        my $emails="leoberbert\@uol.com.br,leoberbert\@gmail.com.br"; ## Include all emails that will receive the alert
        my $hostname = hostname();
        my $server = "myserver_smtp_not_autenticacao.com.br:25"; ## Change by your SMTP server
        my $message = "Filesystem $mount_point acima do Treshold. ";
        system("cat $mail_file | mailx -S smtp=$server -s \"Alerta: Espaço em disco do servidor $hostname está no limite\" -v $emails");
        unlink $mail_file;
} 