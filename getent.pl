#!/usr/bin/perl
use strict;

use Net::LDAP;
use Term::ReadKey;
use warnings;

my $returncode = `getent passwd`;

my @lines = split(/\n/, $returncode);


foreach my $line (@lines)
{
	my @passwd = split(/:/,$line);
	print $passwd[0];

}
