#!/usr/bin/env bash
# Unwrap — reads a shell command on stdin and prints it followed by every
# command hidden inside it, each with its wrapper prefixes removed, so the
# Protect rules judge what would really run:
#   sh|bash|zsh|dash|ksh -c '...'   eval '...' / eval ...   $(...)   `...`
#   prefixes: VAR=value, \cmd, command, env, nice -n N, nohup, time, sudo,
#             exec, xargs; and git's -C <dir> / -c k=v / --git-dir= options.
# A guard rail, not a parser: anything it cannot see stays visible to the
# caller, which denies risky commands held in variables.
exec perl -0777 -e '
  my $start = qr/(?:^|[;&|(\n]|\bthen\b|\bdo\b)/;
  sub strip {
    my ($s) = @_;
    1 while $s =~ s/($start)(\s*)(?:\\(?=[A-Za-z])|(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)+(?=\S)|(?:command|env|nice|nohup|time|sudo|exec|xargs)\s+(?:-\S+(?:\s+-?\d+)?\s+)*(?:[A-Za-z_][A-Za-z0-9_]*=\S*\s+)*)/$1$2/;
    $s =~ s/\bgit\s+(?:(?:-C|-c)\s+\S+\s+|--(?:git-dir|work-tree|namespace)=\S+\s+)+/git /g;
    return $s;
  }
  my $s = strip(do { local $/; <STDIN> });
  my @out = ($s);
  my @todo = ($s);
  my $guard = 0;
  while (@todo && $guard++ < 20) {
    my $t = shift @todo;
    my @inner;
    push @inner, $1 while $t =~ /\$\(((?:[^()]++|\((?1)\))*)\)/g;
    push @inner, $1 while $t =~ /`([^`]*)`/g;
    push @inner, $2 while $t =~ /$start\s*(?:sh|bash|zsh|dash|ksh)\s+-[A-Za-z]*c[A-Za-z]*\s+(["\x27])(.*?)\1/gs;
    push @inner, $2 while $t =~ /$start\s*eval\s+(["\x27])(.*?)\1/gs;
    push @inner, $1 while $t =~ /$start\s*eval\s+([^"\x27;&|\n][^;&|\n]*)/g;
    for my $i (@inner) { my $x = strip($i); push @out, $x; push @todo, $x; }
  }
  print join("\n", @out), "\n";
'
