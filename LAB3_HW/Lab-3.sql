USE LAB1_HW
SET DATEFORMAT DMY
GO

-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo
FROM KyNang
INNER JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE MaChuyenGia = 1
GO

-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen
FROM ChuyenGia
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia
	FROM ChuyenGia_DuAn
	WHERE MaDuAn = 2
)
GO

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn
FROM CongTy INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GO

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(MaChuyenGia) AS SoLuongChuyenGia
FROM ChuyenGia
GROUP BY ChuyenNganh
GO

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT TOP 1 HoTen, NamKinhNghiem 
FROM ChuyenGia
ORDER BY NamKinhNghiem DESC
GO

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn_ThamGia
FROM ChuyenGia
INNER JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen
GO

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
FROM CongTy
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy
GO

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT TOP 1 TenKyNang, COUNT(ChuyenGia_KyNang.MaChuyenGia) AS SoLuongChuyenGia
FROM KyNang 
INNER JOIN ChuyenGia_KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
GROUP BY TenKyNang
ORDER BY SoLuongChuyenGia DESC
GO

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen, CapDo
FROM ChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo >= 4 AND MaKyNang IN (
	SELECT MaKyNang
	FROM KyNang
	WHERE TenKyNang = 'Python'
)
GO

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 TenDuAn, COUNT(MaChuyenGia) AS SoLuongChuyenGia
FROM DuAn
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY TenDuAn
ORDER BY SoLuongChuyenGia DESC
GO

-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
GO

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2, da.TenDuAn
FROM ChuyenGia_DuAn cgd1
INNER JOIN ChuyenGia_DuAn cgd2 ON cgd1.MaDuAn = cgd2.MaDuAn AND cgd1.MaChuyenGia < cgd2.MaChuyenGia
INNER JOIN ChuyenGia c1 ON cgd1.MaChuyenGia = c1.MaChuyenGia
INNER JOIN ChuyenGia c2 ON cgd2.MaChuyenGia = c2.MaChuyenGia
INNER JOIN DuAn da ON cgd1.MaDuAn = da.MaDuAn;
GO

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT HoTen, COUNT(MaKyNang) AS SoLuongKyNangCapDo5
FROM ChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo = 5 
GROUP BY HoTen
GO


SELECT *
FROM ChuyenGia
SELECT *
FROM ChuyenGia_DuAn
SELECT * 
FROM ChuyenGia_KyNang
SELECT *
FROM KyNang
SELECT *
FROM CongTy
SELECT *
FROM DuAn
-- 21. Tìm các công ty không có dự án nào.
SELECT TenCongTy
FROM CongTy
WHERE MaCongTy NOT IN 
(
	SELECT MaCongTy
	FROM DuAn
)
GO

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT cg.HoTen, da.TenDuAn
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cgd ON cg.MaChuyenGia = cgd.MaChuyenGia
LEFT JOIN DuAn da ON cgd.MaDuAn = da.MaDuAn;

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT cg.HoTen
FROM ChuyenGia_KyNang ck
JOIN ChuyenGia cg ON ck.MaChuyenGia = cg.MaChuyenGia
GROUP BY cg.HoTen
HAVING COUNT(ck.MaKyNang) >= 3;

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT ct.TenCongTy, SUM(cg.NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
JOIN ChuyenGia_DuAn cgd ON da.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia cg ON cgd.MaChuyenGia = cg.MaChuyenGia
GROUP BY ct.TenCongTy;


-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT cg.HoTen
FROM ChuyenGia_KyNang ck1
JOIN ChuyenGia cg ON ck1.MaChuyenGia = cg.MaChuyenGia
LEFT JOIN ChuyenGia_KyNang ck2 ON ck1.MaChuyenGia = ck2.MaChuyenGia AND ck2.MaKyNang = (
    SELECT MaKyNang 
	FROM KyNang 
	WHERE TenKyNang = 'Python'
)
WHERE ck1.MaKyNang = (
	SELECT MaKyNang 
	FROM KyNang 
	WHERE TenKyNang = 'Java'
)AND ck2.MaKyNang IS NULL;

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT TOP 1 cg.HoTen, COUNT(ck.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia_KyNang ck
JOIN ChuyenGia cg ON ck.MaChuyenGia = cg.MaChuyenGia
GROUP BY cg.HoTen
ORDER BY SoLuongKyNang DESC;


-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT c1.HoTen AS ChuyenGia1, c2.HoTen AS ChuyenGia2, c1.ChuyenNganh
FROM ChuyenGia c1
JOIN ChuyenGia c2 ON c1.ChuyenNganh = c2.ChuyenNganh AND c1.MaChuyenGia < c2.MaChuyenGia;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 ct.TenCongTy, SUM(cg.NamKinhNghiem) AS TongSoNamKinhNghiem
FROM CongTy ct
JOIN DuAn da ON ct.MaCongTy = da.MaCongTy
JOIN ChuyenGia_DuAn cgd ON da.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia cg ON cgd.MaChuyenGia = cg.MaChuyenGia
GROUP BY ct.TenCongTy
ORDER BY TongSoNamKinhNghiem DESC;


-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT k.TenKyNang
FROM KyNang k
JOIN ChuyenGia_KyNang ck ON k.MaKyNang = ck.MaKyNang
GROUP BY k.TenKyNang
HAVING COUNT(DISTINCT ck.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia);