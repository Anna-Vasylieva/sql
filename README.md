Для виконання практичного завдання 3 треба було створити таку функію: calculate_order_total(p_order_id int); 
такі процедури: create_order(p_customer_id int), add_product_to_order(p_order_id int, p_product_id int, p_quantity int);
та такі тригери: trg_update_order_total, trg_order_log.

Для створення функції яка має повертати загальну суму я використала coalesce щоб уникнути null значення.
Для процедури create_order(p_customer_id int), яка створює замовлення, я використовувала if для перевірки наявності клієнта і у випадки хиби викликала 
помилку 'Customer does not exist'.
Для процедури add_product_to_order(p_order_id int, p_product_id int, p_quantity int), яка додає товари в замовленння, теж використовувала if для перевырки всіх умов,
а також в кінці оновлювала дані про наявність товару.
Для тригеру trg_update_order_total створила функцію update_order_total(), що перевіряє дію над таблицею orders та оновлює її поле total_amount використовуючи функцію
calculate_order_total(p_order_id int). В самому тригері прописала коли ми викликаємо функцію update_order_total(), тобто сам тригер
Для тригеру trg_order_log створила функцію order_log_create() яка заповнює поля в таблиці order_log. В самому тригері прописала коли він викликається.

В тестовій частині, охопила, сподівюсь, всі варіанти подій виконання функцій, процедур, тригерів та правильність exception
