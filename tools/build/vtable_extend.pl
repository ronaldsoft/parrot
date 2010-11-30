#! perl

use strict;
use warnings;

use lib 'lib';
use Parrot::Vtable;

my $vtable = parse_vtable('src/vtable.tbl');

my ( $funcs, $protos ) = vtbl_embed($vtable);

my $header = <<'EOH';
/* ex: set ro:
** !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
**
** This file is generated automatically from 'src/vtable.tbl' by
** tools/build/vtable_extend.pl
*/
EOH

open my $OUT, '>', 'include/parrot/extend_vtable.h' or die $!;

print $OUT $header, <<'EOF';

/*
Copyright (C) 2005-2007, Parrot Foundation.
*/
#ifndef PARROT_EXTEND_VTABLE_H_GUARD
#define PARROT_EXTEND_VTABLE_H_GUARD

/* Need size_t  */
#include <stddef.h>

EOF

print $OUT $protos;

print $OUT <<'EOF';

#endif /* PARROT_EXTEND_VTABLE_H_GUARD */
EOF

# append the C code coda
print $OUT <<'EOF';

/*
 * Local variables:
 *   c-file-style: "parrot"
 *   buffer-read-only: t
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOF

close $OUT or die $!;

open $OUT, '>', 'src/extend_vtable.c' or die $!;

print $OUT $header, <<'EOF';

/*
Copyright (C) 2001-2008, Parrot Foundation.

=head1 NAME

src/extend.c - Parrot extension interface

=head1 DESCRIPTION

These are the functions that Parrot extensions (that is, Parrot subroutines
written in C, or some other compiled language, rather than in Parrot
bytecode) may access.

There is a deliberate distancing from the internals here. Don't go
peeking inside -- you've as much access as bytecode does, but no more,
so we can provide backwards compatibility for as long as we possibly
can.

=head2 Functions

=over 4

=cut

*/

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

/* Some internal notes. Parrot will die a horrible and bizarre death
   if the stack start pointer's not set and a GC run is
   triggered. The pointer *will* be set by the interpreter if the
   interpreter calls code which calls these functions, so most
   extension code is safe, no problem.

   The problem comes in if these routines are called from *outside*
   an interpreter. This happens when an embedding application calls
   them to do stuff with PMCs, STRINGS, interpreter contents, and
   suchlike things. This is perfectly legal -- in fact it's what
   we've documented should be done -- but the problem is that the
   stack base pointer will be NULL. This is Very Bad.

   To deal with this there are two macros that are defined to handle
   the problem.

   PARROT_CALLIN_START(interpreter) will figure out if the stack
   anchor needs setting and, if so, will set it. It must *always*
   come immediately after the last variable declared in the block
   making the calls into the interpreter, as it declares a variable
   and has some code.

   PARROT_CALLIN_END(interpreter) will put the stack anchor back to
   the way it was, and should always be the last statement before a
   return. (If you have multiple returns have it in multiple times)

   Not doing this is a good way to introduce bizarre heisenbugs, so
   just do it. This is the only place they ought to have to be put
   in, and most of the functions are already written, so it's not
   like it's an onerous requirement.

*/

#include "parrot/parrot.h"
#include "parrot/extend.h"

/* HEADERIZER HFILE: none */ /* XXX Ideally the headerizer can run on this file as well. */

EOF

print $OUT $funcs;

print $OUT <<'EOF';
/*

=back

=head1 SEE ALSO

See F<include/parrot/extend.h> and F<docs/pdds/pdd11_extending.pod>.

=head1 HISTORY

Initial version by Dan Sugalski.

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
EOF

close $OUT or die $!;


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
