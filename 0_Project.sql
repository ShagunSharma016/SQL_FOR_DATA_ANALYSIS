-- 1.

WITH different_jobs AS(
    SELECT
        job_id,
        job_title,
         job_title_short,
        job_country,
        job_location,
        job_schedule_type,
        salary_year_avg,
        job_posted_date::DATE,
        name,
        DENSE_RANK() OVER
        (PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC
        ) AS rank
    FROM
        job_postings_fact

    LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id  

    WHERE
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL

)

SELECT *
FROM
    different_jobs
WHERE
    rank <=10
ORDER BY
    job_title_short,salary_year_avg DESC;


-- 2
WITH top_paying_skills AS(
    SELECT
        job_id,
        job_title,
        job_title_short,
        salary_year_avg,
        DENSE_RANK() OVER
        (PARTITION BY job_title_short
        ORDER BY salary_year_avg DESC) AS rank
    FROM
        job_postings_fact
    
    LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id

    WHERE
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
)
SELECT
    top_paying_skills.*,
    skills
FROM
    top_paying_skills

INNER JOIN skills_job_dim
ON top_paying_skills.job_id = skills_job_dim.job_id

INNER JOIN skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE rank<=10
ORDER BY
    job_title_short,salary_year_avg DESC;


-- 3.
WITH top_demand_skills AS(
    SELECT
        job_postings_fact.job_title_short,
        skills_dim.skills,
        COUNT(job_postings_fact.job_id) AS Skill_count,
        DENSE_RANK() OVER
        (PARTITION BY job_postings_fact.job_title_short
        ORDER BY COUNT(job_postings_fact.job_id) DESC) AS rank
    FROM
        job_postings_fact

    INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id

    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id

    GROUP BY
        job_postings_fact.job_title_short,skills_dim.skills

)
SELECT *
FROM
    top_demand_skills
WHERE
    rank<=5
ORDER BY
    job_title_short,Skill_count DESC;


-- 4..
SELECT
    skills_dim.skills,
    ROUND(AVG(salary_year_avg),2) AS Average_salary
FROM
    job_postings_fact

INNER JOIN skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id

INNER JOIN skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE
    salary_year_avg IS NOT NULL

GROUP BY
    
    skills_dim.skills

ORDER BY
    Average_salary DESC

LIMIT 25;

-- 5.
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS Skill_count,
    ROUND(AVG(salary_year_avg),0) AS Average_salary
FROM
    job_postings_fact

INNER JOIN skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id

INNER JOIN skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id 

WHERE
    salary_year_avg IS NOT NULL
GROUP BY
    skills_dim.skill_id,skills_dim.skills

HAVING
    COUNT(skills_job_dim.job_id)>=10

ORDER BY
    Skill_count DESC,
    Average_salary DESC

LIMIT 25;

