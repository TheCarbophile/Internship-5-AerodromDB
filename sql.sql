CREATE TABLE
  airports (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    max_aircraft_capacity INT NOT NULL
  );

CREATE TABLE
  airplanes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    airport_id INT REFERENCES airports (id)
  );

CREATE TABLE
  flights (
    id SERIAL PRIMARY KEY,
    airplane_id INT REFERENCES airplanes (id),
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    start_location VARCHAR(100) NOT NULL,
    end_location VARCHAR(100) NOT NULL
  );

CREATE TABLE
  tickets (
    id SERIAL PRIMARY KEY,
    flight_id INT REFERENCES flights (id),
    user_id INT,
    seat_number VARCHAR(10) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
  );

CREATE TABLE
  users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    loyalty_card BOOLEAN NOT NULL,
    loyalty_years INT,
    ticket_count INT,
    CONSTRAINT loyalty_card_check CHECK (
      (
        loyalty_card
        AND ticket_count >= 10
      )
      OR (NOT loyalty_card)
    )
  );

CREATE TABLE
  pilots (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    flight_count INT NOT NULL
  );

CREATE TABLE
  flight_reviews (
    id SERIAL PRIMARY KEY,
    flight_id INT REFERENCES flights (id),
    rating INT NOT NULL,
    comment TEXT
  );

CREATE TABLE
  aircraft_staff (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    POSITION VARCHAR(100) NOT NULL,
    flight_id INT REFERENCES flights (id)
  );
  
SELECT
  name,
  model
FROM
  airplanes
WHERE
  capacity > 100;
  
SELECT
  *
FROM
  tickets
WHERE
  price BETWEEN 100 AND 200;
  
SELECT
  *
FROM
  pilots
WHERE
  name LIKE '%kinja'
  AND flight_count > 20;

SELECT
  *
FROM
  aircraft_staff
WHERE
  POSITION IN ('Host', 'Hostess')
  AND flight_id IN (
    SELECT
      id
    FROM
      flights
    WHERE
      departure_time <= NOW ()
      AND arrival_time >= NOW ()
  );
  
SELECT
  COUNT(*)
FROM
  flights
WHERE
  start_location = 'Split'
  OR end_location = 'Split'
  AND departure_time >= '2023-01-01'
  AND departure_time < '2024-01-01';

SELECT
  *
FROM
  flights
WHERE
  start_location = 'Beč'
  OR end_location = 'Beč'
  AND departure_time >= '2023-12-01'
  AND departure_time < '2024-01-01';
  
SELECT
  COUNT(*)
FROM
  tickets
WHERE
  flight_id IN (
    SELECT
      id
    FROM
      flights
    WHERE
      start_location = 'AirDUMP'
      AND departure_time >= '2021-01-01'
      AND departure_time < '2022-01-01'
  )
  AND seat_number LIKE 'B%';
 
SELECT
  AVG(rating)
FROM
  flight_reviews
WHERE
  flight_id IN (
    SELECT
      id
    FROM
      flights
    WHERE
      start_location = 'AirDUMP'
  );
  
SELECT
  a.name,
  COUNT(*) AS airbus_count
FROM
  airports a
  JOIN airplanes ap ON a.id = ap.airport_id
WHERE
  a.city = 'London'
  AND ap.model = 'Airbus'
GROUP BY
  a.name
ORDER BY
  airbus_count DESC;
  
SELECT
  a.*
FROM
  airports a
JOIN
  airports source
ON
  sqrt(
    (source.latitude - a.latitude)^2 + (source.longitude - a.longitude)^2
  ) * 111319.9 < 1500000
WHERE
  source.city = 'Split';


  
UPDATE tickets
SET
  price = price * 0.8
WHERE
  flight_id IN (
    SELECT
      id
    FROM
      flights
    WHERE
      id IN (
        SELECT
          flight_id
        FROM
          tickets
        GROUP BY
          flight_id
        HAVING
          COUNT(*) < 20
      )
  );
  
UPDATE pilots
SET
  flight_count = flight_count + 100
WHERE
  id IN (
    SELECT
      p.id
    FROM
      pilots p
      JOIN flights f ON p.id = f.pilot_id
    WHERE
      f.departure_time >= '2023-01-01'
      AND f.departure_time < '2024-01-01'
      AND f.arrival_time - f.departure_time > INTERVAL '10 hours'
    GROUP BY
      p.id
    HAVING
      COUNT(*) > 10
  );
  
DELETE FROM airplanes
WHERE
  id IN (
    SELECT
      a.id
    FROM
      airplanes a
      LEFT JOIN flights f ON a.id = f.airplane_id
    WHERE
      a.age > 20
      AND f.id IS NULL
  );
  
DELETE FROM flights
WHERE
  id IN (
    SELECT
      f.id
    FROM
      flights f
      LEFT JOIN tickets t ON f.id = t.flight_id
    WHERE
      t.id IS NULL
  );
  
DELETE FROM users
WHERE
  name LIKE '%ov'
  OR name LIKE '%in';