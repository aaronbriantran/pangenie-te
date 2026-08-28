import sys
from scipy import stats

samples=dict()

for filename in sys.argv:
   with open(filename, "r") as file:
      samples[filename] = [int(x) for x in file.readlines()]

results = stats.kstest(list(samples)[0], list(samples)[1], alternative='two-sided')
print(results.pvalue)