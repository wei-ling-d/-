-- 先获取用户每小时的首次登录（避免重复计数）
WITH hourly_logins AS (
    SELECT
        uid,
        EXTRACT(HOUR FROM real_time) AS login_hour,
        MIN(real_time) AS first_login_time-- 仅保留每小时第一次登录
    FROM yhu.shuju
    GROUP BY uid, EXTRACT(HOUR FROM real_time)
)
SELECT
    login_hour,
    COUNT(DISTINCT uid) AS active_users
FROM hourly_logins
GROUP BY login_hour
ORDER BY login_hour desc;

