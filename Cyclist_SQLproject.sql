--1. On which day of the week do we on average have the longest trip?

select*
from [dbo].[in$]
 
select DATENAME(WEEKDAY,start_time) AS week_day, round(avg(duration_minutes), 2) as avg_duration
from [dbo].[in$]
group by DATENAME(WEEKDAY,start_time)
order by avg(duration_minutes) desc 

-- The day of the week is Sunday and the average longest trip is 79.29

--2. What month/year has the most bike trips and what is the count of the trips?

select DATENAME(MONTH,start_time) AS trip_month, 
              DATENAME(YEAR,start_time) AS trip_year, 
			  count(trip_id) as num_trip
from [dbo].[cyclist1]

group by DATENAME(MONTH,start_time), DATENAME(YEAR,start_time)

ORDER BY num_trip DESC

-- September 2020 had the most trip of 530

--3. Identify the peak hour(s) of the day when the highest number of trips start. How does this vary between weekdays and weekends?

		
SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END as trip_days,
    DATEPART(HOUR, start_time) as hour_of_day,
    COUNT(*) as total_trips
FROM [dbo].[in$]
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END,
    DATEPART(HOUR, start_time)
ORDER BY trip_days, hour_of_day;

SELECT 
    CASE 
        WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END as trip_days,
    COUNT(*) as total_trips
FROM [dbo].[in$]
GROUP BY 
    CASE 
        WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
        ELSE 'Weekday' 
    END
ORDER BY trip_days;

WITH TripHours AS (
    SELECT 
        DATEPART(HOUR, start_time) AS hour_of_day,
        CASE 
            WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
            ELSE 'Weekday' 
        END AS day_type,
        COUNT(*) AS trip_count
    FROM [dbo].[in$]
    GROUP BY 
        DATEPART(HOUR, start_time),
        CASE 
            WHEN DATENAME(WEEKDAY, start_time) IN ('Saturday','Sunday') THEN 'Weekend' 
            ELSE 'Weekday' 
        END
),
RankedHours AS (
    SELECT 
        hour_of_day,
        day_type,
        trip_count,
        RANK() OVER (PARTITION BY day_type ORDER BY trip_count DESC) AS hour_rank
    FROM TripHours
)

SELECT 
    hour_of_day AS peak_hour,
    day_type,
    trip_count
FROM RankedHours
WHERE hour_rank = 1
ORDER BY day_type, trip_count DESC;