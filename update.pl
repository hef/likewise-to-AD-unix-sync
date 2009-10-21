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
	print "=========\n";
	print "$username $uid $gid\n";
	my $results = $ad->search(base =>"OU=ACMUsers,DC=acm,DC=cs", filter => "sAMAccountName=$username");

	foreach my $entry ($results->entries)
	{
		print $entry->get_value('gidNumber'), "\n";
		print $entry->get_value('unixHomeDirectory'), "\n";
		print $entry->get_value('LoginShell'), "\n";
		print $entry->get_value('msSFU30Name'), "\n";
		print $entry->get_value('msSFU30NisDomain'), "\n";
		print $entry->get_value('uidNumber'), "\n";
		
		my $mesg;
		$mesg = $ad->modify( $entry->dn(), add => { msSFU30NisDomain => "acm" } );
		#LDAPerror($mesg);
		$mesg = $ad->modify( $entry->dn(), add => { unixHomeDirectory => "/home/$username" } );
		#LDAPerror($mesg);
		$mesg = $ad->modify( $entry->dn(), add => { msSFU30Name => "$username" } );
		#LDAPerror($mesg);
		$mesg = $ad->modify( $entry->dn(), add => { gidNumber => "$gid" } );
		#LDAPerror($mesg);
		$mesg = $ad->modify( $entry->dn(), add => { uidNumber => "$uid" } );
		#LDAPerror($mesg);



		
	#	add => [ msSFU30Name => "$username" ],
	#		add => [ uidNumber => "$uid" ],
	#		add => [ msSFU30UidNumber => "$uid" ],
	#		add => [ gidNumber => "$gid" ],
	#		add => [ unixHomeDirectory => "/home/$username" ],
	#		add => [ loginShell => "/bin/bash" ]
	
	}
}

$ad->unbind();

sub LDAPerror
{
	my ($mesg) = @_;
	if( $mesg->code)
	{
		print "Return code: ", $mesg->code;
		print "\tMessage: ", $mesg->error_name;
		print " :",          $mesg->error_text;
		print "MessageID: ", $mesg->mesg_id;
		print "\tDN: ", $mesg->dn;

		#---
		# Programmer note:
		#
		#  "$mesg->error" DOESN'T work!!!
		#
		#print "\tMessage: ", $mesg->error;
		#-----
	}
}
