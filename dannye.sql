DECLARE @BoxGuid UNIQUEIDENTIFIER = NEWID();
INSERT INTO Nodes (NodeGuid, ParentNodeGuid, NodeType, Name)
VALUES (@BoxGuid, NULL, 'Box', N'Архив 2025');

INSERT INTO Boxes (BoxGuid, Description)
VALUES (@BoxGuid, N'Архив всех видео за 2025 год');

DECLARE @FolderSalesGuid UNIQUEIDENTIFIER = NEWID();
DECLARE @FolderMarketingGuid UNIQUEIDENTIFIER = NEWID();
DECLARE @FolderArchiveGuid UNIQUEIDENTIFIER = NEWID();

INSERT INTO Nodes (NodeGuid, ParentNodeGuid, NodeType, Name)
VALUES 
    (@FolderSalesGuid, @BoxGuid, 'Folder', N'Отдел продаж'),
    (@FolderMarketingGuid, @BoxGuid, 'Folder', N'Отдел маркетинга'),
    (@FolderArchiveGuid, @BoxGuid, 'Folder', N'2025-06-17');

	INSERT INTO Folders (FolderGuid, FolderType, Year, Month, Day, Description)
VALUES 
    (@FolderSalesGuid, 'Operational', NULL, NULL, NULL, N'Все видео отдела продаж'),
    (@FolderMarketingGuid, 'Operational', NULL, NULL, NULL, N'Все видео отдела маркетинга'),
    (@FolderArchiveGuid, 'Archive', 2025, 6, 17, N'Архив за 17 июня 2025 года');

DECLARE @Roll1Guid UNIQUEIDENTIFIER = NEWID();
DECLARE @Roll2Guid UNIQUEIDENTIFIER = NEWID();
DECLARE @Roll3Guid UNIQUEIDENTIFIER = NEWID();

INSERT INTO Nodes (NodeGuid, ParentNodeGuid, NodeType, Name)
VALUES 
    (@Roll1Guid, @FolderSalesGuid, 'Roll', N'Ролл_продажи_001'),
    (@Roll2Guid, @FolderMarketingGuid, 'Roll', N'Ролл_маркетинга_001'),
    (@Roll3Guid, @FolderArchiveGuid, 'Roll', N'Архивный_ролл_001');

	INSERT INTO Rolls (RollGuid, Description)
VALUES 
    (@Roll1Guid, N'Первый ролл отдела продаж'),
    (@Roll2Guid, N'Первый ролл отдела маркетинга'),
    (@Roll3Guid, N'Архивный ролл');

	DECLARE @Clip1Guid UNIQUEIDENTIFIER = NEWID();
DECLARE @Clip2Guid UNIQUEIDENTIFIER = NEWID();
DECLARE @Clip3Guid UNIQUEIDENTIFIER = NEWID();
DECLARE @Clip4Guid UNIQUEIDENTIFIER = NEWID();

INSERT INTO Nodes (NodeGuid, ParentNodeGuid, NodeType, Name)
VALUES 
    (@Clip1Guid, @Roll1Guid, 'Clip', N'Интервью_клиента'),
    (@Clip2Guid, @Roll1Guid, 'Clip', N'Презентация_товара'),
    (@Clip3Guid, @Roll2Guid, 'Clip', N'Реклама_продукта'),
    (@Clip4Guid, @Roll3Guid, 'Clip', N'Старое_интервью');

	INSERT INTO Clips (ClipGuid, Duration, Resolution, Description)
VALUES 
    (@Clip1Guid, 180, '1920x1080', N'Интервью с клиентом'),
    (@Clip2Guid, 240, '1920x1080', N'Презентация товара'),
    (@Clip3Guid, 120, '1920x1080', N'Рекламный ролик'),
    (@Clip4Guid, 300, '1280x720', N'Архивное интервью');

	DECLARE @StorageGuid UNIQUEIDENTIFIER = NEWID();
INSERT INTO Storages (StorageGuid, StorageName, RootPath, Description)
VALUES (@StorageGuid, N'Основное хранилище', '\\SERVER\VIDEO\', N'Главный сервер с видеофайлами');

INSERT INTO Files (ClipGuid, StorageGuid, FileType, Quality, RelativePath, FileName, SizeBytes)
VALUES 
    (@Clip1Guid, @StorageGuid, 'Video', 'high', '2025\interviews', 'interview.mp4', 1024000000),
    (@Clip1Guid, @StorageGuid, 'Audio', 'high', '2025\interviews', 'interview.wav', 51200000),

    (@Clip2Guid, @StorageGuid, 'Video', 'medium', '2025\presentations', 'presentation.mp4', 2048000000),
    (@Clip2Guid, @StorageGuid, 'Subtitle', NULL, '2025\presentations', 'subtitles.srt', 1024),

    (@Clip3Guid, @StorageGuid, 'Video', 'high', '2025\ads', 'advert.mp4', 512000000),

    (@Clip4Guid, @StorageGuid, 'Video', 'low', '2025\archive', 'old_interview.mp4', 76800000),
    (@Clip4Guid, @StorageGuid, 'Audio', 'low', '2025\archive', 'old_interview.wav', 25600000);
GO

SELECT 'Nodes' AS TableName, COUNT(*) AS Count FROM Nodes
UNION ALL
SELECT 'Boxes', COUNT(*) FROM Boxes
UNION ALL
SELECT 'Folders', COUNT(*) FROM Folders
UNION ALL
SELECT 'Rolls', COUNT(*) FROM Rolls
UNION ALL
SELECT 'Clips', COUNT(*) FROM Clips
UNION ALL
SELECT 'Files', COUNT(*) FROM Files
UNION ALL
SELECT 'Storages', COUNT(*) FROM Storages;
GO

SELECT 
    n.NodeGuid,
    n.Name,
    n.NodeType,
    p.Name AS ParentName,
    n.ParentNodeGuid
FROM Nodes n
LEFT JOIN Nodes p ON p.NodeGuid = n.ParentNodeGuid
ORDER BY n.NodeType, n.Name;
GO

