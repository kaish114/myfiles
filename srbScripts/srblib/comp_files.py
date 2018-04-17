#!/usr/bin/env python3
#code to compare 2 files
#print first line in which there is difference

from sys import argv,exit
import os

help2 = '''
function returns -1 if files are identical
returns line number if difference is there

third parameter is to print or not
    1 will not print if files are isidentical
    2 will print if files are identical
    3 will also tell whole the differences ... yet incomplete feature
    4 parameter is just to shift the result
        - shifts the output by shift gaps
        - actual code is not shifted
        - exceptions are shifted by shift+1
'''

sp_str = '-'
def check_exceptions(file1,file2,level=1,shift=0):
    if(not os.path.exists(file1)):
        if(level>1):
            print(sp_str*shift+'no file of name '+file1)
        return False
    if(not os.path.exists(file2)):
        if(level>1):
            print(sp_str*shift+'no file of name '+file2)
        return False

    if(os.path.isdir(file1)):
        if(level>1):
            print(sp_str*shift+'required file got folder in file1')
        return False
    if(os.path.isdir(file2)):
        if(level>1):
            print(sp_str*shift+'required file got folder in file2')
        return False
    return True

def comp_files(f1,f2,level=1,shift=0):
    if(not check_exceptions(f1,f2,level,shift+1)):
        return 0

    f1 = open(f1)
    f2 = open(f2)

    l1 = sum(1 for line in f1)
    l2 = sum(1 for line in f2)

    isIdentical = True
    if(l1 != l2):
        if(level>=1):
            print(sp_str*shift+'files differ in size '+str(l1)+' '+str(l2))
            isIdentical=False

    l = min(l1,l2)

    f1.seek(0,0)
    f2.seek(0,0)

    f1 = f1.readlines()
    f2 = f2.readlines()

    i = 0
    for i in range(l):
        if(f1[i] != f2[i]):
            isIdentical = False
            if(level>=1): print(sp_str*shift+"diff in line "+str(i+1))
            if(level>=1): print(sp_str*shift+"line in file 1 :\n"+f1[i])
            if(level>=1): print(sp_str*shift+"line in file 2 :\n"+f2[i])
            if(level < 3): break

    if(isIdentical):
        if(level>=2): print(sp_str*shift+"files are identical")
        return -1;
    else:
        return i+1;


help1 = 'require 3 or 4 arguments \n 1 for files1 \n 2 for file 2 \n 3 for level'


def describe():
    print(help1)
    print(help2)

'''
code begins here
'''
if(__name__ == '__main__'):
    if(len(argv)==2 and argv[1]=='--help'):
        describe();
        exit();

    if(len(argv)!=3 and len(argv)!=4):
        print(help1)
        exit()

    level = 2
    if(len(argv)==4):
        level = int(argv[3])

    if(not check_exceptions(argv[1],argv[2],level)):
        exit()


    f1 = argv[1]
    f2 = argv[2]
    comp_files(f1,f2,level)
