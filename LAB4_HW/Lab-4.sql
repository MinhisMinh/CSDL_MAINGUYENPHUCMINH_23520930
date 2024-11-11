USE LAB1_HW
SET DATEFORMAT DMY
GO

-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 HoTen, COUNT(MaKyNang) AS SoLuongKiNang
FROM ChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen
ORDER BY SoLuongKiNang DESC
GO

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2
FROM ChuyenGia AS CG1
JOIN ChuyenGia AS CG2
 ON CG1.ChuyenNganh = CG2.ChuyenNganh AND CG1.NamKinhNghiem < CG2.NamKinhNghiem AND ABS(CG1.NamKinhNghiem-CG2.NamKinhNghiem) <=2
GO

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT TenCongTy, COUNT(DISTINCT DuAn.MaDuAn) AS SoLuongDuAn, SUM(NamKinhNghiem) AS TongSoNamKinhNghiemChuyenGia
FROM CongTy
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy 
INNER JOIN ChuyenGia_DuAn AS DA ON DuAn.MaDuAn = DA.MaDuAn
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = DA.MaChuyenGia
GROUP BY TenCongTy
GO

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT CG_KN.MaChuyenGia, HoTen
FROM ChuyenGia_KyNang CG_KN
INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
GROUP BY CG_KN.MaChuyenGia, HoTen
HAVING MIN(CapDo) >= 3 AND MAX(CapDo) = 5
GO

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT CG_DA.MaChuyenGia, HoTen, COUNT(CG_DA.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia CG
INNER JOIN ChuyenGia_DuAn CG_DA ON CG.MaChuyenGia = CG_DA.MaChuyenGia
GROUP BY CG_DA.MaChuyenGia, HoTen
GO

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
SELECT CG_KN.MaKyNang, HoTen, CapDo
FROM ChuyenGia_KyNang CG_KN
INNER JOIN ChuyenGia CG ON CG_KN.MaChuyenGia = CG.MaChuyenGia
JOIN (
	SELECT MaKyNang, MAX(CapDo) AS MaxCapDo
	FROM ChuyenGia_KyNang
	GROUP BY MaKyNang
) AS MAXLEVEL ON CG_KN.CapDo = MAXLEVEL.MaxCapDo AND MAXLEVEL.MaKyNang = CG_KN.MaKyNang

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh,  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM ChuyenGia), 0) AS TiLePhanTram
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT K1.TenKyNang AS KyNang1, K2.TenKyNang AS KyNang2, COUNT(*) AS SoLanXuatHien
FROM ChuyenGia_KyNang AS CK1
JOIN ChuyenGia_KyNang AS CK2 ON CK1.MaChuyenGia = CK2.MaChuyenGia AND CK1.MaKyNang < CK2.MaKyNang
JOIN KyNang AS K1 ON CK1.MaKyNang = K1.MaKyNang
JOIN KyNang AS K2 ON CK2.MaKyNang = K2.MaKyNang
GROUP BY K1.TenKyNang, K2.TenKyNang
ORDER BY SoLanXuatHien DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT CongTy.TenCongTy, AVG(DATEDIFF(day, DuAn.NgayBatDau, DuAn.NgayKetThuc)) AS SoNgayTrungBinh
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
SELECT ChuyenGia.HoTen, COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia
JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, ChuyenGia.HoTen
HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaKyNang) = 1;

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT ChuyenGia.HoTen, COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn, SUM(ChuyenGia_KyNang.CapDo) AS TongCapDo,
       ROW_NUMBER() OVER (ORDER BY COUNT(ChuyenGia_DuAn.MaDuAn) DESC, SUM(ChuyenGia_KyNang.CapDo) DESC) AS XepHang
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT DuAn.TenDuAn
FROM DuAn
JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY DuAn.TenDuAn
HAVING COUNT(DISTINCT ChuyenGia.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT CongTy.TenCongTy, 
       ROUND(100.0 * SUM(CASE WHEN DuAn.TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) / COUNT(*), 2) AS TiLeThanhCong
FROM CongTy
JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.TenCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT C1.HoTen AS ChuyenGia1, C2.HoTen AS ChuyenGia2, K1.TenKyNang AS KyNang1, K2.TenKyNang AS KyNang2
FROM ChuyenGia_KyNang AS CK1
JOIN ChuyenGia_KyNang AS CK2 ON CK1.MaKyNang = CK2.MaKyNang AND CK1.CapDo >= 4 AND CK2.CapDo <= 2
JOIN ChuyenGia AS C1 ON CK1.MaChuyenGia = C1.MaChuyenGia
JOIN ChuyenGia AS C2 ON CK2.MaChuyenGia = C2.MaChuyenGia
JOIN KyNang AS K1 ON CK1.MaKyNang = K1.MaKyNang
JOIN KyNang AS K2 ON CK2.MaKyNang = K2.MaKyNang
WHERE C1.MaChuyenGia < C2.MaChuyenGia;