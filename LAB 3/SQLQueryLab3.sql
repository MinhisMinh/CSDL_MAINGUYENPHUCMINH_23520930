USE QUANLYBANHANG
SET DATEFORMAT DMY
GO

SELECT *
FROM CTHD
-- III. Ngôn ngữ truy vấn dữ liệu có cấu trúc:
-- 12.	Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT DISTINCT SOHD
FROM CTHD
WHERE (MASP = 'BB01' OR MASP = 'BB02') AND (SL BETWEEN 10 AND 20)
GO

-- 13.	Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
SELECT SOHD
FROM CTHD
WHERE (MASP = 'BB01' OR MASP = 'BB02') AND (SL BETWEEN 10 AND 20)
GROUP BY SOHD
HAVING COUNT(SOHD) = 2
GO

-- 14.	In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = N'Trung Quoc' OR MASP IN
(
	SELECT MASP
	FROM CTHD
	INNER JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
	WHERE NGHD = '1/1/2007'
)
GO

-- 15.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN (
	SELECT DISTINCT MASP
	FROM CTHD
)
GO

-- 16.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN (
	SELECT DISTINCT MASP
	FROM CTHD
	INNER JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
	WHERE YEAR(NGHD) = '2006'
)
GO

-- 17.	In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND MASP NOT IN (
	SELECT DISTINCT MASP
	FROM CTHD
	INNER JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
	WHERE YEAR(NGHD) = '2006' 
)
GO

SELECT *
FROM SANPHAM
SELECT *
FROM HOADON
SELECT *
FROM CTHD
SELECT *
FROM KHACHHANG
-- 18.	Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD
FROM CTHD
INNER JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Singapore' 
GROUP BY SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 
(
	SELECT COUNT(MASP)
	FROM SANPHAM
	WHERE NUOCSX = 'Singapore'
)
GO

---BAI TAP QUAN LY HOC VU ---
USE QUANLYGIAOVU
GO

-- II. Ngôn ngữ thao tác dữ liệu (Data Manipulation Language):
-- 1.	Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
UPDATE GIAOVIEN 
SET HESO += HESO * 0.02 
WHERE MAGV IN (
	SELECT TRGKHOA FROM KHOA
)
GO

/* 2.	Cập nhật giá trị điểm trung bình tất cả các môn học (DIEMTB) của mỗi học viên 
(tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng). */
UPDATE HV SET DIEMTB = DTB_HOCVIEN.DTB
FROM HOCVIEN HV LEFT JOIN (
-- Cách 1: 
/*	
	SELECT A.MAHV, AVG(A.DIEM) AS DTB 
	FROM KETQUATHI A INNER JOIN (
		SELECT MAHV, MAMH, MAX(LANTHI) LANTHIMAX
		FROM KETQUATHI
		GROUP BY MAHV, MAMH
	) B 
	ON A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI = B.LANTHIMAX 
	GROUP BY A.MAHV
*/
-- Cách 2:
	SELECT MAHV, AVG(DIEM) AS DTB 
	FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 
		FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) 
	GROUP BY MAHV
) DTB_HOCVIEN
ON HV.MAHV = DTB_HOCVIEN.MAHV
GO

-- 3.	Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm.
UPDATE HOCVIEN SET GHICHU = 'Cam thi'
WHERE MAHV IN (
	SELECT MAHV 
	FROM KETQUATHI 
	WHERE LANTHI = 3 AND DIEM < 5
)
GO

/* 4.	Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
		o	Nếu DIEMTB  9 thì XEPLOAI =”XS”
		o	Nếu  8  DIEMTB < 9 thì XEPLOAI = “G”
		o	Nếu  6.5  DIEMTB < 8 thì XEPLOAI = “K”
		o	Nếu  5    DIEMTB < 6.5 thì XEPLOAI = “TB”
		o	Nếu  DIEMTB < 5 thì XEPLOAI = ”Y”
*/
UPDATE HOCVIEN SET XEPLOAI = CASE 
	WHEN DIEMTB >= 9 THEN 'XS'
	WHEN DIEMTB >= 8 THEN 'G'
	WHEN DIEMTB >= 6.5 THEN 'K'
	WHEN DIEMTB >= 5 THEN 'TB'
	ELSE 'Y'
END
GO

-- III. Ngôn ngữ truy vấn dữ liệu:
-- 6.	Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.

-- 7.	Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.

-- 8.	Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.

-- 9.	In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.


-- 10.	Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.


-- 11.	Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.


-- 12.	Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.


-- 13.	Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.


-- 14.	Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.


-- 15.	Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.

-- 16.	Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.

-- 17.	Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).


-- 18.	Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).


