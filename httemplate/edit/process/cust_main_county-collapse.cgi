<% $cgi->redirect(popurl(3). "browse/cust_main_county.cgi?".
                             "country=". uri_escape($cgi->param('country')).";".
                             'state='.   uri_escape($cgi->param('state')).  ';'.
                             'county='.  uri_escape($cgi->param('county'))
                 )
%>
<%init>

die "access denied"
  unless $FS::CurrentUser::CurrentUser->access_right('Configuration');

$cgi->param('taxnum') =~ /^(\d+)$/ or die "Illegal taxnum!";
my $taxnum = $1;
my $cust_main_county = qsearchs('cust_main_county', { 'taxnum' => $taxnum } )
  or die "Unknown taxnum $taxnum";

#really should do this in a .pm & start transaction

my %search = (
               'country' => $cust_main_county->country,
               'state'   => $cust_main_county->state,
             );

$search{'county'} = $cust_main_county->county
  if $cust_main_county->city;

foreach my $delete ( qsearch('cust_main_county', \%search) ) {
#  unless ( qsearch('cust_main',{
#    'state'  => $cust_main_county->getfield('state'),
#    'county' => $cust_main_county->getfield('county'),
#    'country' =>  $cust_main_county->getfield('country'),
#  } ) ) {
    my $error = $delete->delete;
    die $error if $error;
#  } else {
    #should really fix the $cust_main record
#  }

}

$cust_main_county->taxnum('');
if ( $cust_main_county->city ) {
  $cust_main_county->city('');
} elsif ( $cust_main_county->county ) {
  $cust_main_county->county('');
} else {
  die "can't collapse that";
}

my $error = $cust_main_county->insert;
die $error if $error;

</%init>
