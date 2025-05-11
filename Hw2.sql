
Use Spring_2025_Baseball;
DECLARE @DynamicSQL nvarchar(1000);
set @DynamicSQL = N'IF (OBJECT_ID(''dbo.player_FK'', ''F'') IS NOT NULL)
BEGIN
ALTER TABLE dbo.[' + @@servername + '] DROP CONSTRAINT player_FK
END'
--- print @DynamicSQL
Execute sp_Executesql @DynamicSQL;
SET @DynamicSQL = N'DROP TABLE IF EXISTS [' + @@servername + ']; create table [' +
@@servername + '] ( server varchar(255) constraint player_FK foreign key (server)
references People(playerid));'
--- print @DynamicSQL
Execute sp_Executesql @DynamicSQL;
declare @a varchar(20)
declare @msg varchar(40)
declare @xx varchar(10)
SET @DynamicSQL = 'set @xx = (select format(count(*),''##,##0'') from [' +
@@Servername +'])'
--- print @DynamicSQL
Execute sp_Executesql @DynamicSQL, N'@xx int output', @xx = @xx output;
---set @a = Execute sp_Executesql @DynamicSQL;
select @msg = @@servername + ' count = ' + @xx
--RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from allstarfull)
select @msg = 'Allstarfull count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Appearances)
select @msg = 'Appearances count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from AwardsManagers)
select @msg = 'AwardsManagers count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
---set @a = (select format(count(*),'##,##0') from AwardsPlayers)
---select @msg = 'AwardsPlayers count = ' + @a
---RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from AwardsShareManagers)
select @msg = 'AwardsShareManagers count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from AwardsSharePlayers)
select @msg = 'AwardsSharePlayers count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Batting)
select @msg = 'Batting count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
select @msg = 'College Playing count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Fielding)
select @msg = 'Fielding count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from HallofFame)
select @msg = 'HallofFame count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from HomeGames)
select @msg = 'HomeGames count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Managers)
select @msg = 'Managers count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Parks)
select @msg = 'Parks count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from People)
select @msg = 'People count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Pitching)
select @msg = 'Pitching count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Salaries)
select @msg = 'Salaries count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Schools)
select @msg = 'Schools count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from Teams)
select @msg = 'Teams count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT
set @a = (select format(count(*),'##,##0') from TeamsFranchises)
select @msg = 'TeamsFranchises count = ' + @a
RAISERROR(@msg, 0, 1) WITH NOWAIT



select count(*) from dbo.Allstarfull  --5,590 off by 83
select count(*) from dbo.Appearances --113720
select count(*) from dbo.AwardsManagers --193
select count(*) from dbo.AwardsShareManagers --510
select count(*) from dbo.AwardsSharePlayers -- 7447
select count(*) from dbo.Batting -- 113799 
select count(*) from dbo.CollegePlaying --17350
select count(*) from dbo.Fielding --151507
select count(*) from dbo.HallofFame --6381 off by -1
select count(*) from dbo.HomeGames --3233
select count(*) from dbo.Managers --3749
select count(*) from dbo.People --21010
select count(*) from dbo.Pitching --51368
select count(*) from dbo.Salaries --33302
select count(*) from dbo.Schools--1211 off +3
select count(*) from dbo.Teams --3045
select count(*) from dbo.TeamsFranchises --120

