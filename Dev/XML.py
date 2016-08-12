# -*- encoding= utf-8 -*-

import os
import sys
import codecs
import xml.etree.ElementTree as xmlTree

os.chdir('./file')
print(os.curdir)
print(os.getcwd())

metatask = [x for x in os.listdir('.') if os.path.isfile(x) and os.path.splitext(x)[1] == '.xml']
# print(metatask)

def loadxml(name):
    print("==============================")
    for key, value in name.items():
        print("%s:%s" % (key, value))
    for subnod in name:
       print("%s:%s" % (subnod.tag, subnod.text))

def parsexml(name):
    tree = xmlTree.parse(name)
    add = tree.getiterator("Target")
    print(type(add))
    for i in add:
        loadxml(i)

    for target in tree.iter('Range'):
        newtext = str("1:1:64")
        target.text = newtext
        target.set('updated', 'yes')
        loadxml(target)


    if name == "employees.xml":
        root = tree.getroot()
        print("********************************")
        print(root.tag, root.attrib)
        for child in root:
            print(child.tag, child.attrib)

    tree.write(name)


#   print('o'*int(10))
#    print(root[2][1].text)
#    print(root[0].tag, root[0].text)


for file in metatask:
    print(file)
    try:
        parsexml(file)
    #        with codecs.open(file, 'r', 'utf-8', 'xmlcharrefreplace') as xml:
    #           content = xml.read()
    #            print(content)
    except Exception as error:
        print('Error:' + str(error))



