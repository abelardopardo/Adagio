#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re

import Config

# Dictionary supplying the default values for a bunch of variables
defaultOptions = {
    }

def main():
    __sectionList = []
    __options['basedir'] = os.getcwd()
    __options['ada.home'] = os.getcwd()
    __options['file.separator'] = os.path.sep
    (status, n) = Config.Parse(sys.argv[1], None, SetOption)

    print str(status) + ', ' + str(n)
    for s in __sectionList:
        for k, v in sorted([(k, v) for k, v in __options.items() \
                            if k.startswith(s + '.')]):
            print k + ': ' + str(v)

if __name__=="__main__":
    main()
