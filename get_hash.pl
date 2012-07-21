#!/usr/bin/perl

use TumblrDashboardV2;
use lib qw(/home/toshi/perl/lib);
use strict;
use utf8;
use HashDump;
use feature qw (say);

my $pit_account = 'news.azwad.com';

my $limit = 20;
my $offset = 0;
my $since_id = 27680000000;
my $type = 'text';
my $reblog_info = 'True';
my $notes_info = 'True';


my @res;

my $loop = 0;

while  ($loop < 20) {

	say $loop. 'turn';

	my %opt = (
		'limit'				=> $limit,
		'offset'			=> $offset,
		'since_id'		=> $since_id,
#		'type'				=> $type,
		'reblog_info'	=> $reblog_info,
		'note_info'		=> $notes_info,
	);

	my $td = TumblrDashboardV2->new($pit_account);
	$td->set_option(%opt);

	my $hash = $td->get_hash;

	if ($td->_err){
		say 'no contents';
		last;
	}
	while (my ($keys, $var) = each @$hash){
		my $since_id_tmp = $var->{id};
		if ($since_id < $since_id_tmp) {
			 $since_id = $since_id_tmp;
			 say $since_id;
		}
		push (@res, $var);
	}

	++$loop;
}

my $res = \@res;

HashDump->load($res);

