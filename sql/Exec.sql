USE [Velocity];
GO

-- ===================================================
-- 步驟一：先將相關連結清空 -> 因為綁 FK 了，先清空明細才能再清空商品。
-- ===================================================
DELETE FROM [CartItems];
DELETE FROM [OrderDetails];

-- ===================================================
-- 步驟二：清空商品表
-- ===================================================
DELETE FROM [Products];

-- ===================================================
-- 步驟三：把 ProductID 流水號歸零
-- ===================================================
DBCC CHECKIDENT ('Products', RESEED, 0);
GO


-- ===================================================
-- 步驟四：新增安全寫法 -> 裡面沒東西才能新增
-- ===================================================

-- 1. 先宣告變數 -> 變數一定用小寫開頭
-- DECLARE @newFlavor NVARCHAR(100) = N'Velocity 原味高蛋白粉'
-- IF NOT EXISTS(SELECT 1 FROM Products)
-- BEGIN
--     INSERT INTO


-- END




















DELETE FROM CartItems;
DELETE FROM OrderDetails;

-- 現在可以安全清空商品表了
DELETE FROM Products;
GO

-- ===================================================
-- 步驟二：魔法指令 -> 將 ProductID 流水號歸零！
-- ===================================================
-- 如果不清零，下一筆商品 ID 會從 16 開始。這行指令會讓它退回起點。
DBCC CHECKIDENT ('Products', RESEED, 0);
GO

-- ===================================================
-- 步驟三：精準上架 5 款商品
-- 【事前準備】先上架一些 Velocity 高蛋白粉商品
-- 添加商品測試
-- ===================================================
INSERT INTO Products ([Name], [Price], [Stock], [Description], [ImageURL], [Flavor])
VALUES 
    (N'Velocity 原味高蛋白粉', 2999, 10, N'純粹無添加，經典原味', N'/img/p1.jpg', N'原味'),
    (N'Velocity 草莓高蛋白粉', 2999, 10, N'香甜草莓風味', N'/img/p2.jpg', N'草莓'),
    (N'Velocity 焦糖咖啡高蛋白粉', 2999, 5, N'提神首選，焦糖拿鐵風味', N'/img/p3.jpg', N'焦糖咖啡'),
    (N'Velocity 香草高蛋白粉', 1200, 50, N'幫助肌肉修復，濃郁香草', N'/img/p4.jpg', N'香草'),
    (N'Velocity 抹茶高蛋白粉', 1200, 30, N'清爽無負擔，靜岡抹茶', N'/img/p5.jpg', N'抹茶');
GO

-- ===================================================
-- 步驟四：檢查結果
-- ===================================================
SELECT * FROM Products;






-- 報告開場：展示會員系統


-- 1. 註冊會員 3 號
EXEC usp_CreateMember 
    @Email='Reporter1@test.com',
    @Password='12345',
    @Name='Reporter1',
    @Address='台中公園',
    @Phone='09123456798';

-- 2. 檢查帳號是否存在
-- 檢查帳號是否存在 -> 找到帳號版本
EXEC usp_CheckMemberStatus @Email = N'nobody@test.com'; -- 預期：回傳找不到帳號
EXEC usp_CheckMemberStatus @Email = N'Reporter1@test.com'; -- 預期：回傳找不到帳號

-- 3. 測試登入機制 (資安展示)
EXEC usp_LoginMember @Email='Reporter@test.com', @Password='wrong_pwd'; -- 預期：失敗，模糊錯誤訊息
EXEC usp_LoginMember @Email='Reporter1@test.com', @Password='12345';     -- 預期：成功，抓出 CartID

-- 報告中間：展示 MOMO 風格購物車
-- 4. 會員將商品加入購物車
EXEC usp_AddToCart @MemberID = 1, @ProductID = 1, @Quantity = 2; -- 原味 x2 10 - 2
EXEC usp_AddToCart @MemberID = 1, @ProductID = 2, @Quantity = 1; -- 草莓 x1 10 - 2
EXEC usp_AddToCart @MemberID = 1, @ProductID = 3, @Quantity = 1; -- 焦糖 x1 5 - 1
SELECT * FROM Products; -- 還沒買


-- 5. 單獨移除一項商品 (反悔不想買了)
EXEC usp_RemoveFromCart @MemberID = 1, @ProductID = 3; -- 焦糖
SELECT 
    C.CartID AS 推車編號,
    P.Name AS 商品名稱,
    P.Price AS 單價,
    CI.Quantity AS 購買數量,
    (P.Price * CI.Quantity) AS 小計
FROM Cart C
JOIN CartItems CI ON C.CartID = CI.CartID      -- 從推車找到裡面的商品明細
JOIN Products P ON CI.ProductID = P.ProductID  -- 從明細找到商品的真實名稱與價格
WHERE C.MemberID = 1;


-- 6. 查看 MOMO 風格購物車 (兩個表格：明細清單 + 總結帳金額)
EXEC usp_GetCartDetails @MemberID = 1;
SELECT * FROM Products;


-- 報告後面：防超賣結帳與訂單連表
-- 7. 執行結帳 ( UPDLOCK 防止超賣)
EXEC usp_Checkout @MemberID = 1, @ShippingAddress = N'台中歌劇院';

-- 8. 確認商品庫存有順利扣除
SELECT * FROM Products;

-- 9. 調出剛剛結帳的 1號訂單 完整明細 (JOIN 關聯展示)
EXEC usp_GetOrderInvoice @OrderID = 1;

-- 10. 購物車清空
EXEC usp_ClearCart @MemberID = 1; -- 等測試

-- 報告：營運進階功能
-- 10. 會員取消訂單 (展示交易退回與庫存回補)
EXEC usp_CancelOrder @OrderID = 1, @MemberID = 1;

-- 11. 老闆想看的最熱銷排行榜 (展示 GROUP BY 與彙總)
EXEC usp_GetTopSales;



-- -- === 一、註冊：呼叫註冊程式 -> 添加會員 1 號 ===
-- EXEC usp_CreateMember @Email='me@test.com', @Password='1234', @Name='我';
-- SELECT * FROM Members; -- 檢查
-- SELECT * FROM Cart; 


-- -- === 二、加入購物車 ===
-- -- 測試：會員 1 號，把商品 1 號，放 5 個進去。
-- EXEC usp_AddToCart @MemberID = 1, @ProductID = 1, @Quantity = 5;
-- SELECT * FROM CartItems; -- 檢查 -> CartItems 表多了一筆資料，數量是 5


-- -- === 補充示範：會員登入 (usp_LoginMember) ===

-- -- 測試 A：輸入正確的帳號密碼 -> 登入成功
-- -- 預期結果：回傳 Result = 1 -> 帶出會員的基礎資料與他的專屬 CartID
-- EXEC usp_LoginMember @Email='me@test.com', @Password='1234';

-- -- 測試 B：密碼輸入錯誤 (展示資安防護) -> 登入失敗
-- -- 預期結果：回傳 Result = 0。不會告訴使用者是帳號錯還是密碼錯，統一顯示「帳號或密碼錯誤」。
-- EXEC usp_LoginMember @Email='Reporter@test.com', @Password='99999';

-- -- =============================================

-- -- === 三、結帳 ===
-- -- 1. 會員 1 號結帳，送到指定地點。
-- EXEC usp_Checkout @MemberID = 1, @ShippingAddress = N'台中歌劇院';
-- SELECT * FROM Orders; -- 1. 訂單產生 -> Status 是 '待付款'

-- -- 2026 / 2 / 18 -> 修正舊資料：把所有 'Paid' 的都改成 '待付款'
-- UPDATE Orders
-- SET Status = N'待付款'
-- WHERE Status = 'Paid';
-- GO

-- -- 2. Get 訂單明細：裡面記買了商品 1 號
-- SELECT * FROM OrderDetails;
-- SELECT * FROM Orders -- WHERE 


-- -- 3. 購物車清空了：CartItems 應該要是空的 or 這筆被刪掉了
-- SELECT * FROM CartItems;

-- -- 4. 庫存減少了：原本 INSERT 是 10，現在應該剩 5 ( 2/18 進貨 10包 -> 10 - 5)
-- SELECT * FROM Products;


-- USE [Velocity];
-- GO

-- -- 查出訂單明細，並帶出是誰買的。
-- SELECT 
--     OD.OrderDetailID,      -- 明細流水號
--     O.OrderID,             -- 訂單編號
--     M.MemberID AS 會員ID,  -- 我們需要的欄位
--     M.Name AS 會員姓名,     -- 從 Members 表牽過來的名字
--     P.Name AS 商品名稱,     -- 從 Products 表牽過來的商品名
--     OD.Quantity,           -- 數量
--     OD.UnitPrice           -- 單價
-- FROM OrderDetails OD
-- JOIN Orders O ON OD.OrderID = O.OrderID      -- 牽主表
-- JOIN Members M ON O.MemberID = M.MemberID    -- 再透過主表牽起會員
-- JOIN Products P ON OD.ProductID = P.ProductID; -- 順便牽起商品








-- -- === 明天報告示範用 === --
-- -- === 一、註冊：呼叫註冊程式 -> 添加會員 1 號 ===
-- EXEC usp_CreateMember @Email='Reporter@test.com', @Password='12345', @Name='Reporter';
-- SELECT * FROM Members; -- 檢查會員是否建立
-- SELECT * FROM Cart;    -- 檢查車子是否建立


-- -- === 二、加入購物車 ===
-- -- 測試：會員 2 號，把商品 2 號，放 5 個進去。
-- EXEC usp_AddToCart @MemberID = 2, @ProductID = 2, @Quantity = 5;
-- SELECT * FROM CartItems; -- 檢查 -> CartItems 表多了一筆資料，數量是 5


-- USE [Velocity];
-- GO

-- -- === 擴充示範：單獨刪除購物車內的商品 ===
-- -- 假設會員 1 號剛剛加了 商品 1 號 跟 商品 2 號。
-- -- 現在他反悔了，想把「商品 2 號」從購物車拿出來：
-- EXEC usp_RemoveFromCart @MemberID = 1, @ProductID = 2;

-- -- 檢查結果：再次呼叫 MOMO 購物車，看看商品 2 號是不是消失了，總金額有沒有重算。
-- EXEC usp_GetCartDetails @MemberID = 1;


-- -- === 三、結帳 ===
-- -- 1. 會員 1 號結帳，送到指定地點。
-- EXEC usp_Checkout @MemberID = 2, @ShippingAddress = N'台中公園';
-- SELECT * FROM Orders; -- 1. 訂單產生 -> Status 是 '待付款'

-- -- 2026 / 2 / 18 -> 修正舊資料：把所有 'Paid' 的都改成 '待付款'
-- UPDATE Orders
-- SET Status = N'待付款'
-- WHERE Status = 'Paid';
-- GO

-- -- 2. Get 訂單明細：裡面記買了商品 2 號
-- SELECT * FROM OrderDetails;

-- -- 3. 購物車清空了：CartItems 應該要是空的 or 這筆被刪掉了
-- SELECT * FROM CartItems;

-- -- 4. 庫存減少了：原本 INSERT 是 10，現在應該剩 5 ( 2/24 進貨 10包 -> 10 - 5)
-- SELECT * FROM Products;

-- USE [Velocity];
-- GO

-- -- 假設會員 1 號不想買了，按下清空按鈕：
-- EXEC usp_ClearCart @MemberID = 1;

-- -- 檢查：購物車明細清空
-- SELECT * FROM CartItems;

-- EXEC

-- USE [Velocity];
-- GO

-- -- === 擴充示範：檢查會員狀態 (usp_CheckMemberStatus) ===

-- -- 測試 1：檢查一個存在的帳號 (假設我有建這個 me@test.com)
-- -- 預期結果：會算出這個會員加入 Velocity 幾天了
-- EXEC usp_CheckMemberStatus @Email = N'me@test.com';


-- -- 測試 2：檢查一個不存在的帳號
-- -- 預期結果：回傳 Result = 0，告訴我找不到該帳號。
-- EXEC usp_CheckMemberStatus @Email = N'nobody@test.com';


-- USE [Velocity];
-- GO

-- -- 1. 先讓會員 1 號加點東西進購物車
-- EXEC usp_AddToCart @MemberID = 1, @ProductID = 1, @Quantity = 2;
-- EXEC usp_AddToCart @MemberID = 1, @ProductID = 2, @Quantity = 1;

-- -- 2. 呼叫組員想看的購物車內容！
-- EXEC usp_GetCartDetails @MemberID = 1;

-- USE [Velocity];
-- GO

-- -- === 擴充示範：查看歷史訂單與寄送地址 ===
-- -- 假設剛剛結帳完，產生了第 1 號訂單 (@OrderID = 1)
-- -- 現在要調出這筆訂單的詳細發票資訊：
-- EXEC usp_GetOrderInvoice @OrderID = 1;