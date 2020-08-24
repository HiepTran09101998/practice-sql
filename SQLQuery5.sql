USE master;
GO

ALTER DATABASE MyBlog
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE
DROP DATABASE MyBlog
GO

CREATE DATABASE MyBlog
GO

USE MyBlog
GO

CREATE TABLE Users (
	UserID int PRIMARY KEY IDENTITY,
	UserName varchar(20),
	Password varchar(30),
	Email varchar(30) UNIQUE,
	Address nvarchar(200)
)
GO


CREATE TABLE Posts (
	PostID int PRIMARY KEY IDENTITY,
	Title nvarchar(200),
	Content nvarchar(200),
	Tag nvarchar(100),
	Status bit,
	CreateTime datetime DEFAULT GETDATE(),
	Updatetime datetime,
	UserID int,
	CONSTRAINT fk_userID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
)
GO


CREATE TABLE CommentID (
	CommentID int PRIMARY KEY IDENTITY,
	Content nvarchar(500),
	Status bit,
	CreateTime datetime DEFAULT GETDATE(),
	Author nvarchar(30),
	Email varchar(50) NOT NULL,
	PostID int,
	CONSTRAINT fk_postID FOREIGN KEY (PostID) REFERENCES dbo.Posts(PostID)
)
GO


-- 3. Create CONSTRAINT CHECK
ALTER TABLE dbo.Users
ADD CONSTRAINT chk_emailUsers CHECK (Email LIKE '%@%')

ALTER TABLE dbo.CommentID
ADD CONSTRAINT chk_emailComment CHECK (Email LIKE '%@%')

-- 4. Create unique, non-clustered index
CREATE UNIQUE NONCLUSTERED INDEX IX_UserName 
ON dbo.Users (UserName)


-- 6. Select Socal tags
SELECT * FROM dbo.Posts p
	WHERE Tag LIKE '#Social'

-- 7. Select query author email...
SELECT p.PostID, p.Title, p.Content, ci.Author, ci.Email FROM dbo.Posts p
	INNER JOIN dbo.CommentID ci ON p.PostID = ci.PostID
	WHERE ci.Email LIKE 'kingauther@gmail.com'

-- 8. Count total ammount of comments
SELECT p.PostID, p.Content,COUNT(p.PostID) AS [SoCommentTrongTungPost] FROM dbo.Posts p
	INNER JOIN dbo.CommentID ci ON p.PostID = ci.PostID
	GROUP BY p.PostID, p.Content

-- 9. Create View
CREATE VIEW v_NewPort AS
	SELECT TOP 2 p.Title, u.UserName, p.CreateTime FROM dbo.Posts p
		INNER JOIN dbo.Users u ON p.UserID = u.UserID
		ORDER BY p.CreateTime DESC

-- 10. Create stored procedure
CREATE PROC sp_GetComment
	@PostId int
AS
	SELECT * FROM dbo.CommentID ci
	WHERE @PostID = ci.PostID
GO

EXEC sp_GetComment 1
EXEC sp_GetComment 2
EXEC sp_GetComment 3

-- 11. Create Trigger Update Time se dc update tu dong
CREATE TRIGGER tg_Updatetime
ON dbo.Posts
FOR UPDATE
AS
	BEGIN
		UPDATE dbo.Posts SET UpdateTime = GETDATE()
		PRINT 'CreateTime da duoc update tu dong'
	END

DROP TRIGGER tg_Updatetime

INSERT INTO dbo.Posts
(
    --PostID - column value is auto-generated
    Title,
    Content,
    Tag,
    Status,
    CreateTime,
    Updatetime,
    UserID
)
VALUES
(
    -- PostID - int
    N'123', -- Title - nvarchar
    N'123', -- Content - nvarchar
    N'123', -- Tag - nvarchar
    0, -- Status - bit
    '2020-08-24 10:15:37', -- CreateTime - datetime
    '2020-08-27', -- Updatetime - datetime
    3 -- UserID - int
)

UPDATE dbo.Posts SET Title = '230'
WHERE dbo.Posts.Title = '123'

SELECT * FROM dbo.Posts p