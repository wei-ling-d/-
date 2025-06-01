WITH first_login AS (
  SELECT
    uid,
    MIN(date) AS first_login_date
  FROM shuju
  GROUP BY uid
),

-- 第二步：把原始登录数据和首登表做关联，找出每个用户在首登后的登录间隔
retention_base AS (
  SELECT
    d.uid,
    f.first_login_date,
    d.date AS login_date,
    DATEDIFF(d.date, f.first_login_date) AS diff_day
  FROM shuju d
  JOIN first_login f
    ON d.uid = f.uid
)

-- 第三步：统计每天注册用户数、次日/3日/7日回访人数及留存率
SELECT
  first_login_date,
  COUNT(DISTINCT CASE WHEN diff_day = 0 THEN uid END) AS new_users,
  COUNT(DISTINCT CASE WHEN diff_day = 1 THEN uid END) AS retained_day1_users,
  ROUND(
    COUNT(DISTINCT CASE WHEN diff_day = 1 THEN uid END) * 1.0 
    / NULLIF(COUNT(DISTINCT CASE WHEN diff_day = 0 THEN uid END), 0), 4
  ) AS retention_rate_day1
FROM retention_base
GROUP BY first_login_date