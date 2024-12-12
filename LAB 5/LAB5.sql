SET DATEFORMAT DMY;
USE QUANLYBANHANG
GO

-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
-- 11.	Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER TRG_HD_KH ON HOADON FOR Insert, Update
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME, @MAKH CHAR(4)
	SELECT @NGHD = NGHD, @MAKH = MAKH FROM INSERTED
	SELECT	@NGDK = NGDK FROM KHACHHANG WHERE MAKH = @MAKH

	IF (@NGHD >= @NGDK)
		PRINT N'Thêm mới một hóa đơn thành công.'
	ELSE 
	BEGIN
		PRINT N'Lỗi: Ngày mua hàng của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên.'
		-- báo lỗi sài hame RAISERROR('Ngày hóa đơn >= Ngày đăng ký',16,1) 
		--16: lỗi do người định nghĩa + 1: statement 1
		ROLLBACK TRAN --ROLLBACK TRANSACTION
	END
END
GO

DROP TRIGGER TRG_HD_KH

INSERT INTO HOADON(SOHD, NGHD, MAKH, MANV, TRIGIA) VALUES('1024', '22/07/2005', 'KH01', 'NV01', '320000')
delete from HOADON where SOHD = '1024'
GO

--Tao trigger bang KHACHHANG
CREATE OR ALTER TRIGGER TR_HD_KH1 ON KHACHHANG FOR UPDATE
AS 
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME, @MAKH CHAR(4)
	SELECT @NGDK = NGDK, @MAKH = MAKH FROM INSERTED
	SELECT @NGHD = NGHD FROM HOADON WHERE @MAKH = MAKH
	IF(@NGHD>=@NGDK)
		PRINT N'Thuc hien thanh cong'
	ELSE
	BEGIN
		PRINT N'Lỗi: Ngày mua hàng của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên.'
		ROLLBACK TRAN
	END
END
GO

DROP TRIGGER TR_HD_KH1

UPDATE KHACHHANG
SET NGDK = '20/11/2020'
WHERE MAKH = 'KH09'

-- 12.	Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.
CREATE TRIGGER TRG_HD_NV ON HOADON FOR INSERT
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME, @MANV CHAR(4)
	SELECT @NGHD = NGHD, @MANV = MANV FROM INSERTED
	SELECT	@NGVL = NGVL FROM NHANVIEN WHERE MANV = @MANV

	IF (@NGHD >= @NGVL)
		PRINT N'Thêm mới một hóa đơn thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Ngày bán hàng của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.'
		ROLLBACK TRANSACTION
	END
END
GO

CREATE OR ALTER TRIGGER TRG_HD_NV ON NHANVIEN FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME, @MANV CHAR(4)
	SELECT @NGVL = NGVL, @MANV = MANV FROM INSERTED
	SELECT	@NGHD = NGHD FROM HOADON WHERE MANV = @MANV

	IF (@NGHD >= @NGVL)
		PRINT N'Thêm mới một hóa đơn thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Ngày bán hàng của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm.'
		ROLLBACK TRANSACTION
	END
END
GO

INSERT INTO HOADON VALUES ('1026',2005-07-29,NULL,'NV05',6000)

-- 13.	Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.
SELECT *
FROM HOADON

CREATE TRIGGER TRG_HD_CTHD ON HOADON FOR INSERT
AS
BEGIN
	DECLARE @SOHD INT, @COUNT_SOHD INT
	SELECT @SOHD = SOHD FROM INSERTED
	SELECT @COUNT_SOHD = COUNT(SOHD) FROM CTHD WHERE SOHD = @SOHD

	IF (@COUNT_SOHD >= 1)
		PRINT N'Thêm mới một hóa đơn thành công.'
	ELSE
	BEGIN
		PRINT N'Lỗi: Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.'
		ROLLBACK TRANSACTION
	END
END
GO

-- 14.	Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.
CREATE OR ALTER TRIGGER TRG_CTHD ON CTHD FOR INSERT
AS
BEGIN
	DECLARE @SOHD INT, @TONGGIATRI INT

	SELECT @TONGGIATRI = SUM(SL * GIA), @SOHD = SOHD 
	FROM INSERTED INNER JOIN SANPHAM
	ON INSERTED.MASP = SANPHAM.MASP
	GROUP BY SOHD

	UPDATE HOADON
	SET TRIGIA += @TONGGIATRI
	WHERE SOHD = @SOHD
END
GO 


CREATE OR ALTER TRIGGER TR_DEL_CTHD ON CTHD FOR DELETE
AS
BEGIN
	DECLARE @SOHD INT, @GIATRI INT

	SELECT @SOHD = SOHD, @GIATRI = SL * GIA 
	FROM DELETED INNER JOIN SANPHAM 
	ON SANPHAM.MASP = DELETED.MASP

	UPDATE HOADON
	SET TRIGIA -= @GIATRI
	WHERE SOHD = @SOHD
END
GO


-------------------------------- QUANLYHOCVU ------------------------------------------
/*
DROP TABLE KHOA 
DROP TABLE MONHOC 
DROP TABLE DIEUKIEN 
DROP TABLE GIAOVIEN  
DROP TABLE LOP 
DROP TABLE HOCVIEN 
DROP TABLE GIANGDAY  
DROP TABLE KETQUATHI  

DELETE FROM KHOA 
DELETE FROM MONHOC 
DELETE FROM DIEUKIEN
DELETE FROM GIAOVIEN
DELETE FROM LOP
DELETE FROM HOCVIEN
DELETE FROM GIANGDAY
DELETE FROM KETQUATHI

SELECT * FROM KHOA 
SELECT * FROM MONHOC 
SELECT * FROM DIEUKIEN
SELECT * FROM GIAOVIEN
SELECT * FROM LOP
SELECT * FROM HOCVIEN
SELECT * FROM GIANGDAY
SELECT * FROM KETQUATHI
*/
GO

USE QUANLYGIAOVU
GO
SELECT *
FROM LOP
SELECT *
FROM HOCVIEN
-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
-- 9.	Lớp trưởng của một lớp phải là học viên của lớp đó.
CREATE OR ALTER TRIGGER TRG_LOPTRUONG ON LOP AFTER INSERTED, UPDATE 
AS 
BEGIN
	DECLARE @MAHV CHAR(5), @MALOP CHAR(3), @LOPTRUONG CHAR(5)
	SELECT @LOPTRUONG = TRGLOP, @MALOP = MALOP FROM INSERTED
	SELECT @MAHV = MAHV FROM HOCVIEN WHERE MALOP = @MALOP
	IF(@LOPTRUONG != 

END
GO

-- 10.	Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”.

GO

-- 15.	Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.

GO

-- 16.	Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.

GO

-- 17.	Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.

GO

/* 18.	Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ 
không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). */

GO

-- 19.	Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.

GO

-- 20.	Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.

GO

-- 21.	Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).

GO

-- 22.	Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.

GO

/* 23.	Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học 
(sau khi học xong những môn học phải học trước mới được học những môn liền sau). */

GO

-- 24.	Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.

GO