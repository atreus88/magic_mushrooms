#!/usr/bin/env python
#
#
import sys, struct, pwd, time, logging, subprocess

testing = 1
stoponerror = 1

lastlog = '/var/log/lastlog'
psqlwrapper = '/opt/collabnet/teamforge/runtime/scripts/psql-wrapper'
logfile = '/opt/collabnet/teamforge/log/runtime/cvslastlogin.log'
fmt = '1I32s256s'
recsize = struct.calcsize(fmt)

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s %(message)s',
                    filename=logfile, filemode='w')


def getCVSlastlogin(lastfh, userid):
    lastfh.seek(userid * recsize)
    binrec = lastfh.read(recsize)
        if len(binrec) == recsize:
            res = struct.unpack(fmt, binrec)[0]
    try:
        logintime = float(res)
    except
        logintime = 0.0
        logging.error("getCVSlastlogin: user %s got %s" % (userid, res)
    return logintime
    

def getCTFlastlogin(username):
    querystring = "COPY (SELECT extract(epoch from last_login) FROM sfuser WHERE username = '%s') TO STDOUT WITH CSV;" % username
    proc = subprocess.Popen(psqlwrapper, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    res = proc.communicate(querystring)[0]
    try:
        logintime = float(x)
    except ValueError:
        logintime = 0.0
        logging.error("getCTFlastlogin(%s) got %s" % (username, res))
    return logintime


def setCTFlastlogin(username, logintime):
    tzhour, tzmin = divmod(time.timezone, 60*60)
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(logintime))
    timestamp = "%s %s:%02d" % (timestamp, tzhour * -1, tzmin) 
    updatestring = "UPDATE sfuser SET last_login = '%s' WHERE username = '%s';" % (timestamp, username)
    logging.debug("Setting CTF last_login for %s to %s", (username, timestamp))
    if testing:
        logging.info("Would run: %s" % updatestring)
        return 0
    proc = subprocess.Popen(psqlwrapper, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    res = proc.communicate(updatestring)[0]
    if res == "UPDATE 1\n":
        logging.debug("Success setting CTF last_login for %s to %s" % (username, timestamp))
        errorcode = 0
    else:
        logging.error("Failed setting CTF last_login for %s to %s. Response string: %s" % (username, timestamp, res))
        errorcode = 1
    return errorcode


def main():
    users = pwd.getpwall()
    lastf = open(lastlog, 'rb')

    for user in users:
        if user.pw_gid > 4999:
        uid = user.pw_uid
        username = user.pw_name
        logging.debug("Handling user %s %s" % (uid, username))
        cvslogintime = getCVSlastlogin(lastf, uid)
        ctflogintime = getCTFlastlogin(username)
        if cvslogintime > ctflogintime:
            err = setCTFlastlogin(username, cvslogintime):
            if stoponerror and err:
                sys.exit(1)

if __name__ == "__main__":
    main()

