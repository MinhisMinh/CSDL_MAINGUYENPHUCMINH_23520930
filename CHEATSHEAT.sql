/*
DELETE FROM

DROP TABLE

ALTER TABLE
DROP CONSTRAINT 

DROP TRIGGER
*/

CREATE DATABASE --
GO

SET DATEFORMAT DMY
USE --

--Tao bang  --
CREATE TABLE 
(
	MaSach CHAR(5) PRIMARY KEY, 
	TenSach NVARCHAR(100),
	TheLoai NVARCHAR(30),
	DonGia money,
	SoLuong int
);
GO

--TAO BANG --
CREATE TABLE --
(
	MaTG CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(50),
	QuocTich NVARCHAR(30),
	NgaySinh smalldatetime,
	DienThoai varchar(15)
);
GO

--TAO BANG --
CREATE TABLE --
(
	MaTG CHAR(5) FOREIGN KEY REFERENCES TACGIA(MaTG), 
	MaSach CHAR(5) FOREIGN KEY REFERENCES SACH(MaSach),
	PRIMARY KEY (MaTG,MaSach)
);
GO

--TAO BANG --
CREATE TABLE --
(
	MaDG CHAR(5) PRIMARY KEY, 
	TenDG NVARCHAR(50),
	DiaChi NVARCHAR(50),
	NgaySinh smalldatetime,
	DienThoai varchar(15),
	NgDK smalldatetime
);
GO

--TAO BANG --
CREATE TABLE ---
(
	MaPH CHAR(5) PRIMARY KEY, 
	MaSach CHAR(5) FOREIGN KEY REFERENCES SACH(MaSach),
	NgayPH smalldatetime,
	SoLuong int,
	NXB Nvarchar(100),
	LanPhatHanh int
);
GO

--TAO BANG --
CREATE TABLE --
(
	MaMuon CHAR(5) PRIMARY KEY, 
	MaDG CHAR(5) FOREIGN KEY REFERENCES DOCGIA(MaDG),
	MaSach CHAR(5) FOREIGN KEY REFERENCES SACH(MaSach),
	NgayMuon smalldatetime,
	NgayTra smalldatetime,
	TrangThai Nvarchar(20)
);
GO

--C2:

--C3:
ALTER TABLE 
ADD CONSTRAINT 
--C4:

--C5:

--C6:

--C7:

--C8: