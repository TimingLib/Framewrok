from xml.etree import ElementTree
import os

def print_node(node):
    print("=====================================")
    for key, value in node.items():
        print("%s:%s" % (key, value))
    for subnode in node.getchildren():
        print("%s:%s" % (subnode.tag, subnode.text))


def read_xml(text='', xmlfile=''):
    # root = ElementTree.parse(xmlfile)
    root = ElementTree.fromstring(text)

    # 1 getiterator([tag=None])
    # only elements whose tag equals tag are returned from the iterator
    eitor = root.getiterator("employee")
    for e in eitor:
        print_node(e)

    # 2 getchildren()
    # Returns all subelements
    eitor = root.getchildren()
    for e in eitor:
        print_node(e)

        # 3 findall(match)
    # Finds all subelements matching match.
    # match may be a tag name or path. Returns an iterable yielding all matching elements
    node_findall = root.findall("employee")
    for e in node_findall:
        print_node(e)

    # 4 find(match)
    # Finds the first subelement matching match.
    # match may be a tag name or path. Returns an element instance or None
    node_find = root.find('employee')
    print_node(node_find)


'''if __name__ == '__main__':
    read_xml(open("./File/employees.xml").read())'''

print(os.environ)
print(os.getenv('OS'))
print(os.path.expandvars('%OS%'))