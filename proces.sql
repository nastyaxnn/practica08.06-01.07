CREATE PROCEDURE sp_GetClipsByNode
    @NodeGuid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH NodeHierarchy AS (
        SELECT 
            NodeGuid,
            ParentNodeGuid,
            NodeType,
            Name,
            0 AS Level
        FROM Nodes
        WHERE NodeGuid = @NodeGuid
        
        UNION ALL
        
        SELECT 
            n.NodeGuid,
            n.ParentNodeGuid,
            n.NodeType,
            n.Name,
            nh.Level + 1
        FROM Nodes n
        INNER JOIN NodeHierarchy nh ON nh.NodeGuid = n.ParentNodeGuid
    ),
    
    AllClips AS (
        SELECT 
            c.NodeGuid AS ClipGuid,
            c.Name AS ClipName,
            c.ParentNodeGuid AS RollGuid,
            cl.Duration,
            cl.Resolution,
            cl.Description AS ClipDescription,
            (
                SELECT TOP 1 NodeGuid 
                FROM Nodes 
                WHERE NodeGuid IN (
                    SELECT ParentNodeGuid 
                    FROM NodeHierarchy 
                    WHERE NodeGuid = c.NodeGuid
                )
                AND NodeType = 'Folder'
            ) AS FolderGuid,
            (
                SELECT TOP 1 NodeGuid 
                FROM Nodes 
                WHERE NodeGuid IN (
                    SELECT ParentNodeGuid 
                    FROM NodeHierarchy 
                    WHERE NodeGuid = c.NodeGuid
                )
                AND NodeType = 'Box'
            ) AS BoxGuid
        FROM NodeHierarchy nh
        INNER JOIN Nodes c ON c.NodeGuid = nh.NodeGuid
        LEFT JOIN Clips cl ON cl.ClipGuid = c.NodeGuid
        WHERE c.NodeType = 'Clip'
    )
    
    SELECT 
        ac.ClipGuid,
        ac.ClipName,
        ac.Duration,
        ac.Resolution,
        ac.ClipDescription,
        ac.RollGuid,
        r.Name AS RollName,
        f.Name AS FolderName,
        fd.FolderType,
        fd.Year,
        fd.Month,
        fd.Day,
        b.Name AS BoxName,
        fl.FileGuid,
        fl.FileType,
        fl.Quality,
        fl.RelativePath,
        fl.FileName,
        (s.RootPath + fl.RelativePath + '\' + fl.FileName) AS FullPath,
        CAST(fl.SizeBytes / 1048576.0 AS DECIMAL(18, 2)) AS SizeMB
    FROM AllClips ac
    LEFT JOIN Nodes r ON r.NodeGuid = ac.RollGuid
    LEFT JOIN Nodes f ON f.NodeGuid = ac.FolderGuid
    LEFT JOIN Nodes b ON b.NodeGuid = ac.BoxGuid
    LEFT JOIN Folders fd ON fd.FolderGuid = ac.FolderGuid
    LEFT JOIN Files fl ON fl.ClipGuid = ac.ClipGuid
    LEFT JOIN Storages s ON s.StorageGuid = fl.StorageGuid
    ORDER BY ac.ClipName, fl.FileType;
END
GO
-- Вызов для ящика
DECLARE @BoxGuid UNIQUEIDENTIFIER;
SELECT @BoxGuid = NodeGuid FROM Nodes WHERE Name = N'Архив 2025' AND NodeType = 'Box';
EXEC sp_GetClipsByNode @BoxGuid;

-- Вызов для клипа
DECLARE @ClipGuid UNIQUEIDENTIFIER;
SELECT @ClipGuid = NodeGuid FROM Nodes WHERE Name = N'Интервью_клиента' AND NodeType = 'Clip';
EXEC sp_GetClipsByNode @ClipGuid;