DROP SCHEMA public CASCADE;

CREATE SCHEMA public;

-- регионы присутствия банка --
CREATE TABLE regions
(
  id      INTEGER PRIMARY KEY,
  title   TEXT        NOT NULL,
  active  BOOLEAN     NOT NULL DEFAULT TRUE,
  created TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- офисы банка --
CREATE TABLE offices
(
  id        BIGSERIAL PRIMARY KEY,
  title     TEXT        NOT NULL,
  address   TEXT        NOT NULL,
  region_id BIGINT      NOT NULL REFERENCES regions (id),
  active    BOOLEAN     NOT NULL DEFAULT TRUE,
  created   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- головные офисы банка в конкретном регионе --
CREATE TABLE regions_main_offices
(
  region_id INTEGER     NOT NULL UNIQUE REFERENCES regions (id),
  office_id BIGINT      NOT NULL UNIQUE REFERENCES offices (id),
  created   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- сервисы банка --
CREATE TABLE services
(
  id      SERIAL PRIMARY KEY,
  title   TEXT        NOT NULL,
  active  BOOLEAN     NOT NULL DEFAULT TRUE,
  created TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- сервисы банка предлагаемые в конкретных офисах --
CREATE TABLE offices_services
(
  office_id  INTEGER     NOT NULL REFERENCES offices (id),
  service_id INTEGER     NOT NULL REFERENCES services (id),
  created    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT offices_services_pkey PRIMARY KEY (office_id, service_id)
);

-- менеджеры банка --
CREATE TABLE managers
(
  id        BIGSERIAL PRIMARY KEY,
  name      TEXT        NOT NULL,
  boss_id   BIGINT REFERENCES managers (id),
  office_id BIGINT      NOT NULL REFERENCES offices (id),
  active    BOOLEAN     NOT NULL DEFAULT TRUE,
  created   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- зарегистрированные пользователи банка --
CREATE TABLE users
(
  id      BIGSERIAL PRIMARY KEY,
  name    TEXT        NOT NULL,
  phone   TEXT        NOT NULL,
  email   TEXT        NOT NULL UNIQUE,
  active  BOOLEAN     NOT NULL DEFAULT TRUE,
  created TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- продукты банка --
CREATE TABLE products
(
  id      BIGSERIAL PRIMARY KEY,
  title   TEXT        NOT NULL,
  price   BIGINT      NOT NULL CHECK ( price >= 0 ),
  active  BOOLEAN     NOT NULL DEFAULT TRUE,
  created TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- зарегистрированные каналы привлечения клиентов --
CREATE TABLE channels
(
  id      TEXT PRIMARY KEY,
  title   TEXT        NOT NULL,
  active  BOOLEAN     NOT NULL DEFAULT TRUE,
  created timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- покупки клиентов --
CREATE TABLE purchases
(
  id            UUID PRIMARY KEY     DEFAULT gen_random_uuid(),
  -- может быть NULL, если у нас неидентифицированный клиент
  user_id       BIGINT REFERENCES users (id),
  -- может быть NULL, если клиент воспользовался самообслуживанием (веб-сайт, моб.приложение, банкомат, терминал)
  manager_id    BIGINT REFERENCES managers (id),
  product_id    BIGINT      NOT NULL REFERENCES products (id),
  product_title TEXT        NOT NULL,
  product_price BIGINT      NOT NULL CHECK ( product_price >= 0 ),
  -- канал, через который пришёл клиент (например, реклама в веб, пуш-уведомления в смартфоне, смс, звонок менеджера и т.д.)
  -- было добавлено позже, поэтому у "старых" покупок может быть NULL, у некоторых -- опущено, если не удалось определить, через какой канал пришёл клиент
  channel       TEXT                 DEFAULT 'unknown',
  created       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO regions(id, title, active)
VALUES (77, 'город Москва', DEFAULT),
       (78, 'город Санкт-Петербург', DEFAULT),
       (16, 'республика Татарстан', DEFAULT),
       (11, 'республика Коми', FALSE),
       (87, 'Чукотский автономный округ', DEFAULT)
;

INSERT INTO offices (id, title, address, region_id, active)
VALUES (1, 'Красные ворота', '107078, Москва, улица Маши Порываевой, д. 34', 77, DEFAULT),
       (2, 'Пятницкий', '115035, Москва, улица Пятницкая, д. 2/38, стр. 2', 77, DEFAULT),
       (3, 'Красная Пресня', '123242, Москва, улица Красная Пресня, д. 12', 77, DEFAULT),
       (4, '«Проспект Мира»', '129090, Москва, проспект Мира, д. 36, стр. 1', 77, FALSE),
       (5, 'Территориальный офис Санкт-Петербургский', '191036, Санкт-Петербург, улица 2-я Советская, д. 17, лит. "А"',
        78, DEFAULT),
       (6, 'Василеостровский', '199034, Санкт-Петербург, проспект Малый В.О., д. 22, лит. "А"', 78, DEFAULT),
       (7, '«Комендантский»', '197371, Санкт-Петербург, проспект Комендантский, д. 17, корп. 1, лит. "А"', 78, FALSE),
       (8, 'Московский', '420039, Республика Татарстан, Казань, улица Восстания, д. 58/19', 16, DEFAULT),
       (9, '«Новая Казань»', '420066, Республика Татарстан, Казань, улица Чистопольская, д. 4', 16, FALSE),
       (10, 'Сыктывкар', 'Не указан', 11, FALSE)
;

ALTER SEQUENCE offices_id_seq RESTART WITH 11;

INSERT INTO regions_main_offices(region_id, office_id)
VALUES (77, 1),
       (78, 5),
       (16, 8),
       (11, 10)
;

INSERT INTO services(id, title)
VALUES (1, 'Обслуживание физических лиц'),
       (2, 'Обслуживание юридических лиц'),
       (3, 'Обслуживание паевых инвестиционных фондов'),
       (4, 'Обслуживание индивидуальных инвестиционных счетов'),
       (5, 'Премиальное обслуживание'),
       (6, 'Кассовые операции'),
       (7, 'Обмен валюты'),
       (8, 'Сейфовые ячейки (159)')
;

ALTER SEQUENCE services_id_seq RESTART WITH 9;

INSERT INTO offices_services(office_id, service_id)
VALUES (1, 1),
       (1, 2),
       (1, 3),
       (1, 4),
       (1, 5),
       (1, 6),
       (1, 7),
       (1, 8),
       (2, 1),
       (2, 2),
       (2, 3),
       (2, 4),
       (2, 5),
       (2, 6),
       (2, 7),
       (2, 8),
       (3, 1),
       (3, 3),
       (3, 4),
       (3, 5),
       (3, 6),
       (3, 7),
       (3, 8),
       (5, 1),
       (5, 2),
       (5, 5),
       (5, 6),
       (5, 7),
       (6, 1),
       (6, 2),
       (6, 5),
       (6, 6),
       (6, 7),
       (8, 1),
       (8, 2),
       (8, 3),
       (8, 4),
       (8, 5),
       (8, 6),
       (8, 7),
       (8, 8)
;

INSERT INTO managers (id, name, boss_id, office_id, active)
VALUES (1, 'Рита', NULL, 1, DEFAULT),
       (2, 'Константин', 1, 1, DEFAULT),
       (3, 'Кирилл', 2, 1, DEFAULT),
       (4, 'Карина', 2, 1, DEFAULT),
       (5, 'Ксения', 2, 1, FALSE),
       (6, 'Пелагея', 1, 2, DEFAULT),
       (7, 'Полина', 6, 2, DEFAULT),
       (8, 'Прасковья', 7, 2, DEFAULT),
       (9, 'Карина', 1, 3, DEFAULT),
       (10, 'Ксения', 9, 3, DEFAULT),
       (11, 'Кира', 9, 3, DEFAULT),
       (12, 'Пётр', 1, 4, FALSE),
       (13, 'Полина', 12, 4, FALSE),
       (14, 'Снежана', 1, 5, DEFAULT),
       (15, 'Светлана', 14, 5, DEFAULT),
       (16, 'Валентина', 14, 6, DEFAULT),
       (17, 'Виктор', 16, 6, DEFAULT),
       (18, 'Вероника', 16, 6, FALSE),
       (19, 'Маргарита', 1, 8, DEFAULT),
       (20, 'Мария', 19, 8, DEFAULT),
       (21, 'Максим', 20, 8, DEFAULT),
       (22, 'Никита', 19, 9, FALSE)
;

ALTER SEQUENCE managers_id_seq RESTART WITH 23;

INSERT INTO users(id, name, phone, email, active)
VALUES (1, 'Александр', '+79...01', 'alexander@ya.ru', DEFAULT),
       (2, 'Александра', '+79...02', 'alexandra@ya.ru', DEFAULT),
       (3, 'Борис', '+79...03', 'boris@ya.ru', FALSE),
       (4, 'Валерий', '+79...04', 'valerii@ya.ru', DEFAULT),
       (5, 'Валерия', '+79...05', 'valeriia@ya.ru', DEFAULT),
       (6, 'Василиса', '+79...06', 'vasilisa@ya.ru', DEFAULT),
       (7, 'Василий', '+79...07', 'vasilii@ya.ru', DEFAULT)
;

ALTER SEQUENCE users_id_seq RESTART WITH 8;

INSERT INTO products (id, title, price, active)
VALUES (1, 'Product A', 5000, DEFAULT),
       (2, 'Product B', 0, DEFAULT),
       (3, 'Product C', 100, DEFAULT),
       (4, 'Product D', 1000, FALSE),
       (5, 'Product E', 0, DEFAULT),
       (6, 'Product F', 500, FALSE),
       (7, 'Product G', 100000, DEFAULT),
       (8, 'Product I', 50000, DEFAULT)
;

ALTER SEQUENCE products_id_seq RESTART WITH 9;

INSERT INTO channels (id, title, active)
VALUES ('website', 'Официальный веб-сайт', DEFAULT),
       ('ibank', 'Интернет-банк', DEFAULT),
       ('mbank', 'Официальное мобильное приложение', DEFAULT),
       ('tv', 'Реклама на телевидении', DEFAULT),
       ('vk', 'Соц.сеть VK', DEFAULT),
       ('fb', 'Соц.сеть Facebook', FALSE),
       ('bankiru', 'Портал Banki.ru', DEFAULT)
;

INSERT INTO purchases (user_id, manager_id, product_id, product_title, product_price, channel, created)
VALUES (NULL, 2, 1, 'Product A (old version)', 4000, NULL, '2022-01-11 10:00:00 +0300'),
       (1, 2, 1, 'Product A (old version)', 4000, NULL, '2022-01-11 11:00:00 +0300'),
       (1, 6, 2, 'Product B', 0, 'website', '2022-01-12 13:00:00 +0300'),
       (2, 8, 1, 'Product A (old version)', 4000, 'fb', '2022-01-11 10:00:00 +0300'),
       (2, 8, 3, 'Product C', 100, 'fb', '2022-01-15 10:00:00 +0300'),
       (NULL, NULL, 2, 'Product B', 0, NULL, '2022-01-20 10:00:00 +0300'),
       (NULL, NULL, 2, 'Product B', 0, NULL, '2022-01-20 11:00:00 +0300'),
       (NULL, NULL, 2, 'Product B', 0, NULL, '2022-01-20 11:00:00 +0300'),
       (NULL, NULL, 7, 'Product G', 100000, NULL, '2022-01-20 11:00:00 +0300'),
       (3, 12, 4, 'Product D', 1000, NULL, '2022-01-25 11:00:00 +0300'),
       (4, 15, 4, 'Product D', 1000, 'mbank', '2022-02-01 10:00:00 +0300'),
       (4, 15, 5, 'Product E', 100, 'mbank', '2022-02-01 10:05:00 +0300'),
       (5, 15, 1, 'Product A', 5000, 'vk', '2022-02-01 11:00:00 +0300'),
       (6, NULL, 6, 'Product F', 500, 'recommendations', '2022-02-05 11:00:00 +0300'),
       (6, NULL, 6, 'Product F', 500, 'recommendations', '2022-02-10 12:00:00 +0300'),
       (7, NULL, 1, 'Product A', 5000, DEFAULT, '2022-02-06 11:00:00 +0300'),
       (7, NULL, 6, 'Product F', 500, 'recommendations', '2022-02-10 12:00:00 +0300'),
       (7, 20, 1, 'Product A', 5000, DEFAULT, '2022-04-01 11:00:00 +0300'),
       (7, 20, 6, 'Product F', 500, 'recommendations', '2022-04-02 12:00:00 +0300'),
       (2, 8, 1, 'Product A', 5000, 'vk', '2022-04-10 10:00:00 +0300')
;
