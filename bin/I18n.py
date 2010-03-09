#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import sys, locale, os, re

# TODO: Get the locale name and derive the file name to import from
# that. Knowing this rule allows new dictionaries to be included without
# touchting the source code. Need to know if there is any convention about
# locale names.

# Get the current locale
# if 'LC_ALL' in os.environ:
#     locale = locale.setlocale(locale.LC_ALL, os.environ.get('LC_ALL'))
# else:
#     # Default value
#     locale = locale.setlocale(locale.LC_ALL, 'en_US.UTF8')
locale = locale.getdefaultlocale()[0]

# Get the locale prefix
m = re.match('^([^_]+)_.+$', locale)
if m != None:
    localePrefix = m.group(1)
else:
    localePrefix = 'en'

# This is the main dictionary
dictionary = {}

# Select the appropriate import
file = None
# First, use the locale as is
if os.path.exists(os.path.join('i18n', locale + '.py')):
    file = locale
# Take the locale prefix (everything up to the first _ and use it as filename)
elif os.path.exists(os.path.join('i18n', localePrefix + '.py')):
    file = localePrefix
else:
    file = 'en'

try:
    langModule = __import__(file, globals(), locals(), [], -1)
except SyntaxError, e:
    print 'Error while parsing localization file ' + file
    print str(e)
    sys.exit(-1)

# overwrite the dictionary
dictionary = langModule.msgs

def get(msg):
    global dictionary
    if dict == {}:
        return 'I18n Error. No dictionary has been defined'
    try:
        result = dictionary[msg]
    except KeyError:
        return '<<<No I18n for ' + msg + '>>>'

    return result

def main():
    """
    Localization data
    """
    print 'Locale: ' + locale
    pass

if __name__ == "__main__":
    main()
