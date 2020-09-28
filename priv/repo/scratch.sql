-- The purpose of this file is to have a list of working SQL Queries
-- that we can use to inspect the data in the DB.
-- I still find "raw" SQL to be easier to read/reason about than Ecto

-- select distinct people with status.text
SELECT DISTINCT ON (l.person_id, l.app_id)
l.id, l.app_id, l.person_id, l.updated_at,
st.text as status
  FROM logs l
  JOIN status as st on l.status_id = st.id

SELECT DISTINCT ON (l.person_id, l.app_id)
l.id, l.app_id, l.person_id, l.updated_at,
st.text as status
  FROM logs l
  JOIN status as st on l.status_id = st.id
  ORDER BY l.inserted_at

-- GROUP BY
SELECT person_id, app_id
FROM logs
GROUP BY person_id, app_id;

-- try adding status (FAILS)
SELECT person_id, app_id, status_id
FROM logs
GROUP BY (person_id, app_id);
-- ERROR:  column "logs.status_id" must appear in the GROUP BY clause

-- with the number of logs for that person:
SELECT person_id, app_id, count(*) AS count
FROM logs
GROUP BY person_id, app_id;

-- example from:
-- https://stackoverflow.com/questions/9795660/distinct-on-with-order-by
SELECT * FROM (
  SELECT DISTINCT ON (address_id) *
  FROM purchases 
  WHERE product_id = 1
  ORDER BY address_id, purchased_at DESC
) t
ORDER BY purchased_at DESC

-- attempt to use on logs: WORKS
SELECT * FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs
  ORDER BY person_id, inserted_at DESC
) t
ORDER BY inserted_at DESC

-- attempt JOIN in subquery:
SELECT * FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs l
  ORDER BY l.person_id, l.inserted_at DESC
) t
ORDER BY inserted_at DESC

-- This works!!
SELECT l.id as log_id, l.person_id, st.text as status, p."givenName", 
l.inserted_at, p.email, l.auth_provider
FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs
  ORDER BY person_id, inserted_at DESC
) l
JOIN status as st on l.status_id = st.id
JOIN people as p on l.person_id = p.id
ORDER BY l.inserted_at DESC

-- with roles (WORKS!)
SELECT l.id as log_id, l.app_id, l.person_id, p.status, 
st.text as status, p."givenName", p.picture,
l.inserted_at, p.email, l.auth_provider, r.name
FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs
  ORDER BY person_id, inserted_at DESC
) l
JOIN people as p on l.person_id = p.id
JOIN status as st on p.status = st.id
JOIN people_roles as pr on p.id = pr.person_id
JOIN roles as r on pr.role_id = r.id
WHERE l.app_id in (1, 2)
ORDER BY l.inserted_at DESC

/* the gaps are blobs of encrypted data:
6	1	10835816	1	verified			2020-09-24 19:28:25		github	subscriber
4	1	1	1	verified			2020-09-24 17:28:40		google	superadmin
*/

-- Old People query (works)
SELECT l.app_id, l.person_id, p.status,
st.text as status, p."givenName", p.picture,
l.inserted_at, p.email, l.auth_provider, r.name
FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs
  ORDER BY person_id, inserted_at DESC
) l
JOIN people as p on l.person_id = p.id
LEFT JOIN status as st on p.status = st.id
LEFT JOIN people_roles as pr on p.id = pr.person_id
LEFT JOIN roles as r on pr.role_id = r.id
WHERE l.app_id in (#{app_ids})
ORDER BY l.inserted_at DESC
NULLS LAST

-- New People Query Without Apps Costraint: 
-- https://github.com/dwyl/auth/issues/127
SELECT l.app_id, p.id, p.status,
st.text as status, p."givenName", p.picture,
l.inserted_at, p.email, l.auth_provider, r.name
FROM (
  SELECT DISTINCT ON (person_id) *
  FROM logs
  ORDER BY person_id, inserted_at DESC
) l
JOIN people as p on l.person_id = p.id
LEFT JOIN status as st on p.status = st.id
LEFT JOIN people_roles as pr on p.id = pr.person_id
LEFT JOIN roles as r on pr.role_id = r.id
WHERE p.id != 1
ORDER BY l.inserted_at DESC
NULLS LAST

-- Alterntative faster query without logs:
SELECT DISTINCT ON (p.id) p.id, p."givenName", p.picture,
p.updated_at, p.email, p.auth_provider, r.name, pr.app_id,
p.status, st.text as status
FROM people AS p
LEFT JOIN people_roles as pr on p.id = pr.person_id
LEFT JOIN roles as r on pr.role_id = r.id
LEFT JOIN status as st on p.status = st.id
WHERE p.id != 1