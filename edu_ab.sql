-- 1. Luua vaade v_persons_atleast_4eap (FirstName, LastName) õpilastest, kes õpivad Matemaatikainformaatikateaduskonna ainetel, mis annavad vähemalt 4 EAP-d.
CREATE VIEW v_persons_atleast_4eap (FirstName,LastName) AS
SELECT DISTINCT FirstName, LastName 
FROM persons JOIN registrations ON persons.id=registrations.personId 
JOIN courses ON registrations.courseId=courses.id
WHERE courses.eap >= 4 AND courses.facultyId = 9;


-- 2. Luua vaade v_mostA(FirstName, LastName, NrOfA) õpilastest, kes on saanud A-sid (eristuv hindamine) Matemaatika-informaatikateaduskonna ainetest.
CREATE VIEW v_mostA (FirstName,LastName, NrOfA) AS
SELECT DISTINCT FirstName, LastName, COUNT(registrations.finalGrade)
FROM persons JOIN registrations ON persons.id=registrations.personId 
JOIN courses ON registrations.courseId=courses.id
WHERE courses.gradeType = 'eksam' AND courses.facultyId = 9 AND registrations.finalGrade = 'A'
GROUP BY FirstName, LastName, registrations.finalGrade;


-- 3. Luua uus kursus "Andmebaaside teooria". Matemaatika-informaatikateaduskond, MTAT.03.998, 6EAP, Arvestus Lisada sinna kõik õpilased, kes said aines Andmebaasid arvestuse (A).
INSERT INTO courses VALUES(102, 9, 'Andmebaaside teooria', 'MTAT.03.998', 6, 'Arvestus');
INSERT INTO registrations (CourseId, PersonId, FinalGrade)
SELECT 102, persons.id, NULL 
FROM courses JOIN registrations ON courses.id=registrations.courseId
JOIN persons ON registrations.personId=persons.id
WHERE courses.name='Andmebaasid' AND registrations.finalGrade='A';


-- 4. Luua vaade v_andmebaasideTeooria õpilastest, kes õpivad ainet andmebaaside teooria. (PersonId, FirstName, LastName).
CREATE VIEW v_andmebaasideTeooria (PersonId, FirstName, LastName) AS
SELECT DISTINCT persons.id, FirstName, LastName 
FROM persons JOIN registrations ON persons.id=registrations.personId 
JOIN courses ON registrations.courseId=courses.id
WHERE courses.name = 'Andmebaaside teooria';


-- 5. Luua vaade v_top40A (FirstName, LastName, nrOfA) päringule TOP 40 õpilastest, kes on saanud kõige rohkem A-sid (hinne või arvestus) järjestamisel arvestada ka veergudega LastName, FirstName).
CREATE VIEW v_top40A (FirstName, LastName, nrOfA) AS
SELECT TOP 40 firstName, lastName, COUNT(registrations.finalGrade)
FROM persons JOIN registrations ON persons.id=registrations.personId 
JOIN courses ON registrations.courseId=courses.id
WHERE registrations.finalGrade='A'
GROUP BY lastName, firstName
ORDER BY COUNT(registrations.finalGrade) DESC, lastName, firstName;


-- 6. Luua vaade v_top30Students(FirstName, LastName, AverageGrade) päringule TOP 30 õpilastest, kelle keskmine eksami hinne on kõige kõrgem (võrdse keskmise hinde korral vaadata ka veerge LastName, FirstName).
CREATE VIEW v_top30Students (FirstName, LastName, AverageGrade) AS
SELECT TOP 30 firstName, lastName, AVG(finalGrade) AS averageGrade
FROM (SELECT firstName, lastName,
CASE FinalGrade
    WHEN 'A' THEN 5
    WHEN 'B' THEN 4
    WHEN 'C' THEN 3
    WHEN 'D' THEN 2
    WHEN 'E' THEN 1
    WHEN 'F' THEN 0
END AS finalGrade
FROM persons JOIN registrations ON persons.id=registrations.personId 
JOIN courses ON registrations.courseId=courses.id
WHERE courses.gradeType='Eksam') AS average
GROUP BY firstName, lastName
ORDER BY averageGrade DESC, lastName, firstName;

