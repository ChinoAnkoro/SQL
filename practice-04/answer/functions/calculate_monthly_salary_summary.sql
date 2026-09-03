CREATE OR REPLACE PROCEDURE calculate_monthly_salary_summary(
    target_year_month CHAR(7)
)
LANGUAGE plpgsql
AS $$
DECLARE
    target_month_start DATE;
    target_month_end DATE;

    employee_record RECORD;
    work_record RECORD;

    -- 1勤務分の給与
    work_salary INTEGER;

    -- 平日昼勤
    weekday_day_hours NUMERIC := 0;
    weekday_day_salary INTEGER := 0;

    -- 平日夜勤
    weekday_night_hours NUMERIC := 0;
    weekday_night_salary INTEGER := 0;

    -- 休日昼勤
    holiday_day_hours NUMERIC := 0;
    holiday_day_salary INTEGER := 0;

    -- 休日夜勤
    holiday_night_hours NUMERIC := 0;
    holiday_night_salary INTEGER := 0;

    -- 月間給与合計
    total_salary INTEGER := 0;

    -- 従業員カーソル
    employee_cursor CURSOR FOR
        SELECT
            employee_id,
            name,
            hourly_wage,
            night_shift_rate,
            holiday_rate
        FROM employees
        ORDER BY employee_id;
BEGIN
    -- 対象月の月初を取得
    target_month_start :=
        TO_DATE(TRIM(target_year_month) || '-01', 'YYYY-MM-DD');

    target_month_end :=
        (target_month_start + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
    RAISE NOTICE '対象年月: %', target_year_month;
    RAISE NOTICE '対象月の開始日: %', target_month_start;
    RAISE NOTICE '対象月の終了日: %', target_month_end;

    -- カレンダー用一時テーブルを作成
    CREATE TEMP TABLE tmp_calendar (
        work_date DATE PRIMARY KEY,
        day_of_week INTEGER
    ) ON COMMIT DROP;

    -- 再帰CTEで対象月の全日付を生成
    WITH RECURSIVE date_list AS (
        SELECT target_month_start AS work_date

        UNION ALL

        SELECT work_date + 1
        FROM date_list
        WHERE work_date < target_month_end
    )
    INSERT INTO tmp_calendar (work_date, day_of_week)
    -- カレンダー件数を取得する
    SELECT
        work_date,
        EXTRACT(DOW FROM work_date)::INTEGER
    FROM date_list;
    RAISE NOTICE 'カレンダー件数: %',
        (SELECT COUNT(*) FROM tmp_calendar);

    -- 従業員カーソルを開く
    OPEN employee_cursor;

    LOOP
        -- 従業員を１人取得
        FETCH employee_cursor INTO employee_record;

        -- 取得できなければ終了
        EXIT WHEN NOT FOUND;

        RAISE NOTICE '従業員ID: %, 名前: %',
        employee_record.employee_id,
        employee_record.name;

        -- 集計値を初期化
        weekday_day_hours := 0;
        weekday_day_salary := 0;

        weekday_night_hours := 0;
        weekday_night_salary := 0;

        holiday_day_hours := 0;
        holiday_day_salary := 0;

        holiday_night_hours := 0;
        holiday_night_salary := 0;

        total_salary := 0;

        -- 対象従業員の勤務記録を取得
        -- 平日・休日、昼勤・夜勤に分類
        FOR work_record IN
            SELECT
                wr.work_date,
                wr.shift_type,
                wr.hours_worked,
                CASE
                    WHEN h.holiday_date IS NOT NULL
                        OR EXTRACT(DOW FROM wr.work_date) IN (0,6)
                        THEN TRUE
                    ELSE FALSE
                END AS is_holiday,
                CASE
                    WHEN (
                        h.holiday_date IS NOT NULL
                        OR EXTRACT(DOW FROM wr.work_date) IN (0,6)
                    )
                    AND wr.shift_type = 'night'
                        THEN '休日夜勤'
                    WHEN (
                        h.holiday_date IS NOT NULL
                        OR EXTRACT(DOW FROM wr.work_date) IN (0,6)
                    )
                    AND wr.shift_type = 'day'
                        THEN '休日昼勤'
                    WHEN wr.shift_type = 'night'
                        THEN '平日夜勤'
                    ELSE '平日昼勤'
                END AS work_pattern
            FROM work_records wr
            LEFT JOIN holidays h
                ON h.holiday_date = wr.work_date
            WHERE wr.employee_id = employee_record.employee_id
                AND wr.work_date BETWEEN target_month_start AND target_month_end
            ORDER BY wr.work_date
        LOOP

            -- 勤務1件分の給与を計算
            work_salary :=
                FLOOR(
                    employee_record.hourly_wage
                    * work_record.hours_worked
                    * CASE
                        WHEN work_record.work_pattern = '休日夜勤'
                            THEN employee_record.holiday_rate
                                * employee_record.night_shift_rate

                        WHEN work_record.work_pattern = '休日昼勤'
                            THEN employee_record.holiday_rate

                        WHEN work_record.work_pattern = '平日夜勤'
                            THEN employee_record.night_shift_rate

                        ELSE 1
                    END
                ):: INTEGER;

            RAISE NOTICE
                '勤務日: %, 分類: %, 勤務時間: %, 給与: %円',
                work_record.work_date,
                work_record.work_pattern,
                work_record.hours_worked,
                work_salary;

            -- 勤務パターンごとに集計
            IF work_record.work_pattern = '平日昼勤' THEN
                weekday_day_hours :=
                    weekday_day_hours + work_record.hours_worked;

                weekday_day_salary :=
                    weekday_day_salary + work_salary;
            ELSIF work_record.work_pattern = '平日夜勤' THEN
                weekday_night_hours :=
                    weekday_night_hours + work_record.hours_worked;
                weekday_night_salary :=
                    weekday_night_salary + work_salary;
            ELSIF work_record.work_pattern = '休日昼勤' THEN
                holiday_day_hours :=
                    holiday_day_hours + work_record.hours_worked;
                holiday_day_salary :=
                    holiday_day_salary + work_salary;
            ELSIF work_record.work_pattern = '休日夜勤' THEN
                holiday_night_hours :=
                    holiday_night_hours + work_record.hours_worked;
                holiday_night_salary :=
                    holiday_night_salary + work_salary;
            END IF;

            -- 月間給与合計
            total_salary :=
                total_salary + work_salary;
        END LOOP;

        -- 勤務パターンごとの集計結果を表示
        RAISE NOTICE '--- 月間集計 ---';

        RAISE NOTICE
            '平日昼勤: 勤務時間=%時間, 給与=%円',
            weekday_day_hours,
            weekday_day_salary;

        RAISE NOTICE
            '平日夜勤: 勤務時間=%時間, 給与=%円',
            weekday_night_hours,
            weekday_night_salary;

        RAISE NOTICE
            '休日昼勤: 勤務時間=%時間, 給与=%円',
            holiday_day_hours,
            holiday_day_salary;

        RAISE NOTICE
            '休日夜勤: 勤務時間=%時間, 給与=%円',
            holiday_night_hours,
            holiday_night_salary;

        RAISE NOTICE
            '月間給与合計: %円',
            total_salary;

        -- 月間給与を結果テーブルへ登録
        INSERT INTO monthly_salary_summary(
            employee_id,
            year_month,
            total_salary
        )
        VALUES (
            employee_record.employee_id,
            target_year_month,
            total_salary
        )
        ON CONFLICT(employee_id, year_month)
        DO UPDATE SET
            total_salary = EXCLUDED.total_salary;
    END LOOP;

    -- カーソルを閉じる
    CLOSE employee_cursor;
END;
$$;

CALL calculate_monthly_salary_summary('2025-07');

-- 7月の期待値を実績値を比較
SELECT
    CASE
        WHEN NOT EXISTS(
            (
                SELECT
                    employee_id,
                    year_month,
                    total_salary
                FROM monthly_salary_summary
                WHERE year_month = '2025-07'

                EXCEPT

                SELECT
                    employee_id,
                    year_month,
                    total_salary
                FROM summary_answer_july
            )

            UNION ALL

            (
                SELECT
                    employee_id,
                    year_month,
                    total_salary
                FROM summary_answer_july

                EXCEPT

                SELECT
                    employee_id,
                    year_month,
                    total_salary
                FROM monthly_salary_summary
                WHERE year_month = '2025-07'
            )
        )
        THEN 'OK'
        ELSE 'NG'
    END AS result;