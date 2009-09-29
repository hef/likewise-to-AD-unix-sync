#!/usr/bin/perl
use strict;

use Net::LDAP;
use Term::ReadKey;
use warnings;

my $returncode = `getent passwd`;

my @lines = split(/\n/, $returncode);

#get credentials
my $user = $ENV{USER};
print "Password: ";
ReadMode 'noecho';
my $password = ReadLine(0);
chomp($password);
ReadMode 'normal';
print "\n";

#make ad connection
my $ad = Net::LDAP->new("ldap://amadeus.acm.cs/") or die "nope, not connecting";
$ad->bind("$user\@acm.cs", password=>"$password") or die "Could not bind";


foreach my $line (@lines)
{
	my @passwd = split(/:/,$line);
	ldapfinduser($passwd[0],$passwd[2],$passwd[3]);

}

sub ldapfinduser
{
	my ($username, $uid, $gid) = @_;
	print "$username $uid $gid\n";
	my $mesg = $ad->search(base =>"OU=ACMUsers,DC=acm,DC=cs", filter => "sAMAccountName=$username");
	foreach my $entry ($mesg->entries)
	{
		print $entry->dn();
		print "\n";
	}
}

$ad->unbind();

