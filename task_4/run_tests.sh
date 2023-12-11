
g++ main.cpp -o tested.out

for i in {1..25}; do
  
    #output=$(./tested.out ${i} < ./tests/data_tests_1)
    #test=$(cat ./tests/bin1_${i})

    output=$(./tested.out ${i} < ./tests/data_tests_1 | tr -d '\0')
    test=$(cat ./tests/bin1_${i} | tr -d '\0')

    if [ "$output" == "$test" ]; then
        echo "Test ${i}: yes"
    else
        echo "Test ${i}: no"
    fi
done

rm tested.out
