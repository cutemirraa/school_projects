/* Проект: Анализ рынка недвижимости СПб и ЛО
 * Задачи: Время активности объявлений + Сезонность
 * Автор: Зарипова Альмира
*/



-- Задача 1: Время активности объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
final_information as (
	select
		f.id,
		case
			when c.city = 'Санкт-Петербург' then 'Санкт-Петербург'
			else 'ЛенОбл'
		end as region,
		case 
			when a.days_exposition is null then 'non category'
			when a.days_exposition between 1 and 30 then '1-30 days'
			when a.days_exposition between 31 and 90 then '31-90 days'
			when a.days_exposition between 91 and 180 then '91-180 days'
			when a.days_exposition > 180 then '180+ days'
		end as days_category,
		a.last_price / f.total_area as metr_price,
        a.last_price as total_price,
        f.total_area,
        f.rooms,
        f.balcony,
        f.ceiling_height,
        f.floor
    from real_estate.flats as f
    left join real_estate.advertisement as a ON f.id = a.id
    left join real_estate.city as c ON f.city_id = c.city_id
    where 
        f.id in (select id from filtered_id) and f.type_id = 'F8EM' and extract (year from a.first_day_exposition) between 2015 and 2018
)
select
	region,
	days_category,
	count(*) as total_flats,
	round(count(*)::numeric * 100 / sum(count(*)) over (partition by region), 2) as percent_flats_per_region,
	round(avg(metr_price)::numeric, 2) as avg_metr_price,
	round(avg(total_area)::numeric, 2) as avg_total_are,
	percentile_disc(0.5) within group (order by rooms) as rooms_med,
	percentile_disc(0.5) within group (order by balcony) as balcony_med,
	percentile_disc(0.5) within group (order by ceiling_height) as ceiling_height_med,
	percentile_disc(0.5) within group (order by floor) as floor_med
from final_information
group by region, days_category
order by
	region desc,
	case days_category
		when '1-30 days' then 1
		when '31-90 days' then 2
		when '91-180 days' then 3
		when '180+ days' then 4
		when 'non category' then 5
	end;

-- Задача 2: Сезонность объявлений
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
per_month as (
	select
		a.id,
		extract(month from a.first_day_exposition) as first_month,
		extract(month from (a.first_day_exposition + days_exposition::integer)) as last_month,
		f.total_area,
		a.last_price
		from real_estate.advertisement as a
		left join real_estate.flats as f on a.id = f.id 
		left join real_estate.type as t on f.type_id = t.type_id 
		where
			a.id in (select id from filtered_id)
		and t.type = 'город'
		and extract(year from a.first_day_exposition) between 2015 and 2018
),
first_month_stat as (
	select
		first_month as month,
		'first month' as type,
		count(*) as total,
		round(avg(last_price / total_area)::numeric, 2) as avg_metr_price,
		round(avg(total_area)::numeric, 2) as avg_total_area
	from per_month 
	group by first_month
),
last_month_stat as (
	select
		last_month as month,
		'last month' as type,
		count(*) as total,
		round(avg(last_price / total_area)::numeric, 2) as avg_metr_price,
		round(avg(total_area)::numeric, 2) as avg_total_area
	from per_month 
	group by last_month
)
select
	f.month,
    f.total AS first_month_total,
    f.avg_metr_price AS first_avg_metr_price,
    f.avg_total_area AS first_avg_total_area,
    l.total AS last_total,
    l.avg_metr_price AS last_avg_metr_price,
    l.avg_total_area AS last_avg_total_area
FROM first_month_stat as f
LEFT JOIN last_month_stat as l ON f.month = l.month
ORDER BY f.month;