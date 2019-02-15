#!perl

use strict;
use warnings;

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
        logging_dir => $log_dir,
    });

$ext->_initialize_logging;


my $f = Test::BDD::Cucumber::Model::Feature->new(
    name => 'feature1',
    satisfaction => [
        Test::BDD::Cucumber::Model::Line->new(
            raw_content => 'satisfaction1'),
    ],
    );

$ext->pre_feature($f, {});
$ext->_flush_log;


done_testing;
