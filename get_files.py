import sys
import os
import timeit
from pathlib import Path
from typing import *

def listify(o):
    if o is None: return []
    if isinstance(o, list): return o
    if isinstance(o, str): return [o]
    if isinstance(o, Iterable): return list(o)
    return [o]

def setify(o): return o if isinstance(o,set) else set(listify(o))

def _get_files(p, fs, extensions=None):
    p = Path(p)
    res = [p/f for f in fs if not f.startswith('.')
           and ((not extensions) or f'.{f.split(".")[-1].lower()}' in extensions)]
    return res


def get_files(path, extensions=None, recurse=False, include=None):
    path = Path(path)
    extensions = setify(extensions)
    extensions = {e.lower() for e in extensions}
    if recurse:
        res = []
        for i,(p,d,f) in enumerate(os.walk(path)): # returns (dirpath, dirnames, filenames)
            if include is not None and i==0: d[:] = [o for o in d if o in include]
            else:                            d[:] = [o for o in d if not o.startswith('.')]
            res += _get_files(p, f, extensions)
        return res
    else:
        print("non-recursed")
        f = [o.name for o in os.scandir(path) if o.is_file()]
        return _get_files(path, f, extensions)

if __name__  == "__main__":
    print("""
I will read the first command line argument, interpret it as a path to a directory,
recursively search the names of all files and directories under that directory,
and print the number of items found.

I do this ten times. I have no external dependencies beyond Python3.

I need python3. I have been extracted from the fastai_docs library as of 2019-04-26T2331.

""")
    arg1 = sys.argv[1]
    p = Path(arg1)
    #statement ="get_files(\"{}\", recurse=True)".format(p)
    statement ="count = len(get_files(\"{}\", recurse=True)); print(count)".format(p)
    itercount = 10
    timings = timeit.Timer(statement, setup="from __main__ import get_files").repeat(repeat=itercount,number=1)
    print("iterations: {}".format(itercount))
    print("min time: {:f} ms".format( min(timings) * 1000.0 ))





