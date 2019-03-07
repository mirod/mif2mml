# mif2mml

A tool to convert (FrameMaker) MIF files to MathML

### Prerequisites

`mif2mml` is a Perl script. It uses a few Perl modules, so you will need:
* Perl
* the expat library
* the utf8::all, Parse::RecDescent and XML::Twig modules

### Installing

Use [cpanm] (https://metacpan.org/pod/distribution/App-cpanminus/bin/cpanm) to install the modules:

    cpanm utf8::all Parse::RecDescent XML::Twig

You may need to install `expat`, although it is highly likely that it is already installed on your system

## Running the tests

    ./mif2mml.t

The tests run the tool on a list of MIF files that cover the specification. The results are then
compared to results of a previous run, that have been validated.

You can run the test tool on your own data, to check discrepancies between versions of the tool. 

## Usage

    ./mif2mml <list_of_mif_files>

generates one `.mml` file per `.mif` file

### Options

The tool accepts a handfull of options that you most likely don't need to know about
use `pod2text mif2mml` to list them if you're curious 

## Notes and Caveats

The format processed by the tools is described in the [FrameMaker MIF Reference](https://help.adobe.com/en_US/framemaker/mifreference/mifref.pdf)
chapter 6

The tool works by extracting the equation part of a MIF file (the part in ``<MathFullForm `...'>``),
parsing it and generating MathML from it. 

This means that anything _outside_ of the equation is not processed. So custom
notations/functions are not supported (I have never encountered one in the data I have converted, 
but it would probably be possible to deal with them).

### MIF formats

MIF statements (~ operators) can include "formats" that change their appearance in various ways. 

Those formats are somewhat underdocumented in the docs. 

Some of them are often used for minor changes to the way the equation is displayed (like adding a 
bit of spacing between a fraction bar and the square root below). As this is display-engine dependent, 
it makes little sense to carry them into the MathML form. So those formats are generally ignored.
You can use the `-F` option to use them, but you will get a extra `<mpadded>` elements that
will clutter the MathML while bringing little improvement to the displayed equation. 

Those formats can also determine the font used for an element. MathML doesn't really have the concept
of fonts, it relies on an attribute to the element, with a limited range of values, 
see [section 3.2.2 of the MathML TR](https://www.w3.org/TR/MathML2/chapter3.html#presm.commatt).
Translating from the font to the attribute is based on the name of the font. If non-standard fonts
are used, then they will have to be added to the tool (there is no mechanism for a translation
table at the moment, but ths could be done in a future version).

### General Caveat

Generally speaking, MIF equations are created using FrameMaker. 

The only feedback the author gets is the look of the equation. This can lead to some equations looking
right, as long as they are displayed in FrameMaker. 

A typical example is multiline equations being aligned on a character (usually '='). This can be done 
in several different ways. Some ways are easy to process and convert into MathML that respects 
the alignment, and some (like using spaces) being a lot more difficult to deal with (indeed the tool
doesn't deal very well with them). The tool uses a heuristic (ie "an algorithm in a clown suit") to
try to make sense of some of those situations.


## Other Tools

3 other tools that can come in handy when working with `mif2mml` are included:

* `indent_mif`  displays an indented version of the equation in a MIF file
* `grep_mif`    greps MIF files for specific constructs (`pod2text grep_mif` for options)
* `mif2mml.t`   non-regression tests for new versions of the tool (`pod2text mif2mml.t` for options)

## Authors

* **Michel Rodriguez** - *Initial work* - [mirod](https://github.com/mirod)

## License

This project is licensed under the GPL 3 license - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to the IEEE for the first version of this tool
* Thanks to Chris Papademetrious for getting me to restart working on this and for providing 
  new test data


