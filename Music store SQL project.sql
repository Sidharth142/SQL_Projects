 -- Basic
 -- Q1: who the senior mopst employee based on job title ?

 SELECT * FROM musicstore.employee order by levels desc limit 1

 -- Q2: which country have the most invoices ?

 SELECT COUNT(*) as c,BILLING_COUNTRY from musicstore.INVOICE 
 GROUP BY BILLING_COUNTRY ORDER BY c desc

 -- Q3: what are top 3 values of total invoice?

 select total from musicstore.invoice order by total desc limit 3

 -- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
 -- Write a query that returns one city that has the highest sum of invoice totals. 
 -- Return both the city name & sum of all invoice totals 

 select sum(total) as invoice_total,billing_city from musicstore.invoice
 group by billing_city order by  invoice_total desc



-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.

 USE musicstore;
 SELECT
   customer.customer_id,
   customer.first_name,
   customer.last_name,
   SUM(invoice.total) AS total
 FROM
    musicstore.customer
 JOIN
    invoice ON customer.customer_id = invoice.customer_id
 GROUP BY
   customer.customer_id,
    customer.first_name,
    customer.last_name
 ORDER BY
    total DESC
 LIMIT 1;

-- Moderate

-- Q6: Write query to return the email, first name, last name, & Genre of all "Rock Music" listeners. 
 -- Return your list ordered alphabetically by email starting with A. 
 SELECT DISTINCT email,first_name, last_name
 FROM musicstore.customer
 JOIN invoice ON customer.customer_id = invoice.customer_id
 JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
 WHERE track_id IN
 (
 SELECT track_id FROM musicstore.track
 JOIN musicstore.genre ON track.genre_id = genre.genre_id
 WHERE genre.name LIKE 'Rock'
 )
 ORDER BY email;

-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands. *

 SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
 FROM musicstore.track
 JOIN musicstore.album2 ON album2.album_id = track.album_id
 JOIN artist ON artist.artist_id = album2.artist_id
 JOIN genre ON genre.genre_id = track.genre_id
 WHERE genre.name LIKE 'Rock'
 GROUP BY artist.artist_id,artist.name
 ORDER BY number_of_songs DESC
 LIMIT 10;

 -- Q8: Return all the track names that have a song length longer than the average song length. 
 -- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

 SELECT name,milliseconds
 FROM musicstore.track
 WHERE milliseconds > (
 SELECT AVG(milliseconds) AS avg_track_length
 FROM musicstore.track )
 ORDER BY milliseconds DESC;

-- Advanced

-- Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent


 USE musicstore;

WITH best_selling_artist AS (
SELECT 
artist.artist_id AS artist_id, 
artist.name AS artist_name, 
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM musicstore.invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY artist_id, artist_name
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT 
c.customer_id, 
c.first_name, 
c.last_name, 
bsa.artist_name,                                              -- bsa = best selling artist
SUM(il.unit_price*il.quantity) AS amount_spent
FROM musicstore.invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name
ORDER BY 
    amount_spent DESC;
    

-- Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--  the maximum number of purchases is shared return all Genres. */


use musicstore;

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country,genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



-- Q11: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount. */

use musicstore;

WITH Customter_with_country AS 
(
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC,total_spending DESC
)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
