from pybars import Compiler
from codecs import open

import json
import sys
import getopt


def eq(this, a, b):
    return a == b


def render(input_file, value_file, output_file):
    with open(input_file, encoding="utf-8") as inputF:
        source = inputF.read()

    with open(value_file) as valueF:
        values = json.load(valueF)

    print(source)
    print(values)

    compiler = Compiler()
    template = compiler.compile(source)
    output = template(values, helpers={"eq": eq})

    with open(output_file, "w+") as outputF:
        outputF.write(output)


def usage():
    print("python "+sys.argv[0]+" -i <input-file> -u <value-json-file> -o <output-file>")


if __name__ == "__main__":
    try:
        opts, _ = getopt.getopt(sys.argv[1:], "i:v:o:",[])
    except getopt.GetoptError as e:
        usage()
        print(e)
        sys.exit(2)

    input_file_arg = value_file_arg = output_file_arg = ""
    for opt, arg in opts:
        if opt == "-i":
            input_file_arg = arg
        elif opt == "-v":
            value_file_arg = arg
        elif opt == "-o":
            output_file_arg = arg
        else:
            print("Error: wrong param " + arg)
            usage()
            sys.exit(2)
    render(input_file_arg, value_file_arg, output_file_arg)
