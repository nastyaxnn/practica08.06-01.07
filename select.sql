CREATE TABLE Nodes (
    NodeGuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ParentNodeGuid UNIQUEIDENTIFIER NULL,
    NodeType NVARCHAR(10) NOT NULL CHECK (NodeType IN ('Box', 'Folder', 'Roll', 'Clip')),
    Name NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Node_Parent FOREIGN KEY (ParentNodeGuid) REFERENCES Nodes(NodeGuid)
);

CREATE TABLE Boxes (
    BoxGuid UNIQUEIDENTIFIER PRIMARY KEY,
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Box_Node FOREIGN KEY (BoxGuid) REFERENCES Nodes(NodeGuid)
);

CREATE TABLE Folders (
    FolderGuid UNIQUEIDENTIFIER PRIMARY KEY,
    FolderType NVARCHAR(20) NOT NULL CHECK (FolderType IN ('Operational', 'Archive')),
    Year INT NULL CHECK (Year >= 2000 AND Year <= 2100),
    Month INT NULL CHECK (Month BETWEEN 1 AND 12),
    Day INT NULL CHECK (Day BETWEEN 1 AND 31),
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Folder_Node FOREIGN KEY (FolderGuid) REFERENCES Nodes(NodeGuid)
);

CREATE TABLE Rolls (
    RollGuid UNIQUEIDENTIFIER PRIMARY KEY,
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Roll_Node FOREIGN KEY (RollGuid) REFERENCES Nodes(NodeGuid)
);

CREATE TABLE Clips (
    ClipGuid UNIQUEIDENTIFIER PRIMARY KEY,
    Duration INT NULL,
    Resolution NVARCHAR(20) NULL,
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Clip_Node FOREIGN KEY (ClipGuid) REFERENCES Nodes(NodeGuid)
);

CREATE TABLE Storages (
    StorageGuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    StorageName NVARCHAR(100) NOT NULL,
    RootPath NVARCHAR(500) NOT NULL UNIQUE,
    Description NVARCHAR(MAX) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

CREATE TABLE Files (
    FileGuid UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ClipGuid UNIQUEIDENTIFIER NOT NULL,
    StorageGuid UNIQUEIDENTIFIER NOT NULL,
    FileType NVARCHAR(50) NOT NULL CHECK (FileType IN ('Video', 'Audio', 'Subtitle', 'Image')),
    Quality NVARCHAR(50) NULL CHECK (Quality IN ('high', 'medium', 'low', 'raw')),
    RelativePath NVARCHAR(500) NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    SizeBytes BIGINT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_File_Clip FOREIGN KEY (ClipGuid) REFERENCES Nodes(NodeGuid),
    CONSTRAINT FK_File_Storage FOREIGN KEY (StorageGuid) REFERENCES Storages(StorageGuid)
);

CREATE NONCLUSTERED INDEX IX_Nodes_Parent ON Nodes(ParentNodeGuid);
CREATE NONCLUSTERED INDEX IX_Nodes_Type ON Nodes(NodeType);
CREATE NONCLUSTERED INDEX IX_Files_Clip ON Files(ClipGuid);
CREATE NONCLUSTERED INDEX IX_Files_Storage ON Files(StorageGuid);
CREATE NONCLUSTERED INDEX IX_Files_Type ON Files(FileType);