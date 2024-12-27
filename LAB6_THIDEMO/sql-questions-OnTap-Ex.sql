-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE LAB1_HW
SET DATEFORMAT DMY

-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT *
FROM CHUYENGIA

--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'

--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT *
FROM CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NgayBatDau) = '2023'

--5

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn
FROM ChuyenGia
INNER JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia = ChuyenGia.MaChuyenGia
GROUP BY ChuyenGia.MaChuyenGia, HoTen


--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT TenDuAn, CGDA.MaDuAn
FROM DuAn
INNER JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DuAn.MaDuAn
INNER JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia = CGDA.MaChuyenGia
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE TenKyNang = 'Python'  AND CapDo >=4
GROUP BY TenDuAn, CGDA.MaDuAn
GO


--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn
FROM CongTy
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.

SELECT CG1.MaChuyenGia, CG1.HoTen, CG1.ChuyenNganh, CG1.NamKinhNghiem
FROM ChuyenGia CG1 
WHERE CG1.NamKinhNghiem >= ALL
	(
		SELECT CG2.NamKinhNghiem
		FROM ChuyenGia CG2
		WHERE CG1.ChuyenNganh = CG2.ChuyenNganh
	)

--TEST
INSERT INTO ChuyenGia(MaChuyenGia,HoTen,ChuyenNganh,NamKinhNghiem) VALUES (12,'A','IoT', 10)
DELETE FROM ChuyenGia
WHERE MaChuyenGia = 12

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT DISTINCT CG1.MaChuyenGia, CG1.HoTen, CG2.MaChuyenGia, CG2.HoTen
FROM ChuyenGia CG1
INNER JOIN ChuyenGia_DuAn CGDA1 ON CG1.MaChuyenGia = CGDA1.MaChuyenGia
INNER JOIN ChuyenGia_DuAn CGDA2 ON CGDA1.MaDuAn = CGDA2.MaDuAn
INNER JOIN ChuyenGia CG2 ON CG2.MaChuyenGia = CGDA2.MaChuyenGia
WHERE CG1.MaChuyenGia < CG2.MaChuyenGia

-- Nâng cao:
	--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.
SELECT CG.MaChuyenGia, HoTen, SUM(DATEDIFF(DAY,CGDA.NgayThamGia,DA.NgayKetThuc)) AS TongThoiGian
FROM ChuyenGia CG
INNER JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia
INNER JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn 
GROUP BY CG.MaChuyenGia, HoTen


--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).
SELECT CongTy.MaCongTy, TenCongTy, (SUM(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS TyLePhanTram
FROM CongTy
INNER JOIN DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY CongTy.MaCongTy, TenCongTy
HAVING (SUM(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 ELSE 0 END) / COUNT(*)) * 100 > 90
ORDER BY TyLePhanTram DESC

--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.
SELECT TOP 3 KN.MaKyNang, KN.TenKyNang, COUNT(DISTINCT ChuyenGia_DuAn.MaDuAn) AS TangSuat
FROM ChuyenGia_KyNang CGKN
INNER JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
INNER JOIN ChuyenGia_DuAn ON CGKN.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY KN.MaKyNang, TenKyNang
ORDER BY TangSuat DESC

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).
-- kHONG TINH DUOC VI KHONG CO COT LUONG


--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT  MaDuAn, TenDuAn
FROM DuAn DA
WHERE NOT EXISTS
	(
		SELECT *
		FROM ChuyenGia CG
		WHERE NOT EXISTS 
			(
				SELECT *
				FROM ChuyenGia_DuAn CGDA
				WHERE CGDA.MaChuyenGia = CG.MaChuyenGia AND CGDA.MaDuAn = DA.MaDuAn
			)
	)

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.
ALTER TABLE CongTy
ADD SoLuongDuAn int default 0

ALTER TABLE CongTy
DROP COLUMN SoLuongDuAn

CREATE OR ALTER TRIGGER TRG_CAPNHATDUAN ON DuAn AFTER INSERT, DELETE
AS 
BEGIN
	DECLARE @MaCongTy int
	SELECT @MaCongTy = MaCongTy FROM inserted

	UPDATE CongTy
	SET SoLuongDuAn = 
		(
			SELECT COUNT(*)
			FROM DuAn
			WHERE @MaCongTy = MaCongTy
		)
END
	
--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE OR ALTER TRIGGER TRG_NgayCapNhat ON ChuyenGia AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	UPDATE ChuyenGia
	SET NgayCapNhat = GETDATE()
	FROM INSERTED i
	WHERE ChuyenGia.MaChuyenGia = i.MaChuyenGia 
END

--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE OR ALTER TRIGGER TRG_CHECKCG ON ChuyenGia_DuAn AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MACHUYENGIA INT
	SELECT @MACHUYENGIA = MaChuyenGia FROM inserted
	IF((SELECT COUNT (*) FROM ChuyenGia_DuAn WHERE @MACHUYENGIA = ChuyenGia_DuAn.MaChuyenGia) > 5)
	 BEGIN
		PRINT('ERROR!!!')
		ROLLBACK TRAN
	 END
	 ELSE
	 BEGIN
		PRINT('SUCCESS')
	 END
END

--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.

--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
