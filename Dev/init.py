# -*- encoding = utf-8 -*-

'''
    Init the environment of TimingLib database generator.
    Such as, Environment variable,TimingLibgenerate.exe,Perforce,Working dir and Native database.
                                                                                                '''

import os
import codecs
import shutil
import fnmatch

class application(object):
    __slots__ = ('name', 'path')
    def __init__(self, name, path):
        self.name = name
        self.path = path
    def exist(self):
        for root_dir, dirs, files in os.walk(str(self.path)):
            for file in files:
                if self.name == file:
                    return True
                    break
'''
        for file in os.scan(str(self.path)):
            if not file.name.startswith('.') and file.is_file():
                if fnmatch.fnmatch(file.name, self.name):
                    return True
                                                                            '''

perforce = application('p4v.exe', 'C:\Program Files\Perforce')
cygwin = application('Cygwin.bat', 'C:\\')
#visual = application('devenv.exe', 'C:')
#generator = application('NationalInstruments.TimingEstimateDBGenerator.exe', 'C:')

#print(cygwin.name, cygwin.path)

Desktop = os.path.join(os.path.expanduser("~"), 'Desktop')
#print(Desktop)

try:
    os.mkdir(Desktop+"\Timinglib", 0o777)
except Exception as error:
    print("Error:"+str(error))
finally:
    if cygwin.exist() and perforce.exist():
        print("%s, %s existed." % (cygwin.name, perforce.name))
    else:
        print("Init Failed")
        exit(255)


