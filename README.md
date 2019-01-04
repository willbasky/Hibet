# Tibetan-English translator for CLI

[![MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

![Bod](bod.jpg)

## About

The TibetCli translates with all dictionaries from [tibetan-dictionary](https://github.com/christiansteinert/tibetan-dictionary) project. And it use [Wylie transliteration](https://en.wikipedia.org/wiki/Wylie_transliteration) to input tibetan words yet. There is [convertor](http://www.digitaltibetan.org/cgi-bin/wylie.pl) from native tibetan to wylie translit and back, if you wish.

## Installation

1. Install [stack](https://docs.haskellstack.org/en/stable/README/#how-to-install)

2. Install TibetCli

        git clone https://github.com/willbasky/TibetCli.git

        cd ./TibetCli

        stack install tibet

## Usage

[![asciicast](https://asciinema.org/a/219676.svg)](https://asciinema.org/a/219676)

Help commands:

    $ tibet -h
    TibetCli is command line translator from Tibet to English language.

    Usage: tibet [-v|--version] COMMAND
      Translate from Tibetan to English
    Available options:
      -h,--help                Show this help text
      -v,--version             Show TibetCli's version

    Available commands:
      shell                    Start the translate shell
      om                       Print Om to a terminal
      show                     Show titles or descriptions of dictionaries

    $ tibet show -h

    Usage: tibet show COMMAND
      Show commands

    Available options:
      -h,--help                Show this help text

    Available commands:
      names                    Show dictionary titles
      meta                     Show dictionary descriptions

Input `tibet shell` in terminal. And then write your `query` using _Wylie_ transcribtion:

    $ tibet shell
    Which a tibetan word to translate?
    > mo
    5. Hopkins 2015
    ► (1) female; woman; wife; feminine particle; she; (2) particle indicating the end of a statement

    7. Rangjung Yeshe
    ► the girl
    ► lady, female, woman. 2) divination, prophecy
    ► 1) auspicious, mo divination/ prophesy [R]; 2) feminine particle, female, woman, she [R]; 3)  terminative after MA; 4) noun forming particle [R]; 5) is [don ci mo: what is the meaning]

    8. Berzin
    ► prognostication

    etc...

To quit, just input:

    :q

To get queries of the session, input:

    :h

## ToDo

- [x] Lookup throuth all available libaries.
- [x] move backand to [lib](https://hackage.haskell.org/package/optparse-applicative-0.14.2.0)
- [ ] Handle unicode (native tibetan script) from input

