#!perl

use strict;
use warnings;

use Test::BDD::Cucumber::StepFile;

When qr/I navigate to '(.*)'/, sub {
    my $url = S->{ext_wsl}->base_url . $1;

    S->{ext_wsl}->session->get($url);
#    S->{ext_wsl}->try_wait_for_page;;
};

1;
