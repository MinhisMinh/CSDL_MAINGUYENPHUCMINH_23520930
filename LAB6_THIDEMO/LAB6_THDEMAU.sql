--- DE 1
CREATE DATABASE DE1_CUAHANGSACH
SET DATEFORMAT DMY
USE DE1_CUAHANGSACH

/*
DROP TABLE TACGIA
DROP TABLE SACH
*/
CREATE TABLE TACGIA
(
	MaTG char(5) PRIMARY KEY,
	HoTen varchar(20),
	DiaChi varchar(50),
	NgSinh smalldatetime,
	SoDT varchar(15)
)

CREATE TABLE SACH
(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25)
)

CREATE TABLE TACGIA_SACH
(
	MaTG char(5) FOREIGN KEY REFERENCES TACGIA(MaTG),
	MaSach char(5) FOREIGN KEY REFERENCES SACH(MaSach),
	PRIMARY KEY(MaTG,MaSach)
)

CREATE TABLE PHATHANH
(
	MaPH char(5) PRIMARY KEY,
	MaSach char(5) FOREIGN KEY REFERENCES SACH(MaSach),
	NgayPH smalldatetime,
	SoLuong int,
	NhaXuatBan varchar(20)
)

-- Ngày phát hành sách phải lớn hơn ngày sinh của tác giả.
CREATE OR ALTER TRIGGER TRG_TACGIA_PHATHANH ON PHATHANH FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGAYPH smalldatetime, @NGSINH smalldatetime, @MASACH char(5)
	SELECT @NGAYPH = NgayPH, @MASACH = MaSach FROM INSERTED
	SELECT @NGSINH = NgSinh 
	FROM TACGIA, TACGIA_SACH 
	WHERE TACGIA.MaTG = TACGIA_SACH.MaTG AND TACGIA_SACH.MaSach = @MASACH
	IF(@NGAYPH > @NGSINH)
	BEGIN
		PRINT 'THEM MOI MOT TUPLE TRONG PHATHANH THANH CONG!'
	END
	ELSE
	BEGIN
		RAISERROR(N'LOI: Ngày phát hành sách phải lớn hơn ngày sinh của tác giả',16,1)
		ROLLBACK TRAN
	END
END
GO

-- Sách thuộc thể loại “Giáo khoa” chỉ do nhà xuất bản “Giáo dục” phát hành.
CREATE OR ALTER TRIGGER TRG_THELOAISACH ON SACH FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @TheLoai varchar(25), @MaSach char(5), @NhaXuatBan varchar(20)
	SELECT @TheLoai = TheLoai, @MaSach = MaSach FROM INSERTED
	SELECT @NhaXuatBan = NhaXuatBan 
	FROM PHATHANH
	WHERE @MaSach = MaSach
	IF(@TheLoai != N'Giáo khoa' OR @NhaXuatBan = N'Giáo dục')
	BEGIN
		PRINT 'THEM MOI MOT TUPLE TRONG SACH THANH CONG!'
	END
	ELSE
	BEGIN
		RAISERROR(N'LOI: Sách thuộc thể loại “Giáo khoa” chỉ do nhà xuất bản “Giáo dục” phát hành!',16,1)
		ROLLBACK TRAN
	END
END

-- Tìm tác giả (MaTG,HoTen,SoDT) của những quyển sách thuộc thể loại “Văn học” do nhà xuất bản Trẻ phát hành.
SELECT TG.MaTG,HoTen,SoDT
FROM TACGIA TG
INNER JOIN TACGIA_SACH ON TACGIA_SACH.MaTG = TG.MaTG
INNER JOIN SACH ON SACH.MaSach = TACGIA_SACH.MaSach
INNER JOIN PHATHANH ON PHATHANH.MaSach = SACH.MaSach
WHERE TheLoai = N'Văn học' AND NhaXuatBan = N'Trẻ'

-- Tìm nhà xuất bản phát hành nhiều thể loại sách nhất.
SELECT TOP 1 WITH TIES PH.MaSach, NhaXuatBan, COUNT(SACH.MaSach) AS SOLUONG_THELOAISACH
FROM PHATHANH PH
INNER JOIN SACH ON SACH.MaSach = PH.MaSach
GROUP BY PH.MaSach, NhaXuatBan
ORDER BY COUNT(SACH.MaSach) DESC
GO

-- Trong mỗi nhà xuất bản, tìm tác giả (MaTG,HoTen) có số lần phát hành nhiều sách nhất




SELECT *
FROM TACGIA
SELECT *
FROM SACH
SELECT *
FROM TACGIA_SACH
SELECT *
FROM PHATHANH
































--- DE 2