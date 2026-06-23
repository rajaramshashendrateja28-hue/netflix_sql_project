-- 15 business problems

-- 1. Count the number of Movies vs TV Shows

SELECT 
type,
COUNT(TYPE) as Total_Count
FROM netflix
GROUP BY type
-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year LIKE 2020
SELECT *
FROM netflix
WHERE release_year = 2020

--Find the top 5 countries with the most content on Netflix
WITH Cleaned_Info AS (
SELECT
*,
UNNEST(STRING_TO_ARRAY(country,',')) as New_country
FROM netflix
WHERE country IS NOT NULL)
SELECT 
New_country as country
FROM Cleaned_Info
GROUP BY New_country
ORDER BY COUNT(*) DESC LIMIT 5

-- 5. Identify the longest movie
SELECT 
title
FROM netflix
WHERE type='Movie' AND duration= (SELECT MAX(duration) FROM netflix WHERE type='Movie')

-- 6. Find content added in the last 5 years

  SELECT 
  *
  FROM netflix
  WHERE TO_DATE(date_added, 'Month DD, YYYY')>CURRENT_DATE-INTERVAL '5 years'

-- Find all the movies/TV shows by director 'Rajiv Chilaka'

 WITH Cleaned_Info AS(
 SELECT 
 UNNEST(STRING_TO_ARRAY(director,',')) as director_name,
 title
 FROM netflix)
 SELECT 
 director_name,
 title
 FROM Cleaned_Info
 WHERE director_name IS NOT NULL AND director_name='Rajiv Chilaka' 

-- 8. List all TV shows with more than 5 seasons

SELECT
title
FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5
 
 -- 9. Count the number of content items in each genre
 
 WITH Cleaned_Info AS(
 SELECT 
 UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre
 FROM 
 netflix)
 SELECT
 genre,
 COUNT(genre) AS No_Of_Content_Items
 FROM Cleaned_Info
 GROUP BY genre

-- 10. Find average releases in india, and each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

--a
  
WITH Cleaned_Info AS (
SELECT
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_released,
UNNEST(STRING_TO_ARRAY(country,',')) AS modified_country
FROM netflix),
content_in_india AS ( SELECT
year_released,
 COUNT(*) AS no_of_released_content
FROM Cleaned_Info
WHERE modified_country='India' AND modified_country IS NOT NULL
GROUP BY year_released,year_released)
SELECT
AVG(no_of_released_content) AS Avg_Year_Releases_India
FROM content_in_india

--b
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

-- 11. List all movies that are documentaries
 SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'

-- 12. Find all content without a director
 SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
  SELECT
  SUM( CASE WHEN casts LIKE '%Salman Khan%' THEN 1 ELSE 0 END) AS No_of_Appeared
  FROM netflix
  WHERE TO_DATE(date_added, 'Month DD, YYYY')>=CURRENT_DATE- INTERVAL '10 years'

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

    SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- Question 15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
WITH Added_Info AS(
SELECT *,
CASE WHEN description LIKE'%kill%' OR description LIKE'%violence' THEN 'bad' ELSE 'good'END AS categorized_content
FROM netflix)
SELECT 
categorized_content,
COUNT(*) 
FROM Added_Info
GROUP BY categorized_content



















