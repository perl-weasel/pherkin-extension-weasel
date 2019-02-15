#!perl

use strict;
use warnings;

use Carp::Always;
use File::Temp;
use File::Spec;
use Pherkin::Extension::Weasel;
use Test::BDD::Cucumber::Model::Feature;
use Test::BDD::Cucumber::Model::Line;
use Test::BDD::Cucumber::Model::Scenario;
use Test::More;

my $dh = File::Temp->newdir();
my $dn = $dh->dirname;
my $screen_dir = File::Spec->catfile($dn, 'screens');
my $log_dir = File::Spec->catfile($dn, 'log');

mkdir $screen_dir;
mkdir $log_dir;

my $ext = Pherkin::Extension::Weasel->new(
    {
        default_session => 'selenium',
        screenshots_dir => $screen_dir,
        screenshot_events => {
            'pre-step' => 0,
                'post-step' => 0,
                'pre-scenario' => 0,
                'post-scenario' => 0,
        },
        sessions => {},
        logging_dir => $log_dir,
    });

$ext->_initialize_logging;
ok($ext->_log, q{logger correctly created});
ok($ext->_log->{template}, q{logger template processor correctly created});

my $f = Test::BDD::Cucumber::Model::Feature->new(
    name => 'feature1',
    satisfaction => [
        Test::BDD::Cucumber::Model::Line->new(
            raw_content => 'satisfaction1'),
    ],
    );

$ext->pre_feature($f, {});

my $output_file = $ext->_flush_log;
open my $fh, "<", $output_file
    or die "Can't open '$output_file': $!";
my $content = join('', <$fh>);
close $fh
    or warn "Can't close '$output_file': $!";

ok($ext->_log, q{logger correctly retained});
ok($ext->_log->{template}, q{logger template processor correctly retained});
ok($ext->_log->{template}, q{logger template processor correctly retained (2)});
ok($content =~ m!<title>feature1</title>!,
   q{TITLE tag correctly populated});
ok($content =~ m!<h1 class="feature">feature1</h1>!,
   q{Feature name correctly interpolated into H1 tag});
ok($content =~ m!<p>satisfaction1</p>!,
   q{Single line satisfaction correctly interpolated});

my $s = Test::BDD::Cucumber::Model::Scenario->new(
    name => 'scenario1',
    );

ok($ext->_log, q{logger correctly retained before scenario start});
ok($ext->_log->{template},
   q{logger template processor correctly retained before scenario start});
$ext->pre_scenario($s, {}, {});
ok($ext->_log, q{logger correctly retained after scenario start});
ok($ext->_log->{template},
   q{logger template processor correctly retained after scenario start});

$output_file = $ext->_flush_log;
open $fh, "<", $output_file
    or die "Can't open '$output_file': $!";
$content = join('', <$fh>);
close $fh
    or warn "Can't close '$output_file': $!";

print STDERR $content;


done_testing;
