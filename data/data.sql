USE master
GO
CREATE DATABASE FINAL_VER
GO
USE FINAL_VER
GO
CREATE TABLE MonHoc
    (
      tenMonHoc NVARCHAR(400) ,
      CONSTRAINT PK_MonHoc PRIMARY KEY ( tenMonHoc )
    )
CREATE TABLE Chuong
    (
      tenChuong NVARCHAR(400) ,
      tenMonHoc NVARCHAR(400) NOT NULL ,
      CONSTRAINT PK_Chuong PRIMARY KEY ( tenChuong ) ,
      CONSTRAINT FK_Chuong_MonHoc FOREIGN KEY ( tenMonHoc ) REFERENCES dbo.MonHoc ( tenMonHoc )
    )
CREATE TABLE TracNghiem
    (
      id INT IDENTITY(100000, 2) ,
      deBai NVARCHAR(400) NOT NULL ,
      doKho NVARCHAR(400) NOT NULL ,
      CONSTRAINT PK_TracNghiem PRIMARY KEY ( id )
    )
CREATE TABLE TuLuan
    (
      id INT IDENTITY(100001, 2) ,
      deBai NVARCHAR(400) NOT NULL ,
      doKho NVARCHAR(400) NOT NULL ,
      dapAn NVARCHAR(400) NOT NULL ,
      CONSTRAINT PK_TuLuan PRIMARY KEY ( id )
    )
CREATE TABLE TraLoiTracNghiem
    (
      dapAn NVARCHAR(400) ,
      id INT NOT NULL ,
      dungSai BIT NOT NULL ,
      CONSTRAINT PK_TraLoiTracNghiem PRIMARY KEY ( dapAn ) ,
      CONSTRAINT FK_TraLoiTracNghiem_TracNghiem FOREIGN KEY ( id ) REFERENCES dbo.TracNghiem ( id )
    )
CREATE TABLE TracNghiemChuong
    (
      id INT ,
      tenChuong NVARCHAR(400) ,
      CONSTRAINT FK_TracNghiemChuong_TracNghiem FOREIGN KEY ( id ) REFERENCES TracNghiem ( id ) ,
      CONSTRAINT FK_TracNghiemChuong_Chuong FOREIGN KEY ( tenChuong ) REFERENCES Chuong ( tenChuong )
    )
CREATE TABLE TuLuanChuong
    (
      id INT ,
      tenChuong NVARCHAR(400) ,
      CONSTRAINT FK_TuLuanChuong_TuLuan FOREIGN KEY ( id ) REFERENCES TuLuan ( id ) ,
      CONSTRAINT FK_TuLuanChuong_Chuong FOREIGN KEY ( tenChuong ) REFERENCES Chuong ( tenChuong )
    )
GO

CREATE PROC themMonHoc
    @tenMonHoc NVARCHAR(400)
AS
    BEGIN
        IF NOT EXISTS ( SELECT  *
                        FROM    dbo.MonHoc
                        WHERE   tenMonHoc = @tenMonHoc )
            BEGIN
                INSERT  dbo.MonHoc
                        ( tenMonHoc )
                VALUES  ( @tenMonHoc )
            END
    END
GO

CREATE PROC themChuong
    @tenChuong NVARCHAR(400) ,
    @tenMonHoc NVARCHAR(400)
AS
    BEGIN
        IF NOT EXISTS ( SELECT  *
                        FROM    dbo.Chuong
                        WHERE   tenChuong = @tenChuong )
            BEGIN
                INSERT  dbo.Chuong
                        ( tenChuong, tenMonHoc )
                VALUES  ( @tenChuong, @tenMonHoc )
            END
    END
GO

CREATE PROC themTracNghiem
    @deBai NVARCHAR(400) ,
    @doKho NVARCHAR(400)
AS
    BEGIN
        INSERT  dbo.TracNghiem
                ( deBai, doKho )
        VALUES  ( @deBai, @doKho )
    END
GO

CREATE PROC themTuLuan
    @deBai NVARCHAR(400) ,
    @doKho NVARCHAR(400) ,
    @dapAn NVARCHAR(400)
AS
    BEGIN
        INSERT  dbo.TuLuan
                ( deBai, doKho, dapAn )
        VALUES  ( @deBai, @doKho, @dapAn )
    END
GO

CREATE PROC themTuLuanChuong
    @tenChuong NVARCHAR(400)
AS
    BEGIN
        DECLARE @id INT
        SELECT TOP 1
                @id = id
        FROM    dbo.TuLuan
        ORDER BY id DESC
        INSERT  dbo.TuLuanChuong
                ( id, tenChuong )
        VALUES  ( @id, @tenChuong )
    END
GO

CREATE PROC themTracNghiemChuong
    @tenChuong NVARCHAR(400)
AS
    BEGIN
        DECLARE @id INT
        SELECT TOP 1
                @id = id
        FROM    dbo.TracNghiem
        ORDER BY id DESC
        INSERT  dbo.TracNghiemChuong
                ( id, tenChuong )
        VALUES  ( @id, @tenChuong )
    END
GO

CREATE PROC themTraLoiTracNghiem
    @dapAn NVARCHAR(400) ,
    @dungSai BIT
AS
    BEGIN
        DECLARE @id INT
        SELECT TOP 1
                @id = id
        FROM    dbo.TracNghiem
        ORDER BY id DESC
        IF NOT EXISTS ( SELECT  *
                        FROM    dbo.TracNghiem ,
                                dbo.TraLoiTracNghiem
                        WHERE   TracNghiem.id = TraLoiTracNghiem.id
                                AND dapAn = @dapAn )
            BEGIN
                INSERT  dbo.TraLoiTracNghiem
                        ( dapAn, id, dungSai )
                VALUES  ( @dapAn, @id, @dungSai )
            END
    END
GO

CREATE PROC xoaTuLuan @id INT
AS
    BEGIN
        DELETE  FROM dbo.TuLuanChuong
        WHERE   id = @id
        DELETE  FROM dbo.TuLuan
        WHERE   id = @id
        DECLARE @chuongCanXoa TABLE
            (
              tenChuong NVARCHAR(400)
            )
        INSERT  INTO @chuongCanXoa
                ( tenChuong
                )
                SELECT  dbo.Chuong.tenChuong
                FROM    dbo.Chuong
                EXCEPT
                ( SELECT    dbo.TuLuanChuong.tenChuong
                  FROM      dbo.TuLuanChuong
                  UNION
                  SELECT    dbo.TracNghiemChuong.tenChuong
                  FROM      dbo.TracNghiemChuong
                )

        DELETE  FROM dbo.Chuong
        WHERE   tenChuong = ANY ( SELECT    tenChuong
                                  FROM      @chuongCanXoa )

        DECLARE @monCanXoa TABLE
            (
              tenMonHoc NVARCHAR(400)
            )
        INSERT  @monCanXoa
                ( tenMonHoc
                )
                SELECT  dbo.MonHoc.tenMonHoc
                FROM    dbo.MonHoc
                EXCEPT
                SELECT  dbo.Chuong.tenMonHoc
                FROM    dbo.Chuong
        DELETE  FROM dbo.MonHoc
        WHERE   tenMonHoc = ANY ( SELECT    tenMonHoc
                                  FROM      @monCanXoa )
    END
GO
CREATE PROC xoaTracNghiem @id INT
AS
    BEGIN
        DELETE  FROM dbo.TraLoiTracNghiem
        WHERE   id = @id
        DELETE  FROM dbo.TracNghiemChuong
        WHERE   id = @id
        DELETE  FROM dbo.TracNghiem
        WHERE   id = @id
        DECLARE @chuongCanXoa TABLE
            (
              tenChuong NVARCHAR(400)
            )
        INSERT  INTO @chuongCanXoa
                ( tenChuong
                )
                SELECT  dbo.Chuong.tenChuong
                FROM    dbo.Chuong
                EXCEPT
                ( SELECT    dbo.TracNghiemChuong.tenChuong
                  FROM      dbo.TracNghiemChuong
                  UNION
                  SELECT    dbo.TuLuanChuong.tenChuong
                  FROM      dbo.TuLuanChuong
                )
        DELETE  FROM dbo.Chuong
        WHERE   tenChuong = ANY ( SELECT    tenChuong
                                  FROM      @chuongCanXoa )

        DECLARE @monCanXoa TABLE
            (
              tenMonHoc NVARCHAR(400)
            )
        INSERT  @monCanXoa
                ( tenMonHoc
                )
                SELECT  dbo.MonHoc.tenMonHoc
                FROM    dbo.MonHoc
                EXCEPT
                SELECT  dbo.Chuong.tenMonHoc
                FROM    dbo.Chuong
        DELETE  FROM dbo.MonHoc
        WHERE   tenMonHoc = ANY ( SELECT    tenMonHoc
                                  FROM      @monCanXoa )
    END
GO

INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'Địa lý' )
INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'GDCD' )
INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'Hóa học' )
INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'Lịch sử' )
INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'Sinh học' )
INSERT  [dbo].[MonHoc]
        ( [tenMonHoc] )
VALUES  ( N'Vật lý' )
GO 
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Các nước Đông Bắc Á' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Các nước Đông Nam Á' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Cách mạng khoa học-công nghệ và xu hướng toàn cầu hóa nửa sau thế kỉ XX' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Chiến tranh thế giới thứ hai' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Công dân bình đẳng trước pháp luật' ,
          N'GDCD'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Công dân với các quyền tự do cơ bản' ,
          N'GDCD'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Công suất điện', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Đại cương về hóa hữu cơ' ,
          N'Hóa học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Di truyền', N'Sinh học' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Di truyền và biến dị cấp phân tử' ,
          N'Sinh học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Di truyền và đột biến cấp phân tử' ,
          N'Sinh học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Địa lý các vùng kinh tế' ,
          N'Địa lý'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Địa lý dân cư', N'Địa lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Địa lý kinh tế', N'Địa lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Địa lý tự nhiên', N'Địa lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Điện năng', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Điện tích', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Điện trường', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Định luật Ôm', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Dòng điện không đổi' ,
          N'Vật lý'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Dòng điện trong các môi trường' ,
          N'Vật lý'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Đột biến cấp phân tử' ,
          N'Sinh học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Liên Xô và các nước Đông Âu' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Nguồn điện', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Nhóm Cacbon-Silic' ,
          N'Hóa học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Nhóm Nito-Photpho' ,
          N'Hóa học'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Nước Mĩ', N'Lịch sử' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Pháp luật và đời sống' ,
          N'GDCD'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Quyền bình đẳng của công dân trong một số lĩnh vực của đời sống xã hội' ,
          N'GDCD'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Quyền bình đẳng giữa các dân tộc, tôn giáo' ,
          N'GDCD'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Sự điện ly', N'Hóa học' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Tế bào', N'Sinh học' )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Tiến hóa', N'Sinh học' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Tình hình các nước sau chiến tranh' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Trật tự thế giới sau chiến tranh' ,
          N'Lịch sử'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Tụ điện', N'Vật lý' )
INSERT  [dbo].[Chuong]
        ( [tenChuong] ,
          [tenMonHoc]
        )
VALUES  ( N'Vị trí địa lí, phạm vi lãnh thổ' ,
          N'Địa lý'
        )
INSERT  [dbo].[Chuong]
        ( [tenChuong], [tenMonHoc] )
VALUES  ( N'Việt Nam', N'Địa lý' )
GO 

SET IDENTITY_INSERT [dbo].[TracNghiem] ON 
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100136 ,
          N'ở tế bào của sinh vật nhân sơ, mARN sau phiên mã sẽ: ' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100138 ,
          N'Trong cơ chế điều hòa hoạt động của Operon Lac ở vi khuẩn E.coli,gen điều hòa có vai trò:' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100140 ,
          N'Dạng đột biến gen nào sau đây khó có cơ hội biểu hiện kiểu hình nhất? ' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100142 ,
          N'Gen cấu trúc của sinh vật nhân thực gồm có:' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100144 ,
          N'Ở sv nhân sơ, Operon là: ' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100148 ,
          N'Vai trò nào sau đây không phải là của Prôtêin ?' ,
          N'9.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100152 ,
          N'Đột biến gen là: ' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100154 ,
          N'Trong quá trình tiến hoá, cách ly địa lý có vai trò: ' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100156 ,
          N'Cấu trúc nào sau đây trong trong tế bào không chứa axit nuclêic :' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100160 ,
          N'Một prôtêin bình thƣờng có 300 axit amin, trong đó axit amin thứ 200 là alanin . Gen tổng
hợp prôtêin đó bị đột biến xảy ra ở vị trí bộ ba mã hóa axit amin thứ 200 nhƣng vẫn tổng hợp ra prôtêin hoàn
toàn bình thƣờng. Dạng đột biến gen nào có thể gây ra hện tƣợng trên? ' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100162 ,
          N' Các yếu tố quyết định sự khác biệt trong cấu trúc các loại ARN là: ' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100164 ,
          N'Loại đột biến giao tử là đột biến: ' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100166 ,
          N'Phát biểu nào dƣới đây là không đúng khi nói về quá trình dịch mã?' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100170 ,
          N'Phát biểu không đúng về đột biến gen là: ' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100172 ,
          N'Điều kiện để 1 vật dẫn điện là' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100174 ,
          N'Trong các hiện tượng sau, hiện tượng nhiễm điện do hưởng ứng là hiện tượng' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100178 ,
          N'Tổng số proton và electron của một nguyên tử có thể là số nào sau đây?' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100180 ,
          N'Điện trường là' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100182 ,
          N'Cường độ điện trường tại một điểm đặc trưng cho' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100184 ,
          N'Tại một điểm xác định trong điện trường tĩnh, nếu độ lớn của điện tích thử tăng 2 lần thì độ lớn cường độ điện trường' ,
          N'9.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100188 ,
          N'Trong các nhận xét về tụ điện dưới đây, nhân xét không đúng là' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100190 ,
          N'Fara là điện dung của một tụ điện mà' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100192 ,
          N'Dòng điện được định nghĩa là' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100194 ,
          N'Trong các nhận định dưới đây, nhận định không đúng về dòng điện là:' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100196 ,
          N'Cho 3 quả cầu kim loại tích điện lần lượt tích điện là + 3 C, - 7 C và – 4 C. Khi cho chúng được tiếp xúc với nhau thì điện tích của hệ là' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100198 ,
          N'Nguồn điện tạo ra hiệu điện thế giữa hai cực bằng cách' ,
          N'9.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100200 ,
          N'Trong các nhận định về suất điện động, nhận định không đúng là:' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100202 ,
          N'Điện năng tiêu thụ của đoạn mạch không tỉ lệ thuận với' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100204 ,
          N'Cho đoạn mạch có hiệu điện thế hai đầu không đổi, khi điện trở trong mạch được điều chỉnh tăng 2 lần thì trong cùng
khoảng thời gian, năng lượng tiêu thụ của mạch' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100206 ,
          N'Trong các nhận xét sau về công suất điện của một đoạn mạch, nhận xét không đúng là' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100208 ,
          N'Nhận xét nào sau đây đúng? Theo định luật Ôm cho toàn mạch thì cường độ dòng điện cho toàn mạch' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100210 ,
          N'Khi xảy ra hiện tượng đoản mạch, thì cường độ dòng điện trong mạch' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100212 ,
          N'Khi khởi động xe máy, không nên nhấn nút khởi động quá lâu và nhiều lần liên tục vì' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100214 ,
          N'Trong các nhận định sau, nhận định nào về dòng điện trong kim loại là không đúng?' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100216 ,
          N'Trộn 40 ml dung dịch H2SO4 0,25M với 60ml dung dịch NaOH 0,5M. Giá trị pH của dung dịch thu được sau khi trộn là' ,
          N'7.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100218 ,
          N'Dãy gồm các ion (không kể đến sự phân li của nước) cùng tồn tại trong một dung dịch là' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100220 ,
          N'Cặp công thức của Litinitrua và nhôm nitrua là:' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100222 ,
          N'Muốn cho cân bằng của phản ứng nhiệt độ tổng hợp amoniac chuyển dịch sang phải cần phải đồng thờ' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100224 ,
          N'Các bon và silic đều có tính chất nào sau đây giống nhau :' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100226 ,
          N'Trong nhóm IVA,theo chiều tăng của ĐTHN,theo chiều từ C đến Pb,nhận định nào sau đây sai:' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100228 ,
          N'Thành phần các nguyên tố trong hợp chất hữu cơ' ,
          N'9.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100230 ,
          N'Đặc điểm chung của các phân tử hợp chất hữu cơ là
1. thành phần nguyên tố chủ yếu là C và H.
2. có thể chứa nguyên tố khác như Cl, N, P, O.
3. liên kết hóa học chủ yếu là liên kết cộng hoá trị.
4. liên kết hoá học chủ yếu là liên kết ion.
5. dễ bay hơi, khó cháy.
6. phản ứng hoá học xảy ra nhanh.
Nhóm các ý đúng là:' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100232 ,
          N'Phát biểu nào sau được dùng để định nghĩa công thức đơn giản nhất của hợp chất hữu cơ ?' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100234 ,
          N'Điểm khác biệt giữa 2 cơ chế nhân đôi và phiên mã ở sinh vật nhân thực là:
1- Enzim sử dụng cho 2 quá trình.
2- Quá trình nhân đôi cần năng lƣợng còn phiên mã thì không cần.
3- Nhân đôi diễn ra trong nhân còn phiên mã diễn ra ở tế bào chất.
4- Số lƣợng mạch dùng làm mạch khuôn và số lƣợng đơn phân môi trƣờng cung cấp.
5- Nguyên tắc bổ sung giữa các cặp bazơ nitơ khác nhau.' ,
          N'7.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100236 ,
          N'Những nước nào tham gia Hội nghị Ianta ?' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100238 ,
          N'Một trong những nội dung quan trọng của Hội nghị Ianta là:' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100240 ,
          N'Hội nghị Ianta diễn ra từ:' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100242 ,
          N'Hội nghị Ianta đã họp ở đâu?' ,
          N'7.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100244 ,
          N'Hội nghị Ianta có ảnh hưởng như thế nào đối với thế giới sau chiến tranh ?' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100246 ,
          N'Hiến chương Liên hợp quốc được thông qua tại Hội nghị nào ?' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100248 ,
          N'Nguyên tắc nhất trí giữa 5 nuớc lớn trong tổ chức Liên hợp quốc được đề ra vào thời điểm nào ?' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100250 ,
          N'Kế hoạch 5 năm khôi phục kinh tế sau chiến tranh ở Liên Xô diễn ra trong khoảng thời gian nào ?' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100252 ,
          N'Thành tựu của kế hoạch khôi phục kinh tế sau chiến tranh ờ Liên Xô (1945- 1950) ?' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100254 ,
          N'Việc Liên Xô chế tạo thành công bom nguyên tử có ý nghĩa gì ?' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100256 ,
          N'Vị trí của nền kinh tế Liên Xô trong những năm 1950 đến nửa đầu những năm 70 ?' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100258 ,
          N'Một trong những thành công của Liên Xô trong hơn 20 năm xây dựng chủ nghĩa xã hội (1950 - những nãm 70) là :' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100260 ,
          N'Trong số các nước sau, nước nào không thuộc khu vực Đông Bắc Á ?' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100262 ,
          N'Tình hình chung củạ khu vực Đồng Bắc Á trong nửa sau thế kỉ XX là:' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100264 ,
          N'Điều mà cách mạng Trung Quốc chua thực hiện sau cuộc nội chiến (1946 - 1949)?' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100266 ,
          N'Những thành viên sáng lập tổ chức ASEAN là :' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100268 ,
          N'Sau khỉ giành được độc lập, nhóm 5 nước sáng lập ASEAN đã thực hiện chiến lược phát triển kính tế nào ?' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100270 ,
          N'Trong 30 năm cuối của thế kỉ XX, kinh tế ở nhóm nước sáng lập tổ chứ ASEAN đã có những chuyển biến gì ?' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100272 ,
          N'Từ 1945 đến 1950, Mĩ là:' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100274 ,
          N'Dấu hiệu nào chúng tỏ sau Chiến tranh thế giới thứ II, Mĩ là một trung tâm kinh tế - tài chính lớn nhất thế giới ?' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100276 ,
          N'Yếu tố nào không phải là nguyên nhân sự phát triển của kinh tế Mĩ sau Chiến tranh thế giới thứ II ?' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100278 ,
          N'Công cuộc Đổi mới nền kinh tế nước ta được bắt đầu từ năm' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100280 ,
          N'Nền kinh tế Việt Nam muốn tăng trưởng bền vững' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100282 ,
          N'cơ cấu ngành kinh tế trong GDP của nước ta đang chuyển dịch theo hướng' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100284 ,
          N'ý nào dưới đây không đúng với vùng Trung du và miền núi Bắc Bộ?' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100286 ,
          N'Tỉnh nào dưới đây thuộc vùng Trung du và miền núi Bắc Bộ ?' ,
          N'8.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100288 ,
          N'Pháp luật là quy tắc xử sự chung, được áp dụng đối với tất cả mọi người là thể hiện đặc trưng nào dưới đây của pháp luật?' ,
          N'3.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100290 ,
          N'Pháp luật do Nhà nước ban hành và đảm bảo thực hiện' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100292 ,
          N'Mọi công dân đều được hưởng quyền và phải thực hiện nghĩa vụ theo quy định của pháp luật là biểu hiện công dân bình đẳng về' ,
          N'4.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100294 ,
          N'Bất kì công dân nào vi phạm pháp luật đều phải bị xử lý theo quy định của pháp luật là thể hiện bình đẳng về' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100296 ,
          N'Quyền và nghĩa vụ công dân không bị phân biệt bởi dân tộc, giới tính và địa vị xã hội là thể hiện quyền bình đẳng nào dưới đây của công dân ?' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100298 ,
          N'Mọi doanh nghiệp đều có quyền tự do lựa chọn hình thức tổ chức kinh doanh là thể hiện quyền bình đẳng' ,
          N'5.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100300 ,
          N'Bình đẳng giữa cha mẹ và con có nghĩa là' ,
          N'6.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100302 ,
          N'Các dân tộc đều được Nhà nước và pháp luật tôn trọng, tạo điều kiện phát triển mà không bị phân biệt đối xử là thể hiện quyền bình đẳng nào dưới đây ?' ,
          N'2.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100304 ,
          N'Việc đảm bảo tỷ lệ thích hợp người dân tộc thiểu số trong các cơ quan quyền lực nhà nước là thể hiện' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100306 ,
          N'Tự ý bắt và giam giữ người không có căn cứ là hành vi xâm phạm tới quyền nào dưới đây của công dân ?' ,
          N'10.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100308 ,
          N'Trong trường hợp nào sau đây ta có một tụ điện?' ,
          N'1.0/10'
        )
INSERT  [dbo].[TracNghiem]
        ( [id] ,
          [deBai] ,
          [doKho]
        )
VALUES  ( 100310 ,
          N'Người phạm tội quả tang hoặc đang bi truy nã thì' ,
          N'9.0/10'
        )
SET IDENTITY_INSERT [dbo].[TracNghiem] OFF
GO

INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100138 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100136 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100140 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100142 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100144 ,
          N'Di truyền và đột biến cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100234 ,
          N'Di truyền và đột biến cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100234 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100170, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100172, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100172, N'Điện trường' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100174, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100174, N'Điện trường' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100198, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100178, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100180, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100180, N'Điện trường' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100182, N'Điện trường' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100184, N'Điện trường' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100188, N'Tụ điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100190, N'Tụ điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100192, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100192, N'Nguồn điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100194, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100194, N'Nguồn điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100198, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100198, N'Nguồn điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100200, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100200, N'Nguồn điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100202, N'Điện năng' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100202, N'Công suất điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100204, N'Điện năng' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100204, N'Công suất điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100206, N'Điện năng' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100206, N'Công suất điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100208, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100208, N'Định luật Ôm' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100210, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100210, N'Định luật Ôm' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100212, N'Dòng điện không đổi' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100212, N'Định luật Ôm' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100214 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100216, N'Sự điện ly' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100218, N'Sự điện ly' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100220, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100222, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100224, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100226, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100228 ,
          N'Đại cương về hóa hữu cơ'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100230 ,
          N'Đại cương về hóa hữu cơ'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100232 ,
          N'Đại cương về hóa hữu cơ'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100236 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100238 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100240 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100242 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100244 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100246 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100248 ,
          N'Trật tự thế giới sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100250 ,
          N'Liên Xô và các nước Đông Âu'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100250 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100252 ,
          N'Liên Xô và các nước Đông Âu'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100252 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100254 ,
          N'Liên Xô và các nước Đông Âu'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100254 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100256 ,
          N'Liên Xô và các nước Đông Âu'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100256 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100258 ,
          N'Liên Xô và các nước Đông Âu'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100258 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100260, N'Các nước Đông Bắc Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100260 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100262, N'Các nước Đông Bắc Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100262 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100264, N'Các nước Đông Bắc Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100264 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100266, N'Các nước Đông Nam Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100266 ,
          N'Chiến tranh thế giới thứ hai'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100268, N'Các nước Đông Nam Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100270, N'Các nước Đông Nam Á' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100272, N'Nước Mĩ' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100272 ,
          N'Tình hình các nước sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100274 ,
          N'Tình hình các nước sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100274, N'Nước Mĩ' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100276 ,
          N'Tình hình các nước sau chiến tranh'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100196, N'Điện tích' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100148 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100148, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100148, N'Di truyền' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100152 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100152, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100154, N'Tiến hóa' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100156, N'Tế bào' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100160 ,
          N'Di truyền và biến dị cấp phân tử'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100162, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100164, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100166, N'Đột biến cấp phân tử' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100278, N'Địa lý kinh tế' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100278, N'Việt Nam' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100280, N'Địa lý kinh tế' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100282, N'Địa lý kinh tế' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100282, N'Việt Nam' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100284 ,
          N'Địa lý các vùng kinh tế'
        )
GO
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100284, N'Việt Nam' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100286 ,
          N'Địa lý các vùng kinh tế'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100286, N'Việt Nam' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100288 ,
          N'Pháp luật và đời sống'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100290 ,
          N'Pháp luật và đời sống'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100292 ,
          N'Công dân bình đẳng trước pháp luật'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100294 ,
          N'Công dân bình đẳng trước pháp luật'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100296 ,
          N'Công dân bình đẳng trước pháp luật'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100298 ,
          N'Quyền bình đẳng của công dân trong một số lĩnh vực của đời sống xã hội'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100300 ,
          N'Quyền bình đẳng của công dân trong một số lĩnh vực của đời sống xã hội'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100302 ,
          N'Quyền bình đẳng giữa các dân tộc, tôn giáo'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100304 ,
          N'Quyền bình đẳng giữa các dân tộc, tôn giáo'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100306 ,
          N'Công dân với các quyền tự do cơ bản'
        )
INSERT  [dbo].[TracNghiemChuong]
        ( [id], [tenChuong] )
VALUES  ( 100308, N'Tụ điện' )
INSERT  [dbo].[TracNghiemChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100310 ,
          N'Công dân với các quyền tự do cơ bản'
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' điện trường tại điểm đó về phương diện dự trữ năng lượng' ,
          100182 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' Giảm áp suất và tăng nhiệt độ' ,
          100222 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N' Li3N và AlN', 100220, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N' LiN3 và Al3N', 100220, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' môi trường không khí quanh điện tích.' ,
          100180 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' tác dụng lực của điện trường lên điện tích tại điểm đó.' ,
          100182 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' tách electron ra khỏi nguyên tử và chuyển electron và ion về các cực của nguồn.' ,
          100198 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' thể tích vùng có điện trường là lớn hay nhỏ.' ,
          100182 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N' thường có C, H hay gặp O, N, sau đó đến halogen, S, P.' ,
          100228 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'. Đƣợc tạo ra sau khi cắt bỏ các đoạn exôn khỏi mARN sơ khai' ,
          100148 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1, 2, 3', 100234, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1, 3, 4', 100234, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1, 4 , 5', 100234, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'12', 100178, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'13', 100178, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'14', 100178, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'15', 100178, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'16', 100178, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1945 – 1949.', 100250, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1945- 1951.', 100250, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1946- 1950.', 100250, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1947-1951', 100250, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1976', 100278, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1986', 100278, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1991', 100278, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'1C', 100196, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'2, 3, 4', 100234, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'2, 3, 5, 6', 100230, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'2000', 100278, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'2C', 100196, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'3, 4, 5', 100234, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'3, 5, 6', 100230, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'3C', 100196, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'4, 5, 6', 100230, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'4C', 100196, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Ag+, Na+, NO3-, Cl', 100218, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'ai cũng có quyền bắt.' ,
          100310 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Al3+, NH4+, Br-, OH- ' ,
          100218 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Anh - Mĩ - Liẽn Xô.', 100236, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Anh - Pháp - Đức.', 100236, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Anh - Pháp - Mĩ.', 100236, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Ápganixtan, Nêpan.', 100260, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ba nước phe Đồng minh bàn bạc, thoả thuận khu vực đóng quân tại các nước nhằm giải giáp quân đội phát xít; phân chia phạm vi ảnh hưởng ở châu Âu và châu Á.' ,
          100238 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bán kính nguyên tử giảm dần' ,
          100226 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bằng chính sách của Nhà nước.' ,
          100290 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bằng chủ trương của Nhà nước.' ,
          100290 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bằng quyền lực Nhà nước.' ,
          100290 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bằng uy tín của Nhà nước.' ,
          100290 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'bao gồm tất cả các nguyên tố trong bảng tuần hoàn.' ,
          100228 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Bình đẳng dân tộc.', 100296, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng giữa các dân tộc.' ,
          100302 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng giữa các địa phương.' ,
          100302 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng giữa các tầng lớp xã hội.' ,
          100302 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng giữa các thành phần dân cư.' ,
          100302 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng quyền và nghĩa vụ.' ,
          100296 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Bình đẳng tôn giáo.', 100296, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Bình đẳng về thành phần xã hội.' ,
          100296 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Brunây, Thái Lan, Singapo, Malaixia, Mianma.' ,
          100266 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các biến dị tổ hợp xuất hiện qua sinh sản hữu tính.' ,
          100152 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'các điện tích bị mất đi' ,
          100172 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước đã chấm dứt tình trạng nhập siêu.' ,
          100270 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước đã hoàn thành quá trình công nghiệp hoá.' ,
          100270 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước Đông Bắc Á tập trung tiến hành cuốc đấu tranh chống chủ nghĩa thực dân, giành độc lập dân tộc, thống nhất đất nước.' ,
          100262 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước ở khu vực Đông Bắc Á bắt tay xây dựng và phát triển nền kinh tế và đã đạt được những thành tựu quan trọng, bộ mặt đất nước được đổi mới.' ,
          100262 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước phát xít Đức, Italia kí văn kiện đầu hàng phe Đồng minh vô điều kiện.' ,
          100238 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các nước thắng trận thoả thuận viêc phân chia Đức thành haỉ nước Đông Đức và Tây Đức.' ,
          100238 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Các tập đoàn tư bản lũng đoạn Mĩ có sức sản xuất, cạnh tranh lớn, có hiệu quả cả trong và ngoài nước.' ,
          100276 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Cần có nhịp độ phát triển cao; có cơ cấu hợp lí giữa các ngành, các thành phần kinh tế và các vùng lãnh thổ' ,
          100280 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cắt bỏ các đoạn exon, nối các đoạn intron lại với nhau.' ,
          100136 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cắt bỏ các đoạn intron, nối các đoạn exon lại với nhau' ,
          100136 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Cấu trúc không gian của ARN' ,
          100162 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cha mẹ cần tạo điều kiện tốt hơn cho con trai.' ,
          100300 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cha mẹ có quyền yêu thương con gái hơn con trai.' ,
          100300 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cha mẹ khôn phân biệt đối xử giữa các con.' ,
          100300 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cha mẹ yêu thương, chăm sóc con đẻ hơn con nuôi.' ,
          100300 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chỉ cần có cơ cấu hợp lí giữa các ngành và các thành phần kinh tế' ,
          100280 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chỉ cần có cơ cấu hợp lí giữa các vùng lãnh thổ' ,
          100280 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chỉ cần có tốc độ tăng trưởng GDP cao' ,
          100280 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'chỉ công an mới có quyền bắt.' ,
          100310 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chiến lược : Công nghiệp hoá thay thế nhập khẩu.' ,
          100268 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chiến lược : Hiện đại hoá nông nghiệp, đẩy mạnh xuất khẩu nông sản.' ,
          100268 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chiến lược: Công nghiệp hoá lấy xuất khẩu làm chủ đạo.' ,
          100268 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chiến lược: Tập trung phát triển công nghiệp nhẹ nhằm đáp ứng nhu cầu hàng tiêu dùng trong nước và có hàng xuất khẩu.' ,
          100268 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Chính sách Kinh tế mới của Tổng thống Mĩ Rugiơven đã phát huy tác dụng trên thực tế.' ,
          100276 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'có chứa các điện tích tự do.' ,
          100172 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Có diện tích rộng nhất so với các vùng khác trong cả nước' ,
          100284 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Có số dân đông nhất so với các vùng khác trong cả nước' ,
          100284 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Có sự phân hóa thành hai tiểu vùng' ,
          100284 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Có tính khử mạnh', 100224, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Có tính khử và tính oxi hóa' ,
          100224 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Có tính oxi hóa mạnh' ,
          100224 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Cộng hòa dân chủ nhân dân Triều Tiên, Nhật Bản.' ,
          100260 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công nghiệp phát triển mạnh, chiếm tỉ trọng trong nền kinh tế quốc dân cao hơn nông nghiệp.' ,
          100270 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công suất có đơn vị là oát (W).' ,
          100206 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công suất tỉ lệ nghịch với thời gian dòng điện chạy qua mạch' ,
          100206 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công suất tỉ lệ thuận với cường độ dòng điện chạy qua mạch.' ,
          100206 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công suất tỉ lệ thuận với hiệu điện thế hai đầu mạch' ,
          100206 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công thức đơn giản nhất là công thức biểu thị số nguyên tử của mỗi nguyên tố trong phân tử' ,
          100232 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công thức đơn giản nhất là công thức biểu thị tỉ lệ phần trăm số mol của mỗi nguyên tốtrong phân tử.' ,
          100232 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công thức đơn giản nhất là công thức biểu thị tỉ lệ số nguyên tử C và H có trong phân tử' ,
          100232 ,
          0
        )
GO
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Công thức đơn giản nhất là công thức biểu thị tỉ lệ tối giản về số nguyên tử của các nguyên tốtrong phân tử' ,
          100232 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Cường độ dòng điện càng lớn thì trong một đơn vị thời gian điện lượng chuyển qua tiết diện thẳng của vật dẫn càngnhiều.' ,
          100194 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Cường độ dòng điện được đo bằng ampe kế.' ,
          100194 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'cường độ dòng điện trong mạch.' ,
          100202 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đàm phán, kí kết các hiệp ước với các nước phát xít bại trận.' ,
          100238 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đánh dấu sự hình thành một trật tự thế giới mới sau chiến tranh.' ,
          100244 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đầu thanh kim loại bị nhiễm điện khi đặt gần 1 quả cầu mang điện.' ,
          100174 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đều phản ứng được với NaOH' ,
          100224 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Điện dung của tụ càng lớn thì tích được điện lượng càng lớn.' ,
          100188 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Điện dung của tụ có đơn vị là Fara (F).' ,
          100188 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Điện dung đặc trưng cho khả năng tích điện của tụ' ,
          100188 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Độ âm điện giảm dần', 100226, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đơn vị của cường độ dòng điện là A.' ,
          100194 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đơn vị của suất điện động là Jun' ,
          100200 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'dòng chuyển dời có hướng của các điện tích' ,
          100192 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'dòng chuyển động của các điện tích' ,
          100192 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'động cơ đề sẽ rất nhanh hỏng' ,
          100212 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Dòng điện không đổi là dòng điện chỉ có chiều không thay đổi theo thời gian.' ,
          100194 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Dòng điện trong kim loại là dòng chuyển dời có hướng của các electron tự do;' ,
          100214 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'dòng đoản mạch kéo dài tỏa nhiệt mạnh sẽ làm hỏng acquy' ,
          100212 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đƣợc tạo ra sau khi cắt bỏ các đoạn intrôn khỏi mARN sơ khai' ,
          100148 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đƣợc tạo ra trực tiếp từ mạch khuôn của phân tử ADN mẹ' ,
          100148 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen có thể làm biến đổi đột ngột một hoặc một số tính trạng nào đó trên cơ thể sinh vật' ,
          100170 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen làm biến đổi một hoặc một số cặp nuclêôtit trong cấu trúc của gen' ,
          100170 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen làm phát sinh các alen mới trong quần thể' ,
          100170 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen làm thay đổi vị trí của gen trên nhiễm sắc thể.' ,
          100170 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen lặn khi tạo giao tử.' ,
          100140 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen lặn ở giai đoạn tiền phôi.' ,
          100140 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen lặn ở tế bào sinh dƣỡng.' ,
          100140 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Đột biến gen lặn xảy ra trong nguyên phân.' ,
          100140 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Giải phóng toàn bộ Trung Hoa lục địa.' ,
          100264 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'giảm 2 lần', 100204, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'giảm 2 lần.', 100184, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'giảm 4 lần', 100204, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Giảm áp suất và giảm nhiệt độ' ,
          100222 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Giảm tỉ trọng nông – lâm – ngư nghiệp, giảm tỉ trọng dịch vụ' ,
          100282 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Giảm tỉ trọng nông – lâm – ngư nghiệp, tăng tỉ trọng công nghiệp – xây dựng và tiến tới ổn định dịch vụ' ,
          100282 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'giảm về 0', 100210, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'giữa hai bản tụ có điện môi với hằng số điện môi bằng 1.' ,
          100190 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'giữa hai bản tụ có hiệu điện thế 1V thì nó tích được điện tích 1 C' ,
          100190 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'giữa hai bản tụ có một hiệu điện thế không đổi thì nó được tích điện 1 C' ,
          100190 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'gồm có C, H và các nguyên tố khác.' ,
          100228 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'H+, Fe3+, NO3-, SO42-' ,
          100218 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Hà Nam', 100286, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'hai tấm gỗ khô đặt cách nhau một khoảng trong không khí' ,
          100308 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'hai tấm kẽm ngâm trong dung dịch axit.' ,
          100308 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'hai tấm nhôm đặt cách nhau một khoảng trong nước nguyên chất.' ,
          100308 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'hai tấm nhựa phủ ngoài một lá nhôm.' ,
          100308 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hạn chế sự giao phối tự do giữa các cá thể thuộc các quần thể cùng loài.' ,
          100154 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hạn chế sự giao phối tự do giữa các cá thể thuộc các quần thể khác loài' ,
          100154 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Hàn Quốc, Đài Loan.', 100260, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hiệu điện thế càng lớn thì điện dung của tụ càng lớn.' ,
          100188 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'hiệu điện thế hai đầu mạch.' ,
          100202 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hình thành nền nông nghiệp sản xuất lớn, hiện đại.' ,
          100270 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hoạt hóa enzim phân giải Lactôzơ' ,
          100138 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Hội nghị Ianta.', 100246, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Hội nghị Pari.', 100246, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Hội nghị Pôt-xđam.', 100246, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Hội nghị Xan Phran-xi-xcô.' ,
          100246 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'hỏng nút khởi động', 100212, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Inđônêxia, Maiaixia, Philippin, Singapo, Thái Lan.' ,
          100266 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Inđônêxia, Philippin, Singapo, Mianma, Maiaixia.' ,
          100266 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Khẳng định vai trò to lớn của Liên Xô đổi với sự phát triển phong trào cách mạng thế gỉới.' ,
          100254 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Khi trong kim loại có dòng điện thì electron sẽ chuyển động cùng chiều điện trường.' ,
          100214 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'khoảng cách giữa hai bản tụ là 1mm.' ,
          100190 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Không di truyền.', 100164, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'không đổi', 100204, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'không đổi so với trước' ,
          100210 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'không đổi.', 100184, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'không xác định', 100184, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Kinh tế Mĩ chiếm gần 40% tổng sản phẩm kinh tế thế giới.' ,
          100274 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Kinh tế Mĩ chiếm hơn 50% tổng sản phẩm kinh tế thế giới.' ,
          100274 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Là điều kiện làm biến đổi kiểu hình của sinh vật theo hƣớng thích nghi' ,
          100154 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'là dòng chuyển dời có hướng của electron' ,
          100192 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'là dòng chuyển dời có hướng của ion dương.' ,
          100192 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Là quốc gỉa có thu nhập bình quân đầu người cao nhất châu Âu.' ,
          100258 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Là sự kiện đánh dấu sự xác lập vai trò thống trị thế giới của chủ nghĩa đế quốc Mĩ.' ,
          100244 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'làm biến mất electron ở cực dương' ,
          100198 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Làm nảy sinh những mâu thuẫn mới giữa các nước đế quốc với các nước đế quốc.' ,
          100244 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Lạp thể ', 100156, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Lật đổ nền thống trị của Quốc Dân đảng ở Nam Kinh.' ,
          100264 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Li2N3 và Al2N3', 100220, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Li3N2 và Al3N2', 100220, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Liên Xô', 100242, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Liên Xô là cường quốc công nghiệp đứng hàng thứ hai trên thế giới.' ,
          100256 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Liên Xô là cường quốc công nghiệp thứ hai ở châu Âu.' ,
          100256 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Liên Xô là một nước có nền nông nghiệp hiện đại nhất thế giới.' ,
          100256 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Liên Xô là siêu cường kinh tế duy nhất.' ,
          100256 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Liên Xô trở thành nước đầu tiên sở hữu vũ khí nguyên tử.' ,
          100254 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Lưới nội chất trơn ', 100156, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'mất một cặp nuclêôtit cuối của bộ ba mã hóa axit amin thứ 200 nhƣng lại giống với cặp nuclêôtit bên cạnh.' ,
          100160 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Mg2+, K+, SO42-, PO43- ' ,
          100218 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Mĩ - Liên Xô - Trung Quốc.' ,
          100236 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Mĩ đã có sự điều chính về cơ cấu sản xuất, đổi mới kĩ thuật nhằm nâng cao năng suất lao động.' ,
          100276 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Mĩanma, Philípin, Singapo, Malaixia, Brunây.' ,
          100266 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'môi trường bao quanh điện tích, gắn với điện tích và tác dụng lực điện lên các điện tích khác đặt trong nó' ,
          100180 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'môi trường chứa các điện tích.' ,
          100180 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'môi trường dẫn điện', 100180, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Một trong 3 trung tâm kinh tế - tài chính lớn của thế giới.' ,
          100272 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Mùa hanh khô, khi mặc quần vải tổng hợp thường thấy vải bị dính vào người.' ,
          100174 ,
          1
        )
GO
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ngày 12 đến 22/4/ 1945' ,
          100240 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ngày 2 đến 12/4/1945.' ,
          100240 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ngày 2 đến 14/2/1945.' ,
          100240 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ngày 4 đến 11/2/1945' ,
          100240 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'ngay lập tức đi qua màng nhân vào tế bào chất.' ,
          100136 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'nghĩa vụ và trách nhiệm.' ,
          100292 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nguyên nhân điện trở của kim loại là do sự mất trật tự trong mạng tinh thể;' ,
          100214 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Nhân', 100156, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'nhất thiết phải có cacbon, thường có H, hay gặp O, N sau đó đến halogen, S, P...' ,
          100228 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nhiệt độ của kim loại càng cao thì dòng điện qua nó bị cản trở càng nhiều;' ,
          100214 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'nhiệt độ của vật dẫn trong mạch.' ,
          100202 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nhóm các gen cấu trúc có chức năng khác nhau phân bố thành từng cụm có chung một gen điều hoà' ,
          100144 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nhóm các gen chỉ huy cùng chi phối các hoạt động của một gen cấu trúc' ,
          100144 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nhóm gen cấu trúc có liên quan về chức năng phân bố thành từng cụm có chung một gen điều hoà' ,
          100144 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nhóm gen cấu trúc phân bố liền nhau tập trung thành từng cụm' ,
          100144 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Nước Anh', 100242, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nước đầu tiên phóng thành công vệ tinh nhân tạo bay vào quỹ đạo trái đất.' ,
          100272 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Nước Pháp', 100242, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Nước tiên phong thực hiện cuộc "cách mạng xanh" trong nông nghiệp.' ,
          100258 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Ở tế bào nhân sơ, sau khi quá trình dịch mã kết thúc, foocmin mêtiônin đƣợc cắt khỏi chuỗi pôlipeptit.' ,
          100166 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'pH=12.', 100216, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'pH=13. ', 100216, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'pH=14.', 100216, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'pH=9.', 100216, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'phải chờ ý kiến của cấp trên rồi mới được bắt.' ,
          100310 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'phải xin lệnh khẩn cấp để bắt.' ,
          100310 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Quả cầu kim loại bị nhiễm điện do nó chạm vào thanh nhựa vừa cọ xát vào len dạ' ,
          100174 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Quyền bất khả xâm phạm về thân thể.' ,
          100306 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'quyền bình đẳng giữa các công dân.' ,
          100304 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'quyền bình đẳng giữa các dân tộc.' ,
          100304 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'quyền bình đẳng giữa các vùng miền.' ,
          100304 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'quyền bình đẳng trong công việc chung của Nhà nước.' ,
          100304 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Quyền được bảo hộ về tính mạng và sức khỏe.' ,
          100306 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Quyền tự do cá nhân.' ,
          100306 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Quyền tự do thân thể.' ,
          100306 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'quyền và nghĩa vụ.', 100292, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'quyền và trách nhiệm.' ,
          100292 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng công nghiệp Mĩ nửa sau những năm 40 chiếm gần 40% tổng sản lượng công nghiệp toàn thế giới.' ,
          100274 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng công nghiệp Mĩ nửa sau những năm 40 chiếm hơn 60% tổng sản lượng công nghiệp toàn thế giới.' ,
          100274 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng cổng nghiệp tăng 73%, nông nghiệp đạt mức trước chỉến tranh (năm 1940).' ,
          100252 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng công nghiệp và nông nghiệp đều tăng 73%.' ,
          100252 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng công nghiệp và nông nghiệp năm 1950 đạt mức sản lượng năm 1940.' ,
          100252 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sản lượng nông nghiệp, công nghiệp đểu vượt mức sản lượng năm 1940.' ,
          100252 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sau khi đƣợc tổng hợp thì nó cuộn xoắn để thực hiện chức năng sinh học' ,
          100148 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sau khi hoàn tất quá trình dịch mã, ribôxôm táchkhỏi mARN và giữ nguyên cấu trúc để chuẩn bị cho quá trình dịch mã tiếp theo.' ,
          100166 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'sinh ra electron ở cực âm.' ,
          100198 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'sinh ra ion dương ở cực dương.' ,
          100198 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Số lƣợng, thành phần các loại ribônuclêôtit trong cấu trúc' ,
          100162 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Số lƣợng, thành phần, trật tự của các loại ribônuclêôtit và cấu trúc không gian của ARN' ,
          100162 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Số oxi hoá cao nhất là +4' ,
          100226 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sự biến đổi đột ngột về cấu trúc của ADN.' ,
          100152 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sự biến đổi đột ngột về cấu trúc di truyền của NST.' ,
          100152 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Sự biến đổi vật chất di truyền xảy ra ở cấp độ tế bào hay cấp độ phân tử' ,
          100152 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Suất điện động của nguồn có trị số bằng hiệu điện thế giữa hai cực khi mạch ngoài hở' ,
          100200 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Suất điện động được đo bằng thương số công của lực lạ dịch chuyển điện tích ngược nhiều điện trường và độ lớn điệntích dịch chuyển' ,
          100200 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Suất điện động là đại lượng đặc trưng cho khả năng sinh công của nguồn điện' ,
          100200 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tác động làm biến đổi kiểu gen của các cá thể và vốn gen của quần thể' ,
          100154 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tại Hội nghị I-an-ta (tháng 2/1945).' ,
          100248 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tại Hội nghị Pốt-xđam (tháng 7/1945).' ,
          100248 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tại Hội nghị San Phran-xi-xco (Tháng 4 - 6/1945).' ,
          100248 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tại Hội nghị Tế-hê-ran (1943).' ,
          100248 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'tăng 2 lần', 100204, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'tăng 2 lần.', 100184, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tăng áp suất và giảm nhiệt độ' ,
          100222 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tăng áp suất và tăng nhiệt độ' ,
          100222 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'tăng giảm liên tục', 100210, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'tăng rất lớn', 100210, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tăng tỉ trọng nông – lâm – ngư nghiệp, công nghiệp – xây dựng và tiến tới ổn định dịch vụ' ,
          100282 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tăng tỉ trọng nông – lâm – ngư nghiệp, giảm tỉ trọng công nghiệp – xây dựng' ,
          100282 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tất cả các prôtêin sau dịch mã đều đƣợc cắt bỏ axit amin mở đầu và tiếp tục hình thành các cấu trúc bậccao hơn để trở thành prôtêin có hoạt tính sinh học.' ,
          100166 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Thanh Hóa', 100286, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thành phần, trật tự của các loại ribônuclêôtit' ,
          100162 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thanh thước nhựa sau khi mài lên tóc hút được các vụn giấy' ,
          100174 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'thay cặp A-T bằng cặp T-A hoặc thay cặp G-X bằng cặp X-G nên không có bộ ba mới nào xuất hiện' ,
          100160 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'thay thế một cặp nuclêôtit ở bộ ba mã hóa axit amin thứ 200, nhƣng bộ ba mới này vẫn mã hóa cho axitamin alanin.' ,
          100160 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thế độc quyền vũ khí nguyên tử của Mĩ bị phá vỡ.' ,
          100254 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thế giới bắt đầu bước vào thời đại chiến tranh hạt nhân.' ,
          100254 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'thêm một cặp nuclêôtit vào vị trí cặp nuclêôtit số hai của bộ ba mã hóa axit amin thứ 200 nhƣng lạigiống với cặp nuclêôtit bên cạnh.' ,
          100160 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'thời gian dòng điện chạy qua mạch.' ,
          100202 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thu hổi chủ quyền trên toàn bộ lãnh thổ Trung Hoa.' ,
          100264 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Thủ tiêu chế độ nửa thực dân nửa phong kiến ở Trung Quốc.' ,
          100264 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'thực hiện pháp luật.' ,
          100294 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Thụy Sĩ', 100242, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tỉ lệ nghịch điện trở trong của nguồn;' ,
          100208 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tỉ lệ nghịch với điện trở ngoài của nguồn;' ,
          100208 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tỉ lệ nghịch với suất điện động của nguồn;' ,
          100208 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tỉ lệ nghịch với tổng điện trở trong và điện trở ngoài. ' ,
          100208 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Ti thể', 100156, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tiếp giáp với Trung Quốc và Lào' ,
          100284 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tiêu hao quá nhiều năng lượng.' ,
          100212 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Tính nhân văn.', 100288, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tính phi kim giảm dần,tính kim loại tăng dần' ,
          100226 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Tính phổ cập.', 100288, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tính quy phạm phổ biến.' ,
          100288 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Tính rộng rãi.', 100288, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'tốc độ dịch chuyển điện tích tại điểm đó.' ,
          100182 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tổng hợp Protein cấu tạo nên enzim phân giải Lactôzơ' ,
          100138 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Tổng hợp Protein ức chế' ,
          100138 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'trách nhiệm pháp lý.' ,
          100294 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'trách nhiệm trước Tòa án.' ,
          100294 ,
          0
        )
GO
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'trách nhiệm và pháp lý.' ,
          100292 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trở thành khuôn khổ của một trật tự thế giới, từng bước được thiết lập trong những năm 1945 - 1947.' ,
          100244 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trở thành nước đi đầu trong các ngành công nghiệp mới như : công nghiệp điện hạt nhân, công nghiệp vũ trụ.' ,
          100258 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trở thành quốc gia hàng đầu thế giới về vũ khí sinh học.' ,
          100258 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'trong kinh doanh.', 100298, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'trong lao động.', 100298, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trong quá trình dịch mã ở tế bào nhân thực, tARN mang axit amin mở đầu là mêtiônin đến ribôxôm đểbắt đầu dịch mã.' ,
          100166 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'trong tài chính.', 100298, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'trong tổ chức.', 100298, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trừ Nhật Bản, các nước Đông Bắc Á khác đều lựa chọn con đường đi lên Chủ nghĩa xã hội và đã đạt được những thành tựu to lớn.' ,
          100262 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trừ Nhật Bản, các nước Đông Bắc Á khác đều nằm trong tình trạng kinh tế thấp kém, chính trị bất ổn định.' ,
          100262 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trực tiếp kiểm soát hoạt động của gen cấu trúc' ,
          100138 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'trực tiếp làm khuôn tổng hợp prôtêin' ,
          100136 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trung Quốc, Nhật Bản.' ,
          100260 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trung tâm kinh tế - tài chính của châu Mĩ.' ,
          100272 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Trung tâm kinh tế - tài chính của thế giới.' ,
          100272 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Tuyên Quang', 100286, 1 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Vai trò của Nhà nước trong việc hoạch định chính sách và điều tiết nền kinh tế.' ,
          100276 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'vật nhất thiết phải làm bằng kim loại' ,
          100172 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'vật phải ở nhiệt độ phòng' ,
          100172 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn], [id], [dungSai] )
VALUES  ( N'Vĩnh Phúc', 100286, 0 )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Vùng điều hòa đầu gen- vùng mã hóa không liên tục' ,
          100142 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Vùng điều hòa đầu gen- vùng mã hóa không liên tục- vùng kết' ,
          100142 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Vùng điều hòa đầu gen- vùng mã hóa liên tục' ,
          100142 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Vùng điều hòa đầu gen- vùng mã hóa liên tục- vùng kết thúc.' ,
          100142 ,
          1
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Xảy ra ở các mô sinh dƣỡng' ,
          100164 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Xảy ra trong quá trình giảm phân của tế bào sinh giao tử.' ,
          100164 ,
          0
        )
INSERT  [dbo].[TraLoiTracNghiem]
        ( [dapAn] ,
          [id] ,
          [dungSai]
        )
VALUES  ( N'Xảy ra trong quá trình nguyên phân của hợp tử' ,
          100164 ,
          1
        )
GO

SET IDENTITY_INSERT [dbo].[TuLuan] ON 
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100097 ,
          N'Có mấy loại điện tích? Nêu sự tương tác giữa chúng' ,
          N'1.0/10' ,
          N'Có hai loại điện tích là điện tích dương và điện tích âm.
Các điện tích cùng dấu đẩy nhau, trái dấu thì hút nhau.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100099 ,
          N'Có những cách nhiễm điện cho vật nào?' ,
          N'2.0/10' ,
          N'Có 3 cách nhiễm điện cho vật là nhiễm điện do
- Cọ xát: electron di chuyển từ vật A sang vật B, kết quả A và B nhiễm điện trái dấu.
- Tiếp xúc: electron di chuyển từ vật A sang vật B, kết quả A và B nhiễm điện cùng dấu.
- Hưởng ứng: không trao đổi điện tích, chỉ phân bố lại điện tích.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100101 ,
          N'Nêu định luật Cu-lông' ,
          N'3.0/10' ,
          N'Lực hút hay đẩy giữa hai điện tích điểm có phương trùng với đường nối hai điện tích điểm, có độ lớn tỉ lệ thuận
với tích độ lớn hai điện tích và tỉ lệ nghịch với bình phương khoảng cách giữa chúng.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100103 ,
          N'Định luật bảo toàn điện tích là gì?' ,
          N'4.0/10' ,
          N'Trong một hệ cô lập về điện, tổng đại số các điện tích là không đổi.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100109 ,
          N'Nêu định luật chồng chất điện trường' ,
          N'6.0/10' ,
          N'Cường độ điện trường tại một điểm bằng tổng các véc tơ cường độ điện
trường thành phần tại điểm đó'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100113 ,
          N'Đường sức điện là gì?
Nêu các đặc điểm của đường sức điện?' ,
          N'7.0/10' ,
          N'Khái niệm: Đường sức điện là đường mà tiếp tuyến tại mỗi điểm của nó là giá của véctơ cường độ điện
trường tại điểm đó
Các đặc điểm của đƣờng sức điện
- Qua mỗi điểm trong điện trường chỉ vẽ được một đường sức và chỉ một mà thôi.
- Đường sức điện là những đường có hướng. Hướng của đường sức điện tại một điểm là hướng của cường độ
điện trường tại điểm đó.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100115 ,
          N'Điện trường đều là gì?' ,
          N'8.0/10' ,
          N'- Là điện trường mà véc tơ cường độ điện trường có hướng và độ lớn như nhau tại mọi điểm.
- Đường sức của điện trường đều là những đường song song cách đều'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100117 ,
          N'Tụ điện là gì?' ,
          N'10.0/10' ,
          N'- Tụ điện là một hệ thống gồm hai vật dẫn đặt gần nhau và ngăn cách với nhau bằng lớp chất cách điện.
- Tụ điện phẳng được cấu tạo từ 2 bản kim loại phẳng song song với nhau và ngăn cách với nhau bằng điện
môi.
- Điện dung là đại lượng đặc trưng cho khả năng tích điện của tụ điện. Nó được xác định bằng thương số giữa
điện tích của tụ và hiệu điện thế giữa hai bản của nó.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100121 ,
          N'Dòng điện là gì?' ,
          N'3.0/10' ,
          N'là dòng chuyển dời có hướng của các hạt mang điện.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100123 ,
          N'Cường độ dòng điện là gì?' ,
          N'3.0/10' ,
          N'Cường độ dòng điện là đại lượng đặc trưng cho tác dụng mạnh hay yếu của dòng điện. Nó được xác định bằng
thương số của điện lượng chuyển qua một tiết diện thẳng của vật dẫn trong một khoảng thời gian và khoảng thời
gian đó.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100125 ,
          N'Nguồn điện la gì?' ,
          N'7.0/10' ,
          N'Nguồn điện có chức năng tạo ra và duy trì một hiệu điện thế.
Nguồn điện bao gồm cực âm và cực dương. Trong nguồn điện phải có một loại lực tồn tại và tách electron ra
khỏi nguyên tử và chuyển electron hay ion về các cực của nguồn điện. Lực đó gọi là lực lạ. Cực thừa electron là
cực âm. Cực còn lại là cực dương.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100127 ,
          N'Cường độ dòng điện không đổi chạy qua dây tóc của một bóng đèn là 0,64 A.
a) Tính điện lượng dịch chuyển qua tiết diện thẳng của dây tóc trong thời gian một phút.
b) Tính số electron dịch chuyển qua tiết diện thẳng của dây tóc trong khoảng thời gian nói trên.' ,
          N'9.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100129 ,
          N'Một bộ acquy có suất điện động 6 V, sản ra một công là 360 J khi acquy này phát điện.
a) Tính lượng điện tích dịch chuyển trong acquy.
b) Thời gian dịch chuyển lượng điện tích này là 5 phút. Tính cường độ dòng điện chạy qua acquy khi đó.' ,
          N'8.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100131 ,
          N'Cho hai quả cầu kim loại nhỏ, giống nhau, tích điện và cách nhau 20 cm thì chúng hút nhau một lực bằng 1,2 N. Cho chúng tiếp xúc với nhau rồi tách chúng ra đến khoảng cách như cũ thì chúng đẩy nhau với lực đẩy bằng lực hút. Tính điện tích lúc đầu của mỗi quả cầu.' ,
          N'1.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100133 ,
          N'Nêu tính chất dòng điện trong kim loại?' ,
          N'2.0/10' ,
          N'Bản chất dòng điện trong kim loại là dòng chuyển dời có hướng của các electron ngược chiều điện trường. Điện trở suất của kim loại phụ thuộc vào nhiệt độ'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100135 ,
          N'Hiện tượng siêu dẫn là gì?' ,
          N'2.0/10' ,
          N'Là hiện tượng điện trở suất của vật liệu giảm đột ngột xuống bằng 0 khi khi nhiệt độ
của vật liệu giảm xuống thấp hơn một giá trị Tc nhất định. Giá trị này phụ thuộc vào bản thân vật liệu.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100137 ,
          N'Dòng điện trong chất điện phân là gì?' ,
          N'2.0/10' ,
          N'Dòng điện trong chất điện phân là dòng chuyển dời có hướng của các ion trong điện trường theo hai hướng ngược nhau.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100141 ,
          N'Dòng điện trong chất khí là gì?' ,
          N'1.0/10' ,
          N'Trong điều kiện thường thì chất khí không dẫn điện. Chất khí chỉ dẫn điện khi trong lòng nó có sự ion hóa
các phân tử.
- Dòng điện trong chất khí là dòng chuyển dời có hướng của các ion dương, ion âm và các electron do chất
khí bị ion hóa sinh ra.
- Khi dùng nguồn điện gây hiệu điện thế lớn thì xuất hiện hiện tượng nhân hạt tải điện trong lòng chất khí.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100143 ,
          N'Dòng điện trong chân không là gì?' ,
          N'3.0/10' ,
          N'Là dòng chuyển động ngược chiều điện trường của các electron bứt ra từ điện cực.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100145 ,
          N'Dòng điện trong chất bán dẫn là gì?' ,
          N'4.0/10' ,
          N'Dòng điện trong chất bán dẫn là dòng các electron dẫn chuyển động ngược chiều điện trường và dòng các lỗ trống chuyển động cùng chiều điện trường'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100147 ,
          N'Một bình điện phân có anôt là Ag nhúng trong dung dịch AgNO3, một bình điện phân khác có anôt là Cu nhúng trong
dung dịch CuSO4. Hai bình đó mắc nối tiếp nhau vào một mạch điện. sau 2 giờ, khối lượng của cả hai catôt tăng lên 4,2
g. Tính cường độ dòng điện đi qua hai bình điện phân và khối lượng Ag và Cu bám vào catôt mỗi bình.' ,
          N'7.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100149 ,
          N'Sự điện ly là gì?' ,
          N'1.0/10' ,
          N'Là quá trình hòa tan các chất trong nước ra ion'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100151 ,
          N'Phân loại các chất điện ly' ,
          N'2.0/10' ,
          N'Chất điện li mạnh: là chất khi tan trong nước, các phân tử hòa tan đều phân li ra ion.
Chất điện li yếu: là chất khi tan trong nước chỉ có một số phần tử hòa tan phân li ra ion, phần tử còn lại
vẫn tồn tại dưới dạng phân tử trong dung dịch.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100153 ,
          N'Axit, bazo, hidroxit lưỡng tính là gì?' ,
          N'4.0/10' ,
          N'Axit là chất khi tan trong nước phân li ra cation H+
Bazơ là chất khi tan trong nước phân li ra ion H+
Hidroxit lưỡng tính là hidroxit khi tan trong nước vừa có thể phân li như axit, vừa có thể phân li như
bazơ'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100155 ,
          N'Tính nồng độ mol/lit của các ion sau:
a. 200 ml dung dịch NaCl 2M
b. 200 ml dung dịch CaCl2 0,5M
c. 400 ml dung dịch Fe2(SO4)3 0,2M
d.100 ml dung dịch FeCl3 0,3M
e. 200 ml dung dịch chứa 12 gam MgSO4
f. 200 ml dung dịch chứa 34,2 gam Al2(SO4)3' ,
          N'3.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100157 ,
          N'Hòa tan 8,08 gam Fe(NO3)3 .9H2O trong nước thành 500 ml dung dịch . Tính nồng độ mol các ion
trong dung dịch thu được' ,
          N'5.0/10' ,
          N'Học sinh tự làm'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100159 ,
          N'Nêu vị trí, cấu hình nhóm Nito' ,
          N'10.0/10' ,
          N'Vị tí: Nitơ ở ô thứ 7, chu kỳ 2, nhóm VA của bảng tuần hoàn.
Cấu hình electron: 1s2 2s2 2p3'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100161 ,
          N'Nêu tính chất hóa học nhóm Nito' ,
          N'9.0/10' ,
          N' Ở nhiệt độ thường, nitơ trơ về mặt hóa học, nhưng ở nhiệt độ cao nitơ trở nên hoạt động.
- Trong các phản ứng hóa học nitơ vừa thể hiện tính oxi hóa vừa thể hiện tính khử. Tuy nhiên tính oxi hóa
vẫn là chủ yếu.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100165 ,
          N'Điều chế Nito như thế nào?' ,
          N'3.0/10' ,
          N'a. Trong công nghiệp
- Nitơ được điều chế bằng cách chưng cất phân đoạn không khí lỏng.
b. Trong phòng thí nghiệm
- Đun nóng nhẹ dung dịch bảo hòa muối amoni nitrit'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100167 ,
          N'Nêu vị trí, cấu hình nhóm Photpho' ,
          N'9.0/10' ,
          N'a. Vị trí: Ô thứ 15, nhóm VA, chu kỳ 3 trong bảng tuần hoàn.
b. Cấu hình electron: 1s2 2s2 2p6 3s2 3p3.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100169 ,
          N'Nêu vị trí, cấu hính nhóm Cacbon' ,
          N'2.0/10' ,
          N'a. Vị trí
- Cacbon ở ô thứ 6, chu kỳ 2, nhóm IVA của bảng tuần hoàn
b. Cấu hình electron nguyên tử 1s2 2s2 2p2. C có 4 electron lớp ngoài cùng'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100171 ,
          N'Nêu tính chất vật lý của Cacbon' ,
          N'9.0/10' ,
          N'- C có ba dạng thù hình chính: Kim cương, than chì và fuleren'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100173 ,
          N'Nêu tính chất vật lý, hóa học của silic' ,
          N'6.0/10' ,
          N'1. Tính chất vật lý
- Silic có hai dạng thù hình: silic tinh thể và silic vô định hình.
2. Tính chất hóa học
- Silic có các số oxi hóa: -4, 0, +2 và +4 (số oxi hóa +2 ít đặc trưng hơn).
- Trong các phản ứng hóa học, silic vừa thể hiện tính oxi hóa vừa thể hiện tính khử.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100175 ,
          N'Bằng phương pháp hóa học hãy nhận biết các chất khí sau: SO2, CO2, NH3 và N2' ,
          N'7.0/10' ,
          N'Dùng quỳ tím ẩm vào các chất khí trên.
- Qùy tím hóa xanh: NH3.
- Qùy tím không màu: còn lại
Dùng dung dịch Ca(OH)2 vào các chất khí còn lại.
- Xuất hiện kết tủa trắng: CO2
- Không hiện tượng: còn lại
Dùng dung dịch Brom
- Dung dịch brom mất màu: SO2.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100177 ,
          N'Hợp chất hữu cơ là gì?' ,
          N'3.0/10' ,
          N'Hợp chất hữu cơ (HCHC): là hợp chất của cacbon (trừ CO, CO2, muối cacbonat, xianua,
cacbua…).'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100179 ,
          N'Nêu đặc điểm chung của hợp chất hữu cơ' ,
          N'8.0/10' ,
          N'Nhất thiết phải chứa cacbon, thường có H, O, N, …
Liên kết trong HCHC chủ yếu là liên kết cộng hóa trị, thường có nhiệt độ nóng chảy, nhiệt độ
sôi thấp, thường không tan hoặc ít tan trong nước, nhưng dễ tan trong dung môi hữu cơ.
Thường kém bền với nhiệt; Phản ứng của các HCHC thường chậm, không hoàn toàn, không
theo một hướng nhất định.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100181 ,
          N'Phân loại hợp chất hữu cơ?' ,
          N'6.0/10' ,
          N'Hiđrocacbon: Chỉ gồm hai nguyên tố C và H; bao gồm hiđrocacbon no, hiđrocacbon không no,
hiđrocacbon thơm.
Dẫn xuất của hiđrocacbon: Ngoài C và H còn có nguyên tố khác như O, N, halogen,…'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100185 ,
          N'Hãy nêu những đặc điểm và thành tựu chính của cuộc cách mạng khoa học-công nghệ trong nửa sau thế kỉ XX' ,
          N'1.0/10' ,
          N'Đặc điểm: Khoa học trở thành lực lượng sản xuất trực tiếp.
Thành tựu chính:
Khoa học cơ bản: Có những bước nhảy vọt trong các ngành Toán học, Vật lý học, Sinh học... Con người đã ứng dụng vào cải tiến kĩ thuật, phục vụ sản xuất...
Công nghệ: phát minh ra những công cụ sản xuất mới, những vât liệu mới, công nghệ sinh học với những đột phá trong công nghệ di truyền, công nghệ tế bào...'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100189 ,
          N'Xu thế toàn cầu hóa được thể hiện trên những lĩnh vực nào?' ,
          N'3.0/10' ,
          N'Về kinh tế: tăng cường những ảnh hưởng, tác động lẫn nhau.
Sự phát triển nhanh chóng của quan hệ thương mại quốc tế.
Sự phát triển và tác động to lớn của các công ti xuyên quốc gia
Sự sáp nhập và hợp nhất các công ti thành những tập đoàn lớn.
Sự ra đời của các tổ chức liên kết kinh tế, thương mại, tài chính quốc tế và khu vực.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100191 ,
          N'Hãy giải thích thế nào khoa học đã trở thành một lực lượng sản xuất trực tiếp?' ,
          N'3.0/10' ,
          N'Mọi phát minh kĩ thuật đều bắt nguồn từ nghiên cứu khoa học, khoa học gắn liền với kĩ thuật, khoa học mở đường cho kĩ thuật. Đến lượt mình, kĩ thuật lại đi trước mở đường cho sản xuất. Khoa học đã tham gia trực tiếp vào sản xuất, đã trở thành nguồn gốc chính của những tiến bộ kĩ thuật và công nghệ.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100193 ,
          N'Dựa vào bản đồ Các nước Đông Nam Á và bản đồ Địa lí tự nhiên Việt Nam, hãy cho biết nước ta tiếp giáp với các nước nào trên đất liền và trên biển.' ,
          N'7.0/10' ,
          N'-	Trên đất liền nước ta giáp: Trung Quốc, Lào, Campuchia.

-	Trên biển nước ta giáp 8 nước: Trung Quốc, Cam-pu-chia, Thái Lan, Ma-lai-xi-a, Bru-nây, Phi-lip-pin, Xin-ga-po, In-đô-nê-xi-a.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100195 ,
          N'Dựa vào kiến thức đã học, hãy cho biết phạm vi lãnh thổ của mỗi nước bao gồm những bộ phận nào?' ,
          N'4.0/10' ,
          N'-Phạm vi lãnh thổ của mỗi nước bao gồm: vùng đất, vùng trời, vùng biển.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100197 ,
          N'Hãy lấy ví dụ để chứng minh tác động của con người tới địa hình nước ta?' ,
          N'6.0/10' ,
          N'+ Xây dựng hệ thống đê điều chống lũ khu vực đồng bằng sông Hồng.
+ Cải thiện hệ thống kênh rạch chằng chịt phục vụ giao thông, tưới tiêu.
+ Khai thác địa hình đồi núi, làm ruộng bậc thang tạo cảnh đẹp và nâng cao hiệu quả kinh tế.
+ Xây dựng các nhà máy thủy điện, hồ chứa nước.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100199 ,
          N'Hãy nêu ảnh hưởng của Biển Đông đến thiên nhiên nước ta.' ,
          N'8.0/10' ,
          N'-Biển Đông rộng, nhiệt độ nước biển cao làm tăng độ ẩm các khối khí khi đi qua biển, làm giảm tính lạnh khô vào mùa đông và nóng bức trong mùa hạ.
-Tạo nên khí hậu mát mẻ, trong lành cho các vùng ven biển của nước ta.
-Làm khí hậu nước ta có tính hải dương điều hòa.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100201 ,
          N'Dựa vào kiến thức đã học cho biết vì sao nước ta có khí hậu nhiệt đới ẩm gió mùa?' ,
          N'9.0/10' ,
          N'-Nước ta nằm trong vùng nội chí tuyến bán cầu Bắc và trong năm Mặt Trời qua thiên đỉnh 2 lần.
-Tiếp giáp với Biển Đông rộng lớn, được tăng cường độ ẩm và lượng mưa.
-Nằm trong khu vực Châu Á gió mùa điển hình nhất thế giới.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100203 ,
          N'Từ hình 16.1, hãy nhận xét tỉ lệ gia tăng dân số qua các giai đoạn.' ,
          N'3.0/10' ,
          N'-Tỉ suất gia tăng dân số qua các thời kì không ổn định và đang có xu hướng giảm nhưng vẫn còn cao so với thế giới.
-Trước năm 1954 chiến tranh chống Pháp, mức gia tăng dân số thấp.
-Từ 1954 – 1976 xây dựng CNXH ở miền Bắc, tỉ lệ gia tăngdân số nhanh.
-Từ 1976 sau khi thống nhất đất nước mức gia tăng giảm dần.'
        )
INSERT  [dbo].[TuLuan]
        ( [id] ,
          [deBai] ,
          [doKho] ,
          [dapAn]
        )
VALUES  ( 100205 ,
          N'Từ bảng 16.3, hãy so sánh và cho nhận xét về sự thay đổi tỉ trọng dân số thành thị, nông thôn.' ,
          N'4.0/10' ,
          N'-Tỉ lệ dân thành thị và nông thôn đang có sự chuyển dịch theo hướng giảm tỉ lệ nông thôn, dân tỉ lệ dân thành thị.
 + Tỉ lệ dân nông thôn giảm từ 80,5% (1990) xuống 73,1% (2005).
 + Tỉ lệ dân thành thị tăng từ 19,5% (1990) lên 26,9% (2005).'
        )
SET IDENTITY_INSERT [dbo].[TuLuan] OFF
 GO
 

INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100097, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100097, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100099, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100099, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100101, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100101, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100103, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100103, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100109, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100113, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100113, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100121, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100123, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100125, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100125, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100127, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100129, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100129, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100131, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100133 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100135 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100149, N'Sự điện ly' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100151, N'Sự điện ly' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100153, N'Sự điện ly' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100155, N'Sự điện ly' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100157, N'Sự điện ly' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100159, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100161, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100165, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100167, N'Nhóm Nito-Photpho' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100169, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100171, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100173, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100175, N'Nhóm Cacbon-Silic' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100185 ,
          N'Cách mạng khoa học-công nghệ và xu hướng toàn cầu hóa nửa sau thế kỉ XX'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100189 ,
          N'Cách mạng khoa học-công nghệ và xu hướng toàn cầu hóa nửa sau thế kỉ XX'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100191 ,
          N'Cách mạng khoa học-công nghệ và xu hướng toàn cầu hóa nửa sau thế kỉ XX'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100193, N'Địa lý tự nhiên' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100193 ,
          N'Vị trí địa lí, phạm vi lãnh thổ'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100195, N'Địa lý tự nhiên' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100195 ,
          N'Vị trí địa lí, phạm vi lãnh thổ'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100197, N'Địa lý tự nhiên' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100197, N'Việt Nam' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100199, N'Địa lý tự nhiên' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100199, N'Việt Nam' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100201, N'Địa lý tự nhiên' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100201, N'Việt Nam' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100203, N'Địa lý dân cư' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100203, N'Việt Nam' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100205, N'Địa lý dân cư' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100205, N'Việt Nam' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100115, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100117, N'Điện trường' )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100117, N'Điện tích' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100141 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100143 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100145 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100147 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id], [tenChuong] )
VALUES  ( 100147, N'Dòng điện không đổi' )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100137 ,
          N'Dòng điện trong các môi trường'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100177 ,
          N'Đại cương về hóa hữu cơ'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100179 ,
          N'Đại cương về hóa hữu cơ'
        )
INSERT  [dbo].[TuLuanChuong]
        ( [id] ,
          [tenChuong]
        )
VALUES  ( 100181 ,
          N'Đại cương về hóa hữu cơ'
        )
