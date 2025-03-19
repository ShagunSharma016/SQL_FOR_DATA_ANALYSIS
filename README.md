# Introduction
📊 Dive into the data job market! Focusing on different data science job roles, this project explores top-paying jobs, in-demand skills, and where high demand meets high salary in data analytics.

# Background
Driven by a quest to navigate the data analyst job market more effectively, this project was born from a desire to pinpoint top-paid and in-demand skills, streamlining others' work to find optimal jobs.

### The questions I wanted to answer through my SQL queries were:
**1. What are top-paying data science jobs?**  
**2. What skills are required for these top-paying jobs?**  
**3. What skills are most in demand for data science jobs?**  
**4. Which skills are associated with higher salaries?**  
**5. What are the most optimal skills to learn?**  

# Tools I Used
For my deep dive into the data analyst job market, I harnessed the power of several key tools:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.
## Query - 1
```


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
```

## Query - 2
```
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
````

## Query - 3
```
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
```

## Query - 4
```
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
```

## Query - 5
```
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

```
# What I Learned
Throughout this adventure, I've turbocharged my SQL toolkit with some serious firepower:

- **Complex Query Crafting:** Mastered the art of advanced SQL, merging tables and wielding WITH clauses for temp table maneuvers.
- **Data Aggregation:** Got cozy with GROUP BY and turned aggregate functions like COUNT() and AVG() into my data-summarizing sidekicks.

# Conclusions
This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.

