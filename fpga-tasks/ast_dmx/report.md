##### Для запуска тестов необходимо использовать файл make_sim.do. Внутри него закомментированы 4 набора тестов, нужно раскомментировать любой один из них и запустить симуляцию. При тестировании весь лог выводится без перерывов, все ошибки "сыпятся" в консоль, что очень сильно тормозит симуляцию. Поэтому для глубокого тестирования лучше модернизировать ./tb/macros.sv путем замены display на error/stop или просто раскомментировать комментарий $stop в макросе SHOW_WRONG_SIGNALS, чтобы прекратить симуляцию в случае первой же ошибки.

---

1) Ошибка при попытке переслать пакет длиной в 1 байт. Ready поднят всегда.
Для запуска надо раскомментировать тест ONE_PACKET

на 4 интерфейса посылаются поочередно пакеты в 1 байт. Ни один из них не придет.
Время: начало симуляции, транскрипт результата симуляции выглядит так: 
```
# driver sent           4 packets
# monitor received           0 packets
# PROBLEMS WITH PACKETS!
```

---

2) Ошибка при попытке переслать пакет длиной в 1 байт если ready меняется.
Для запуска надо раскомментировать тест ONE_BYTE_RAND_READY
Время: 45
```
# SCOREBOARD: DIFFERENT DIR  AT TIME:       45
# EXPECTED        2, got        0
# ------------------------------------------------------------------
# SCOREBOARD: DIFFERENT CHANNEL  AT TIME:       45
# EXPECTED        3, got       33
# ------------------------------------------------------------------
# SCOREBOARD: DIFFERENT BETWEEN DATA VALUE  AT TIME:       45
# EXPECTED      244, got      203
```



В 35 отсылается пакет 1 байт (который пропадает в dut). Затем попытка отослать 2-й пакет, но ready висит в 0, поэтому он не отсылается в логике драйвера. При этом модуль вообще демультиплексирует пакет в другой интерфейс dir (от предыдущего пакета). Соответственно, ошибка по всем составляющим пакета.

---

3) проблема с пакетами больше 1
Суть теста: по интерфейсу 0 пересылаются пакеты от 2 до 100 байтов, затем по интерфейсу 1 от 2 до 100 байтов и т.д.
Для запуска надо раскомментировать тест MANY_BYTES_RAND_READY, он симулирует работу с пакетами во время рандомно поднятых ready.

Время: 1835

```
# DIR:           1
# MONITOR: source end_of_packet wrong  AT TIME:     1835
# EXPECTED        0, got        1
```

Попытка получения пакета размером в 9 байтов (состоит из 2 посылок получается) неудачная, отсутствует сигнал startofpacket перед endofpacket (хотя бы). Далее так же сыпятся ошибки, тест комплексный.

При этом отправлено 396 пакетов, получено всего 237

---
4) Этот тест направлен на поиск ошибок при смене DIR с рандомными и постоянно поднятыми ready.
Для запуска надо раскомментировать тест SWAP_DIRS_RAND_READY
Частично он дублирует логику теста MANY_BYTES_RAND_READY, но это не проблема.

---

5) Тест MAIN_TEST запускает все тесты, описанные выше + более глубокие тесты

Есть ошибки работы модуля с сигналами valid, SOF/EOP, возможно empty и channel (не удалось отследить, так как нарушается порядок пакетов в mailbox из-за потерь их в принципе или пересылания в другой интерфейс, что так же видно в логах).
