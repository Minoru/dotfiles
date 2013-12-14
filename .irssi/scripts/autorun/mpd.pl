# MPD Now-Playing Script for irssi
# Copyright (C) 2005 Erik Scharwaechter
# <diozaka@gmx.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# The full version of the license can be found at
# http://www.gnu.org/copyleft/gpl.html.
#
#
#######################################################################
# I'd like to thank Bumby <bumby@evilninja.org> for his impc script,  #
# which helped me a lot with making this script.                      #
#######################################################################
# Type "/np help" for a help page!                                    #
#######################################################################
# CHANGELOG:                                                          #
#  0.4: First official release                                        #
#  0.5: Info message if no song is playing                            #
#       Display alternative text if artist and title are not set      #
#       Some minor changes                                            #
#  0.6: (Alexander Batischev <eual.jp@gmail.com>)                     #
#       Format of output changed to '/me is now listening to'         #
#       Script now deletes file extension when show filename          #
#       Added %ALBUM                                                  #
#       Colors aded                                                   #
#       mpd_silence_text added (more info in help)                    #
#       One more alternative text (for the case when album is unknown)#
#  0.7: (Alexander Batischev <eual.jp@gmail.com>)                     #
#       Add IPv6 support                                              #
#######################################################################

use strict;
use IO::Socket::INET6;
use Irssi;

use vars qw{$VERSION %IRSSI %MPD};

$VERSION = "0.7";
%IRSSI = (
          name        => 'mpd',
          authors     => 'Erik Scharwaechter',
          contact     => 'diozaka@gmx.de',
          license     => 'GPLv2',
          description => 'print info about song you are listening to',
         );

sub my_status_print {
    my($msg,$witem) = @_;

    if ($witem) {
        $witem->print($msg);
    } else {
        Irssi::print($msg);
    }
}

sub np {
    my($data,$server,$witem) = @_;

    if ($data =~ /^help/) {
        help();
        return;
    }

    $MPD{'port'}    = Irssi::settings_get_str('mpd_port');
    $MPD{'host'}    = Irssi::settings_get_str('mpd_host');
    $MPD{'timeout'} = Irssi::settings_get_str('mpd_timeout');
    $MPD{'format'}  = Irssi::settings_get_str('mpd_format');
    $MPD{'alt_text'} = Irssi::settings_get_str('mpd_alt_text');
    $MPD{'alt_text2'} = Irssi::settings_get_str('mpd_alt_text2');
    $MPD{'silence_text'} = Irssi::settings_get_str('mpd_silence_text');

    my $socket = IO::Socket::INET6->new(
                          Proto    => 'tcp',
                          PeerPort => $MPD{'port'},
                          PeerAddr => $MPD{'host'},
                          timeout  => $MPD{'timeout'}
                          );

    if (not $socket) {
        my_status_print('No MPD listening at '.$MPD{'host'}.':'.$MPD{'port'}.'.', $witem);
        return;
    }

    $MPD{'status'}   = "";
    $MPD{'artist'}   = "";
    $MPD{'title'}    = "";
    $MPD{'album'}    = "";
    $MPD{'filename'} = "";

    my $ans = "";
    my $str = "";

    # NOTE: it's better for you to follow this link before reading code:
    # http://mpd.wikia.com/wiki/MusicPlayerDaemonCommands

    print $socket "status\n";
    while (not $ans =~ /^(OK$|ACK)/) {
        $ans = <$socket>;
        if ($ans =~ /state: (.+)$/) {
            $MPD{'status'} = $1;
        }
    }

    if ($MPD{'status'} eq "stop" or $MPD{'status'} eq "pause") {
        if ($witem && ($witem->{type} eq "CHANNEL" or $witem->{type} eq "QUERY"))
        {
            $str = $MPD{'silence_text'};
            $witem->command("ME $str");
        } else {
            Irssi::print("You're not in a channel.");
        }
        close $socket;
        return;
    }

    print $socket "currentsong\n";
    $ans = "";
    while (not $ans =~ /^(OK$|ACK)/) {
        $ans = <$socket>;
        if ($ans =~ /file: (.+)$/) {
            my $filename = $1;
            $filename =~ s/.*\///;
            $filename =~ s/\..*//e;
            $MPD{'filename'} = $filename;
        } elsif ($ans =~ /Artist: (.+)$/) {
            $MPD{'artist'} = $1;
        } elsif ($ans =~ /Title: (.+)$/) {
            $MPD{'title'} = $1;
        } elsif ($ans =~ /Album: (.+)$/) {
            $MPD{'album'} = $1;
        }
    }

    close $socket;

    if ($MPD{'artist'} eq "" and $MPD{'title'} eq "") {
        $str = $MPD{'alt_text'};
    } elsif ($MPD{'album'} eq "") {
        $str = $MPD{'alt_text2'};
    } else {
        $str = $MPD{'format'};
    }

    # Unknown Track by Unknown Artist from Unknown Album is THE BEST :)
    if ($MPD{'artist'} eq "") { $MPD{'artist'} = "Unknown Artist" };
    if ($MPD{'title'} eq "")  { $MPD{'title'}  = "Unknown Track" };
    if ($MPD{'album'} eq "")  { $MPD{'album'}  = "Unknown Album" };

    $str =~ s/\%ARTIST/$MPD{'artist'}/g;
    $str =~ s/\%TITLE/$MPD{'title'}/g;
    $str =~ s/\%FILENAME/$MPD{'filename'}/g;
    $str =~ s/\%ALBUM/$MPD{'album'}/g;

    if ($witem && ($witem->{type} eq "CHANNEL" ||
                   $witem->{type} eq "QUERY")) {
        if($MPD{'format'} =~ /^\/me /) {
            $witem->command($str);
        } else {
            $witem->command("ME $str");
        }
    } else {
        Irssi::print("You're not in a channel.");
    }
}


sub help {
   print '
 MPD Now-Playing Script
========================

by Erik Scharwaechter (diozaka@gmx.de)
modified by Alexander Batischev (eual.jp@gmail.com)

VARIABLES
  mpd_host          The host that runs MPD (localhost)
  mpd_port          The port MPD is bound to (6600)
  mpd_timeout       Connection timeout in seconds (5)
  mpd_format        The text to display
  mpd_alt_text      The text to display if %%ARTIST and %%TITLE are empty
  mpd_alt_text2     The text to display if %%ALBUM is empty
  mpd_silence_text  The text ro display if MPD is sopped or paused

USAGE
  /np           Print the song you are listening to
  /np help      Print this text
';
}


Irssi::settings_add_str('mpd', 'mpd_host', 'localhost');
Irssi::settings_add_str('mpd', 'mpd_port', '6600');
Irssi::settings_add_str('mpd', 'mpd_timeout', '5');
# Here I used colors, you may need this table:
#
# \002 means bold (Usage: \002Here is bold text\002)
# \037 means underlined text (Usage: \037Here is underlined text\037)
# \003fg[,bg] sets foreground and background colors (Usage: \0033Here is green
# text\003  or  \0038,1Here is yellow text at black background\003)
#
# Table of mIRC colors (it's de-facto standard in the IRC world):
#  0  white
#  1  black
#  2  blue
#  3  green
#  4  lightred
#  5  brown
#  6  purple
#  7  orange
#  8  yellow
#  9  lightgreen
# 10  cyan
# 11  lightcyan
# 12  lightblue
# 13  pink
# 14  grey
# 15  lightgrey

Irssi::settings_add_str('mpd', 'mpd_format', "is now listening to \00305%TITLE\003 by \00303%ARTIST\003 from \00310%ALBUM\003");
Irssi::settings_add_str('mpd', 'mpd_silence_text', "is now listening to \0038the silence\003");
Irssi::settings_add_str('mpd', 'mpd_alt_text', "is now listening to \002\00314%FILENAME\003\002");
Irssi::settings_add_str('mpd', 'mpd_alt_text2', "is now listening to \00305%TITLE\003 by \00303%ARTIST\003");

Irssi::command_bind np        => \&np;
Irssi::command_bind 'np help' => \&help;

