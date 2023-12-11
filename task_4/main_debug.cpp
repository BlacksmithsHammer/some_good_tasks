#include <iostream>
#include <vector>
#include <deque>

using namespace std;

//функция для быстрого дебага
void print_vector(vector <int> &arr){
    auto it = begin(arr);
    cout << "buff: ";
    while(it != end(arr) && cout << *it++, it != end(arr)) { cout << ", "; }
    cout << "  size: " << arr.size();
}




int main(int argc, char *argv[])
{
    if (argc > 1 && atoi(argv[1]) > 0)
    {
        int window_size = atoi(argv[1]);
        int value;
        deque  <int> buff_order;
        vector <int> buff;
        int tmp_ind;



        while(buff.size() < (window_size / 2) && std::cin.read(reinterpret_cast<char *>(&value), sizeof(value)))
        {
            tmp_ind = buff.size();

            buff.push_back(value);
            buff_order.push_back(value);

            while (tmp_ind > 0){
                if (buff[tmp_ind] < buff[tmp_ind - 1]){
                    swap(buff[tmp_ind], buff[tmp_ind - 1]);
                    tmp_ind--;
                } else {
                    break;
                }
            }

            print_vector(buff);

            cout << endl;
        }
        
        //дошли до середины окна, получили столько элементов, сколько умещается в половину фильтра - 1
        while(buff.size() < (window_size) && std::cin.read(reinterpret_cast<char *>(&value), sizeof(value)))
        {
            tmp_ind = buff.size();
            buff.push_back(value);
            buff_order.push_back(value);

            while (tmp_ind > 0){
                if (buff[tmp_ind] < buff[tmp_ind - 1]){
                    swap(buff[tmp_ind], buff[tmp_ind - 1]);
                    tmp_ind--;
                } else {
                    break;
                }
            }

            //добавляем в ответ значение из середины буфера, если размер буфера нечетный
            //иначе добавляем среднее значение между 2 срединными элементами (отбрасывая "плавающую" часть)
            if (buff.size() % 2 != 0){
                cout << " ANSWER (stage 2): "  << buff[buff.size() / 2] << '\n';
            } else {
                cout << " ANSWER (stage 2): "  << (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2 << '\n';
            }

            print_vector(buff);
            cout << endl;
        }


        //обработка до момента, когда окно упрется в границу, то есть пока окно без потерь
        int unnecessary_element;
        while(std::cin.read(reinterpret_cast<char *>(&value), sizeof(value))){
            unnecessary_element = buff_order.at(0);
            buff_order.pop_front();
            buff_order.push_back(value);
            //не буду использовать итераторы, чтобы в данном случае как раз сократить и без того большой код
            tmp_ind = 0;
            while (buff[tmp_ind] != unnecessary_element) {
                tmp_ind++;
            }

            buff[tmp_ind] = value;

            while (tmp_ind > 0 && buff[tmp_ind] < buff[tmp_ind - 1]){
                swap(buff[tmp_ind], buff[tmp_ind - 1]);
                tmp_ind--;
            }

            while (tmp_ind < (buff.size() - 1) && buff[tmp_ind] > buff[tmp_ind + 1]){
                swap(buff[tmp_ind], buff[tmp_ind + 1]);
                tmp_ind++;
            }

            if (buff.size() % 2 != 0){
                cout << "added: " << value << "   " << " ANSWER (stage 3): "  << buff[buff.size() / 2] << '\n';
            } else {
                cout << " ANSWER (stage 3): "  << (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2 << '\n';
            }

            print_vector(buff);
            cout << "\n";

        }
        
        while(buff.size() > window_size / 2 + 1){
            unnecessary_element = buff_order.at(0);
            buff_order.pop_front();
            
            tmp_ind = 0;
            while (buff[tmp_ind] != unnecessary_element) {
                tmp_ind++;
            }
            

            //удалил в "ручном" режиме
            for(; tmp_ind < buff.size() - 1; tmp_ind++){
                swap(buff[tmp_ind], buff[tmp_ind + 1]);
            }
            buff.pop_back();

            if (buff.size() % 2 != 0){
                cout << " ANSWER (stage 4): "  << buff[buff.size() / 2] << '\n';
            } else {
                cout << " ANSWER (stage 4): "  << (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2 << '\n';
            }
            print_vector(buff);
            cout << "\n";
        }

        return 0;
    }

    return -1;
}
