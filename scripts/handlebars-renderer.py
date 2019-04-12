import os

from pybars import Compiler
from codecs import open

import json
import sys
import getopt


def eq(this, a, b):
    return a == b


def render(input_file, value_file, output_file, enable_env):
    with open(input_file, encoding="utf-8") as inputF:
        source = inputF.read()

    with open(value_file) as valueF:
        values = json.load(valueF)
    if enable_env:
        for k, v in os.environ.iteritems():
            if k not in values:
                values[k] = v

    compiler = Compiler()
    template = compiler.compile(source)
    output = template(values, helpers={"eq": eq})

    with open(output_file, "w+") as outputF:
        outputF.write(output)


def usage():
    print("python "+sys.argv[0] +
          "\n       -i    <input-file> "
          "\n       -u    <value-json-file> "
          "\n       -o    <output-file> "
          "\n       -e    enable environment variable if that not exist in config file ")


if __name__ == "__main__":
    try:
        opts, _ = getopt.getopt(sys.argv[1:], "i:v:o:e", [])
    except getopt.GetoptError as e:
        usage()
        print(e)
        sys.exit(1)

    enable_env = False
    input_file_arg = value_file_arg = output_file_arg = ""
    for opt, arg in opts:
        if opt == "-i":
            input_file_arg = arg
        elif opt == "-v":
            value_file_arg = arg
        elif opt == "-o":
            output_file_arg = arg
        elif opt == "-e":
            enable_env = True
        else:
            print("Error: wrong param " + arg)
            usage()
            sys.exit(1)
    if input_file_arg == "" or value_file_arg == "" or output_file_arg == "":
        usage()
        sys.exit(1)
    render(input_file_arg, value_file_arg, output_file_arg, enable_env)
