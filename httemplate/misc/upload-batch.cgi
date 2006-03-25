<%

  my $fh = $cgi->upload('batch_results');
  my $filename = $cgi->param('batch_results');
  $filename =~ /^(.*[\/\\])?([^\/\\]+)$/
    or die "unparsable filename: $filename\n";
  my $paybatch = $2;

  my $error = defined($fh)
    ? FS::cust_pay_batch::import_results( {
        'filehandle' => $fh,
        'format'     => $cgi->param('format'),
        'paybatch'   => $paybatch,
      } )
    : 'No file';

  if ( $error ) {
    %>
    <!-- mason kludge -->
    <%
    eidiot($error);
#    $cgi->param('error', $error);
#    print $cgi->redirect( "${p}cust_main-import.cgi
  } else {
    %>
    <!-- mason kludge -->
    <%= include("/elements/header.html",'Batch results upload successful') %> <%
  }
%>

