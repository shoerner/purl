#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket::INET;

#Flush after every write
$| = 1;

my $socket;
my $client_socket;

$socket = new IO::Socket::INET (
	PeerHost => 'shoerner.net',
	PeerPort => 80,
	Proto => 'tcp',
) or die "ERROR in socket creation: $!\n";

$socket->send("GET / HTTP/1.0\n\n");

my @output;
my $HTMLStart;
while ( <$socket> ) 
{ 
	push(@output, $_); 
	if(substr($_, 0, 9) eq "<!DOCTYPE")
	{
		$HTMLStart = scalar(@output)-1;
	}
}
close $socket;

for(my $counter = $HTMLStart; $counter < @output; $counter++)
{
	print $output[$counter];
}