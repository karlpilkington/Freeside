#!/usr/bin/perl
# BEGIN LICENSE BLOCK
# 
# Copyright (c) 1996-2003 Jesse Vincent <jesse@bestpractical.com>
# 
# (Except where explictly superceded by other copyright notices)
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# Unless otherwise specified, all modifications, corrections or
# extensions to this work which alter its source code become the
# property of Best Practical Solutions, LLC when submitted for
# inclusion in the work.
# 
# 
# END LICENSE BLOCK

use strict;

BEGIN {
    $ENV{'PATH'}   = '/bin:/usr/bin';                      # or whatever you need
    $ENV{'CDPATH'} = '' if defined $ENV{'CDPATH'};
    $ENV{'SHELL'}  = '/bin/sh' if defined $ENV{'SHELL'};
    $ENV{'ENV'}    = '' if defined $ENV{'ENV'};
    $ENV{'IFS'}    = '' if defined $ENV{'IFS'};
}

use lib ("/opt/rt3/local/lib", "/opt/rt3/lib");
use RT;

package RT::Mason;

use CGI qw(-private_tempfiles);    #bring this in before mason, to make sure we
                                   #set private_tempfiles

BEGIN {
    if ($CGI::MOD_PERL) {
	require HTML::Mason::ApacheHandler;
    }
    else {
	require HTML::Mason::CGIHandler;
    }
}

use HTML::Mason;                   # brings in subpackages: Parser, Interp, etc.

use vars qw($Nobody $SystemUser $r);

#This drags in RT's config.pm
RT::LoadConfig();

use Carp;

{
    package HTML::Mason::Commands;
    use vars qw(%session);

    use RT::Tickets;
    use RT::Transactions;
    use RT::Users;
    use RT::CurrentUser;
    use RT::Templates;
    use RT::Queues;
    use RT::ScripActions;
    use RT::ScripConditions;
    use RT::Scrips;
    use RT::Groups;
    use RT::GroupMembers;
    use RT::CustomFields;
    use RT::CustomFieldValues;
    use RT::TicketCustomFieldValues;

    use RT::Interface::Web;
    use MIME::Entity;
    use Text::Wrapper;
    use CGI::Cookie;
    use Time::ParseDate;
    use HTML::Entities;
}


# Activate the following if running httpd as root (the normal case).
# Resets ownership of all files created by Mason at startup.
# Note that mysql uses DB for sessions, so there's no need to do this.
unless ($RT::DatabaseType =~ /(mysql|Pg)/) {
    # Clean up our umask to protect session files
    umask(0077);

if ( $CGI::MOD_PERL)  {
    chown( Apache->server->uid, Apache->server->gid, [$RT::MasonSessionDir] )
	if Apache->server->can('uid');
        }
    # Die if WebSessionDir doesn't exist or we can't write to it
    stat($RT::MasonSessionDir);
    die "Can't read and write $RT::MasonSessionDir"
	unless ( ( -d _ ) and ( -r _ ) and ( -w _ ) );
}

my $ah = &RT::Interface::Web::NewApacheHandler() if $CGI::MOD_PERL;

sub handler {
    ($r) = @_;

    RT::Init();

    # We don't need to handle non-text items
    return -1 if defined( $r->content_type ) && $r->content_type !~ m|^text/|io;

    my %session;
    my $status = $ah->handle_request($r);
    undef (%session);

    $RT::Logger->crit("Transaction not committed. Usually indicates a software fault. Data loss may have occurred") if $RT::Handle->TransactionDepth;
    return $status;
}

1;
