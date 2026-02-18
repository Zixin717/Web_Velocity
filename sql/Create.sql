-- USE [master];  -- 切換到系統資料庫 -> 避免鎖住
-- GO

-- -- 1. 如果資料庫存在，就把它刪掉 (DROP) -> 已執行 2026 / 2 / 17 （勿動）
-- IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Velocity')
-- BEGIN
--     --這行是用來強制踢掉連線中的人，確保可以刪除
--     ALTER DATABASE [Velocity] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--     DROP DATABASE [Velocity];
-- END
-- GO

-- -- 2. 重新建立乾淨的資料庫 -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE DATABASE [Velocity];
-- GO


-- USE [Velocity];
-- GO

-- -- 1. 會員表 -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE [Members]
-- (
--     [MemberID] INT PRIMARY KEY IDENTITY(1,1),
--     [Email] NVARCHAR(100) NOT NULL UNIQUE,
--     [Password] NVARCHAR(255) NOT NULL,
--     [Name] NVARCHAR(50) NOT NULL,
--     [Address] NVARCHAR(200),
--     [Phone] VARCHAR(20),
--     [CreatedAt] DATETIME DEFAULT GETDATE() -- 創建時間 -> 備著用
-- );
-- GO

-- -- 2. 商品表 -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE [Products]
-- (
--     [ProductID] INT PRIMARY KEY IDENTITY(1,1),
--     [Name] NVARCHAR(100) NOT NULL,
--     [Price] INT NOT NULL,
--     [Stock] INT NOT NULL DEFAULT 0,
--     [Description] NVARCHAR(MAX),
--     [ImageURL] NVARCHAR(500),
--     [Flavor] NVARCHAR(50)
-- );
-- GO

-- -- 3. 購物車表 (Cart) -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE Cart
-- (
--     [CartID] INT PRIMARY KEY IDENTITY(1,1),
--     [MemberID] INT NOT NULL UNIQUE,
--     [UpdatedAt] DATETIME DEFAULT GETDATE(),
--     CONSTRAINT FK_Cart_Member FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
-- );
-- GO

-- -- 4. 購物車明細 (CartItems) -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE CartItems
-- (
--     [CartItemID] INT PRIMARY KEY IDENTITY(1,1), -- 不確定這一欄的意思？
--     [CartID] INT NOT NULL, -- 連接外鍵
--     [ProductID] INT NOT NULL, -- 商品 ID 能理解
--     [Quantity] INT NOT NULL CHECK (Quantity > 0), -- 數量不能小於零勉強能理解，因為前面拉出購物車了所以這邊有條件。
--     [AddedDate] DATETIME DEFAULT GETDATE(), -- 添加時間 -> 可以讓用戶依照添加時間檢視
--     CONSTRAINT FK_CartItems_Cart FOREIGN KEY (CartID) REFERENCES Cart(CartID), -- FK 能理解
--     CONSTRAINT FK_CartItems_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID) -- FK 能理解
-- );
-- GO

-- -- 5. 訂單主表 -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE [Orders]
-- (
--     [OrderID] INT PRIMARY KEY IDENTITY(1,1),
--     [MemberID] INT NOT NULL,
--     [OrderDate] DATETIME DEFAULT GETDATE(),
--     [TotalAmount] INT NOT NULL,
--     [Status] NVARCHAR(20) DEFAULT N'待付款',
--     [ShippingAddress] NVARCHAR(200) NOT NULL,
--     CONSTRAINT FK_Orders_Member FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
-- );
-- GO

-- -- 6. 訂單明細表 -> 已執行 2026 / 2 / 17 （勿動）
-- CREATE TABLE [OrderDetails]
-- (
--     [OrderDetailID] INT PRIMARY KEY IDENTITY(1,1),
--     [OrderID] INT NOT NULL,
--     [ProductID] INT NOT NULL,
--     [Quantity] INT NOT NULL,
--     [UnitPrice] INT NOT NULL,
--     CONSTRAINT FK_Details_Order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
--     CONSTRAINT FK_Details_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
-- );
-- GO










-- 一、資料庫 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE DATABASE [Velocity];
-- GO

-- -- 二、建立表 -> 把建立資料庫的指令註解掉後，再執行這個。
-- --              一張一張表建比較保險，之前同時間一起建，卡 bug 很難發現哪個欄位出錯QQ

-- 1. 會員表 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE [Members](
--     [MemberID] INT PRIMARY KEY IDENTITY(1,1), -- 會員 ID -> PK鍵
--     [Email] NVARCHAR(100) NOT NULL UNIQUE,    -- Email   -> 不能重複
--     [Password] NVARCHAR(100) NOT NULL,        -- 密碼    -> 記得之後後端要加密
--     [MemberName] NVARCHAR(50) NOT NULL,       -- Name    -> 名字
--     [Address] NVARCHAR(200),                  -- 地址     -> Address
--     [Phone] VARCHAR(20)                       -- Phone    -> 電話
-- );
-- GO

-- 已執行 2026 / 2 / 16 （勿動）
-- ALTER TABLE [Members]
-- ALTER COLUMN [Password] NVARCHAR(200) NOT NULL; -- 修改 Members 表中的 Password 欄位，長度改為 200
-- GO

-- 2. 商品表 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE [Products](
--     [ProductID] INT PRIMARY KEY IDENTITY(1,1), -- 商品 ID  -> PK 鍵
--     [ProductName] NVARCHAR(100) NOT NULL,      -- 商品名稱 -> 不能為空
--     [Price] INT NOT NULL,                      -- 價格     -> 整數 不能為空
--     [Stock] INT NOT NULL DEFAULT 0,            -- 庫存     -> 整數 不能為空 預設為零
--     [Description] NVARCHAR(MAX),               -- 描述     -> MAX 可以存很長的文章
--     [ImageURL] NVARCHAR(200),                  -- 圖片網址
--     [Flavor] NVARCHAR(50)                      -- 口味
-- );
-- GO

-- 3. 我的最愛 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE [Wishlist](
--     [WishlistID] INT PRIMARY KEY IDENTITY(1,1), -- 流水號
--     [MemberID] INT NOT NULL, -- 修正點：必須先宣告欄位，才能設外鍵。
--     [ProductID] INT NOT NULL,
--     FOREIGN KEY (MemberID) REFERENCES Members(MemberID), 
--     FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
-- );
-- GO

-- -- 4. 購物車 -> 中繼站 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE [ShoppingCart](
--     [CartID] INT PRIMARY KEY IDENTITY(1,1), -- 購物車流水號 -> PK 鍵
--     [MemberID] INT NOT NULL, -- 先設定欄位再連接 FK
--     [ProductID] INT NOT NULL, -- 補上欄位
--     [Count] INT DEFAULT 1, -- 數量 -> 要先設 1，不然後面結帳 Null * Null 會爆炸。
--     FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
--     FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
-- );
-- GO

-- -- 5. 訂單主表 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE [Orders] (
--     [OrderID] INT PRIMARY KEY IDENTITY(1,1), -- 訂單編號 -> PK 鍵
--     [MemberID] INT NOT NULL, -- 補上欄位 -> 給 MemberID 外來鍵
--     [OrderDate] DATETIME DEFAULT GETDATE(), -- 下單時間
--     [TotalAmount] INT NOT NULL, -- 總金額 -> 不能留空
--     [Status] NVARCHAR(20) DEFAULT '待付款', -- 狀態 -> 預設待付款
--     [TransmitAddress] NVARCHAR(100) NOT NULL, -- 寄送地址 -> 不能為空
--     FOREIGN KEY (MemberID) REFERENCES Members(MemberID) -- 外來鍵
-- );
-- GO

-- -- 6. 訂單明細表 -> 已執行 2026 / 2 / 14 （勿動）
-- CREATE TABLE OrderDetails (
--     [Id] INT PRIMARY KEY IDENTITY(1,1), -- 訂單流水號 -> PK
--     [OrderID] INT NOT NULL,
--     [ProductID] INT NOT NULL,
--     [Quantity] INT NOT NULL,  -- 數量 -> 不能為空
--     [UnitPrice] INT NOT NULL, -- 當下價格 - 不能為空
--     FOREIGN KEY (OrderID) REFERENCES Orders(OrderID), -- 紅字 -> 等待建表
--     FOREIGN KEY (ProductID) REFERENCES Products(ProductID), -- 紅字 -> 等待建表
-- );
-- GO