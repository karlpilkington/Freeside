<!-- mason kludge -->
<%
#Begin silliness
#
#use FS::UI::CGI;
#use FS::UI::agent;
#
#$ui = new FS::UI::agent;
#$ui->browse;
#exit;
#__END__
#End silliness
%>

<%= header('Agent Listing', menubar(
  'Main Menu'   => $p,
  'Agent Types' => $p. 'browse/agent_type.cgi',
#  'Add new agent' => '../edit/agent.cgi'
)) %>
Agents are resellers of your service. Agents may be limited to a subset of your
full offerings (via their type).<BR><BR>
<A HREF="<%= $p %>edit/agent.cgi"><I>Add a new agent</I></A><BR><BR>

<%= table() %>
<TR>
  <TH COLSPAN=2>Agent</TH>
  <TH>Type</TH>
  <TH><FONT SIZE=-1>Freq.</FONT></TH>
  <TH><FONT SIZE=-1>Prog.</FONT></TH>
</TR>
<% 
#        <TH><FONT SIZE=-1>Agent #</FONT></TH>
#        <TH>Agent</TH>

foreach my $agent ( sort { 
  #$a->getfield('agentnum') <=> $b->getfield('agentnum')
  $a->getfield('agent') cmp $b->getfield('agent')
} qsearch('agent',{}) ) {
  my($hashref)=$agent->hashref;
  my($typenum)=$hashref->{typenum};
  my($agent_type)=qsearchs('agent_type',{'typenum'=>$typenum});
  my($atype)=$agent_type->getfield('atype');
  print <<END;
      <TR>
        <TD><A HREF="${p}edit/agent.cgi?$hashref->{agentnum}">
          $hashref->{agentnum}</A></TD>
        <TD><A HREF="${p}edit/agent.cgi?$hashref->{agentnum}">
          $hashref->{agent}</A></TD>
        <TD><A HREF="${p}edit/agent_type.cgi?$typenum">$atype</A></TD>
        <TD>$hashref->{freq}</TD>
        <TD>$hashref->{prog}</TD>
      </TR>
END

}

print <<END;
    </TABLE>
  </BODY>
</HTML>
END

%>
