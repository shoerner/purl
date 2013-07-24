#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket::INET;
use Getopt::Long;

#Flush after every write
$| = 1;

my $socket;
my $client_socket;
my ($port, $host, $path);
my @HTMLDump;
my $HTMLStart;

sub seperateURL
{
	my $incomingURL = join('', @_);

	#get addressing port 
	$incomingURL =~ /https\:\/\// ? $port = 443 : $port = 80;

	#Get addressing hostname
	if(index($incomingURL, '://') != -1)
	{
		my $typeEnd = index($incomingURL, '://')+3;
		if(index($incomingURL, '/', $typeEnd) != -1)
		{
			$host = substr($incomingURL, $typeEnd, (index($incomingURL, '/', $typeEnd)-$typeEnd));
			$path = substr($incomingURL, index($incomingURL, '/', $typeEnd))
		}
		else
		{
			$host = substr($incomingURL, $typeEnd);
			$path = '';
		}
		
	}
	else
	{
		$host = substr($incomingURL, 0, (index($incomingURL, '/')));
		if(index($incomingURL, '/') != -1)
		{
			$path = substr($incomingURL, index($incomingURL, '/'))
		}
		else
		{
			$path = '';
		}
	}

	print "Port: $port\n";
	print "Host: $host\n";
	print "Path: $path\n";
}
sub performHTTPRequest
{
	$socket = new IO::Socket::INET (
		PeerHost => $host,
		PeerPort => $port,
		Proto => 'tcp',
	) or die "Error in socket creation: $!\n";

	$socket->send("GET $path HTTP/1.0\n\n");

	while ( <$socket> ) 
	{ 
		push(@HTMLDump, $_); 
		if(substr($_, 0, 9) eq "<!DOCTYPE")
		{
			$HTMLStart = scalar(@HTMLDump)-1;
		}
	}
	close $socket;
}
sub printHTML
{
	for(my $counter = $HTMLStart; $counter < @HTMLDump; $counter++)
	{
		print $HTMLDump[$counter];
	}
}

seperateURL($ARGV[0]);
performHTTPRequest();
printHTML();