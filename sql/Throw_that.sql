-- USE Velocity;
-- GO

-- -- 1. 會員註冊 (sp_Register)
-- CREATE PROCEDURE sp_Register           -- 創建預程式 -> sp_Register
--     @Email NVARCHAR(100),              -- 設置變數 Email -> 要加型態
--     @Password NVARCHAR(200),           -- 設置變數 Password
--     @MemberName NVARCHAR(50),          -- 設置變數 用戶名
--     @Address NVARCHAR(200) = NULL,     -- 設置變數 地址
--     @Phone VARCHAR(20) = NULL          -- 設置變數 電話號碼
-- AS
-- BEGIN -- 註冊程序 start
--     SET NOCOUNT ON; -- 不回報「影響 n 行」的訊息讓前端乾淨點（不確定畫面呈現如何）

--     -- 1. 情況一：帳號存在
--     --           檢查帳號是否存在
--     IF EXISTS(SELECT 1 FROM Members WHERE [Email]=@Email) -- 如果存在(1)就運行 -> 選 1 從 Members 表單的 Email=@Email
--     BEGIN
--         -- 如果有，回傳 -1 代表失敗( E-mail 重複 )
--         SELECT -1 AS Result, 'Email 已註冊' AS MESSAGE; 
--         -- SELECT -1 AS Result -> 欄位名稱變成 Result
--         -- 之後前端可以寫 if (data.Result == -1)，清楚又好用
--         RETURN;
--     END
    
--     -- 2. 情況二：帳號不存在，可新增會員。
--     BEGIN TRANSACTION; -- 融合組員的 Transaction 寫法
--     BEGIN TRY -- 新增會員 -> 嘗試區 start
--         INSERT INTO Members([Email], [Password], [MemberName], [Address], [Phone])
--         VALUES (@Email, @Password, @MemberName, @Address, @Phone);

--         -- 不建立 Cart 直接讓它成功
--         COMMIT TRANSACTION; -- 提交這筆交易
--         -- 回傳 1 代表成功 -> 收尾
--         SELECT 1 AS Result, '註冊成功' AS MESSAGE; -- 前端可以寫 if (data.Result == -1)
--     END TRY -- 新增會員 -> 嘗試區 end
--     BEGIN CATCH -- 註冊失敗 -> 捕獲區 start
--         ROLLBACK TRANSACTION;
--         SELECT 0 AS RESULT, ERROR_MESSAGE() AS MESSAGE;
--     END CATCH -- 註冊失敗 -> 捕獲區 end 
-- END -- 註冊程序 end
-- GO


-- -- 2. 會員登入 (sp_Login)
-- CREATE PROCEDURE sp_Login    -- 創建預程式 -> sp_Login
--     @Email NVARCHAR(100),    -- 設置變數 Email   -> 要加型態
--     @Password NVARCHAR(200)  -- 設置變數 Password
-- AS
-- BEGIN -- 登入程序 start
--     SET NOCOUNT ON; -- 不回報「影響 n 行」的訊息讓前端乾淨點（不確定畫面呈現如何）

--     -- 宣告變數存會員 ID
--     DECLARE @MemberID INT;

--     -- 1. 先找會員 -> 確認帳密都對
--     SELECT @MemberID = [MemberID] -- 請資料庫拿出 [MemberID] 的欄位，並讓它等於 @MemberID。
--     FROM Members -- 告訴資料庫我要調取的資料來自 Members 這張表
--     WHERE [Email] = @Email AND [Password] = @Password; -- 告訴資料庫篩選條件，選擇該會員。

--     -- 2. 判斷
--     IF @MemberID IS NOT NULL
--     BEGIN
--         -- 成功
--         -- 回傳 1 順便去 ShoppingCart 表把 CartID 抓出來 (Left Join)
--         SELECT -- 如果有這個 @MemberID，請資料庫調出 1 與後面的結果（欄位）。
--             1 AS RESULT,
--             M.MemberID, -- Members 的 MemberID
--             M.MemberName,
--             M.Address,
--             M.Phone,
--             ISNULL(C.CartID, 0) AS CartID, -- 如果沒有購物車就回傳 0
--             '登入成功' AS MESSAGE
--         FROM Members M -- 來源於 Members 這張表，並取名為 M。
--         LEFT JOIN ShoppingCart C ON M.MemberID = C.MemberID
--         -- 插入 ShoppingCart 這張表，並取名叫 C。同時間同步會員表跟購物車的會員ID。
--         WHERE M.MemberID = @MemberID;  -- 篩選條件為 會員表的 ID，要等於變數 @MemberID。
--     END
--     ELSE
--     BEGIN
--         -- 失敗
--         -- 修正點：為了資安，不告訴他是帳號錯還是密碼錯，統一說失敗。
--         -- 也不用 RAISERROR，直接回傳 0 讓前端判斷就好
--         SELECT 
--             0 AS RESULT, 
--             '帳號或密碼錯誤' AS Message;
--     END

-- END -- 登入程序 end
-- GO

-- -- 3. 加入購物車 (sp_AddToCart)
-- CREATE PROCEDURE sp_AddToCart -- 創建預程式 -> sp_AddToCart
--     @MemberID INT,  -- 設置變數 會員ID
--     @ProductID INT, -- 設置變數 商品ID
--     @Count INT      -- 設置變數 數量
-- AS
-- BEGIN -- 加入購物車 start
--     SET NOCOUNT ON;
--     -- 1. 檢查用戶是否將商品放進購物車？
--     IF EXISTS (SELECT 1 FROM ShoppingCart WHERE MemberID = @MemberID AND ProductID = @ProductID)
--     BEGIN
--         -- 情況 A：已經有了 -> 更新數量( 原本的 + 新加的 )
--         UPDATE ShoppingCart
--         SET [Count] = [Count] + @Count
--         WHERE MemberID = @MemberID AND ProductID = @ProductID;
--     END
--     ELSE
--     BEGIN
--         -- 情況 B：還沒有 -> 新增一筆
--         INSERT INTO ShoppingCart(MemberID, ProductID, [Count])
--         VALUES(@MemberID, @ProductID, @Count);
--     END

--     SELECT 1 AS RESULT; -- 告訴前端成功了
-- END -- 加入購物車 end
-- GO


-- -- 4. 移除購物車 (sp_RemoveFromCart)
-- CREATE PROCEDURE sp_RemoveFromCart
--     @MemberID INT,
--     @ProductID INT
-- AS
-- BEGIN -- 移除購物車 start
--     SET NOCOUNT ON;

--     DELETE FROM ShoppingCart
--     WHERE MemberID=@MemberID AND ProductID=@ProductID -- 其實有點好奇為什麼要加 Member？刪掉商品就好了吧？還是計算機執行指令時不加 Member，會刪掉所有用戶的購物車？:O

--     SELECT 1 AS RESULT; -- 傳回 1 給前端代表成功 -> 之後應該會寫？寫在 JS 嗎？還是寫在後端？需要關聯圖QQ
-- END -- 移除購物車 end
-- GO

-- -- 5. 結帳 (sp_Checkout)
-- CREATE PROCEDURE sp_Checkout -- 創建預程式 -> sp_Checkout
--     @MemberID INT,
--     @TransmitAddress NVARCHAR(200) -- 允許使用者結帳時修改地址
-- AS
-- BEGIN -- 結帳 start
--     SET NOCOUNT ON;

--     -- 開始交易模式 -> 開啟保護網：像是按下「錄影鍵」，接下來的一連串動作，要嘛全部成功，要嘛全部不算數。
--     BEGIN TRANSACTION;

--     BEGIN TRY -- 嘗試區 -> 試著做這些事
--         -- 第一步：計算購物車總金額
--         DECLARE @TotalAmount INT; -- 宣告變數 @TotalAmount 整形

--         SELECT @TotalAmount = SUM(p.Price*c.Count)
--         -- p.Price = Products.Price (商品的價格)
--         -- c.Count = ShoppingCart.Count (購物車的數量)
--         FROM ShoppingCart c JOIN Products p -- 翻譯：從現在開始，ShoppingCart 簡稱為 c，Products 簡稱為 p。
--         ON c.ProductID = p.ProductID -- ShoppingCart.ProductID = Products.ProductID
--         WHERE c.MemberID = @MemberID; -- ShoppingCart.MemberID = @MemberID

--         -- 如果購物車是空的就取消交易
--         IF @TotalAmount IS NULL
--         BEGIN
--             ROLLBACK TRANSACTION;
--             SELECT -1 AS RESULT, '購物車為空' AS MESSAGE;
--             RETURN; -- 回傳，不過為什麼其它地方都沒有回傳指令？什麼場合需要呢？
--         END

--         -- 第二步：建立訂單主檔
--         INSERT INTO Orders (MemberID, OrderDate, TotalAmount, [Status], TransmitAddress)
--         VALUES (@MemberID, GETDATE(), @TotalAmount, 'Paid', @TransmitAddress);

--         -- 取得剛剛那張新訂單的 ID (SCOPE_IDENTITY)
--         DECLARE @NewOrderID INT = SCOPE_IDENTITY();
--         -- SCOPE_IDENTITY() 功能： 取得「剛剛那張身分證號碼」。
--         -- 當 INSERT INTO Orders 時，OrderID 是自動產生的 (Identity 1, 2, 3...)。
--         -- 這行指令會告訴我 -> 剛產生的號碼是 105 號
--         -- 這樣我下一秒要把商品加入 OrderDetails 時，才知道要填哪張訂單號碼 (105)。

--         -- 第三步：把購物車的東西搬到訂單明細
--         -- 這裡用 INSERT INTO ... SELECT 語法，一次搬運多筆資料提升效率。
--         INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) -- 訂單ID, 商品ID, 數量, 商品單價
--         SELECT @NewOrderID, c.ProductID, c.Count, p.Price -- 抓取欄位 -> 訂單流水號, 購物車的商品ID, 購物車數量, 商品的價格
--         FROM ShoppingCart c JOIN Products p -- 從現在起(FROM) ShoppingCart = c 加上(JOIN) Products = p
--         ON c.ProductID = p.ProductID -- 然後(ON) ShoppingCart 的 ProductID = Products 的 ProductID
--         WHERE c.MemberID = @MemberID;-- 目標位置(WHERE) -> ShoppingCart 的 MemberID = @MemberID

--         -- 第四步：扣庫存 (不能做完就先放著)
--         -- 依照購買數量扣除商品庫存
--         UPDATE Products
--         SET Stock = Stock - c.Count
--         FROM Products p
--         JOIN ShoppingCart c ON p.ProductID = c.ProductID
--         WHERE c.MemberID = @MemberID;

--         -- 第五步：清空這位會員的購物車
--         DELETE FROM ShoppingCart WHERE MemberID = @MemberID;

--         -- 如果上面全部都沒報錯就正式提交
--         COMMIT TRANSACTION;
        
--         -- 回傳新訂單編號，顯示成功
--         SELECT 1 AS Result, @NewOrderID AS OrderID;
--     END TRY
--     BEGIN CATCH -- 捕獲區 -> 如果上面出錯了，就跳來這裡。
--         -- 萬一中間有任何錯誤，全部還原 (時光倒流)，當作沒發生過
--         ROLLBACK TRANSACTION; -- -> 倒帶： 如果出錯，按下「倒帶鍵」，把剛剛刪掉的、新增的資料全部恢復原狀，當作沒發生過。
--         SELECT 0 AS Result, ERROR_MESSAGE() AS ErrorMsg; -- ERROR_MESSAGE()是函式嗎？ErrorMsg 是變數……？
--     END CATCH
-- END -- 結帳 end
-- GO
