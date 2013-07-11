#!/usr/bin/env python
infile = '/tmp/prod/cee/tigris/DSMessageBody.ibd'
outfile = '/tmp/samtestvol/DSMessageBody.ibd'

import os, sys, re, time, fileinput

pgpgout_prev = 0
pgpgin_prev = 0

def getprocinfo():
	global pgpgout_prev
	global pgpgin_prev
	procfiles = [ '/proc/meminfo','/proc/vmstat']
	linere = '^(pgpgin|pgpgout|Dirty:|Writeback:)'
	for line in fileinput.input(procfiles):
		if re.match(linere, line):
			(myvar, myval, extra) = re.split('\W+', line, maxsplit=2)
			if myvar == 'pgpgin': 
				pgpgin = int(myval)
			elif myvar == 'pgpgout': 
				pgpgout = int(myval)
			elif myvar == 'Dirty' : 
				dirty = myval
			elif myvar == 'Writeback' : 
				writeback = myval

	pgpgin_tmp = pgpgin
	pgpgout_tmp = pgpgout
	pgpgin = pgpgin - pgpgin_prev
	pgpgout = pgpgout - pgpgout_prev
	pgpgin_prev = pgpgin_tmp
	pgpgout_prev = pgpgout_tmp
	return pgpgin, pgpgout, dirty, writeback

def getfilesize():
	starttime = time.time()
	try:
		st=os.stat(outfile)
		size = st.st_size
	except:
		size = 0
	endtime = time.time()
	return size, endtime-starttime	
	

def main():
	while True:
		timestr = time.strftime("%H:%M:%S", time.localtime(time.time()))
		(pgpgin, pgpgout, dirty, writeback) = getprocinfo()
		(size, stattime) = getfilesize()
		print timestr, pgpgin, pgpgout, dirty, writeback, size, stattime
		sys.stdout.flush()
		time.sleep(1)


if __name__ == "__main__":
	main()
