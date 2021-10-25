#!/usr/bin/perl -w
# original: http://tinyurl.com/zneombb
# Modify by: sornram9254.com
# Support Thai encoding / UTF-8
use strict; #Data::Dumper;
use JSON qw( decode_json );
use JSON qw( encode_json );
use WWW::Mechanize;
use Term::ReadKey;
# http://stackoverflow.com/a/885888 | What is the difference between my and our in Perl?
our $baseUrl = "https://www.discordapp.com/api/";
print "E-mail: ";
chomp (our $email = <STDIN>);
print "Password: ";
ReadMode("noecho");
chomp (our $password = <STDIN>);
our $lastMsgID = "0";
our $botUserID = "";
our $intChanID = 242240917480669184; #dev, 241308379090386944; #general

our $lastUserID = "";
our $lastMsg = "";
our $lastMsgUser = "";
# Clear the terminal screen
system "clear";
BEGIN { system "clear"; }
sub login( $$ ) {
	# Set local variables
	my $apiEmail = $_[0];
	my $apiPassword = $_[1];
	my $apiUrl = $baseUrl . "auth/login";
	my $postData = encode_json { "email" => $apiEmail, "password" => $apiPassword };

	# Connect to Discord
	my $discordClient = WWW::Mechanize->new( agent => 'DiscordBot-Perl' );
	my $clientConnected = eval { $discordClient->post( $apiUrl, 'Content-Type' => 'application/json', Content => $postData ); };
	if ( ! $clientConnected ) { errorCon( ); } # Error on any connection errors
	else { # Set values when connection is successful
		our $apiContent = $discordClient->content;
		our $apiJson = decode_json( $apiContent );
		our $apiToken = $apiJson->{'token'};
		return ( $apiToken ); # Return Auth Token
	}
}
our $authToken = login( $email, $password );
sub logout {
# logout of auth token	
}
sub getUserInfo( $ ) {
	my $apiUrl = $baseUrl . "users/\@me";
	my $discordClient = WWW::Mechanize->new( agent => 'DiscordBot-Perl' );
	$discordClient->add_header( 'Authorization' => "$authToken" );
	$discordClient->get( $apiUrl, 'Content-Type' => 'application/json' );
	my $clientConnected = eval { $discordClient->get( $apiUrl, 'Content-Type' => 'application/json' ); };
	if ( ! $clientConnected ) { errorCon( ); }
	else { # Set values when connection is successful
		our $apiContent = $discordClient->content;
		our $apiJson = decode_json( $apiContent );
		$botUserID = $apiJson->{'id'};
		#print "\n" . Dumper( $apiJson ) . "\n";
	}
}
sub getChannel( $ ) {
	my $apiUrl = $baseUrl . "channels/" . $_[0];
	my $discordClient = WWW::Mechanize->new( agent => 'DiscordBot-Perl' );
	$discordClient->add_header( 'Authorization' => "$authToken" );
	$discordClient->get( $apiUrl, 'Content-Type' => 'application/json' );
	my $clientConnected = eval { $discordClient->get( $apiUrl, 'Content-Type' => 'application/json' ); };
	if ( ! $clientConnected ) { errorCon( ); }
	else { # Set values when connection is successful
		our $apiContent = $discordClient->content;
		our $apiJson = decode_json( $apiContent );
		#print "Pretty Response:\n" . Dumper( $apiJson ) . "\n";
	}
}
sub getMessages( $ ) {
	my $apiUrl = $baseUrl . "channels/" . $_[0] . "/messages?limit=1";
	my $discordClient = WWW::Mechanize->new( agent => 'DiscordBot-Perl' );
	# Add the auth token to the header
	$discordClient->add_header( 'Authorization' => "$authToken" );
	my $clientConnected = eval { $discordClient->get( $apiUrl, 'Content-Type' => 'application/json' ); };
	if ( ! $clientConnected ) { errorCon( ); }
	else { # Set values when connection is successful
		our $apiContent = $discordClient->content;
		my $apiJson = decode_json( $apiContent );
		my $msgID = $apiJson->[0]->{'id'}; # Message ID
		my $msgAuthorID = $apiJson->[0]->{'author'}->{'id'}; #username
		my $msgContent = $apiJson->[0]->{'content'};
        #-DEBUG-#####################
		my $msgAuthor = $apiJson->[0]->{'author'}->{'username'};
        $lastMsgUser = $msgAuthor;
        $lastMsg     = $msgContent;
        #############################
		if ($msgID > $lastMsgID && $lastUserID ne $msgAuthorID) { # TBE
			our @message = split( " ", $msgContent );
			# Simple test command
            ##############################################################
			if($message[0] eq "!test"){
				sendMsg("Success สำมะเหร็ด!");
			}
            ##############################################################
            my $receiveMsg = receiveMsg($msgContent);
			if($receiveMsg =~ /ดีคั|ดีครั|สวัสดี|หวัดดี|ดีฮะ|ดีฮั|ดีจ้|ดีจ๊|ดีจ่|hello/ig){
				sendMsg("ส วั ส ดี จ้ า  <@".$msgAuthorID."> o.o/");
            }
            ##############################################################
			$lastMsgID = $msgID;
		}
	}
}
sub createMessage( $$ ) {
	my $apiUrl = $baseUrl . "channels/" . $_[0] . "/messages";
	my $postData = encode_json { "content" => "$_[1]" };
	my $discordClient = WWW::Mechanize->new( agent => 'DiscordBot-Perl' );
	$discordClient->add_header( 'Authorization' => "$authToken" );
	#$discordClient->add_header( 'Authorization' => '' );
	$discordClient->post( $apiUrl, 'Content-Type' => 'application/json', Content => "$postData" );
}
sub sendMsg{
    my ($str) = @_;
    createMessage( $intChanID, Encode::decode("UTF-8", $str));
}
sub receiveMsg{
    my ($str) = @_;
    return Encode::encode("UTF-8", $str);
}
sub errorCon {
	print "Error: Unable to connect to Discord!\n";
}

while ( 1 ) {
    getChannel($intChanID);
    getMessages($intChanID);
    print "====\n<".$lastMsgUser.">".receiveMsg($lastMsg)."\n====\n"; 
	sleep 1;
}
