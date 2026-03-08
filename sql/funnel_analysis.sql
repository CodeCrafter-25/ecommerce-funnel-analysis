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
        event_name,  
        event_bundle_sequence_id, ...
