package Dancer::Logger::File;
use strict;
use warnings;
use base 'Dancer::Logger::Abstract';

use File::Spec;
use Dancer::Config 'setting';
use Dancer::FileUtils 'path';

my $logfile;

sub logdir {
    my $appdir = setting('appdir');
    my $logroot = $appdir || File::Spec->tmpdir();
    return path($logroot, 'logs');
}

sub init {
    my $logdir = logdir();

    if (!-d $logdir) {
        if (not mkdir $logdir) {
            warn "log directory $logdir doen't exist, unable to create";
            return undef $logfile;
        }
    }

    $logfile = setting('environment');
    $logfile = path($logdir, "$logfile.log");

    unless (open(LOGFILE, '>>', $logfile)) {
        warn "Unable to open $logfile for writing, unable to log";
        undef $logfile;
    }
    close LOGFILE;
}

sub _format {
    my ($level, $message) = @_;
    my ($package, $file, $line) = caller(3);
    $package ||= '-';
    $file    ||= '-';
    $line    ||= '-';

    my $time = localtime;
    chomp $message;
    return "$time [$$] ($level) $message in $file l. $line\n";
}

sub _log {
    my ($self, $level, $message) = @_;
    return unless defined $logfile;

    if (open(LOGFILE, '>>', $logfile)) {
        print LOGFILE _format($level => $message);
        close LOGFILE;
    }
}

1;
