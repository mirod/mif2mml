# mif2mml

A tool to convert (FrameMaker) MIF files to MathML

## Getting Started



### Prerequisites

`mif2mml` is a Perl script, so you will need 
* Perl
* the expat library
* the utf8::all, Parse::RecDescent and XML::Twig modules

### Installing

Use `cpanm` to install the modules:

    cpanm utf8::all Parse::RecDescent XML::Twig

You may need to install `expat`, although it is highly likely that it is already installed on your system

## Running the tests

    ./mif2mml.t

The tests run the tool on a list of MIF files that cover the specification. The results are then
compared to results of a previous run, that have been validated.

You can run the test tool on your own data, to check discrepancies between versions of the tool. 

## Usage

  ./mif2mml [options] <list_of_mif_files>

generates one `.mml` file per `.mif` file

## Other Tools

3 other tools that can come in handy when working with `mif2mml` are included:

* `indent_mif`  displays an indented version of the equation in a MIF file
* `grep_mif`    greps MIF files for specific constructs (`pod2text grep_mif` for options)
* `mif2mml.t`   non-regression tests for new versions of the tool (`pod2text mif2mml.t` for options)

### Options

The tool accepts a handfull of options that you most likely don't need to know about
use `pod2text mif2mml` to list them if you must


## Authors

* **Michel Rodriguez** - *Initial work* - [mirod](https://github.com/mirod)

## License

This project is licensed under the GPL 3 license - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to the IEEE for the first version of this tool
* Thanks to Chris Papademetrious for getting me to restart working on this and for providing 
  new test data


