AnyEvent::Discord::Client->new(token => $token)
 
my $token = 'BOT TOKEN';
 
my $bot = new AnyEvent::Discord::Client(
  token => $token,
  commands => {
    'commands' => sub {
      my ($bot, $args, $msg, $channel, $guild) = @_;
      $bot->say($channel->{id}, join("   ", map {"`$_`"} sort grep {!$commands_hidden{$_}} keys %{$bot->commands}));
    },
  },
);
 
$bot->add_commands(
  'hello' => sub {
    my ($bot, $args, $msg, $channel, $guild) = @_;
 
    $bot->say($channel->{id}, "hi, $msg->{author}{username}!"); # Command
  },
);
 
$bot->connect();
AnyEvent->condvar->recv;
