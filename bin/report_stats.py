#!/usr/bin/env python3

import pstats
import sys

stats_file = sys.argv[1]
print("Parsing: {0}".format(stats_file))

p = pstats.Stats(stats_file)

# prints them all
#p.strip_dirs().sort_stats(-1).print_stats()

# This sorts the profile by cumulative time in a function, and then 
# only prints the ten most significant lines. If you want to understand 
# what algorithms are taking time, the above line is what you would use.
p.sort_stats('cumulative').print_stats(10)
