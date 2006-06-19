package FS::access_user;

use strict;
use vars qw( @ISA );
use FS::Record qw( qsearch qsearchs dbh );
use FS::m2m_Common;
use FS::access_usergroup;

@ISA = qw( FS::m2m_Common FS::Record );

=head1 NAME

FS::access_user - Object methods for access_user records

=head1 SYNOPSIS

  use FS::access_user;

  $record = new FS::access_user \%hash;
  $record = new FS::access_user { 'column' => 'value' };

  $error = $record->insert;

  $error = $new_record->replace($old_record);

  $error = $record->delete;

  $error = $record->check;

=head1 DESCRIPTION

An FS::access_user object represents an internal access user.  FS::access_user inherits from
FS::Record.  The following fields are currently supported:

=over 4

=item usernum - primary key

=item username - 

=item _password - 

=item last -

=item first -

=back

=head1 METHODS

=over 4

=item new HASHREF

Creates a new internal access user.  To add the user to the database, see L<"insert">.

Note that this stores the hash reference, not a distinct copy of the hash it
points to.  You can ask the object for a copy with the I<hash> method.

=cut

# the new method can be inherited from FS::Record, if a table method is defined

sub table { 'access_user'; }

=item insert

Adds this record to the database.  If there is an error, returns the error,
otherwise returns false.

=cut

# the insert method can be inherited from FS::Record

=item delete

Delete this record from the database.

=cut

# the delete method can be inherited from FS::Record

=item replace OLD_RECORD

Replaces the OLD_RECORD with this one in the database.  If there is an error,
returns the error, otherwise returns false.

=cut

# the replace method can be inherited from FS::Record

=item check

Checks all fields to make sure this is a valid internal access user.  If there is
an error, returns the error, otherwise returns false.  Called by the insert
and replace methods.

=cut

# the check method should currently be supplied - FS::Record contains some
# data checking routines

sub check {
  my $self = shift;

  my $error = 
    $self->ut_numbern('usernum')
    || $self->ut_text('username')
    || $self->ut_text('_password')
    || $self->ut_text('last')
    || $self->ut_text('first')
  ;
  return $error if $error;

  $self->SUPER::check;
}

=item name

Returns a name string for this user: "Last, First".

=cut

sub name {
  my $self = shift;
  $self->get('last'). ', '. $self->first;
}

=item access_usergroup

=cut

sub access_usergroup {
  my $self = shift;
  qsearch( 'access_usergroup', { 'usernum' => $self->usernum } );
}

#=item access_groups
#
#=cut
#
#sub access_groups {
#
#}
#
#=item access_groupnames
#
#=cut
#
#sub access_groupnames {
#
#}

=item agentnums 

Returns a list of agentnums this user can view (via group membership).

=cut

sub agentnums {
  my $self = shift;
  my $sth = dbh->prepare(
    "SELECT DISTINCT agentnum FROM access_usergroup
                              JOIN access_groupagent USING ( groupnum )
       WHERE usernum = ?"
  ) or die dbh->errstr;
  $sth->execute($self->usernum) or die $sth->errstr;
  map { $_->[0] } @{ $sth->fetchall_arrayref };
}

=item agentnums_href

Returns a hashref of agentnums this user can view.

=cut

sub agentnums_href {
  my $self = shift;
  { map { $_ => 1 } $self->agentnums };
}

=item agentnums_sql

Returns an sql fragement to select only agentnums this user can view.

=cut

sub agentnums_sql {
  my $self = shift;
  '( '.
    join( ' OR ', map "agentnum = $_", $self->agentnums ).
  ' )';
}

=back

=head1 BUGS

=head1 SEE ALSO

L<FS::Record>, schema.html from the base documentation.

=cut

1;

