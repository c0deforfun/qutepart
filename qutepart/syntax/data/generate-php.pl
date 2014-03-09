#!/usr/bin/perl

# This perl script read stdin and write on stdout. It shall be an XML language file.
#
# * If the name of the language is 'HTML', then it creates the language 'PHP (HTML)'
#   which shall be used for PHP hl.
#
# * If the name of the language is something else (say '*'), it creates the language '*/PHP'.
#   This new language is the same as the old one, but is able to detect PHP everywhere.
#
# This script will correctly set extensions & mimetype, and will replace
# <IncludeRules context="##*"> by <IncludeRules context="##*/PHP">
#
# Generated languages need a language named 'PHP/PHP', which shall take care of PHP hl itself
# and which will be called every time something like <?php is encountred.
#
# Author: Jan Villat <jan.villat@net2000.ch>
# License: LGPL

my $file = "";

while (<>)
{
  $file .= $_;
}

$warning = "\n\n<!-- ***** THIS FILE WAS GENERATED BY A SCRIPT - DO NOT EDIT ***** -->\n";

$file =~ s/(?=<language)/$warning\n\n\n/;

if ($file =~ /<language[^>]+name="HTML"/)
{
  $root = 1;
}

if ($root == 1)
{
  $file =~ s/<language([^>]+)name="[^"]*"/<language$1name="PHP (HTML)"/s;
  $file =~ s/<language([^>]+)section="[^"]*"/<language$1section="Scripts"/s;
  $file =~ s/<language([^>]+)extensions="[^"]*"/<language$1extensions="*.php;*.php3;*.wml;*.phtml;*.phtm;*.inc"/s;
  $file =~ s/<language([^>]+)mimetype="[^"]*"/<language$1mimetype="text\/x-php4-src;text\/x-php3-src;text\/vnd.wap.wml;application\/x-php"/s;
}
else
{
  $file =~ s/<language([^>]+)name="([^"]*)"/<language$1name="$2\/PHP" hidden="true"/s;
  $file =~ s/<language([^>]+)section="[^"]*"/<language$1section="Other"/s;
  $file =~ s/<language([^>]+)extensions="[^"]*"/<language$1extensions=""/s;
  $file =~ s/<language([^>]+)mimetype="[^"]*"/<language$1mimetype=""/s;
}

$findphp = "<context name=\"FindPHP\">\n<RegExpr context=\"##PHP/PHP\" String=\"&lt;\\?(?:=|php)?\" lookAhead=\"true\" />\n</context>\n";

$file =~ s/<IncludeRules\s([^>]*)context="##(?!Alerts|Doxygen|Modelines)([^"]+)"/<IncludeRules $1context="##$2\/PHP"/g;
$file =~ s/(<context\s[^>]*>)/$1\n<IncludeRules context="FindPHP" \/>/g;
$file =~ s/(?=<\/contexts\s*>)/$findphp/;

print $file;
print $warning;
