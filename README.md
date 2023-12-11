# some_good_tasks


g++ was used for compilation. To pass the window size as a parameter, provide an integer (without - or --) when calling the executable. Input and output are handled using < and > (standard stdin and stdout) in Linux for convenience.

example: g++ main.cpp && ./a.out 3 < ./tests/binary_1_n.bin > test1.bin

number 3 in example - size of window

To run the tests, download the repository and execute the run_tests.sh script in the task_4 folder. If the test is successful, it will output 'yes'; otherwise, it will output 'no'.

