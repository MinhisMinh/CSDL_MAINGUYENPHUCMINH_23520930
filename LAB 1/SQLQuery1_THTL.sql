--- Mai Nguyen Phuc Minh - 23520930 - Lab 1 ---
--- 1. Tạo các quan hệ và khai báo các khóa chính, khóa ngoại của quan hệ.
--- TAO BANG ---
CREATE DATABASE QUANLYBANHANG
GO

--- TAO CSDL QUANLY ---
USE QUANLYBANHANG
GO
---TAO BANG KHACHHANG ---
CREATE TABLE KHACHHANG
(
	MAKH CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	DCHI VARCHAR(50) NOT NULL,
	SODT VARCHAR(20) NOT NULL,
	NGSINH SMALLDATETIME,
	NGDK SMALLDATETIME,
	DOANHSO MONEY NOT NULL,
);
GO

--- TAO BANG NHANVIEN ---
CREATE TABLE NHANVIEN
(
	MANV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40) NOT NULL,
	SODT VARCHAR(20) NOT NULL UNIQUE,
	NGVL SMALLDATETIME NOT NULL,
)
GO

--- TAO BANG SANPHAM ---
CREATE TABLE SANPHAM
(
	MASP CHAR(4) PRIMARY KEY,
	TENSP VARCHAR(40) NOT NULL,
	DVT VARCHAR(20),
	NUOCSX VARCHAR(40),
	GIA MONEY NOT NULL
)
GO

--- TAO BANG HOADON ---
CREATE TABLE HOADON
(
	SOHD INT PRIMARY KEY,
	NGHD SMALLDATETIME,
	MAKH CHAR(4) FOREIGN KEY REFERENCES KHACHHANG(MAKH),
	MANV CHAR(4) FOREIGN KEY REFERENCES NHANVIEN(MANV),
	TRIGIA MONEY
)
GO

--- TAO BANG CTHD ---
CREATE TABLE CTHD
(
	SOHD INT FOREIGN KEY REFERENCES HOADON(SOHD),
	MASP CHAR(4) FOREIGN KEY REFERENCES SANPHAM(MASP),
	SL INT,
	PRIMARY KEY (SOHD, MASP)
)
GO

--- 2. Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.
ALTER TABLE SANPHAM
ADD GHICHU VARCHAR(20)
GO

--- 3. Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG.
ALTER TABLE KHACHHANG
ADD LOAIKH TINYINT
GO

--- 4. Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100).
ALTER TABLE SANPHAM 
ALTER COLUMN GHICHU VARCHAR(100)
GO

--- 5. Xóa thuộc tính GHICHU trong quan hệ SANPHAM.
ALTER TABLE SANPHAM
DROP COLUMN GHICHU
GO

--- 6. Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, …
ALTER TABLE KHACHHANG
ALTER COLUMN LOAIKH VARCHAR(20)
ALTER TABLE KHACHHANG
ADD CONSTRAINT CK_LOAIKH CHECK(LOAIKH in ('Vang lai', 'Thuong xuyen', 'Vip'))
GO

--- 7. Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
ALTER TABLE SANPHAM
ADD CONSTRAINT CK_DVT CHECK(DVT in ('cay','hop','cai','quyen','chuc'))
GO

--- 8. Giá bán của sản phẩm từ 500 đồng trở lên
ALTER TABLE SANPHAM
ADD CONSTRAINT CK_GIA CHECK(GIA >= 500)
GO

--- 9. Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.
ALTER TABLE CTHD ADD CONSTRAINT CK_SL CHECK(SL >= 1)
GO

--- 10.	Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
ALTER TABLE KHACHHANG ADD CONSTRAINT CK_NGDK CHECK(NGDK > NGSINH)
GO

CREATE DATABASE QUANLYGIAOVU
GO

--- TAO CSDL QUANLY ---
USE QUANLYGIAOVU
GO
----------------------------------- KHOA ----------------------------------------------
CREATE TABLE KHOA
(
	MAKHOA VARCHAR(4) PRIMARY KEY,
	TENKHOA VARCHAR(40),
	NGTLAP SMALLDATETIME,
	TRGKHOA CHAR(4)
)
GO

---------------------------------- MONHOC ---------------------------------------------
CREATE TABLE MONHOC
(
	MAMH VARCHAR(10) PRIMARY KEY,
	TENMH VARCHAR(40),
	TCLT TINYINT,
	TCTH TINYINT,
	MAKHOA VARCHAR(4) FOREIGN KEY REFERENCES KHOA(MAKHOA)
)
GO

--------------------------------- DIEUKIEN --------------------------------------------
CREATE TABLE DIEUKIEN
(
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	MAMH_TRUOC VARCHAR(10),
	PRIMARY KEY (MAMH, MAMH_TRUOC)
)
GO

--------------------------------- GIAOVIEN --------------------------------------------
CREATE TABLE GIAOVIEN
(
	MAGV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	HOCVI VARCHAR(10),
	HOCHAM VARCHAR(10),
	GIOITINH VARCHAR(3),
	NGSINH SMALLDATETIME,
	NGVL SMALLDATETIME,
	HESO NUMERIC(4,2),
	MUCLUONG MONEY,
	MAKHOA VARCHAR(4) FOREIGN KEY REFERENCES KHOA(MAKHOA)
)
GO

----------------------------------- LOP -----------------------------------------------
CREATE TABLE LOP
(
	MALOP CHAR(3) PRIMARY KEY,
	TENLOP VARCHAR(40),
	TRGLOP CHAR(5),
	SISO TINYINT,
	MAGVCN CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV)
)
GO

--------------------------------- HOCVIEN ---------------------------------------------
CREATE TABLE HOCVIEN
(
	MAHV CHAR(5) PRIMARY KEY,
	HO VARCHAR(40),
	TEN VARCHAR(10),
	NGSINH SMALLDATETIME,
	GIOITINH VARCHAR(3),
	NOISINH VARCHAR(40),
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP) 
)
GO

--------------------------------- GIANGDAY --------------------------------------------
CREATE TABLE GIANGDAY
(
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	MAGV CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV),
	HOCKY TINYINT,
	NAM SMALLINT,
	TUNGAY SMALLDATETIME,
	DENNGAY SMALLDATETIME,
	PRIMARY KEY (MALOP, MAMH)
)
GO

--------------------------------- KETQUATHI -------------------------------------------
CREATE TABLE KETQUATHI
(
	MAHV CHAR(5) FOREIGN KEY REFERENCES HOCVIEN(MAHV),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	LANTHI TINYINT,
	NGTHI SMALLDATETIME,
	DIEM NUMERIC(4,2),
	KQUA VARCHAR(10),
	PRIMARY KEY (MAHV, MAMH, LANTHI)
)
GO

ALTER TABLE KHOA ADD CONSTRAINT FK__KHOA__TRGKHOA FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV)

ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(60)
GO

ALTER TABLE HOCVIEN ADD DIEMTB NUMERIC(4, 2)
GO 

ALTER TABLE HOCVIEN ADD XEPLOAI VARCHAR(10)
GO

-- 2.	Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”
CREATE FUNCTION check_valid_MALOP (@MAHV VARCHAR(5))
RETURNs TINYINT
AS 
BEGIN
	IF LEFT(@MAHV, 3) IN (SELECT MALOP FROM LOP)
		RETURN 1
	RETURN 0
END
GO

CREATE FUNCTION check_valid_STT (@MAHV VARCHAR(5), @MALOP_HOCVIEN VARCHAR(3))
RETURNs TINYINT
AS
BEGIN
    IF RIGHT(@MAHV, 2) BETWEEN 1 AND (SELECT SISO FROM LOP WHERE MALOP = @MALOP_HOCVIEN)
		RETURN 1
	RETURN 0
END
GO

ALTER TABLE HOCVIEN ADD CONSTRAINT CK_MAHV CHECK(
	LEN(MAHV) = 5 AND 
	dbo.check_valid_MALOP(MAHV) = 1 AND 
	dbo.check_valid_STT(MAHV, MALOP) = 1
)
GO

-- 3.	Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
ALTER TABLE HOCVIEN ADD CONSTRAINT CHK_GIOITINH CHECK(GIOITINH IN ('Nam', 'Nu'))
GO

-- 4.	Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_DIEM CHECK(
	DIEM BETWEEN 0 AND 10 AND
	LEN(SUBSTRING(CAST(DIEM AS VARCHAR), CHARINDEX('.', DIEM) + 1, 1000)) >= 2
)
GO

-- 5.	Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_KQUA CHECK(KQUA = IIF(DIEM BETWEEN 5 AND 10, 'Dat', 'Khong dat'))
GO

-- 6.	Học viên thi một môn tối đa 3 lần.
ALTER TABLE KETQUATHI ADD CONSTRAINT CHK_SOLANTHI CHECK(LANTHI <= 3)
GO

-- 7.	Học kỳ chỉ có giá trị từ 1 đến 3.
ALTER TABLE GIANGDAY ADD CONSTRAINT CHK_HOCKY CHECK(HOCKY BETWEEN 1 AND 3)
GO

-- 8.	Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHK_HOCVI CHECK(HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'))
GO