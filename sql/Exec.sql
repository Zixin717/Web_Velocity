USE [Velocity];
GO

-- === 一、註冊：呼叫註冊程式 -> 添加會員 1 號 ===
EXEC usp_CreateMember @Email='me@test.com', @Password='1234', @Name='我';
SELECT * FROM Members; -- 檢查
SELECT * FROM Cart; 


-- === 二、加入購物車 ===
-- 測試：會員 1 號，把商品 1 號，放 5 個進去。
EXEC usp_AddToCart @MemberID = 1, @ProductID = 1, @Quantity = 5;
SELECT * FROM CartItems; -- 檢查 -> CartItems 表多了一筆資料，數量是 5


-- === 三、結帳 ===
-- 1. 會員 1 號結帳，送到指定地點。
EXEC usp_Checkout @MemberID = 1, @ShippingAddress = N'台中歌劇院';
SELECT * FROM Orders; -- 1. 訂單產生 -> Status 是 '待付款'

-- 2026 / 2 / 18 -> 修正舊資料：把所有 'Paid' 的都改成 '待付款'
UPDATE Orders
SET Status = N'待付款'
WHERE Status = 'Paid';
GO

-- 2. Get 訂單明細：裡面記買了商品 1 號
SELECT * FROM OrderDetails;
SELECT * FROM Orders -- WHERE 


-- 3. 購物車清空了：CartItems 應該要是空的 or 這筆被刪掉了
SELECT * FROM CartItems;

-- 4. 庫存減少了：原本 INSERT 是 10，現在應該剩 5 ( 2/18 進貨 10包 -> 10 - 5)
SELECT * FROM Products;


USE [Velocity];
GO

-- 查出訂單明細，並帶出是誰買的。
SELECT 
    OD.OrderDetailID,      -- 明細流水號
    O.OrderID,             -- 訂單編號
    M.MemberID AS 會員ID,  -- 我們需要的欄位
    M.Name AS 會員姓名,     -- 從 Members 表牽過來的名字
    P.Name AS 商品名稱,     -- 從 Products 表牽過來的商品名
    OD.Quantity,           -- 數量
    OD.UnitPrice           -- 單價
FROM OrderDetails OD
JOIN Orders O ON OD.OrderID = O.OrderID      -- 牽主表
JOIN Members M ON O.MemberID = M.MemberID    -- 再透過主表牽起會員
JOIN Products P ON OD.ProductID = P.ProductID; -- 順便牽起商品








-- === 明天報告示範用 === --
-- === 一、註冊：呼叫註冊程式 -> 添加會員 1 號 ===
EXEC usp_CreateMember @Email='Reporter@test.com', @Password='12345', @Name='Reporter';
SELECT * FROM Members; -- 檢查會員是否建立
SELECT * FROM Cart;    -- 檢查車子是否建立


-- === 二、加入購物車 ===
-- 測試：會員 2 號，把商品 2 號，放 5 個進去。
EXEC usp_AddToCart @MemberID = 2, @ProductID = 2, @Quantity = 5;
SELECT * FROM CartItems; -- 檢查 -> CartItems 表多了一筆資料，數量是 5


-- === 三、結帳 ===
-- 1. 會員 1 號結帳，送到指定地點。
EXEC usp_Checkout @MemberID = 2, @ShippingAddress = N'台中公園';
SELECT * FROM Orders; -- 1. 訂單產生 -> Status 是 '待付款'

-- 2026 / 2 / 18 -> 修正舊資料：把所有 'Paid' 的都改成 '待付款'
UPDATE Orders
SET Status = N'待付款'
WHERE Status = 'Paid';
GO

-- 2. Get 訂單明細：裡面記買了商品 2 號
SELECT * FROM OrderDetails;

-- 3. 購物車清空了：CartItems 應該要是空的 or 這筆被刪掉了
SELECT * FROM CartItems;

-- 4. 庫存減少了：原本 INSERT 是 10，現在應該剩 5 ( 2/24 進貨 10包 -> 10 - 5)
SELECT * FROM Products;
