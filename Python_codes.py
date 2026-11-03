"""
Решения практических задач из серии курсов «Поколение Python» (платформа Stepik).
Раздел: работа со строками, списками, алгоритмы и функции.
1) Валидация телефонного номера
Определить, является ли введенная строка корректным телефонным номером.
Допустимые форматы: abc-def-hijk или 7-abc-def-hijk (где буквы — цифры от 0 до 9, разделенные дефисом).
Вывести «YES», если формат верный, и «NO» в противном случае.
"""
n = input().split('-')
flag = True
if len(n) == 4:
    for i in range(len(n)):
        if ''.join(n).isdigit() and n[0] == '7' and len(n[-1]) == 4:
            flag = True
        else:
            flag = False
elif len(n) == 3:
    for i in range(len(n)):
        if ''.join(n).isdigit() and len(n[1]) == 3 and len(n[-1]) == 4:
            flag = True
        else:
            flag = False
else:
    flag = False
if flag:
    print('YES')
else:
    print('NO')
  
  """
2) Напишите функцию convert_to_python_case(text), которая принимает в качестве аргумента строку в «верблюжьем регистре» 
и преобразует его в «змеиный регистр».
  """
# объявление функции
def convert_to_python_case(text):
    result = ''
    for i in range(len(text)):
        if text[i].isupper() and i != 0:
            result += '_'
            result += text[i].lower()
        else:
            result +=  text[i].lower()
    return result     
    return text.lower()
# считываем данные
txt = input()
# вызываем функцию
print(convert_to_python_case(txt))

"""
3) Правильная скобочная последовательность
Функция принимает строку из символов '(' и ')' и возвращает True, если каждой 
открывающей скобке соответствует парная закрывающая (с соблюдением порядка), иначе — False.
"""
# объявление функции
def is_correct_bracket(text):
    cnt = 0
    if text.count('(') == text.count(')'):
        for i in range(len(text)):
            if text[i] == '(':
                cnt += 1
            else:
                cnt-=1
            if cnt < 0:
                return False
        if cnt == 0:
            return True
        else:
            return False
    else:
        return False

# считываем данные
txt = input()

# вызываем функцию
print(is_correct_bracket(txt))

"""
4) Напишите функцию get_month(language, number), которая принимает на вход два аргумента 
language – язык ru или en и number – номер месяца (от 1 до 12 включительно) и возвращает название месяца на русском или английском языке.
"""
# объявление функции
def get_month(language, number):
    ru_month = ['','январь','февраль','март','апрель','май','июнь','июль','август','сентябрь','октябрь','ноябрь','декабрь']
    en_month = ['','january','february','march','april','may','june','july','august','september','october','november','december']
    if language == 'ru':
        return ru_month[number]
    else:
        return en_month[number]
        
# считываем данные
lan = input()
num = int(input())

# вызываем функцию
print(get_month(lan, num))

"""
5) Проверка полноты алфавита (Панграмма)
Функция принимает английский текст и возвращает True, если он содержит все 26 букв алфавита, иначе — False.
"""
# объявление функции
def is_pangram(text):
    text_sp = []
    text = text.lower()
    text_sp.extend(text.replace(' ', ''))
    alf_v = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 
             'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    for i in alf_v:
        if i not in text_sp:
            return False
      
    return True

# считываем данные
text = input()

# вызываем функцию
print(is_pangram(text))
