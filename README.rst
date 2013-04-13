+--------+------------+----------------------------------------------+ 
| Name   | License    | Description                                  | 
+========+============+==============================================+ 
| libctx | Boost v1.0 | A cooperative multitasking library for C/C++ | 
+--------+------------+----------------------------------------------+ 

About
=======
libctx began life as a port of Boost::Context to C and ended up a substantial
rewrite for speed (extremely minor) and flexibility. This library enables
functions like co-routines, exceptions or other neat tricks in C. libctx
attempts (and succeeds!) at being small and self-contained. While the features
found here are fun and interesting, some care should be taken in their use
since, without careful planning, things can go downhill quickly.

Problem Description
===================
There have long been functions for jumping around code in C. Several have seen
wide adoption, but suffer from inconsistent implementations or other
restrictions.

setjmp
------
The earliest are setjmp()/longjmp(). These functions are available on pretty
much any UNIX/Linux system, but come with a number of problems. Most severely,
because you cannot execute functions on an independent stacks, you can only
jump in the direction of stack unwinding. Secondarily, implementations provide
inconsistent support for extended CPU state saving. One feature that setjmp
has that others don't is support for saving/restoring signal mask state. While
this sounds neat at first, mixing signals and cooperative multitasking is bad
mojo. Just don't do it (there is a reason no one else implements this).

ucontext
--------
Next came an attempt at UNIX standardization via ucontext. This approach
provides a mechanism for independent stacks, but still suffers from
inconsistent implementations. Some implementations of ucontext also depend on
memory allocation during state save, decreasing performance.

Boost::Context
--------------
Of the many other attempts not worth mentioning, Boost::Context stands out. It
is mature, consistent and widely-deployed. Its main problem is that it is
written in C++ and I wished to use it in C applications. If you are already
using Boost, you probably want to use Boost::Context. However, if you don't
want to add a dependency on C++, or you don't plan on using Boost, you might
find libctx useful.

Testing
=======
libctx has been tested in the following configurations:

+----------------+-------+-------+-------+-------+--------+--------+
|                |  x86  |  arm  | sparc |  ppc  |  mips  | mipsel |
+================+=======+=======+=======+=======+========+========+
| **Debian**     | 32/64 | v5-v7 | 32/64 | 32/64 |   32   |   32   |
+----------------+-------+-------+-------+-------+--------+--------+
| **Fedora**     | 32/64 | v5-v7 |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+
| **FreeBSD**    | 32/64 |       |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+
| **NetBSD**     | 32/64 |       |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+
| **OpenBSD**    | 32/64 |       |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+
| **Apple OS X** | 32/64 |       |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+
| **Solaris**    | 32/64 |       |       |       |        |        |
+----------------+-------+-------+-------+-------+--------+--------+

Windows Support
===============
I don't currently plan on supporting Windows. Not that I'm against
it, I just don't have systems to test it on. Boost::Context already
provides Windows support. Feel free to use it. If you'd like to use
libctx on Windows, it should be a fairly straightforward port from
Boost::Context. I'd be happy to merge any such patches.
