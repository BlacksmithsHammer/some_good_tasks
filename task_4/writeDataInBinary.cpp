#include <iostream>
#include <fstream>

int main(int argc, char* argv[]) {
    // Создаем массив чисел для записи
    int numbers[] = {}; //9 чисел
    //, 34657, 354, 648, -134, 45, 2345, 346, 57, 23576, 23, 1, 5687, 98, 3, 87, 3
    std::ofstream file("binary_file.bin", std::ios::binary);

    if (!file.is_open()) {
        std::cerr << "Unable to open the file for writing." << std::endl;
        return 1;
    }

    file.write(reinterpret_cast<const char*>(numbers), sizeof(numbers));
    file.close();

    std::cout << "writed" << std::endl;

    return 0;
}