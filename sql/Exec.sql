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


-- === 補充示範：會員登入 (usp_LoginMember) ===

-- 測試 A：輸入正確的帳號密碼 -> 登入成功
-- 預期結果：回傳 Result = 1 -> 帶出會員的基礎資料與他的專屬 CartID
EXEC usp_LoginMember @Email='me@test.com', @Password='1234';

-- 測試 B：密碼輸入錯誤 (展示資安防護) -> 登入失敗
-- 預期結果：回傳 Result = 0。不會告訴使用者是帳號錯還是密碼錯，統一顯示「帳號或密碼錯誤」。
EXEC usp_LoginMember @Email='Reporter@test.com', @Password='99999';

-- =============================================

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


USE [Velocity];
GO

-- === 擴充示範：單獨刪除購物車內的商品 ===
-- 假設會員 1 號剛剛加了 商品 1 號 跟 商品 2 號。
-- 現在他反悔了，想把「商品 2 號」從購物車拿出來：
EXEC usp_RemoveFromCart @MemberID = 1, @ProductID = 2;

-- 檢查結果：再次呼叫 MOMO 購物車，看看商品 2 號是不是消失了，總金額有沒有重算。
EXEC usp_GetCartDetails @MemberID = 1;


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

USE [Velocity];
GO

-- 假設會員 1 號不想買了，按下清空按鈕：
EXEC usp_ClearCart @MemberID = 1;

-- 檢查：購物車明細清空
SELECT * FROM CartItems;

EXEC

USE [Velocity];
GO

-- === 擴充示範：檢查會員狀態 (usp_CheckMemberStatus) ===

-- 測試 1：檢查一個存在的帳號 (假設我有建這個 me@test.com)
-- 預期結果：會算出這個會員加入 Velocity 幾天了
EXEC usp_CheckMemberStatus @Email = N'me@test.com';


-- 測試 2：檢查一個不存在的帳號
-- 預期結果：回傳 Result = 0，告訴我找不到該帳號。
EXEC usp_CheckMemberStatus @Email = N'nobody@test.com';


USE [Velocity];
GO

-- 1. 先讓會員 1 號加點東西進購物車
EXEC usp_AddToCart @MemberID = 1, @ProductID = 1, @Quantity = 2;
EXEC usp_AddToCart @MemberID = 1, @ProductID = 2, @Quantity = 1;

-- 2. 呼叫組員想看的購物車內容！
EXEC usp_GetCartDetails @MemberID = 1;

USE [Velocity];
GO

-- === 擴充示範：查看歷史訂單與寄送地址 ===
-- 假設剛剛結帳完，產生了第 1 號訂單 (@OrderID = 1)
-- 現在要調出這筆訂單的詳細發票資訊：
EXEC usp_GetOrderInvoice @OrderID = 1;