#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Config::Pit;
use feature qw( say );


{ package TumblrDashboardV2;
	sub new {
		my $proto = shift;
		my $class = ref $proto || $proto;
		my $self = {};
		bless $self, $class;
		$self->pit_account(shift);
		return $self;
	}

	sub pit_account {
		my $self = shift;
		if ( @_ ) {
			$self->{pit_account} = $_[0];
		}
		return $self->{pit_account};
	}
	
	sub set_option {
		my ( $self, %args ) = @_;
		if ( @_) {
			$self->{option} = { %args };
		}
		return $self->{option};
	
	}

	sub get {
		my $self = shift;

		my $pit_account;
		if ( $self->{pit_account}){
			$pit_account = $self->{pit_account};
		}
		else{
			return print "Set pit_account\n";
		}
		my $config = Config::Pit::pit_get($pit_account, require => {
				"blog_name"				 => "blog_name",
				"consumer_key"		 => "consumer_key",
				"consumer_secret"	 => "consumer_secret",
				"token"						 => "token",
				"token_secret"		 => "token_secret",
			});

		my %oauth_api_params = (
			'consumer_key'		 => $config->{consumer_key},
			'consumer_secret'	 => $config->{consumer_secret},
			'token'						 => $config->{token},
			'token_secret'		 => $config->{token_secret},
			'signature_method' => 'HMAC-SHA1',
			request_method		 => 'POST',
		);

		my %option = %{$self->{option}};
		my $url = 'http://api.tumblr.com/v2/user/dashboard/';		
#		say $url;


		use Net::OAuth;
		$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
		use HTTP::Request::Common;
		use LWP::UserAgent;
		use JSON;

		my $oauth_request =  Net::OAuth->request("protected resource")->new(
				request_url => $url,
				%oauth_api_params,
				timestamp => time(),
				nonce => rand(1000000),
				extra_params => {
					%option
         }
			);

		$oauth_request->sign;
		if ($oauth_request->verify){
			say 'make request';
		}else{
			say 'cannot make request';
		}

		my $dashboard = LWP::UserAgent->new;

		my $result = $dashboard->request(POST $url, Content => $oauth_request->to_post_body);

		say 'get contents';

		if ( $result->is_success ){
			say 'request is succeeded';
			my $r = decode_json($result->content);
				my $var_id = $r->{response}->{posts}->[0]->{id} || undef;
				if ( defined($var_id)){
					say "defined $var_id";
					$self->{err} = 0;
					return $self->{content_data} = $r;
				}else{
					say 'not defined var_id';
					$self->{err} = 1;
					return $self->{content_data} = undef;
				}
		}else{
			say 'request is failed';
			$self->{err} = 1;
			return $self->{content_data} = undef;
		}
	}

	sub get_hash {
		my $self = shift;
		my $content_data;

		if ($self->{content_data} ){
			$content_data = $self->{content_data};
		}else{
			$content_data = $self->get();
		}

		unless (exists $content_data->{response}->{posts}) {
			print "no contents data\n";
			return $self->{err} = 1;
		}

		for my $post ($content_data->{response}->{posts}) {
			while( my ($keys, $values)= each $post){
				$self->{posts}->[$keys] = $values;
 			}
		}
		$self->{err} = 0;
		return $self->{posts};
	}

	sub _err {
		my $self = shift;
		return $self->{err} || 0;
	}
}

1;


