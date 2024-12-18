SET DATEFORMAT DMY;
USE QUANLYBANHANG
GO

-- I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
-- 11.	Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK).
CREATE OR ALTER TRIGGER TRG_HD_KH ON HOADON FOR Insert, Update
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
CREATE OR ALTER TRIGGER TRG_HD_NV ON HOADON FOR INSERT
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

CREATE OR ALTER TRIGGER TRG_HD_CTHD ON HOADON FOR INSERT
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

--9. Lớp trưởng của một lớp phải là học viên của lớp đó
CREATE OR ALTER TRIGGER HV_UPDATE_MALOP
ON HOCVIEN
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu lớp trưởng của một lớp không thuộc lớp đó
    IF EXISTS (
        SELECT 1
        FROM inserted I
        JOIN LOP L ON I.MAHV = L.TRGLOP
        WHERE I.MALOP != L.MALOP
    )
    BEGIN
        PRINT 'LOI: Lop truong cua mot lop phai la hoc vien lop do';
        ROLLBACK TRANSACTION;
    END;
END;

CREATE OR ALTER TRIGGER LOP_VALIDATE_TRGLOP
ON LOP
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra nếu lớp trưởng không thuộc lớp
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN HOCVIEN H
        ON I.TRGLOP = H.MAHV AND I.MALOP = H.MALOP
        WHERE I.TRGLOP IS NOT NULL AND H.MAHV IS NULL
    )
    BEGIN
        PRINT 'LOI: Lop truong phai la mot hoc vien thuoc lop';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”
CREATE TRIGGER TRG_VALIDATE_TRGKHOA
ON KHOA
AFTER UPDATE, INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN GIAOVIEN GV
        ON I.TRGKHOA = GV.MAGV AND I.MAKHOA = GV.MAKHOA
        WHERE I.TRGKHOA IS NOT NULL 
        AND (GV.MAGV IS NULL OR GV.HOCVI NOT IN ('TS', 'PTS'))
    )
    BEGIN
        PRINT 'LOI: Truong khoa phai la giao vien thuoc khoa va co hoc vi TS hoac PTS';
        ROLLBACK TRANSACTION;
    END;
END;
--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_KETQUATHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        LEFT JOIN GIANGDAY GD
        ON I.MAMH = GD.MAMH AND GD.MALOP = (SELECT MALOP FROM HOCVIEN WHERE MAHV = I.MAHV)
        WHERE GD.DENNGAY > I.NGTHI
    )
    BEGIN
        PRINT 'LOI: Hoc vien chi duoc thi sau khi lop da hoc xong mon hoc';
        ROLLBACK TRANSACTION;
    END;
END;
--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_GIANGDAY
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        WHERE (
            SELECT COUNT(*)
            FROM GIANGDAY
            WHERE MALOP = I.MALOP AND HOCKY = I.HOCKY AND NAM = I.NAM
        ) > 3
    )
    BEGIN
        PRINT 'LOI: Moi hoc ky cua mot nam hoc, mot lop chi duoc hoc toi da 3 mon';
        ROLLBACK TRANSACTION;
    END;
END;
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó
sql
Sao chép mã
CREATE TRIGGER TRG_UPDATE_SISO
ON HOCVIEN
AFTER INSERT, DELETE
AS
BEGIN
    UPDATE LOP
    SET SISO = (SELECT COUNT(*) FROM HOCVIEN WHERE MALOP = LOP.MALOP);
END;
--18. Trong quan hệ DIEUKIEN, không được tồn tại các cặp quan hệ không hợp lệ
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_DIEUKIEN
ON DIEUKIEN
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        WHERE I.MAMH = I.MAMH_TRUOC
           OR EXISTS (
               SELECT 1
               FROM DIEUKIEN D
               WHERE D.MAMH = I.MAMH_TRUOC AND D.MAMH_TRUOC = I.MAMH
           )
    )
    BEGIN
        PRINT 'LOI: Gia tri cua MAMH va MAMH_TRUOC khong duoc giong nhau hoac co quan he xung dot';
        ROLLBACK TRANSACTION;
    END;
END;
--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_MUCLUONG
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM GIAOVIEN G1
        JOIN GIAOVIEN G2
        ON G1.HOCVI = G2.HOCVI AND G1.HOCHAM = G2.HOCHAM AND G1.HESO = G2.HESO
        WHERE G1.MUCLUONG != G2.MUCLUONG
    )
    BEGIN
        PRINT 'LOI: Cac giao vien co cung hoc vi, hoc ham, he so luong thi muc luong phai bang nhau';
        ROLLBACK TRANSACTION;
    END;
END;
--20. Học viên chỉ được thi lại (lần thi > 1) khi điểm lần thi trước dưới 5
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_LANTHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN KETQUATHI K
        ON I.MAHV = K.MAHV AND I.MAMH = K.MAMH AND I.LANTHI > K.LANTHI
        WHERE K.DIEM >= 5
    )
    BEGIN
        PRINT 'LOI: Hoc vien chi duoc thi lai khi diem lan truoc duoi 5';
        ROLLBACK TRANSACTION;
    END;
END;
--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_NGTHI
ON KETQUATHI
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN KETQUATHI K
        ON I.MAHV = K.MAHV AND I.MAMH = K.MAMH AND I.LANTHI > K.LANTHI
        WHERE I.NGTHI <= K.NGTHI
    )
    BEGIN
        PRINT 'LOI: Ngay thi cua lan sau phai lon hon ngay thi cua lan truoc';
        ROLLBACK TRANSACTION;
    END;
END;
--22. Phân công giảng dạy phải xét đến thứ tự môn học trước sau
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_GIANGDAY_DIEUKIEN
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN DIEUKIEN D
        ON I.MAMH = D.MAMH
        WHERE EXISTS (
            SELECT 1
            FROM GIANGDAY GD
            WHERE GD.MALOP = I.MALOP AND GD.MAMH = D.MAMH_TRUOC AND GD.DENNGAY > I.TUNGAY
        )
    )
    BEGIN
        PRINT 'LOI: Phai hoc xong mon truoc khi phan cong giang day mon sau';
        ROLLBACK TRANSACTION;
    END;
END;
--23. Giáo viên chỉ được phân công dạy môn học thuộc khoa mình
sql
Sao chép mã
CREATE TRIGGER TRG_VALIDATE_GIANGDAY_GIAOVIEN
ON GIANGDAY
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN MONHOC MH
        ON I.MAMH = MH.MAMH
        JOIN GIAOVIEN GV
        ON I.MAGV = GV.MAGV
        WHERE MH.MAKHOA != GV.MAKHOA
    )
    BEGIN
        PRINT 'LOI: Giao vien chi duoc day mon hoc thuoc khoa minh phu trach';
        ROLLBACK TRANSACTION;
    END;
END;