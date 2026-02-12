-- 登入：儲存用戶資料
    -- ID
    -- Password

-- 商品：儲存商品資料
    -- 商品名稱
    -- 商品圖片
    -- 商品價格
    -- 商品庫存
    -- 商品描述
    -- 商品口味
    
-- 會員資料
    -- 姓名
    -- 地址
    -- 電話號碼
    -- 電子信箱
--訂單管理
    --訂單Id
    --訂購時間
    --訂購商品
    --商品數量
    --總金額


-- 未執行( ！請勿按下執行！ )
-- 1. 建立會員表
CREATE TABLE Members(
    MemberID INT PRIMARY KEY IDENTITY(1,1), -- 會員 ID -> PK鍵
    Email NVARCHAR(100) NOT NULL UNIQUE,    -- Email   -> 不能重複
    Password NVARCHAR(100) NOT NULL,        -- 密碼    -> 記得之後後端要加密
    Name NVARCHAR(50) NOT NULL,             -- Name    -> 名字
    Address NVARCHAR(200),                  -- 地址     -> Address
    Phone VARCHAR(20)                       -- Phone    -> 電話
);

-- 2. 建立商品表
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1), -- 商品 ID -> PK 鍵
    Name NVARCHAR(100) NOT NULL,             -- 
    Price INT NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    Description NVARCHAR(MAX), -- MAX 可以存很長的文章
    ImageURL NVARCHAR(200),
    Flavor NVARCHAR(50)
);

-- 3. 建立訂單主表
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT NOT NULL, -- 這裡應該要設 Foreign Key，但 MVP 先求有
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount INT NOT NULL,
    Status NVARCHAR(20) DEFAULT '待付款'
);

-- 4. 建立訂單明細表
CREATE TABLE OrderDetails (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice INT NOT NULL
);
