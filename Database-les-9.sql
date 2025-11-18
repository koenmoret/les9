-- Eerst alle koppeltabellen droppen, dan de hoofdtabellen!
DROP TABLE IF EXISTS television_remotecontroller CASCADE;
DROP TABLE IF EXISTS television_cimodule CASCADE;
DROP TABLE IF EXISTS television_wallbracket CASCADE;

DROP TABLE IF EXISTS cimodules CASCADE;
DROP TABLE IF EXISTS televisions CASCADE;
DROP TABLE IF EXISTS remotecontrollers CASCADE;
DROP TABLE IF EXISTS wallbrackets CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;


-- User tabel
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    adres VARCHAR(255),
    functie VARCHAR(64),
    loonschaal INTEGER,
    vakantiedagen INTEGER
);

-- Abstract Product tabel (gebruik als hoofdproduct)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(127) NOT NULL,
    brand VARCHAR(127),
    price DOUBLE PRECISION,
    currentstock INTEGER,
    sold INTEGER,
    datesold DATE,
    type VARCHAR(64)
);

-- Television tabel (subclass van Product)
CREATE TABLE televisions (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    height DOUBLE PRECISION,
    width DOUBLE PRECISION,
    schermkwaliteit VARCHAR(64),
    schermtype VARCHAR(64),
    wifi BOOLEAN,
    smarttv BOOLEAN,
    voicecontrol BOOLEAN,
    hdr BOOLEAN,
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- RemoteController tabel (subclass van Product)
CREATE TABLE remotecontrollers (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    smart BOOLEAN,
    batterytype VARCHAR(64),
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- CI Module tabel (subclass van Product)
CREATE TABLE cimodules (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    provider VARCHAR(127),
    encoding VARCHAR(127),
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- WallBracket tabel (subclass van Product)
CREATE TABLE wallbrackets (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    adjustable BOOLEAN,
    bevestigingsmethode VARCHAR(127),
    height DOUBLE PRECISION,
    width DOUBLE PRECISION,
    FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Relaties tussen producten:
-- Een televisie kan meerdere remote controllers, CI modules en wall brackets hebben (0..*)
-- Optioneel: Koppel tabellen voor de relaties

CREATE TABLE television_remotecontroller (
    television_id INTEGER,
    remotecontroller_id INTEGER,
    PRIMARY KEY (television_id, remotecontroller_id),
    FOREIGN KEY (television_id) REFERENCES televisions(id),
    FOREIGN KEY (remotecontroller_id) REFERENCES remotecontrollers(id)
);

CREATE TABLE television_cimodule (
    television_id INTEGER,
    cimodule_id INTEGER,
    PRIMARY KEY (television_id, cimodule_id),
    FOREIGN KEY (television_id) REFERENCES televisions(id),
    FOREIGN KEY (cimodule_id) REFERENCES cimodules(id)
);

CREATE TABLE television_wallbracket (
    television_id INTEGER,
    wallbracket_id INTEGER,
    PRIMARY KEY (television_id, wallbracket_id),
    FOREIGN KEY (television_id) REFERENCES televisions(id),
    FOREIGN KEY (wallbracket_id) REFERENCES wallbrackets(id)
);

-- Optioneel: Demo data invoegen
INSERT INTO products (name, brand, price, currentstock, sold, datesold, type) VALUES
('Philips OLED TV', 'Philips', 1199.99, 15, 8, '2025-11-01', 'television'),
('Samsung Remote', 'Samsung', 29.99, 50, 25, '2025-10-15', 'remotecontroller'),
('Ziggo CI+ Module', 'Ziggo', 14.99, 100, 55, '2025-11-05', 'cimodule'),
('Vogel''s Wall Bracket', 'Vogel''s', 59.99, 10, 5, '2025-09-21', 'wallbracket');

-- Voorbeeld van een televisie toevoegen
INSERT INTO televisions (product_id, height, width, schermkwaliteit, schermtype, wifi, smarttv, voicecontrol, hdr)
VALUES ((SELECT id FROM products WHERE name = 'Philips OLED TV'), 70.0, 110.0, 'Ultra HD', 'OLED', true, true, true, true);

-- Voeg een afstandsbediening toe
INSERT INTO remotecontrollers (product_id, smart, batterytype)
VALUES ((SELECT id FROM products WHERE name = 'Samsung Remote'), true, 'AA');

-- Voeg een CI Module toe
INSERT INTO cimodules (product_id, provider, encoding)
VALUES ((SELECT id FROM products WHERE name = 'Ziggo CI+ Module'), 'Ziggo', 'MPEG-4');

-- Voeg een Wall Bracket toe
INSERT INTO wallbrackets (product_id, adjustable, bevestigingsmethode, height, width)
VALUES ((SELECT id FROM products WHERE name = 'Vogel''s Wall Bracket'), true, 'Schroeven', 30.0, 50.0);

-- Relaties leggen
INSERT INTO television_remotecontroller (television_id, remotecontroller_id)
VALUES ((SELECT id FROM televisions WHERE product_id = (SELECT id FROM products WHERE name = 'Philips OLED TV')),
        (SELECT id FROM remotecontrollers WHERE product_id = (SELECT id FROM products WHERE name = 'Samsung Remote')));

INSERT INTO television_cimodule (television_id, cimodule_id)
VALUES ((SELECT id FROM televisions WHERE product_id = (SELECT id FROM products WHERE name = 'Philips OLED TV')),
        (SELECT id FROM cimodules WHERE product_id = (SELECT id FROM products WHERE name = 'Ziggo CI+ Module')));

INSERT INTO television_wallbracket (television_id, wallbracket_id)
VALUES ((SELECT id FROM televisions WHERE product_id = (SELECT id FROM products WHERE name = 'Philips OLED TV')),
        (SELECT id FROM wallbrackets WHERE product_id = (SELECT id FROM products WHERE name = 'Vogel''s Wall Bracket')));


SELECT t.id AS tv_id, p.name AS tv_naam, rc.id AS rc_id, prc.name AS rc_naam
FROM televisions t
JOIN products p ON t.product_id = p.id
LEFT JOIN television_remotecontroller trc ON t.id = trc.television_id
LEFT JOIN remotecontrollers rc ON trc.remotecontroller_id = rc.id
LEFT JOIN products prc ON rc.product_id = prc.id;

