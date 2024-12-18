-- Câu hỏi và ví dụ về Triggers (101-110)
USE LAB1_HW
SET DATEFORMAT DMY
-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
ALTER TABLE CHUYENGIA
ADD NgayCapNhat DATETIME

CREATE OR ALTER TRIGGER Trg_NgayCapNhat ON CHUYENGIA AFTER INSERT, UPDATE 
AS 
BEGIN
	UPDATE ChuyenGia
	SET NgayCapNhat = GETDATE()
	FROM inserted i
	WHERE ChuyenGia.MaChuyenGia = i.MaChuyenGia
END
GO
-- Test 
UPDATE ChuyenGia
SET HoTen = N'Nguyễn Văn An'
WHERE MaChuyenGia = 1

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
ALTER TABLE DuAn
ADD LoginStatus smalldatetime

CREATE OR ALTER TRIGGER TRG_CHECKSTATUS ON DuAn AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MADUAN CHAR(1)
	SELECT @MADUAN = MaDuAn FROM inserted
	IF EXISTS (SELECT * FROM INSERTED)
	BEGIN
		UPDATE DuAn
		SET LoginStatus = GETDATE()
		WHERE @MADUAN = MaDuAn
	END
END

-- TEST 
UPDATE DuAn
SET TrangThai = N'Hoàn thành'
WHERE MaDuAn = 5

SELECT *
FROM DuAn

-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER Trigger_LimitChuyenGiaDuAn
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM inserted;
    
    IF (SELECT COUNT(*) FROM ChuyenGia_DuAn WHERE MaChuyenGia = @MaChuyenGia) > 5
    BEGIN
        RAISERROR('Chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc', 16, 1);
        ROLLBACK;
    END;
END;


-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
CREATE TRIGGER Trigger_CapNhatSoNhanVien
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaCongTy INT;
    
    -- Cập nhật số nhân viên cho công ty khi thêm hoặc xóa chuyên gia
    SELECT @MaCongTy = MaCongTy FROM inserted;
    IF (@MaCongTy IS NULL)
    BEGIN
        SELECT @MaCongTy = MaCongTy FROM deleted;
    END;
    
    UPDATE CongTy
    SET SoNhanVien = (SELECT COUNT(*) FROM ChuyenGia WHERE MaCongTy = @MaCongTy)
    WHERE MaCongTy = @MaCongTy;
END;


-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER Trigger_KhongXoaDuAnHoanThanh
ON DuAn
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE TrangThai = N'Hoàn thành')
    BEGIN
        RAISERROR('Không thể xóa dự án đã hoàn thành', 16, 1);
        ROLLBACK;
    END;
END;


-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.

CREATE TRIGGER Trigger_CapNhatCapDoKyNang
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaDuAn INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaDuAn = MaDuAn FROM inserted;

    -- Logic để cập nhật cấp độ kỹ năng tùy theo dự án
    UPDATE ChuyenGia_KyNang
    SET CapDo = (SELECT MAX(CapDo) FROM ChuyenGia_KyNang WHERE MaChuyenGia = @MaChuyenGia)
    WHERE MaChuyenGia = @MaChuyenGia;
END;

-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE KyNangLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    MaKyNang INT,
    CapDo INT,
    ThoiGian DATETIME,
    HanhDong NVARCHAR(50)
);

CREATE TRIGGER Trigger_GhiLogCapDoKyNang
ON ChuyenGia_KyNang
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaKyNang INT, @CapDo INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaKyNang = MaKyNang, @CapDo = CapDo FROM inserted;
    
    INSERT INTO KyNangLog (MaChuyenGia, MaKyNang, CapDo, ThoiGian, HanhDong)
    VALUES (@MaChuyenGia, @MaKyNang, @CapDo, GETDATE(), N'Update');
END;


-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
CREATE TRIGGER Trigger_KiemTraNgayKetThuc
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @NgayBatDau DATE, @NgayKetThuc DATE;
    SELECT @NgayBatDau = NgayBatDau, @NgayKetThuc = NgayKetThuc FROM inserted;
    
    IF @NgayKetThuc <= @NgayBatDau
    BEGIN
        RAISERROR('Ngày kết thúc của dự án phải lớn hơn ngày bắt đầu', 16, 1);
        ROLLBACK;
    END;
END;


-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.
CREATE TRIGGER Trigger_XoaKyNang
ON KyNang
AFTER DELETE
AS
BEGIN
    DECLARE @MaKyNang INT;
    SELECT @MaKyNang = MaKyNang FROM deleted;
    
    DELETE FROM ChuyenGia_KyNang WHERE MaKyNang = @MaKyNang;
END;


-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER Trigger_LimitDuAnDangThucHien
ON DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM inserted;
    
    IF (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy AND TrangThai = N'Đang thực hiện') > 10
    BEGIN
        RAISERROR('Công ty không thể có quá 10 dự án đang thực hiện cùng một lúc', 16, 1);
        ROLLBACK;
    END;
END;


-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.
CREATE TRIGGER Trigger_CapNhatLuongChuyenGia
ON ChuyenGia_KyNang
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @CapDo INT, @SoNamKinhNghiem INT;
    SELECT @MaChuyenGia = MaChuyenGia, @CapDo = CapDo, @SoNamKinhNghiem = SoNamKinhNghiem FROM inserted;
    
    -- Logic tính lương (ví dụ: Lương = (Cấp độ * 1000) + (Kinh nghiệm * 500))
    UPDATE ChuyenGia
    SET Luong = (@CapDo * 1000) + (@SoNamKinhNghiem * 500)
    WHERE MaChuyenGia = @MaChuyenGia;
END;

-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).

-- Tạo bảng ThongBao nếu chưa có
CREATE TABLE ThongBao (
    ThongBaoID INT IDENTITY(1,1) PRIMARY KEY,
    MaDuAn INT,
    ThongBao NVARCHAR(500),
    ThoiGian DATETIME
);

CREATE TRIGGER Trigger_ThongBaoDuAnDenHan
ON DuAn
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @NgayKetThuc DATE;
    SELECT @MaDuAn = MaDuAn, @NgayKetThuc = NgayKetThuc FROM inserted;
    
    IF DATEDIFF(DAY, GETDATE(), @NgayKetThuc) = 7
    BEGIN
        INSERT INTO ThongBao (MaDuAn, ThongBao, ThoiGian)
        VALUES (@MaDuAn, N'Dự án sắp đến hạn trong 7 ngày.', GETDATE());
    END;
END;


-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.
CREATE TRIGGER Trigger_KhongXoaChuyenGiaDangThamGiaDuAn
ON ChuyenGia
AFTER DELETE, UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM deleted;
    
    IF EXISTS (SELECT 1 FROM ChuyenGia_DuAn WHERE MaChuyenGia = @MaChuyenGia)
    BEGIN
        RAISERROR('Không thể xóa hoặc cập nhật chuyên gia đang tham gia dự án.', 16, 1);
        ROLLBACK;
    END;
END;


-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.

-- Tạo bảng ThongKeChuyenNganh nếu chưa có
CREATE TABLE ThongKeChuyenNganh (
    MaChuyenNganh INT,
    SoLuongChuyenGia INT
);

CREATE TRIGGER Trigger_CapNhatSoLuongChuyenGia
ON ChuyenGia_KyNang
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaChuyenNganh INT;
    SELECT @MaChuyenNganh = MaChuyenNganh FROM inserted;
    
    UPDATE ThongKeChuyenNganh
    SET SoLuongChuyenGia = (SELECT COUNT(*) FROM ChuyenGia_KyNang WHERE MaChuyenNganh = @MaChuyenNganh)
    WHERE MaChuyenNganh = @MaChuyenNganh;
END;


-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.

-- Tạo bảng DuAnHoanThanh nếu chưa có
CREATE TABLE DuAnHoanThanh (
    MaDuAn INT,
    TenDuAn NVARCHAR(200),
    NgayHoanThanh DATE,
    ChiTiet NVARCHAR(500)
);

CREATE TRIGGER Trigger_BanSaoDuAnHoanThanh
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @TenDuAn NVARCHAR(200), @NgayHoanThanh DATE, @ChiTiet NVARCHAR(500);
    SELECT @MaDuAn = MaDuAn, @TenDuAn = TenDuAn, @NgayHoanThanh = NgayHoanThanh, @ChiTiet = ChiTiet FROM inserted;
    
    IF @NgayHoanThanh IS NOT NULL
    BEGIN
        INSERT INTO DuAnHoanThanh (MaDuAn, TenDuAn, NgayHoanThanh, ChiTiet)
        VALUES (@MaDuAn, @TenDuAn, @NgayHoanThanh, @ChiTiet);
    END;
END;


-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
CREATE TRIGGER Trigger_CapNhatDiemDanhGiaCongTy
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM inserted;
    
    UPDATE CongTy
    SET DiemDanhGiaTrungBinh = (
        SELECT AVG(DiemDanhGia) FROM DuAn WHERE MaCongTy = @MaCongTy
    )
    WHERE MaCongTy = @MaCongTy;
END;



-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.

CREATE TRIGGER Trigger_PhanCongChuyenGia
ON DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaDuAn INT, @CapDo INT, @SoNamKinhNghiem INT;
    SELECT @MaDuAn = MaDuAn FROM inserted;
    
    -- Logic phân công chuyên gia (ví dụ: kỹ năng và kinh nghiệm phù hợp)
    INSERT INTO ChuyenGia_DuAn (MaChuyenGia, MaDuAn)
    SELECT MaChuyenGia, @MaDuAn
    FROM ChuyenGia_KyNang
    WHERE CapDo >= 3 AND SoNamKinhNghiem >= 5;  -- Điều kiện phân công
END;


-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.

CREATE TRIGGER Trigger_CapNhatTrangThaiChuyenGia
ON ChuyenGia_DuAn
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM inserted;
    
    UPDATE ChuyenGia
    SET TrangThai = N'Bận'
    WHERE MaChuyenGia = @MaChuyenGia;
END;


-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.

CREATE TRIGGER Trigger_KhongTrungLapKyNang
ON ChuyenGia_KyNang
AFTER INSERT
AS
BEGIN
    DECLARE @MaChuyenGia INT, @MaKyNang INT;
    SELECT @MaChuyenGia = MaChuyenGia, @MaKyNang = MaKyNang FROM inserted;
    
    IF EXISTS (SELECT 1 FROM ChuyenGia_KyNang WHERE MaChuyenGia = @MaChuyenGia AND MaKyNang = @MaKyNang)
    BEGIN
        RAISERROR('Kỹ năng này đã tồn tại cho chuyên gia.', 16, 1);
        ROLLBACK;
    END;
END;


-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.
CREATE TABLE BaoCaoDuAn (
    MaDuAn INT,
    BaoCao NVARCHAR(500),
    ThoiGian DATETIME
);

CREATE TRIGGER Trigger_BaoCaoDuAnKetThuc
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @TrangThai NVARCHAR(50);
    SELECT @MaDuAn = MaDuAn, @TrangThai = TrangThai FROM inserted;
    
    IF @TrangThai = N'Hoàn thành'
    BEGIN
        INSERT INTO BaoCaoDuAn (MaDuAn, BaoCao, ThoiGian)
        VALUES (@MaDuAn, N'Báo cáo tổng kết dự án', GETDATE());
    END;
END;





-- 133. (tiếp tục) Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.
CREATE TRIGGER Trigger_CapNhatThuHangCongTy
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM inserted;
    
    UPDATE CongTy
    SET ThuHang = (
        SELECT COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy AND TrangThai = N'Hoàn thành'
    )
    WHERE MaCongTy = @MaCongTy;
END;



-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).
CREATE TRIGGER Trigger_ThongBaoThangCapChuyenGia
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @SoNamKinhNghiem INT;
    SELECT @MaChuyenGia = MaChuyenGia, @SoNamKinhNghiem = SoNamKinhNghiem FROM inserted;
    
    IF @SoNamKinhNghiem >= 10
    BEGIN
        INSERT INTO ThongBao (MaDuAn, ThongBao, ThoiGian)
        VALUES (NULL, N'Chuyên gia đã được thăng cấp!', GETDATE());
    END;
END;

-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.
CREATE TRIGGER Trigger_CapNhatTrangThaiDuAnKhẩnCap
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaDuAn INT, @NgayBatDau DATE, @NgayKetThuc DATE;
    SELECT @MaDuAn = MaDuAn, @NgayBatDau = NgayBatDau, @NgayKetThuc = NgayKetThuc FROM inserted;
    
    IF DATEDIFF(DAY, GETDATE(), @NgayKetThuc) < 0.1 * DATEDIFF(DAY, @NgayBatDau, @NgayKetThuc)
    BEGIN
        UPDATE DuAn
        SET TrangThai = N'Khẩn cấp'
        WHERE MaDuAn = @MaDuAn;
    END;
END;


-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.

CREATE TRIGGER Trigger_CapNhatSoDuAnDangThucHien
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaChuyenGia INT;
    SELECT @MaChuyenGia = MaChuyenGia FROM inserted;
    
    UPDATE ChuyenGia
    SET SoDuAnDangThucHien = (SELECT COUNT(*) FROM ChuyenGia_DuAn WHERE MaChuyenGia = @MaChuyenGia)
    WHERE MaChuyenGia = @MaChuyenGia;
END;

-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.
CREATE TRIGGER Trigger_CapNhatTyLeThanhCongCongTy
ON DuAn
AFTER UPDATE
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM inserted;
    
    UPDATE CongTy
    SET TyLeThanhCong = (
        SELECT CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM DuAn WHERE MaCongTy = @MaCongTy)
        FROM DuAn WHERE MaCongTy = @MaCongTy AND TrangThai = N'Hoàn thành'
    )
    WHERE MaCongTy = @MaCongTy;
END;


-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.
CREATE TABLE LuongLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    MaChuyenGia INT,
    Luong INT,
    ThoiGian DATETIME,
    HanhDong NVARCHAR(50)
);

CREATE TRIGGER Trigger_GhiLogLuongChuyenGia
ON ChuyenGia
AFTER UPDATE
AS
BEGIN
    DECLARE @MaChuyenGia INT, @Luong INT;
    SELECT @MaChuyenGia = MaChuyenGia, @Luong = Luong FROM inserted;
    
    INSERT INTO LuongLog (MaChuyenGia, Luong, ThoiGian, HanhDong)
    VALUES (@MaChuyenGia, @Luong, GETDATE(), N'Update');
END;

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.
CREATE TRIGGER Trigger_CapNhatSoLuongChuyenGiaCapCao
ON ChuyenGia
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaCongTy INT;
    SELECT @MaCongTy = MaCongTy FROM inserted;
    
    UPDATE CongTy
    SET SoLuongChuyenGiaCapCao = (SELECT COUNT(*) FROM ChuyenGia WHERE MaCongTy = @MaCongTy AND CapDo >= 5)
    WHERE MaCongTy = @MaCongTy;
END;

-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.


CREATE TRIGGER Trigger_CapNhatTrangThaiDuAnCanBoSungNhanLuc
ON ChuyenGia_DuAn
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaDuAn INT, @SoLuongChuyenGia INT, @SoLuongYeuCau INT;
    SELECT @MaDuAn = MaDuAn FROM inserted;
    
    -- Giả sử yêu cầu là 5 chuyên gia cho mỗi dự án
    SET @SoLuongYeuCau = 5;
    
    SELECT @SoLuongChuyenGia = COUNT(*) FROM ChuyenGia_DuAn WHERE MaDuAn = @MaDuAn;
    
    IF @SoLuongChuyenGia < @SoLuongYeuCau
    BEGIN
        UPDATE DuAn
        SET TrangThai = N'Cần bổ sung nhân lực'
        WHERE MaDuAn = @MaDuAn;
    END;
END;
