# -*- encoding = utf-8 -*-

'''
    This module define some interfaces of the native database.
                                                            '''
import os
import os.path
import sqlite3

dir = os.path.join(os.getcwd(), 'file\\')
print(dir)

class dabs(object):
    def __init__(self, name='model.db', path=dir):
        self.name = name
        self.path = path
        pass

    def exist(self):
        if os.access(str(self.path)+str(self.name), os.F_OK):
            return True
        else:
            print("The native database not exist.")
    def targetinfo(self):
        con = sqlite3.connect(str(self.path)+str(self.name))
        c = con.cursor()
        c.execute('select * from targetinfo')
        values = c.fetchall()
        print(values)
        con.close()
    def components(self):
        self.targetinfo()
        pass
    def tasks(self):
        pass

if __name__ == '__main__':
    tl = dabs()
    tl.targetinfo()
