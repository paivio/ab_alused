-- AB alused, yl 4, PÄIVI OJALA, itminf

-- 1. Leida klubi ‘Laudnikud’ liikmete nimekiri (eesnimi, perenimi) tähestiku järjekorras (eesnimi, perenimi).
SELECT eesnimi, perenimi 
FROM isikud, klubid
WHERE klubid.id=isikud.klubi AND klubid.nimi='Laudnikud'
ORDER BY nimi, perenimi;


-- 2. Leida klubi ‘Laudnikud’ liikmete arv.
SELECT COUNT (eesnimi) AS liikmete_arv
FROM isikud, klubid
WHERE klubid.id=isikud.klubi AND klubid.nimi='Laudnikud';


-- 3. Leida V-tähega algavate klubide M-tähega algavate eesnimedega isikute perekonnanimed (ja ei muud).
SELECT perenimi
FROM isikud, klubid
WHERE klubid.id=isikud.klubi AND LEFT(klubid.nimi,1)='V' AND LEFT(isikud.eesnimi,1)='M';


-- 4. Leida kõige esimesena alanud partii algusaeg.
SELECT MIN(partiid.algushetk) AS esimene_partii
FROM partiid;


-- 5. Leida partiide mängijad (viited mängijatele (väljad: valge ja must)), mis algasid 04. märtsil 2005 aastal ajavahemikus 9:00 kuni 11:00.
SELECT valge, must
FROM partiid
WHERE algushetk BETWEEN ('2005-03-04 09:00') AND ('2005-03-04 10:59');


-- 6. Leida valgetega võitnute (valge_tulemus=2) isikute nimed (eesnimi, perenimi), kus partii kestis 9 kuni 11 minutit (vt funktsiooni Datediff(); Datediff(minute, <algus>, <lõpp>)).
SELECT eesnimi, perenimi, (SELECT DATEDIFF(minute, algushetk, lopphetk)) AS vahe 
FROM partiid JOIN isikud ON (partiid.valge=isikud.id)
WHERE vahe BETWEEN 9 AND 11 
AND valge_tulemus=2;


-- 7. Leida tabelis Isikud rohkem kui 1 kord esinevad perekonnanimed (ja ei muud).
SELECT perenimi
FROM isikud
GROUP BY perenimi
HAVING COUNT(perenimi) > 1;


-- 8. Leida klubid (nimi ja liikmete arv), kus on alla 4 liikme.
SELECT klubid.nimi, COUNT(isikud.eesnimi) AS liikmeid
FROM klubid JOIN isikud ON (klubid.id=isikud.klubi)
GROUP BY klubid.nimi
HAVING liikmeid < 4;


-- 9. Leida kõigi Arvode poolt kokku valgetega mängitud partiide arv.
SELECT eesnimi, COUNT(partiid.id) AS partiide_arv
FROM partiid JOIN isikud ON (partiid.valge=isikud.id)
WHERE eesnimi = 'Arvo'
GROUP BY eesnimi;


-- 10. Leida kõigi Arvode poolt kokku valgetega mängitud partiide arv turniiride lõikes (turniiri id ja partiide arv).
SELECT eesnimi, turniir, COUNT(partiid.id) AS partiide_arv
FROM partiid JOIN isikud ON (partiid.valge=isikud.id)
WHERE eesnimi = 'Arvo'
GROUP BY eesnimi, turniir;


-- 11. Leida kõigi Mariade poolt kokku mustadega mängitud mängudest saadud punktide arv (tulemus = 2 on võit ja annab ühe punkti, tulemus = 1 on viik ja annab pool punkti).
SELECT eesnimi, SUM(musta_tulemus*0.5) AS punktid
FROM isikud JOIN partiid ON (partiid.must=isikud.id)
WHERE eesnimi = 'Maria'
GROUP BY eesnimi;


-- 12. Leida partiide keskmine kestvus turniiride kaupa (tulemuseks on tabel 2 veeruga: turniiri nimi, keskmine partii pikkus).
SELECT nimi, AVG(DATEDIFF(minute, partiid.algushetk, partiid.lopphetk)) AS keskmine_aeg 
FROM partiid JOIN turniirid ON (partiid.turniir=turniirid.id)
GROUP BY nimi;
