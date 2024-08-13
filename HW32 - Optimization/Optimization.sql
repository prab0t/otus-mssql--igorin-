SET STATISTICS IO, TIME ON;
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
	JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
	JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
	JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
	JOIN Warehouse.StockItemTransactions AS ItemTrans
		ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
	AND (Select SupplierId
			FROM Warehouse.StockItems AS It
			Where It.StockItemID = det.StockItemID) = 12
	AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
			FROM Sales.OrderLines AS Total
				Join Sales.Orders AS ordTotal
				On ordTotal.OrderID = Total.OrderID
			WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
			AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID


--Заменил подзапросы на join. 
--Присоединение таблицы Warehouse.StockItems происходит в основном запросе через join, а не в подзапросе
--Использование сравнения дат вместо DATEDIFF
SET STATISTICS IO, TIME ON;
SELECT ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
	JOIN Sales.OrderLines AS det 
		ON det.OrderID = ord.OrderID
	JOIN Sales.Invoices AS Inv 
		ON Inv.OrderID = ord.OrderID AND Inv.BillToCustomerID != ord.CustomerID 
	JOIN Sales.CustomerTransactions AS Trans 
		ON Trans.InvoiceID = Inv.InvoiceID
	JOIN Warehouse.StockItems AS ItemTrans2 
		ON ItemTrans2.StockItemID = det.StockItemID AND ItemTrans2.SupplierId = 12
	JOIN Warehouse.StockItemTransactions AS ItemTrans 
		ON ItemTrans.StockItemID = det.StockItemID
WHERE  Inv.InvoiceDate = ord.OrderDate
					 AND (
				SELECT SUM(Total.UnitPrice*Total.Quantity)
				FROM Sales.OrderLines AS Total
				JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
				WHERE ordTotal.CustomerID = ord.CustomerID
				GROUP BY ordTotal.CustomerID
			) > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

