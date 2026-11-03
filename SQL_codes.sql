/* 
Задания были взяты с курса "Симулятор SQL"

1) Для каждого дня недели в таблице user_actions посчитайте:
Общее количество оформленных заказов.
Общее количество отменённых заказов.
Общее количество неотменённых заказов (т.е. доставленных).
Долю неотменённых заказов в общем числе заказов (success rate).
Новые колонки назовите соответственно created_orders, canceled_orders, actual_orders и success_rate. Колонку с долей неотменённых заказов округлите до трёх знаков после запятой.
Все расчёты проводите за период с 24 августа по 6 сентября 2022 года включительно, чтобы во временной интервал попало равное количество разных дней недели.
Группы сформируйте следующим образом: выделите день недели из даты с помощью функции to_char с параметром 'Dy', также выделите порядковый номер дня недели с помощью функции DATE_PART с параметром 'isodow'.
Далее сгруппируйте данные по двум полям и проведите все необходимые расчёты.
В результате должна получиться группировка по двум колонкам: с порядковым номером дней недели и их сокращёнными наименованиями.
Результат отсортируйте по возрастанию порядкового номера дня недели.
*/
SELECT date_part('isodow', time) :: integer as weekday_number,
       to_char(time,'Dy') as weekday,
       count(*) filter(WHERE action = 'create_order') as created_orders,
       count(*) filter (WHERE action = 'cancel_order') as canceled_orders,
       count(*) filter(WHERE action = 'create_order') - count(*) filter (WHERE action = 'cancel_order') as actual_orders,
       round((count(*) filter(WHERE action = 'create_order') - count(*) filter (WHERE action = 'cancel_order')):: decimal / count(*) filter(WHERE action = 'create_order'),
             3) as success_rate
FROM   user_actions
WHERE  time between '2022-08-24'
   and '2022-09-07'
GROUP BY 1, 2
ORDER BY 1
/*
2) Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.
Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя и возраст курьера. 
Возраст измерьте числом полных лет, как мы делали в прошлых уроках. Считайте его относительно последней даты в таблице user_actions — как для пользователей, 
так и для курьеров. Колонки с возрастом назовите user_age и courier_age. Результат отсортируйте по возрастанию id заказа.
*/
SELECT a.order_id,
       c.user_id,
       b.courier_id,
       date_part('year', age(p.last_date, k.birth_date)) :: integer as user_age,
       date_part('year', age(p.last_date, l.birth_date)) :: integer as courier_age
FROM   orders as a join (SELECT DISTINCT order_id,
                                         courier_id
                         FROM   courier_actions) as b
        ON a.order_id = b.order_id join (SELECT DISTINCT order_id,
                                                 user_id
                                 FROM   user_actions) as c
        ON a.order_id = c.order_id cross join (SELECT max(time) as last_date
                                       FROM   user_actions) as p join users as k
        ON k.user_id = c.user_id join couriers as l
        ON l.courier_id = b.courier_id
WHERE  array_length(a.product_ids, 1) = (SELECT max(array_length(product_ids, 1))
                                         FROM   orders)
ORDER BY 1
 /*
3) Выясните, какие пары товаров покупают вместе чаще всего.
Пары товаров сформируйте на основе таблицы с заказами. Отменённые заказы не учитывайте. В качестве результата выведите две колонки — колонку с парами наименований 
товаров и колонку со значениями, показывающими, сколько раз конкретная пара встретилась в заказах пользователей. Колонки назовите соответственно pair и count_pair.
Пары товаров должны быть представлены в виде списков из двух наименований. Пары товаров внутри списков должны быть отсортированы в порядке возрастания наименования.
Результат отсортируйте сначала по убыванию частоты встречаемости пары товаров в заказах, затем по колонке pair — по возрастанию.
*/
SELECT array[ least(c1.name, c2.name),
       greatest(c1.name, c2.name) ] as pair,
       count(*) as count_pair
FROM   (SELECT DISTINCT order_id,
                        unnest(product_ids) as product_id
        FROM   orders as t1
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) as a join (SELECT DISTINCT order_id,
                                                            unnest(product_ids) as product_id
                                            FROM   orders as t2
                                            WHERE  order_id not in (SELECT order_id
                                                                    FROM   user_actions
                                                                    WHERE  action = 'cancel_order')) as b
        ON a.order_id = b.order_id and
           a.product_id < b.product_id join products as c1
        ON a.product_id = c1.product_id join products as c2
        ON b.product_id = c2.product_id
GROUP BY 1
ORDER BY count_pair desc, pair asc
/*
4) На основе информации в таблицах orders и products рассчитайте ежедневную выручку сервиса и отразите её в колонке daily_revenue. 
Затем с помощью оконных функций и функций смещения посчитайте ежедневный прирост выручки. Прирост выручки отразите как в абсолютных значениях,
так и в % относительно предыдущего дня. Колонку с абсолютным приростом назовите revenue_growth_abs, а колонку с относительным — revenue_growth_percentage.
Для самого первого дня укажите прирост равным 0 в обеих колонках. При проведении расчётов отменённые заказы не учитывайте. Результат отсортируйте по колонке с датами по возрастанию.
*/
SELECT date,
       daily_revenue,
       case when lag(daily_revenue) OVER(ORDER BY date) is null then 0
            else round(daily_revenue - lag(daily_revenue) OVER(ORDER BY date),
                       1) end as revenue_growth_abs,
       case when lag(daily_revenue) OVER(ORDER BY date) is null then 0
            else round(((daily_revenue - lag(daily_revenue) OVER(ORDER BY date)) / lag(daily_revenue) OVER(ORDER BY date))* 100,
                       1) end as revenue_growth_percentage
FROM   (SELECT DISTINCT a.date,
                        round(sum(price) OVER(PARTITION BY a.date), 1) as daily_revenue
        FROM   (SELECT creation_time :: date as date,
                       order_id,
                       unnest(product_ids) as product_id
                FROM   orders
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order'))a join products as b
                ON a.product_id = b.product_id)t1
ORDER BY date
/*
5) С помощью оконной функции рассчитайте медианную стоимость всех заказов из таблицы orders, оформленных в нашем сервисе.
В качестве результата выведите одно число. Колонку с ним назовите median_price. Отменённые заказы не учитывайте.
*/
WITH unnested_orders AS (
    SELECT 
        order_id, 
        UNNEST(product_ids) AS product_id
    FROM orders 
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions 
        WHERE action = 'cancel_order'
    )
),
order_prices AS (
    SELECT DISTINCT 
        a.order_id, 
        SUM(b.price) OVER(PARTITION BY a.order_id) AS sum_order
    FROM unnested_orders AS a
    JOIN products AS b
        ON a.product_id = b.product_id
),
ranked_orders AS (
    SELECT 
        sum_order, 
        ROW_NUMBER() OVER(ORDER BY sum_order) AS numb,
        COUNT(*) OVER() AS total_count
    FROM order_prices
)
SELECT 
    CASE  
        WHEN COUNT(numb) % 2 = 1 THEN MAX(sum_order) FILTER (WHERE numb = (total_count / 2) + 1)
        ELSE AVG(sum_order) FILTER (WHERE numb = (total_count / 2) OR numb = (total_count / 2) + 1)
    END AS median_price
FROM ranked_orders;
