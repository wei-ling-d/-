-- 视频时长分组后分析行为路径
WITH base AS (
    SELECT *,
           CASE 
               WHEN duration_time < 30 THEN 'short'
               WHEN duration_time < 90 THEN 'medium'
               WHEN duration_time < 120 THEN 'long'
               ELSE 'very_long'
           END AS video_level
    FROM yhu.shuju
)
SELECT
    video_level,
    COUNT(*) AS play_count,
    SUM(CASE WHEN finish = 1 THEN 1 ELSE 0 END) AS finish_count,
    SUM(CASE WHEN `like`=1 THEN 1 ELSE 0 END) AS like_count,
    SUM(CASE WHEN finish = 1 AND `like` = 1 THEN 1 ELSE 0 END) AS like_after_finish_count,

    ROUND(SUM(CASE WHEN finish = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 4) AS finish_rate,
    ROUND(
        CASE 
            WHEN SUM(CASE WHEN finish = 1 THEN 1 ELSE 0 END) = 0 THEN 0
            ELSE SUM(CASE WHEN finish = 1 AND `like` = 1 THEN 1 ELSE 0 END) * 1.0
                 / SUM(CASE WHEN finish = 1 THEN 1 ELSE 0 END)
        END, 
        4
    ) AS like_conversion_rate
FROM base
GROUP BY video_level
ORDER BY play_count DESC;
