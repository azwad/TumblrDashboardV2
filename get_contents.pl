#!/usr/bin/perl

use TumblrDashboardV2;
use lib qw(/home/toshi/perl/lib);
use strict;
use utf8;
use HashDump;
use feature qw( say);

my $pit_account = 'news.azwad.com';
my $limit = 50;
my $offset = 0;
my $since_id = 27576448332;
my $type = 'text';
#my $since_id = 27688888888;
my $reblog_info = 'True';
my $notes_info = 'True';


my $td = TumblrDashboardV2->new($pit_account);

my %opt = (
		'limit'				=> $limit,
		'offset'			=> $offset,
		'since_id'		=> $since_id,
#		'type'				=> $type,
		'reblog_info'	=> $reblog_info,
		'note_info'		=> $notes_info,
);
	$td->set_option(%opt);

my $res  = $td->get;
if ($td->_err){
	say "err:".  $td->_err;
}else{
	HashDump->load($res);
}
