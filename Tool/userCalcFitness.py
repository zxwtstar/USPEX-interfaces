#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""
USPEX 10.5 release
Users can interface their own code here.
"""

"""
inputs are: flag, Step
flag: one of the following numbers that distinguishes between
different properties.

% 0: if converged/done or not
% 1: energy/enthalpy
%-1: collect all energy
% 2: pressue tensor
%-2: all pressure tensor
% 3: dielectric constant
% 4: gap
% 5: magmoment
%-5: atomic magmoments
% 6: elastic constant matrix (array data)
% 7: atomic forces
% 8: relaxation atomic positions
% 9: relaxation lattice paramter
%10: birefringence
%11: half-metal

if flag == 0
    target = 1 if calculation is done 
    otherwise 
    target = 0;

Step: Calculation Step. I don't know if it is needed by user or not!
      Let's keep it.   

output is : "target" is the only output which should be a real number
corresponding to the optType.
"""


import sys
import random

flag = int(sys.argv[1])
Step = int(sys.argv[2])


if flag == 0:
# here target should be 0 in case of unsuccessful calculation
# OR 1 in case of successful and converged calculation.
    target = 1;

elif flag == 1:
    target = 5555   # keep this number if you are not going to change enthalpy.
#    target = ....  # enthalpy

elif flag == 6:
    target = elasticMatrix # this is a 6*6 matrix

else:
# calculate the fitness corresponding to the optType
#    fitness = ...?
    fitness = random.random()
    target = fitness


### Please keep this format of outputing the results
print('<CALLRESULT> ' + str(target))


