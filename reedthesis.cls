%
% This file is copyright (C) 2003 Sam Noble. It may be modified so long
% as my name is not removed and the modifier adds his name to the file.
% Redistribution permitted.
%
% 27 Jan 2004	Sam Noble	Removed tocbibind dependency.
% 04 Dec 2001 	Sam Noble	Class file
% 03 Sep 1995	David Perkinson	Title Page
% Acknowledgements Page, David Perkinson & Sam Noble
% May 2005 Patrick Carlisle Table of contents chapter definition
% 2004-2005 Ben Salzberg (BTS) a variety of tweaks here and in the template
% 2025 Sam Gauck rewrite and drastically simplify template
% 2025 Tristan Figueroa-Reid add additional customization options
%
% Oddities:
%
%   We *ASSUME* that any time \cleardoublepage is called
%  we actually want a blank back side with NO page number/heading
%
%   Minor bug -- seems to be a more general LaTeX thing:
%  If you use \frontmatter \mainmatter without any chapters inbetween
%  be prepared to have the page numbering messed up. Not a big deal,
%  but I'm not sure how to fix it.
%
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{reedthesis}[2025/03/14 The Reed College Thesis Class]

\LoadClassWithOptions{book}

% TODO: why can't we add nls between options for organization?
\DeclareKeys[reedthesis]{
    % This allows selecting the style used for the bibliography
    bibstyle.store         = \@reedthesis@bibstyle,
    % This allows selecting the name of the bibliography file
    bibfile.store          = \@reedthesis@bibfile,
    % This controls the styling of the chapter title in the header.
    % Note this applies to both the left and right groups.
    headerstyle .choice:,
    % This makes the headers uppercase
    headerstyle / uppercase .code = \@reedthesis@headeruppercasetrue,
    % This makes the headers small caps
    headerstyle / smallcaps .code = \@reedthesis@headersmallcapstrue,
    % This controls the styling of links.
    % By default, they are unstyled (black).
    linkstyle .choice:,
    % Enables colored links that are blue ("web") colored.
    linkstyle / web .code        = \@reedthesis@coloredlinkstrue,
    % Enables multicolored links that are not just blue, marked in accordance to the
    % type of link.
    linkstyle / labelled .code   = \@reedthesis@multicoloredlinkstrue,
    % :n from https://tex.stackexchange.com/a/682260/386893
    % This controls the styling of the ToC dots, allowing for levelled control of where
    % the dots are placed. By default, both chapter and section dots are enabled.
    tocchapterdots .if                = @reedthesis@tocdotschapter,
    tocchapterdots .default:n         = true,
    notocchapterdots .ifnot           = @reedthesis@tocdotschapter,
    notocchapterdots .default:n       = true,
    tocchapterdots .initial:n         = true,
    % and ToC section dots
    tocsectiondots .if                = @reedthesis@tocdotssection,
    tocsectiondots .default:n         = true,
    notocsectiondots .ifnot           = @reedthesis@tocdotssection,
    notocsectiondots .default:n       = true,
    tocsectiondots .initial:n         = true,
    % This enables "Chapter N" naming in the ToC, instead of just "N."
    tocchaptername .if      = @reedthesis@tocchaptername
}

% Allegedly you are supposed to be able to provide initial values
%   with the `.initial` property in `DeclareKeys`, but this didn't
%   work for me, so here we are.
% \newif\if@reedthesis@tocdotschapter
% \@reedthesis@tocdotschaptertrue
\newif\if@reedthesis@tocdotssection
\@reedthesis@tocdotssectiontrue

\newif\if@reedthesis@headeruppercase
\newif\if@reedthesis@headersmallcaps

\newif\if@reedthesis@coloredlinks
\newif\if@reedthesis@multicoloredlinks

\DeclareUnknownKeyHandler[reedthesis]{
  \ClassWarning{reedthesis}{Unknown option #1 (with value #2)}
}

\ProcessKeyOptions[reedthesis]

\RequirePackage{xstring}

\ClassInfo{reedthesis}{Detected bibstyle: \@reedthesis@bibstyle}
\IfEq{\@reedthesis@bibstyle}{chicago}
{% if true
  \ClassInfo{reedthesis}{Selecting biblatex-chicago}
  \RequirePackage{biblatex-chicago}
}
{% if false
  \ClassInfo{reedthesis}{Selecting biblatex}
  \IfEq{\@reedthesis@bibstyle}{}
    {
      \ClassWarning{reedthesis}{Did not specify a bibstyle: defaulting to APA}
      \RequirePackage[style=apa]{biblatex}
    }
    {\RequirePackage[style=\@reedthesis@bibstyle]{biblatex}}
}

\ClassInfo{reedthesis}{Detected bibfile: \@reedthesis@bibfile}
\IfEq{\@reedthesis@bibfile}{}
  {\addbibresource{bibliography.bib}}
  {\addbibresource{\@reedthesis@bibfile}}

\RequirePackage[
    margin=1in,
    bindingoffset=0.5in
]{geometry}

\RequirePackage[
    hidelinks
]{hyperref}

\RequirePackage{fancyhdr}

\if@reedthesis@multicoloredlinks
  \ClassInfo{reedthesis}{Multi-colored links enabled}
  \usepackage[ocgcolorlinks]{ocgx2}

  \if@reedthesis@coloredlinks
    \ClassWarning{reedthesis}{Please only choose between colored links and multicolored links - by default, we have preferred multicolored links.}
  \fi
\else
  \ClassInfo{reedthesis}{Multi-colored links disabled}
  \if@reedthesis@coloredlinks
    \ClassInfo{reedthesis}{Colored links enabled}
    \hypersetup{
      colorlinks = true,
      allcolors = blue
    }  
  
    \usepackage[ocgcolorlinks]{ocgx2}
  \else
    \ClassInfo{reedthesis}{Colored links disabled}
  \fi
\fi

% Header/footer rules
\AtBeginDocument{%
  \fancyhf{} % hide old headers/footers
  \fancyhead[LE,RO]{\thepage} % show page numbers
  \if@reedthesis@headeruppercase
    \ClassInfo{reedthesis}{Uppercase headers enabled}
    \fancyhead[RE]{\slshape \leftmark}
    \fancyhead[LO]{\slshape \rightmark}
    \if@reedthesis@headersmallcaps
      % This can never happen because the option has been converted to a `choice` option.
      \ClassWarning{reedthesis}{You enabled both header upper case and header small caps - please only use one. By default, we've used header upper case}
    \else
      \ClassInfo{reedthesis}{Small caps headers disabled}
    \fi
  \else
    \ClassInfo{reedthesis}{Uppercase headers disabled}
    \if@reedthesis@headersmallcaps
      \ClassInfo{reedthesis}{Small caps headers enabled}
      \fancyhead[RE]{\footnotesize \itshape \leftmark}
      \fancyhead[LO]{\footnotesize \itshape \rightmark}
    \else
      \ClassInfo{reedthesis}{Small caps headers disabled}
      \fancyhead[RE]{\slshape \nouppercase \leftmark}
      \fancyhead[LO]{\slshape \nouppercase \rightmark}
    \fi
  \fi
  \pagestyle{fancy}
}

% When we say 'enabling section dots,' we just lie!
\if@reedthesis@tocdotschapter
  \ClassInfo{reedthesis}{Enabling ToC chapter dots}
  \renewcommand\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{1.5em}%
    \begingroup
      \parindent \z@ \rightskip \@pnumwidth
      \parfillskip -\@pnumwidth
      \leavevmode \bfseries
      \advance\leftskip\@tempdima
      \hskip -\leftskip
      #1\nobreak\normalfont
      \leaders\hbox{$\m@th \mkern \@dotsep mu\hbox{.}\mkern \@dotsep mu$}\hfill
      \nobreak\hb@xt@\@pnumwidth{\bfseries \hss #2}\par
      \penalty\@highpenalty
    \endgroup
  \fi}
  \if@reedthesis@tocdotssection
    \ClassInfo{reedthesis}{ToC section dots enabled}
  \else
    \ClassWarning{reedthesis}{ToC section dots disabling but ToC chapter dots enabling will soon be available.}
    % TODO
  \fi
\else
  \if@reedthesis@tocdotssection
    \ClassInfo{reedthesis}{ToC chapter dots disabled, ToC section dots enabled}
  \else
    % TODO this could have unintended consequences
    \usepackage[titles]{tocloft}
    \renewcommand{\cftdot}{}  
    \ClassInfo{reedthesis}{Disabling ToC section and chapter dots disabled}
  \fi
\fi

% This option shows "Chapter 1" in ToC instead of the default "1."
\if@reedthesis@tocchaptername
  \ClassInfo{reedthesis}{Enabling TOC chapter names}
  % Stolen from book.cls PBC 5/12/05
  \def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne
    \if@mainmatter
      \refstepcounter{chapter}%
      \typeout{\@chapapp\space\thechapter.}%
      \addcontentsline{toc}{chapter}%
      {\@chapapp\space\thechapter:\space#1}%
    \else
      \addcontentsline{toc}{chapter}{#1}%
    \fi
  \else
    \addcontentsline{toc}{chapter}{#1}%
  \fi
  \chaptermark{#1}%
  \addtocontents{lof}{\protect\addvspace{10\p@}}%
  \addtocontents{lot}{\protect\addvspace{10\p@}}%
  \if@twocolumn
    \@topnewpage[\@makechapterhead{#2}]%
  \else
    \@makechapterhead{#2}%
    \@afterheading
  \fi}
\else
  \ClassInfo{reedthesis}{TOC chapter names disabled}
\fi

% Stolen from latex.ltx and modified
% to set pagestyle to empty on the
% inserted (left-hand) page
\newcommand{\RTcleardoublepage}{
	\clearpage\if@twoside \ifodd\c@page\else
	\thispagestyle{empty}\hbox{}\newpage
	\if@twocolumn\hbox{}\newpage\fi\fi\fi}

% All usages of \cleardoublepage should honor
% the behavior described above.
\let\RToldcleardoublepage\cleardoublepage
\renewcommand{\cleardoublepage}{\RTcleardoublepage}

% Stolen from book.cls and modified
% to set pagestyle to empty instead of plain
% on the first page of each chapter
\let\RToldchapter\chapter
\renewcommand{\chapter}{\if@openright\cleardoublepage\else\clearpage\fi
                    \thispagestyle{empty}%
                    \global\@topnum\z@
                    \@afterindentfalse
                    \secdef\@chapter\@schapter}

% % adjust margins for binding  (changed 2007-04-24 tgp)
% \setlength{\oddsidemargin}{.5in}
% \setlength{\evensidemargin}{0in}
% \setlength{\textwidth}{6.0in}
% \setlength{\textheight}{9.0in}
% \setlength\topmargin{0in}
% \addtolength\topmargin{-\headheight}
% \addtolength\topmargin{-\headsep}

\def\division#1{\gdef \@division{#1}}
\def\@division{\@latex@warning@no@line{No \noexpand\division given}}
\def\department#1{\gdef \@department{#1}}
\def\@department{\@latex@warning@no@line{No \noexpand\department given}}
\def\thedivisionof#1{\gdef \@thedivisionof{#1}}
\def\@thedivisionof{The Division of}
\def\approvedforthe#1{\gdef \@approvedforthe{#1}}
\def\@approvedforthe{Division}
\def\advisor#1{\gdef \@advisor{#1}}
\def\@advisor{\@latex@warning@no@line{No \noexpand\advisor given}}
\def\altadvisor#1{\gdef \@altadvisor{#1} \@altadvisortrue}
\global\let\@altadvisor\@empty
\newif\if@altadvisor
\@altadvisorfalse

\renewcommand{\contentsname}{Table of Contents}
% \renewcommand{\bibname}{References}

\AtEndPreamble{
  \hypersetup{
    pdfauthor=\@author,
    pdfcreator={Reed College LaTeX Thesis Class SN DP PC BTS SG TFR},
    % pdfproducer=c,
    % pdfsubject=d,
    pdftitle=\@title,
  }
}

% I hacked the title page to all be the same font size 
% as requested by the library, BTS 2005

\renewcommand{\maketitle}{%
  {\pagestyle{empty}
  \fontsize{12}{14}\selectfont
  \begin{titlepage}
  \newpage
  \let\footnotesize\small
  \let\footnoterule\relax
  \let \footnote \thanks

  \baselineskip = 1.4\baselineskip
  \setbox0=\hbox{of the Requirements for the Degree}

  \begin{center}
    \setcounter{page}{1}
    \null\vfil
    {\fontsize{12}{14}\selectfont \@title}
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \vfil
    A Thesis \\
    Presented to \\
    \@thedivisionof \ \@division \\
    Reed College
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \vfil
    In Partial Fulfillment \\
    of the Requirements for the Degree \\
    Bachelor of Arts
    \vfil
    \centerline{\hbox to \wd0 {\hbox{}\hrulefill\hbox{}}}
    \bigskip
    \centerline{}
    \bigskip
    {\fontsize{12}{14}\selectfont \lineskip .75em
    \begin{tabular}[t]{c}%
      \@author
    \end{tabular}\par}
    \vskip 1.5em
    {\fontsize{12}{14}\selectfont \@date \par}
  \end{center}\par
  \end{titlepage}

%% Approved for the division page
  \cleardoublepage
  {\fontsize{12}{14}
  \setbox0=\hbox{Approved for the \@approvedforthe}
  \thispagestyle{empty}
  \null\vfil		% just below center of page
  \par\vskip 6cm	% below center, not center
  \centerline{\copy0}	% approved
  \centerline{(\@department)} %major
  \vskip 1cm		%space to sign
  \centerline{\makebox[\wd0][c]{\hrulefill}
	\if@altadvisor \makebox[.5in]{} \makebox[\wd0][c]{\hrulefill} \fi}
  \centerline{\makebox[\wd0][c]{\@advisor}
	\if@altadvisor \makebox[.5in]{} \makebox[\wd0][c]{\@altadvisor} \fi}
  \par\vfil\null}
  \cleardoublepage
  }
}

