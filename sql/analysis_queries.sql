-- Q1, Engagement per user
q("""
SELECT Id,
       COUNT(*) AS days_recorded,
       SUM(CASE WHEN LikelyNotWorn = 0 THEN 1 ELSE 0 END) AS active_days,
       ROUND(100.0 * SUM(CASE WHEN LikelyNotWorn = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_active
FROM daily_activity
GROUP BY Id
ORDER BY active_days DESC
""")

--Q2, Drop-off over time
q("""
SELECT strftime('%W', ActivityDate) AS week_no,
       COUNT(DISTINCT Id) AS users_active
FROM daily_activity
WHERE LikelyNotWorn = 0
GROUP BY week_no
ORDER BY week_no
""")

--Q3, Day of week
q("""
SELECT DayOfWeek,
       ROUND(AVG(TotalSteps), 0) AS avg_steps,
       ROUND(AVG(Calories), 0) AS avg_calories
FROM daily_activity
WHERE LikelyNotWorn = 0
GROUP BY DayOfWeek
ORDER BY avg_steps DESC
""")

--Q4, Hour of day
q("""
SELECT Hour, ROUND(AVG(StepTotal), 0) AS avg_steps
FROM hourly_steps
GROUP BY Hour
ORDER BY Hour
""")

--Q5, User segments
q("""
WITH user_avg AS (
    SELECT Id, AVG(TotalSteps) AS avg_steps
    FROM daily_activity
    WHERE LikelyNotWorn = 0
    GROUP BY Id
)
SELECT CASE
         WHEN avg_steps >= 10000 THEN '4. Highly active (10k+)'
         WHEN avg_steps >= 7500  THEN '3. Active (7.5k-10k)'
         WHEN avg_steps >= 5000  THEN '2. Lightly active (5k-7.5k)'
         ELSE '1. Low activity (<5k)'
       END AS segment,
       COUNT(*) AS users,
       ROUND(AVG(avg_steps), 0) AS segment_avg_steps
FROM user_avg
GROUP BY segment
ORDER BY segment
""")


