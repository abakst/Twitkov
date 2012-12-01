#!/usr/bin/perl

use CGI;

$query = new CGI;

print "Content-type: text/html\n\n";
print "<div id='gentweet'>";
print $query->param('search');
$search = $query->param('search');
$tweet = `./twitkov 2 $query->param('search')`;
print "$tweet\n";
print "</div>\n";
