#include <iostream>
#include <vector>
#include <deque>
#include <vector>
#include <algorithm>

using namespace std;


int main(int argc, char *argv[])
{
    if (argc > 1 && atoi(argv[1]) > 0)
    {
        int window_size = atoi(argv[1]);
        int value;

        //в буффере хранятся динамически элементы, попадающие в окно, в двусвязном списке сохраняется порядок прибывших в буфер элементов, чтобы потом их удалять в обратном порядке
        deque  <int> buff_order;
        vector <int> buff;
        int tmp_ind, tmp_res;


        //ведем считывание до середины окна, чтобы 
        while(buff.size() < (window_size / 2) && std::cin.read(reinterpret_cast<char *>(&value), sizeof(value)))
        {
            buff.push_back(value);
            buff_order.push_back(value);
        }
        
        sort(buff.begin(), buff.end());

        //дошли до середины окна, получили столько элементов, сколько умещается в половину фильтра - 1
        while(buff.size() < (window_size) && std::cin.read(reinterpret_cast<char *>(&value), sizeof(value)))
        {

            
            //формирую буфер и порядок
            tmp_ind = buff.size();
            buff.push_back(value);
            buff_order.push_back(value);

            //перемещаем новый элемент в буфере в нужное место, чтобы сохранить отсортированный порядок. операция выполняется за O(buff.size() вместо n log n например)

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
                tmp_res = buff[buff.size() / 2];
            } else {
                tmp_res = (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2;
            }

            std::cout.write(reinterpret_cast<const char*>(&tmp_res), sizeof(tmp_res));

        }


        //обработка до момента, когда окно упрется в границу, то есть пока окно без потерь
        int unnecessary_element;
        while(std::cin.read(reinterpret_cast<char *>(&value), sizeof(value))){

            //удаление выбывающего из окна элемента из порядка
            unnecessary_element = buff_order.at(0);
            buff_order.pop_front();
            buff_order.push_back(value);

            //не использую итераторы, чтобы в данном случае как раз сократить и без того большой код
            //вставляю новый элемент на место того, который выбывает по очереди
            tmp_ind = 0;
            while (buff[tmp_ind] != unnecessary_element) {
                tmp_ind++;
            }

            buff[tmp_ind] = value;


            //перемещаем новый элемент в буфере в нужное место, чтобы сохранить отсортированный порядок. операция выполняется за O(buff.size() вместо n log n например)
            while (tmp_ind > 0 && buff[tmp_ind] < buff[tmp_ind - 1]){
                swap(buff[tmp_ind], buff[tmp_ind - 1]);
                tmp_ind--;
            }

            while (tmp_ind < (buff.size() - 1) && buff[tmp_ind] > buff[tmp_ind + 1]){
                swap(buff[tmp_ind], buff[tmp_ind + 1]);
                tmp_ind++;
            }

            if (buff.size() % 2 != 0){
                tmp_res = buff[buff.size() / 2];
            } else {
                tmp_res = (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2;
            }

            std::cout.write(reinterpret_cast<const char*>(&tmp_res), sizeof(tmp_res));

        }
        
        //случай, когда окно начинает уменьшаться из-за недостатка элементов

        while(buff.size() > window_size / 2 + 1){
            unnecessary_element = buff_order.at(0);
            buff_order.pop_front();
            
            tmp_ind = 0;
            while (buff[tmp_ind] != unnecessary_element) {
                tmp_ind++;
            }
            

            //удалил из вектора в "ручном" режиме
            for(; tmp_ind < buff.size() - 1; tmp_ind++){
                swap(buff[tmp_ind], buff[tmp_ind + 1]);
            }
            //с конца удаляется за единицу времени, передвигали за n...
            buff.pop_back();

            if (buff.size() % 2 != 0){
                tmp_res = buff[buff.size() / 2];
            } else {
                tmp_res = (buff[buff.size() / 2] + buff[buff.size() / 2 - 1]) / 2;
            }

            std::cout.write(reinterpret_cast<const char*>(&tmp_res), sizeof(tmp_res));
        }

        return 0;
    }

    return -1;
}
