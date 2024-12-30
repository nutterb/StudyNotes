CREATE TABLE [Tome] (
  [OID] INTEGER PRIMARY KEY, 
  [Title] VARCHAR(50) NOT NULL, 
  [Abbreviation] VARCHAR(5),
  [Order] INT
);

CREATE TABLE [Book] (
  [OID] INTEGER PRIMARY KEY, 
  [ParentTome] INTEGER NOT NULL, 
  [Title] VARCHAR(50) NOT NULL, 
  [Abbreviation] VARCHAR(5),
  [Order] INTEGER, 
  [IsSection] BIT DEFAULT 0,
  
  FOREIGN KEY (ParentTome) REFERENCES [Tome](OID)
);

CREATE TABLE [Chapter] (
  [OID] INTEGER PRIMARY KEY, 
  [ParentBook] INTEGER NOT NULL,
  [ChapterNumber] INTEGER NOT NULL, 
  
  FOREIGN KEY (ParentBook) REFERENCES [Book](OID)
);

CREATE TABLE [Verse] (
  [OID] INTEGER PRIMARY KEY, 
  [ParentChapter] INTEGER NOT NULL, 
  [VerseNumber] INTEGER NOT NULL, 
  
  FOREIGN KEY (ParentChapter) REFERENCES [Chapter](OID)
);

CREATE TABLE [StudyNote] (
  [OID] INTEGER PRIMARY KEY, 
  [Note] TEXT
);

CREATE TABLE [StudyNoteScriptureReference] (
  [OID] INTEGER PRIMARY KEY, 
  [ParentStudyNote] INTEGER NOT NULL, 
  [ParentVerse] INTEGER NOT NULL, 
  
  FOREIGN KEY (ParentStudyNote) REFERENCES [StudyNote](OID), 
  FOREIGN KEY (ParentVerse) REFERENCES [Verse](OID)
);

CREATE TABLE [StudyNoteOtherReference](
  [OID] INTEGER PRIMARY KEY, 
  [ParentStudyNote] INTEGER NOT NULL, 
  [Reference] TEXT, 
  
  FOREIGN KEY (ParentStudyNote) REFERENCES [StudyNote](OID)
);
