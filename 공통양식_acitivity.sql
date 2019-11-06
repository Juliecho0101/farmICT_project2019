


declare @date_s date, @date_f date, @aniid  int
set @date_s = '2017-01-01'
set @date_f = '2019-05-31'




;with lac_tb as (
   select
      c.FARM_NAME
	  ,b.FARM_NO
	  ,LacAniId
	  ,b.AniUserNumber
	  ,b.AniName
      ,LacNumber
      ,LacCalvingDate
      ,LEAD(LacCalvingDate, 1, getdate()) OVER (PARTITION BY a.farm_no, LacAniId ORDER BY LacNumber) nextLacCalvingDate
   from lely_collect_farm_RemLactation a
    left outer join lely_collect_farm_HemAnimal  as b on a.LacAniId=b.AniId and a.FARM_NO=b.FARM_NO
	left outer join LELY_COLLECT_FARM as c on a.FARM_NO=c.FARM_NO
	where LacNumber>0
	
	)


	select
   t1.FARM_NAME as 목장명, t1.LacAniId as 개체시스템번호, t1.AniUserNumber as 개체사용자번호,
   t1.LacNumber as 산차,asc_date as 일자, datediff(dd, LacCalvingDate, asc_date) as 분만후일령, 
   t2.일평균활동량

	from 
	(
		select
		FARM_NO, AscAniId, convert(date, AscCellTime,113) as asc_date , avg(AscActivity) 일평균활동량
		from LELY_COLLECT_FARM_PrmActivityScr
		where AscCellTime>=dateadd(d,-1,@date_s) and AscCellTime<=dateadd(d,+1,@date_f)
		group by FARM_NO, AscAniId, convert(date, AscCellTime,113)
		) as T2, lac_tb as T1
		where t1.LacAniId = t2.AscAniId and t2.asc_date >= t1.LacCalvingDate and t2.asc_date < t1.nextLacCalvingDate
		and t2.asc_date between @date_s and @date_f and t1.FARM_NO=t2.FARM_NO
		order by FARM_NAME, AscAniId, asc_date