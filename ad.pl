#!/usr/bin/perl
use strict;

use Net::LDAP;
use Term::ReadKey;
use warnings;
my $user = $ENV{USER};

print "Password: ";
ReadMode 'noecho';
my $password = ReadLine(0);
chomp($password);
ReadMode 'normal';
print "\n";

my $ad = Net::LDAP->new("ldap://amadeus.acm.cs/") or die "nope, not connecting";
$ad->bind("$user\@acm.cs", password=>"$password") or die "Could not bind";

my $mesg = $ad->search(base => "DC=acm,DC=cs", filter => "objectClass=user");
$mesg->code && die $mesg->error;
foreach my $entry ($mesg->entries)
{
	$entry->dump;
}

$ad->unbind();
