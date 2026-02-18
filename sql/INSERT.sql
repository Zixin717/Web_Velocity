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
VALUES(N'香草高蛋白粉', 2999, 10, N'測試：此為文字描述', N'暫無圖檔', N'香草口味');
GO -- 未執行 -> 報告測試用

INSERT INTO Products ([Name], [Price], [Stock], [Description],[ImageURL],[Flavor])
VALUES(N'抹茶高蛋白粉', 2999, 5, N'測試：此為文字描述', N'暫無圖檔', N'抹茶口味');
GO -- 未執行 -> 報告測試用

-- 查表
SELECT * FROM Products;