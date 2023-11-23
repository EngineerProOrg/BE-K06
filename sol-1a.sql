SELECT stock_name,
SUM(
  CASE
    When operation = 'Buy' then -price
    When operation = 'Sell' then price
  END 
)
AS capital_gain_loss
FROM stocks
Group By stock_name