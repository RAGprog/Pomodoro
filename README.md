[eng][eng] | [ru][ru]

# AVR MCU implementation of pomodoro time controller

[The current version](/advanced) is for the cheap but old __at90s2313__ or __attiny2313__ (_in at90s2313 mode_).  

* Freq. = 1..16MHz (changeble)
* 2 LEDs on PB0 and PB1 (Anode to pin, cathode to GND) (changeble)
* 1 button from PD2 to GND  

optional:
* 1 button from RESET to GND
* you can add multiple parallel actions (coroutines)

If you have Proteus, then you can run the attached simulation.

You can change the program to suit your needs or to another controller. _Please share your code._  
I'll be glad to contact you for any of your questions.

_tstu-no@inbox.ru_

----

# Реализация таймера Pomodoro на микроконтроллере AVR

[Текущая версия](/advanced) – для дешевого, но старого __at90s2313__ или __attiny2313__ (_в режиме at90s2313_). Можете также использовать [упрощенную версию](/simple).  

* Частота = 1..16MHz (изменяемо)
* 2 светодиода к PB0 и PB1 (анод к выводу МК, катод к общему выводу) (изменяемо)
* 1 кнопка между PD2 и общим выводом  

опционально:
* 1 кнопка между RESET и общим выводом

_\* общий вывод = GND_

![Схема](./media/scheme.png "Схема")

Если у вас есть Proteus, то вы можете запустить приложенную [симуляцию](/2313.pdsprj).

## Возможности:

* Возможность псевдопараллельной работы нескольких подпрограмм (реализован планировщик), для демонстрации активировано несколько независимых "мигалок" на выводах МК. Для снижения потребления энергии - отлючите их.

---
Вы можете изменить программу под ваши цели или для использования с другим МК. _Пожалуйста, делитесь вашим кодом._  
Вам захотелось задать вопрос, получить разъяснения, возникли сложности – буду рад связаться с вами.


_tstu-no@inbox.ru_

---

[todo list](/todo.md)

[eng]: </README.md#AVR-MCU-implementation-of-pomodoro-time-controller>
[ru]: </README.md#Реализация-таймера-Pomodoro-на-микроконтроллере-AVR>