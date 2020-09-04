class SqlQueries:
    """Contains: create queries, create queries dictionary and insert queries. """
    def fact_queries():

        top_day_songs = """
        SELECT 
            song,
            artist,
            COUNT(*)
        FROM songplay
        JOIN songs
        ON songs.artist_id = songplay.artist_id
        GROUP BY artist, song, COUNT(*)
        ORDER BY COUNT(*) DESC
        WHERE year = {}
        AND month = {}
        AND day = {}
        LIMIT 10
        """

        top_month_songs = """
        SELECT 
            song,
            artist,
            COUNT(*)
        FROM songplay
        JOIN songs
        ON songs.artist_id = songplay.artist_id
        GROUP BY artist, song, COUNT(*)
        ORDER BY COUNT(*) DESC
        WHERE year = {}
        AND month = {}
        LIMIT 10
        """

        top_year_songs = """
        SELECT 
            song,
            artist,
            COUNT(*)
        FROM songplay
        JOIN songs
        ON songs.artist_id = songplay.artist_id
        GROUP BY artist, song, COUNT(*)
        ORDER BY COUNT(*) DESC
        WHERE year = {}
        LIMIT 10
        """

        upgrade_downgrade_count = """
        SELECT 
            page,
            COUNT(*)
        FROM sparkify.staging_events
        GROUP BY page
        WHERE page IN ('Downgrade', 'Upgrade')
        """

        avg_session_id_item = """
        SELECT
        page,
        ROUND(AVG(iteminsession), 1) AS avg_item_in_session,
        ROUND(AVG(sessionid), 1) AS avg_session_id
        from 
        staging_events
        WHERE 
        page IN ('Upgrade', 'Downgrade', 'Submit Upgrade', 'Submit Downgrade')
        GROUP BY
        page
        """

        return locals()