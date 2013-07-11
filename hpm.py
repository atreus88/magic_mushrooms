#!/usr/bin/env python
import sys
sys.path.append('/usr/collab/lib/python2.4/site-packages')

import apachelog
import optparse
defaultinput = '/opt/collabnet/teamforge/log/httpd/ssl_access_log'
#defaultinput = '/home/sjuvonen/tmp/ssl_access_log.test'
defaultformat =  r'%h %l %{CtfUserName}o %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D %I %O'
minutes = {}

def initialize():
    oparser = optparse.OptionParser()

    oparser.add_option('-i', '--inputfile', 
        action='store', dest='inputfile', default = defaultinput,
        help = 'Log file to parse, default %s' % defaultinput)
    oparser.add_option('-f', '--format',
        action='store', dest='logformat', default = defaultformat,
        help = 'Apache LogFormat string from httpd.conf, default \'%s\'' % defaultformat)
    oparser.add_option('-s', '--starttime',
        action='store', dest='starttime', default='0', type='string', 
        help = 'Include entries starting from time expressed as YYYYMMDDhhmmss')
    oparser.add_option('-e', '--endtime', 
        action='store', dest='endtime', default='99999999999999', type='string',
        help = 'Include entries ending in time expressed as YYYYMMDDhhmmss')

    options, args = oparser.parse_args()
    return options, args


if __name__ == '__main__':
    options, args = initialize()
    p = apachelog.parser(options.logformat)

    for line in open(options.inputfile):
        try:
            data = p.parse(line)
        except:
            sys.stderr.write("Unable to parse %s" % line)

        datestr, offset = apachelog.parse_date(data['%t'])
        if ((datestr > options.starttime) and (datestr < options.endtime)):
            minute = datestr[:-2]
            try:
                minutes[minute] += 1
            except KeyError:
                minutes[minute] = 1

    for k, v in sorted(minutes.iteritems()):
	# print ISO8601 format date
	print "%s-%s-%sT%s:%s %s" % (k[:4], k[4:6], k[6:8], k[8:10], k[10:12], v)
