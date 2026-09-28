--1 Consumption unit
with combined_data as (
SELECT DATE(date) AS date,
LOWER(trim(media_source)) AS media_source,
LOWER(trim(campaign)) AS campaign,
UPPER(trim(country_code)) AS country,
cost_usd as cost,
0 as ad_revenue,
0 as installs,
0 as in_app_revenue
from `mornhouse-test-environment.test_app_dataset.cost_table`
union all

 --2 installation unit
SELECT Date(install_date) as date,
lower(trim(media_source)) as media_source,
lower(trim(campaign_name)) as campaign,
upper(trim(country)) as country,
0 as cost,
1 as installs,
0 as ad_revenue,
0 as in_app_revenue
from `mornhouse-test-environment.test_app_dataset.non_org_installs_report`
union all

  --3 (ad revenue IAA)
select
Date(install_date) as date,
lower(trim(media_source)) as media_source,
lower(trim(campaign_name)) as campaign,
upper(trim(country)) as country,
0 as cost,
0 as installs,
event_revenue_usd as ad_revenue,
0 as in_app_revenue
from `mornhouse-test-environment.test_app_dataset.ad_revenue_raw`
union all

--4 (in_app revenue /IAP )
select
DATE(event_date) as date,
lower(trim(media_source)) as media_source,
lower(trim(campaign_name)) as campaign,
upper(trim(country)) as country,
0 as cost,
0 as installs,
0 as ad_revenue,
event_revenue_usd as in_app_revenue
from mornhouse-test-environment.test_app_dataset.in_app_events_report
) 

--5 calculation of payback metrics
SELECT
date,
media_source, campaign,country,
sum (cost) as cost,
sum(installs) as installs,
sum(ad_revenue) as ad_revenue,
sum(in_app_revenue) as in_app_revenue,
(sum(ad_revenue)+sum(in_app_revenue)) as total_revenue,
(sum(ad_revenue) + sum(in_app_revenue)) - (sum(cost)) as profit,
safe_divide(sum(cost),sum(installs)) as cpi,
safe_divide((sum(ad_revenue)+sum(in_app_revenue)), sum(cost)) as roas
from combined_data
group by 1,2,3,4
order by date desc,cost desc;
