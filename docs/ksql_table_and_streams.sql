--Create stream that includes only the buy side trades
CREATE STREAM BUY_TRADES WITH (KAFKA_TOPIC='BUY_TRADES', PARTITIONS=1, REPLICAS=1) AS SELECT
  STOCKTRADES.QUANTITY QUANTITY,
  STOCKTRADES.SYMBOL SYMBOL,
  STOCKTRADES.PRICE PRICE,
  STOCKTRADES.ACCOUNT ACCOUNT,
  STOCKTRADES.USERID USERID
FROM STOCKTRADES STOCKTRADES
WHERE (STOCKTRADES.SIDE = 'BUY')
EMIT CHANGES;

--Create stream that includes only the sell side trades
CREATE STREAM SELL_TRADES WITH (KAFKA_TOPIC='SELL_TRADES', PARTITIONS=1, REPLICAS=1) AS SELECT
  STOCKTRADES.QUANTITY QUANTITY,
  STOCKTRADES.SYMBOL SYMBOL,
  STOCKTRADES.PRICE PRICE,
  STOCKTRADES.ACCOUNT ACCOUNT,
  STOCKTRADES.USERID USERID
FROM STOCKTRADES STOCKTRADES
WHERE (STOCKTRADES.SIDE = 'SELL')
EMIT CHANGES;

--Create table that aggregates the buy orders and calculates the total value traded
CREATE TABLE AGG_BUY_ORDERS WITH (KAFKA_TOPIC='AGG_BUY_ORDERS', PARTITIONS=1, REPLICAS=1) AS SELECT
  BUY_TRADES.SYMBOL SYMBOL,
  SUM(BUY_TRADES.QUANTITY) QUANTITY_AGG,
  AVG(BUY_TRADES.PRICE) PRICE_AVG,
  SUM((BUY_TRADES.QUANTITY * BUY_TRADES.PRICE)) VALUE_TRADED
FROM BUY_TRADES BUY_TRADES
WINDOW TUMBLING ( SIZE 60 SECONDS )
GROUP BY BUY_TRADES.SYMBOL
EMIT CHANGES;

--Create table that aggregates the sell orders and calculates the total value traded
CREATE TABLE AGG_SELL_ORDERS WITH (KAFKA_TOPIC='AGG_SELL_ORDERS', PARTITIONS=1, REPLICAS=1) AS SELECT
  SELL_TRADES.SYMBOL SYMBOL,
  SUM(SELL_TRADES.QUANTITY) QUANTITY_AGG,
  AVG(SELL_TRADES.PRICE) PRICE_AVG,
  SUM((SELL_TRADES.QUANTITY * SELL_TRADES.PRICE)) VALUE_TRADED
FROM SELL_TRADES SELL_TRADES
WINDOW TUMBLING ( SIZE 60 SECONDS )
GROUP BY SELL_TRADES.SYMBOL
EMIT CHANGES;