
# 1.New user by install date
SELECT
    install_date,
    COUNT(user_id) AS users
FROM users
GROUP BY install_date
ORDER BY install_date;

# 2. Installed but never played users
SELECT
    u.user_id
FROM users u
LEFT JOIN sessions s
ON u.user_id = s.user_id
WHERE s.session_id IS NULL;

# 3.Cumulate user by install date
SELECT
    install_date,
    COUNT(user_id) AS new_users,
    SUM(COUNT(user_id)) OVER (ORDER BY install_date) AS cumulative_users
FROM users
GROUP BY install_date
ORDER BY install_date;
# 4.Total sessions by country
SELECT
    u.country,
    COUNT(s.session_id) AS total_sessions
FROM sessions s
JOIN users u
    ON s.user_id = u.user_id
GROUP BY u.country
ORDER BY total_sessions DESC;

# 5. Daily active users
SELECT
    DATE(session_start) AS activity_date,
    COUNT(DISTINCT user_id) AS daily_active_users
FROM sessions
GROUP BY DATE(session_start)
ORDER BY activity_date;

# 6. Daily active users by country
WITH session_users AS (
    SELECT
        DATE(session_start) AS activity_date,
        user_id
    FROM sessions
)

SELECT
    s.activity_date,
    u.country,
    COUNT(DISTINCT s.user_id) AS dau
FROM session_users s
JOIN users u
    ON s.user_id = u.user_id
GROUP BY s.activity_date, u.country
ORDER BY s.activity_date;

# 7.Fail rate by level
SELECT
    level,
    SUM(CASE WHEN result = 'fail' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS fail_rate
FROM level_attempts
GROUP BY level
ORDER BY level;

# 8.Average fail
WITH user_level_fail AS (
    SELECT
        user_id,
        level,
        COUNT(CASE WHEN result='fail' THEN 1 END) AS fail_count
    FROM level_attempts
    GROUP BY user_id, level
)

SELECT
    level,
    AVG(fail_count) AS avg_fail
FROM user_level_fail
GROUP BY level;

# 9. Top difficult level base on fail rate
WITH level_stats AS (
    SELECT
        level,
        COUNT(*) AS attempts,
        COUNT(CASE WHEN result='fail' THEN 1 END) AS fails
    FROM level_attempts
    GROUP BY level
)

SELECT
    level,
    fails * 1.0 / attempts AS fail_rate,
    RANK() OVER (ORDER BY fails * 1.0 / attempts DESC) AS difficulty_rank
FROM level_stats;

