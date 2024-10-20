#### Для запуска тестов необходимо использовать файл make_sim.do. Внутри него закомментированы 6 наборов тестов, нужно раскомментировать любой один из них и запустить симуляцию. При тестировании весь лог выводится без перерывов, все ошибки "сыпятся" в консоль, что очень сильно тормозит симуляцию. Поэтому для глубокого тестирования лучше модернизировать ./tb/macros.sv путем замены display на error/stop или просто раскомментировать комментарий $stop в макросе SHOW_WRONG_SIGNALS, чтобы прекратить симуляцию в случае первой же ошибки. При этом местами вывод ошибок сделан через $display.

---

Основной упор был сделан на покрытие тестами, поэтому как и в предыдущих лабораторных работах есть BIG_TEST объединяющий в себе все остальные тесты.

---
Все последующие 4 найденные ошибки запускаются в одном тесте MVP

---

1) Модуль долго не отвечал при транзакции с base_address = 10, length = 40 и рандомно меняющимися сигналами готовности reader'a и writer'a

Аналогичная проблема наблюдается и в больших тестах, возможно, причина как раз в сигналах готовности waitrequest модулей работы с памятью.
```
# Time-out  AT TIME:    10845
# Driver waiting waitrequest == 0 for a very long time
```

2) Модуль возвращает на запись данные в X-состоянии, хотя отдавались ему корректно.
```
# Problem with word in address 18  AT TIME:    11685
# EXPECTED        0, got        x
```

3) Модуль возвращает корректное слово с некорректной маской, из-за чего оно не пишется в память и происходит ошибка

```
# Problem with word in address 14  AT TIME:    11805
# EXPECTED       34, got       33
```

4) Аналогичная проблема в логе далее: тест-кейс проверяет, пишет ли лишнее модуль, если base_address + length > размер памяти. Как понял, баг возникает именно при записи последнего слова.

```
# Problem with word in address 1023  AT TIME:    12565
# EXPECTED       e5, got       e4
```
---
Далее описание тестов:
 
 1) MVP - демонстрация основных багов в кратко виде

 2) RANDOM_WAITREQUEST - большой тест для проверки работоспособности модуля при меняющихся значениях waitrequest

 3) STATIC_WAITREQUEST- большой тест для проверки работоспособности модуля при не изменяющихся значениях waitrequest

 4) OVERSIZE_LENGTH - набор тестов на корректную обработку случаев, когда base_address + length > размер памяти

 5) MAX_LATENCY - набор тестов для проверки работоспособности с разными задержками на чтение
 6) BIG_TEST - объединение всех предыдущих тестов