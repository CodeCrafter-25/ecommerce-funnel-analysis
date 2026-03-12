WITH session_data AS (
    SELECT 
        user_pseudo_id,
        (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
        traffic_source.source AS source,
        traffic_source.medium AS medium,
        traffic_source.name AS campaign,
        device.category AS device_category,
        device.language AS device_language,
        device.operating_system AS os,
        geo.country AS country
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name = 'session_start'
),

event_data AS (
    SELECT 
        user_pseudo_id,
        (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
        CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING)) AS user_session_id, 
        event_bundle_sequence_id,
        TIMESTAMP_MICROS(event_timestamp) AS event_time,
        REGEXP_EXTRACT(
            (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), 
            r'^(?:https?:\/\/)?[^\/]+\/(.*)$'
        ) AS landing_page_location
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase')
)

SELECT 
    e.user_session_id,
    e.event_name,
    e.event_time,
    e.landing_page_location,
    s.source,  
    s.medium,  
    s.campaign,  
    s.device_category,  
    s.device_language,  
    s.os,  
    s.country  
FROM event_data e
JOIN session_data s  
ON e.user_pseudo_id = s.user_pseudo_id
AND e.session_id = s.session_id  
ORDER BY e.event_time;  
