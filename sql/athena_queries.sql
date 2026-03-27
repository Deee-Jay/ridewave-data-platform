SELECT
    driver_id,
    city,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    RANK() OVER (
        PARTITION BY city
        ORDER BY SUM(fare_amount) DESC
    ) AS city_rank
FROM ridewave_raw_Dheeraj11.rides
WHERE fare_amount IS NOT NULL
GROUP BY driver_id, city;



WITH monthly AS (
    SELECT
        DATE_TRUNC('month', CAST(ride_date AS DATE)) AS month,
        COUNT(*) AS ride_count
    FROM ridewave_raw_Dheeraj11.rides
    GROUP BY 1
)
SELECT
    month,
    ride_count,
    LAG(ride_count) OVER (ORDER BY month) AS prev_month_count,
    ride_count - LAG(ride_count)
        OVER (ORDER BY month)              AS change
FROM monthly
ORDER BY month;

-- S1c: CTE — Drivers with more than 5 rides AND completed status
-- Business use: Identify reliable high-volume drivers
WITH completed_counts AS (
    SELECT driver_id, COUNT(*) AS total_rides
    FROM ridewave_raw_Dheeraj11.rides
    GROUP BY driver_id
    HAVING COUNT(*) > 5
),
completed_status AS (
    SELECT DISTINCT driver_id
    FROM ridewave_raw_YOUR_NAME.rides
    WHERE ride_status = 'completed'
)
SELECT
    cc.driver_id,
    cc.total_rides,
    CASE WHEN cs.driver_id IS NOT NULL
         THEN 1 ELSE 0 END AS has_completed
FROM completed_counts cc
LEFT JOIN completed_status cs ON cc.driver_id = cs.driver_id
ORDER BY cc.total_rides DESC;
