#lang scribble/manual
@(require "utils.rkt"
          (for-label setup/xref))

@(define fn (italic "fn"))

@title[#:tag "running"]{Running @exec{scribble}}

The @exec{scribble} command-line tool (also available as @exec{raco
scribble}) runs a Scribble document and renders it to a specific
format. Select a format with one of the following flags, where the
output name @|fn| is by default the document source name without
its file suffix:

@itemlist[

 @item{@DFlag{html} --- a single HTML page @filepath{@|fn|.html},
       plus CSS sources and needed image files; this mode is the
       default if no format is specified}

 @item{@DFlag{htmls} --- multiple HTML pages (and associated files) in
       a @filepath{@|fn|} directory, starting with
       @filepath{@|fn|/index.html}}

 @item{@DFlag{latex} --- LaTeX source @filepath{@|fn|.tex}, plus
       any needed additional files (such as non-standard class files)
       needed to run @exec{latex} or @exec{pdflatex}}

 @item{@DFlag{pdf} --- PDF @filepath{@|fn|.pdf} that is generated
       via @exec{pdflatex}}

 @item{@DFlag{text} --- plain text in a single file
       @filepath{@|fn|.txt}, with non-ASCII content encoded as UTF-8}

]

Use @DFlag{dest-name} to specify a @|fn| other than the default name,
but only when a single source file is provided. Use the @DFlag{dest}
flag to specify a destination directory (for any number of source
files).

After all flags, provide one or more document sources. When multiple
documents are rendered at the same time, cross-reference information
in one document is visible to the other documents. See
@secref["xref-flags"] for information on references that cross
documents that are built separately.

@section{Extra and Format-Specific Files}

Use the @DFlag{style} flag to specify a format-specific file to adjust
the output style file for certain formats. For HTML (single-page or
multi-page) output, the style file should be a CSS file that is
applied after all other CSS files, and that may therefore override
some style properties. For Latex (or PDF) output, the style file
should be a @filepath{.tex} file that can redefine Latex commands.
When a particular Scribble function needs particular CSS or Latex
support, however, a better option is to use a @racket[css-addition] or
@racket[tex-addition] style property so that the support is included
automatically; see @secref["config"] for more information.

In rare cases, use the @DFlag{style} flag to specify a format-specific
base style file. For HTML (single-page or multi-page) output, the
style file should be a CSS file to substitute for
@filepath{scribble.css} in the @filepath{scribble} collection. For
Latex (or PDF) output, the style file should be a @filepath{.tex} file
to substitute for @filepath{scribble.tex} in the @filepath{scribble}
collection. The @DFlag{style} flag is rarely useful, because the
content of @filepath{scribble.css} or @filepath{scribble.tex} is
weakly specified; replacements must define all of the same styles, and
the set of styles can change across versions of Racket.

Use @DFlag{prefix} to specify an alternate format-specific to start of
the output file. For HTML output, the starting file specifies the
@tt{DOCTYPE} declaration of each output HTML file as a substitute for
@filepath{scribble-prefix.html} in the @filepath{scribble}
collection. For Latex (or PDF) output, the the starting file specifies
the @ltx{documentclass} declaration and initial @ltx{usepackage}
declarations as a substitute for @filepath{scribble-prefix.tex} in the
@filepath{scribble} collection. See also @racket[html-defaults],
@racket[latex-defaults], and @secref["config"].

For any output form, use the @DPFlag{extra} flag to add a needed file
to the build destination, such as an image file that is referenced in
the generated output but not included via @racket[image] (which copies
the file automatically).

@subsection[#:tag "xref-flags"]{Handling Cross-References}

Cross references within a document or documents rendered together are
always resolved. When cross references span documents that are
rendered separately, format-specific cross-reference information needs
to be saved and loaded explicitly.

A Racket installation includes HTML-format cross-reference information
for all installed documentation. Each document's information is in a
separate file, so that loading all relevant files would be tedious. The
@DPFlag{xref-in} flag loads cross-reference information by calling a
specified module's function; in particular, the
@racketmodname[setup/xref] module provides
@racket[load-collections-xref] to load cross-reference information for
all installed documentation. Thus,

@commandline{scribble ++xref-in setup/xref load-collections-xref mine.scrbl}

renders @filepath{mine.scrbl} to @filepath{mine.html} with
cross-reference links to the Racket installation's documentation.

The @DFlag{redirect-main} flag redirects links to the local
installation's documentation to a given URL, such as
@tt{http://docs.racket-lang.org/}. Beware that documentation links
sometimes change (although Scribble generates HTML paths and anchors
in a relatively stable way), so
@tt{http://download.racket-lang.org/docs/@italic{version}/html/} may be
more reliable when building with an installation for @italic{version}.

The @DFlag{redirect} flag is similar to @DFlag{redirect-main}, except
that it builds on the given URL to indicate a cross-reference tag that
is more stable than an HTML path and anchor (in case the documentation
for a function changes sections, for example). No server currently
exists to serve such tag requests, however.

For cross-references among documentation that is not part of the
Racket installation, use @DFlag{info-out} to save information from a
document build and use @DPFlag{info-in} to load previously saved
information. For example, if @filepath{c.scrbl} refers to information
in @filepath{a.scrbl} and @filepath{b.scrbl}, then

@commandline{scribble --info-out a.sxref a.scrbl}
@commandline{scribble --info-out b.sxref b.scrbl}
@commandline{scribble ++info-in a.sxref ++info-in b.sxref c.scrbl}

builds @filepath{c.html} with cross-reference links into
@filepath{a.html} and @filepath{b.html}.
