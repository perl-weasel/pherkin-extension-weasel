
=head1 NAME

Pherkin::Extension::Weasel - Pherkin extension for web-testing

=head1 VERSION

0.01

=head1 SYNOPSIS



=cut

package Pherkin::Extension::Weasel;

use strict;
use warnings;

our $VERSION = '0.01';


use Module::Runtime qw(use_module);
use Test::BDD::Cucumber::Extension;

use Weasel;
use Weasel::Session;

use Moose;
extends 'Test::BDD::Cucumber::Extension';


=head1 Test::BDD::Cucumber::Extension protocol implementation

=over

=item step_directories

=cut

sub step_directories {
    return [ 'weasel_steps/' ];
}

=item pre_execute

=cut

sub pre_execute {
    my ($self) = @_;

    my $ext_config = $self->sessions;
    my %sessions;
    for my $sess_name (keys %{$ext_config}) {
        my $sess = $ext_config->{$sess_name};
        my $drv = use_module($sess->{driver}->{drv_name});
        $drv = $drv->new(%{$sess->{driver}});
        my $session = Weasel::Session->new(driver => $drv);
        $sessions{$sess_name} = $session;
    }
    my $weasel = Weasel->new(
        default_session => $self->default_session,
        sessions => \%sessions);
    $self->_weasel($weasel);
}


=item pre_scenario

=cut

sub pre_scenario {
    my ($self, $scenario, $feature_stash, $stash) = @_;

    if (grep { $_ eq 'weasel'} @{$scenario->tags}) {
        $stash->{ext_wsl} = $self->_weasel->session;
        $self->_weasel->session->start;
    }
}


sub post_scenario {
    my ($self, $scenario, $feature_stash, $stash) = @_;

    $stash->{ext_wsl}->stop
        if defined $stash->{ext_wsl};
}

=back

=head1 ATTRIBUTES

=over

=item default_session

=cut

has 'default_session' => (is => 'ro');

=item sessions

=cut

has 'sessions' => (is => 'ro',
                   isa => 'HashRef',
                   required => 1);

=item base_url

URL part to be used for prefixing URL arguments in steps

=cut

has base_url => ( is => 'rw', default => '' );

=item screenshots_dir

=cut

has screenshots_dir => (is => 'rw', isa => 'Str');

=item screenshot_events

=cut

has screenshot_events => (is => 'ro',
                          isa => 'HashRef',
                          default => sub { {} },
                          traits => ['Hash'],
                          handles => {
                              screenshot_on => 'set',
                              screenshot_off => 'delete',
                          },
    );

=item _weasel

=cut


has _weasel => (is => 'rw',
                isa => 'Weasel');

=back

=head1 CONTRIBUTORS

Erik Huelsmann

=head1 MAINTAINERS

Erik Huelsmann

=head1 BUGS

Bugs can be filed in the GitHub issue tracker for the Weasel project:
 https://github.com/perl-weasel/weasel-driver-selenium2/issues

=head1 SOURCE

The source code repository for Weasel is at
 https://github.com/perl-weasel/weasel-driver-selenium2

=head1 SUPPORT

Community support is available through
L<perl-weasel@googlegroups.com|mailto:perl-weasel@googlegroups.com>.

=head1 COPYRIGHT

 (C) 2016  Erik Huelsmann

Licensed under the same terms as Perl.

=cut


1;
