USE [Velocity];
GO

-- 添加商品測試
INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'原味口味高蛋白粉', 2999, 10, N'測試：此為文字描述', N'暫無圖檔', N'原味口味');
GO

INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'草莓口味高蛋白粉', 2999, 10, N'測試：此為文字描述', N'暫無圖檔', N'草莓口味');
GO

INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'焦糖咖啡口味高蛋白粉', 2999, 5, N'測試：此為文字描述', N'暫無圖檔', N'焦糖咖啡口味');
GO 

INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'香草口味高蛋白粉', 2999, 10, N'測試：此為文字描述', N'暫無圖檔', N'香草口味');
GO -- 未執行 -> 報告測試用

INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'抹茶口味高蛋白粉', 2999, 5, N'測試：此為文字描述', N'暫無圖檔', N'抹茶口味');
GO -- 未執行 -> 報告測試用

-- 【事前準備】先上架一些 Velocity 高蛋白粉商品
INSERT INTO Products ([Name], [Price], [Stock], [Description], [ImageURL], [Flavor])
VALUES 
    (N'Velocity 香草口味高蛋白粉', 1200, 50, N'幫助肌肉修復', N'/img/p1.jpg', N'濃郁可可'),
    (N'Velocity 抹茶口味高蛋白粉', 1200, 30, N'清爽無負擔', N'/img/p2.jpg', N'靜岡抹茶'),
    (N'Velocity 草莓口味乳清蛋白', 250, 100, N'香甜草莓風味', N'/img/p3.jpg', N'無');

-- 查表
SELECT * FROM Products;