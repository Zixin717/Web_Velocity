USE [Velocity];
GO

-- 1. 註冊會員 (usp_CreateMember) -> 已執行 2026 / 2 / 17
--    邏輯：先檢查 Email -> 新增會員 -> 順便送他一台購物車 (Cart)。
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateMember')
    DROP PROCEDURE usp_CreateMember;
GO

CREATE PROCEDURE usp_CreateMember
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @Name NVARCHAR(50),
    @Address NVARCHAR(200) = NULL,
    @Phone VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. 檢查 Email 是否重複 (防呆)
    IF EXISTS (SELECT 1 FROM Members WHERE Email = @Email)
    BEGIN
        -- 回傳 -1 代表失敗，前端 JS 接到 -1 就跳出「帳號已存在」
        SELECT -1 AS Result, N'錯誤：該 Email 已被註冊。' AS Message;
        RETURN;
    END

    -- 2. 開啟交易模式 -> 要嘛全成功，要嘛全失敗
    BEGIN TRANSACTION;
    BEGIN TRY -- 嘗試區 start -> 執行這個
        -- A. 新增會員資料
        INSERT INTO Members (Email, Password, Name, Address, Phone)
        VALUES (@Email, @Password, @Name, @Address, @Phone);

        -- B. 抓取剛剛產生的新會員 ID (SCOPE_IDENTITY)
        DECLARE @NewMemberID INT = SCOPE_IDENTITY();

        -- C. 自動為新會員建立一台購物車 (Cart)
        -- 這樣以後只要找 MemberID 對應的 CartID 就可以，不用每次都判斷有沒有車。
        INSERT INTO Cart (MemberID) VALUES (@NewMemberID);

        -- D. 提交交易 -> 蓋章確認
        COMMIT TRANSACTION;

        -- E. 回傳成功訊息與會員資料
        SELECT 1 AS Result, N'註冊成功' AS Message, *
        FROM Members WHERE MemberID = @NewMemberID;
    END TRY -- 嘗試區 end
    BEGIN CATCH -- 捕獲區 start -> 出錯時執行這個
        -- 萬一出錯 (例如網路斷線)，全部還原
        ROLLBACK TRANSACTION;
        -- 回傳錯誤訊息
        SELECT 0 AS Result, ERROR_MESSAGE() AS Message;
    END CATCH -- 捕獲區 end
END;
GO


-- ============================================================

-- 2. 會員登入 (usp_LoginMember) -> 已修正資安問題 -> 已執行 2026 / 2 / 17
--    邏輯：檢查帳密 -> 回傳會員資料 + 購物車 ID (重要。前端要把這個 ID 存起來)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_LoginMember')
    DROP PROCEDURE usp_LoginMember;
GO

CREATE PROCEDURE usp_LoginMember
    @Email NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MemberID INT;

    -- 1. 嘗試比對帳號與密碼 (兩者都要對)
    SELECT @MemberID = MemberID
    FROM Members
    WHERE Email = @Email AND Password = @Password;

    -- 2. 判斷結果
    IF @MemberID IS NOT NULL
    BEGIN
        -- === 登入成功 ===
        -- 回傳會員資料 + 用戶的購物車 ID (CartID)
        -- LEFT JOIN 是為了保險，萬一用戶沒購物車也不會報錯 (雖然註冊時已經建了)
        SELECT 
            1 AS Result,
            M.MemberID, 
            M.Name, 
            M.Email, 
            ISNULL(C.CartID, 0) AS CartID, -- 如果沒車就回傳 0
            N'登入成功' AS Message
        FROM Members M
        LEFT JOIN Cart C ON M.MemberID = C.MemberID
        WHERE M.MemberID = @MemberID;
    END
    ELSE
    BEGIN
        -- === 登入失敗 (資安修正版) ===
        -- 統一回傳「帳號或密碼錯誤」，不讓駭客知道是哪個錯。
        -- 也不用 RAISERROR 讓程式崩潰，回傳 0 就好
        SELECT 0 AS Result, N'帳號或密碼錯誤' AS Message;
    END
END;
GO

-- ============================================================

-- 3. 加入購物車 (usp_AddToCart) -> 包含庫存檢查 -> 已執行 2026 / 2 / 17
--    邏輯：找購物車 -> 檢查庫存 -> 有就更新數量 / 沒有就新增
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AddToCart')
    DROP PROCEDURE usp_AddToCart;
GO

CREATE PROCEDURE usp_AddToCart
    @MemberID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CartID INT;

    -- 1. 取得該會員的購物車 ID
    SELECT @CartID = CartID FROM Cart WHERE MemberID = @MemberID;

    -- 2. 防超賣檢查 1 -> 檢查庫存夠不夠？
    -- 如果 (庫存量) < (想買的數量)
    IF (SELECT Stock FROM Products WHERE ProductID = @ProductID) < @Quantity
    BEGIN
        SELECT -1 AS Result, N'庫存不足，無法加入。' AS Message;
        RETURN;
    END

    -- 3. 判斷車子裡有沒有這商品？
    IF EXISTS (SELECT 1 FROM CartItems WHERE CartID = @CartID AND ProductID = @ProductID)
    BEGIN
        -- A. 已經有 -> 數量相加
        UPDATE CartItems 
        SET Quantity = Quantity + @Quantity, AddedDate = GETDATE()
        WHERE CartID = @CartID AND ProductID = @ProductID;
    END
    ELSE
    BEGIN
        -- B. 沒有 -> 新增一筆
        INSERT INTO CartItems (CartID, ProductID, Quantity)
        VALUES (@CartID, @ProductID, @Quantity);
    END

    SELECT 1 AS Result, N'加入成功' AS Message;
END;
GO

-- ============================================================

-- 4. 查看購物車 (usp_GetCartDetails) -> 已執行 2026 / 2 / 17
--    邏輯：列出車裡所有東西，並算出小計 (單價 x 數量)。
USE [Velocity];
GO

-- 4. 升級：查看購物車 (usp_GetCartDetails)
-- 修改日期：2026/02/24 -> 採用朝弼的 MOMO 風格介面與想法！
ALTER PROCEDURE usp_GetCartDetails
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- =========================================
    -- 第一部分：購物車明細清單 (對應 MOMO 每一項商品)
    -- =========================================
    SELECT 
        P.ProductID,
        P.Name AS ProductName,  -- 對應 MOMO 上的：【SAMPO 聲寶】
        P.ImageURL,             -- 對應 MOMO 上的：商品圖片
        P.Price AS UnitPrice,   -- 單價
        CI.Quantity,            -- 對應 MOMO 上的：數量 [ - 1 + ]
        (P.Price * CI.Quantity) AS SubTotal -- 對應 MOMO 上的：總計 $868
    FROM Cart C
    JOIN CartItems CI ON C.CartID = CI.CartID
    JOIN Products P ON CI.ProductID = P.ProductID
    WHERE C.MemberID = @MemberID
    ORDER BY CI.AddedDate DESC; -- 最晚加進去的放最上面

    -- =========================================
    -- 第二部分：購物車「總金額」 (對應 MOMO 準備結帳的總額)
        -- =========================================
    -- 這裡用了 ISNULL，如果購物車是空的，總金額就會顯示 0，而不會變成 NULL 報錯
    SELECT 
        ISNULL(SUM(P.Price * CI.Quantity), 0) AS TotalCartAmount
    FROM Cart C
    JOIN CartItems CI ON C.CartID = CI.CartID
    JOIN Products P ON CI.ProductID = P.ProductID
    WHERE C.MemberID = @MemberID;

END;
GO

-- ============================================================

-- 5. 移除購物車 (usp_RemoveFromCart) -> 已執行 2026 / 2 / 17
--    邏輯：把某個商品丟出車外。
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RemoveFromCart')
    DROP PROCEDURE usp_RemoveFromCart;
GO

CREATE PROCEDURE usp_RemoveFromCart
    @MemberID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CartID INT;

    -- 1. 找車
    SELECT @CartID = CartID FROM Cart WHERE MemberID = @MemberID;

    -- 2. 刪除
    DELETE FROM CartItems 
    WHERE CartID = @CartID AND ProductID = @ProductID;

    SELECT 1 AS Result, N'移除成功' AS Message;
END;
GO

-- ============================================================


USE [Velocity];
GO


-- 6. 結帳 (usp_Checkout) -> 交易 + 扣庫存 -> 已執行 2026 / 2 / 17
--    邏輯：檢查庫存 -> 算總錢 -> 建訂單 -> 搬明細 -> 扣庫存 -> 清空車
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_Checkout')
    DROP PROCEDURE usp_Checkout;
GO

CREATE PROCEDURE usp_Checkout -- 編輯 2026 / 2 / 23 -> 回家記得改成 ALTER 重新執行一遍
    @MemberID INT,
    @ShippingAddress NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CartID INT;
    DECLARE @TotalAmount INT = 0;
    DECLARE @NewOrderID INT;

    -- 1. 找車
    SELECT @CartID = CartID FROM Cart WHERE MemberID = @MemberID;

    -- 2. 車是空的 -> 不結帳
    IF NOT EXISTS (SELECT 1 FROM CartItems WHERE CartID = @CartID)
    BEGIN
        SELECT -1 AS Result, N'購物車是空的哦，快去挑選喜歡的商品吧！' AS Message;
        RETURN;
    END

    -- 3. 開啟交易 (保護網)
    BEGIN TRANSACTION;
    BEGIN TRY
        -- A. 防超賣檢查 2 -> 再次檢查所有商品庫存
        -- (防止有人放入購物車很久沒結帳，結果被別人買光了)

        -- ==========================================
        -- ！重要！ 加入老師的 WITH (UPDLOCK)
        -- ==========================================
        IF EXISTS (
            SELECT 1 
            FROM CartItems CI 
            JOIN Products P 
            WITH (UPDLOCK) ON CI.ProductID = P.ProductID -- 在 Products 後面加上 WITH (UPDLOCK)，鎖住這些商品不讓別人同時買。
            WHERE CI.CartID = @CartID AND P.Stock < CI.Quantity
        )
        BEGIN
            -- 發現有商品庫存不足，立刻取消交易
            ROLLBACK TRANSACTION;
            SELECT -2 AS Result, N'部分商品庫存不足' AS Message;
            RETURN;
        END

        -- B. 計算總金額
        SELECT @TotalAmount = SUM(P.Price * CI.Quantity)
        FROM CartItems CI
        JOIN Products P ON CI.ProductID = P.ProductID
        WHERE CI.CartID = @CartID;

        -- C. 建立訂單 (Status = '代付款')
        INSERT INTO Orders (MemberID, OrderDate, TotalAmount, Status, ShippingAddress)
        VALUES (@MemberID, GETDATE(), @TotalAmount, N'待付款', @ShippingAddress);

        -- 取得剛產生的訂單編號
        SET @NewOrderID = SCOPE_IDENTITY();

        -- D. 搬運明細 (CartItems -> OrderDetails)
        -- 這裡會把當下的 Price 存進 UnitPrice，這是正確的做法 (紀錄歷史價格)
        INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @NewOrderID, CI.ProductID, CI.Quantity, P.Price
        FROM CartItems CI
        JOIN Products P ON CI.ProductID = P.ProductID
        WHERE CI.CartID = @CartID;

        -- E. 扣庫存 (最重要的一步)
        UPDATE P
        SET P.Stock = P.Stock - CI.Quantity
        FROM Products P
        JOIN CartItems CI ON P.ProductID = CI.ProductID
        WHERE CI.CartID = @CartID;

        -- F. 清空購物車
        DELETE FROM CartItems WHERE CartID = @CartID;

        -- 全部成功，提交！
        COMMIT TRANSACTION;
        SELECT 1 AS Result, @NewOrderID AS OrderID, N'結帳成功' AS Message;

    END TRY
    BEGIN CATCH
        -- 出錯就還原
        ROLLBACK TRANSACTION;
        SELECT 0 AS Result, ERROR_MESSAGE() AS Message;
    END CATCH
END;
GO



-- ============================================================

-- 7. 查詢訂單 (usp_GetOrderInvoice) -> 已執行 2026 / 2 / 17
--    這個是用來讓使用者結帳後，或是去「歷史訂單」頁面看明細用的。
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_GetOrderInvoice')
    DROP PROCEDURE usp_GetOrderInvoice;
GO

CREATE PROCEDURE usp_GetOrderInvoice
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. 查訂單的來源 -> 誰買的？多少錢？寄去哪？
    SELECT O.*, M.Name AS MemberName
    FROM Orders O
    JOIN Members M ON O.MemberID = M.MemberID
    WHERE O.OrderID = @OrderID;

    -- 2. 查訂單的詳細 -> 買了什麼？
    SELECT 
        P.Name AS ProductName, 
        OD.Quantity, 
        OD.UnitPrice, 
        (OD.Quantity * OD.UnitPrice) AS SubTotal
    FROM OrderDetails OD
    JOIN Products P ON OD.ProductID = P.ProductID
    WHERE OD.OrderID = @OrderID;
END;
GO

USE [Velocity];
GO


-- ============================================================
-- 8. 清空整個購物車 (usp_ClearCart) -> 明天記得在電腦上執行
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ClearCart')
    DROP PROCEDURE usp_ClearCart;
GO

CREATE PROCEDURE usp_ClearCart
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CartID INT;

    -- 1. 找到這位會員的購物車編號
    SELECT @CartID = CartID FROM Cart WHERE MemberID = @MemberID;

    -- 2. 把這台購物車裡面的所有商品 (CartItems) 刪除
    -- 重點：只刪除 CartItems (商品明細)，不刪除 Cart (推車本身)，推車要留著。
    DELETE FROM CartItems WHERE CartID = @CartID;

    -- 3. 回傳成功訊息給前端
    SELECT 1 AS Result, N'購物車已全部清空' AS Message;
END;
GO

USE [Velocity];
GO

-- 9. 檢查會員狀態 (usp_CheckMemberStatus)
-- 邏輯：檢查信箱是否存在，存在就秀出會員資料與「加入天數」，不存在就報錯。
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CheckMemberStatus')
    DROP PROCEDURE usp_CheckMemberStatus;
GO

CREATE PROCEDURE usp_CheckMemberStatus
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Members WHERE Email = @Email)
    BEGIN
        -- 情況 A：帳號存在 -> 回傳 1，並秀出年資
        SELECT 
            1 AS Result,
            MemberID,
            Name,
            Email,
            CreatedAt,
            DATEDIFF(DAY, CreatedAt, GETDATE()) AS MemberDays, -- 這裡用了朝弼原本的邏輯：計算加入天數！
            N'帳號存在' AS Message
        FROM Members
        WHERE Email = @Email;
    END
    ELSE
    BEGIN
        -- 情況 B：帳號不存在 -> 回傳 0
        SELECT 
            0 AS Result, 
            N'找不到該帳號：' + @Email AS Message;
    END
END;
GO