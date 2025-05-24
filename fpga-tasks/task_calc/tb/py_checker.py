errors_counter = 0
test_counter   = 0

def calc_q(a, b, c, d):
    return ((a - b) * (1 + 3*c) - 4*d) // 2

with open("input.txt") as fin, open("output.txt") as fout:
    for i, (line_in, line_out) in enumerate(zip(fin, fout), 1):
        nums_in = list(map(int, line_in.strip().split()))
        num_out = int(line_out.strip())
        test_counter += 1
        print(f"Test: {test_counter}   Input = {nums_in}, Output = {num_out}")
        
        if (calc_q(*nums_in) == num_out):
            print("Test passed!")
        else:
            print(f"Test failed: module output {num_out} != golden sample {calc_q(*nums_in)}")
            errors_counter += 1

print("===========================================")
print(f"Total tests: {test_counter}")
print(f"Total errors: {errors_counter}")
print("===========================================")



