-- AB alused, yl 5, itminf, Päivi Ojala


-- 1. Luua vaade v_turniiripartiid (turniir_nimi, partii_id, partii_algus, partii_lopp).
CREATE VIEW v_turniiripartiid (turniir_nimi, partii_algus, partii_lopp) AS
SELECT turniirid.nimi, partiid.algushetk, partiid.lopphetk
FROM turniirid, partiid
WHERE turniirid.id=partiid.turniir;

-- 2a. Luua vaade v_klubipartiikogused_1 (klubi_nimi, partiisid) veeru partiisid väärtus = selliste partiide arv, kus kas valge või must mängija on klubi liige (kui mõlemad samast, siis lisandub klubile 1 partii).
CREATE VIEW v_klubipartiikogused_1 (klubi_nimi, partiisid) AS
SELECT klubid.nimi, COUNT(DISTINCT partiid.id)
FROM klubid, partiid, isikud 
WHERE klubid.id=isikud.klubi AND 
(partiid.valge=isikud.id OR partiid.must=isikud.id)
GROUP BY klubid.nimi;

-- 2b. Luua vaade v_klubipartiikogused_2 (klubi_nimi, partiisid) veeru partiisid väärtus = selliste partiide arv, kus kas valge või must mängija on klubi liige (kui mõlemad samast, siis lisandub klubile 2 partiid).
CREATE VIEW v_klubipartiikogused_2 (klubi_nimi, partiisid) AS
SELECT klubid.nimi, COUNT(partiid.id)
FROM klubid, partiid, isikud 
WHERE klubid.id=isikud.klubi AND 
(partiid.valge=isikud.id OR partiid.must=isikud.id)
GROUP BY klubid.nimi;

-- 3. Luua vaade v_punktid (partii, turniir, mangija, varv, punkt), kus oleksid kõigi mängijate kõigi partiide jooksul saadud punktid (viitega partiile ja turniirile) koos värviga (valge (V), must (M)). 
CREATE VIEW v_punktid (partii, turniir, mangija, varv, punkt) AS
SELECT v.id, v.turniir, v.valge,'V', v.valge_tulemus*0.5
FROM partiid as v
UNION ALL
SELECT m.id, m.turniir, m.must,'M', m.musta_tulemus*0.5
FROM partiid as m;

-- 4. Vaate v_punktid ja vaate v_mangijad põhjal teha vaade v_edetabelid (mangija, turniir, punkte), kus veerus mangija on mängija nimi (v_mangijad.isik_nimi) ja veerus turniir on turniiri ID. Punkte arvutatakse iga turniiri jaoks (mängija punktid sellel turniiril).
CREATE VIEW v_edetabelid (mangija, turniir, punkte) AS
SELECT v_mangijad.isik_nimi, v_punktid.turniir, SUM(v_punktid.punkt)
FROM v_mangijad JOIN v_punktid ON v_punktid.mangija=v_mangijad.isik_id
GROUP BY v_mangijad.isik_nimi, v_punktid.turniir;

-- 5. Teha päring paremusjärjestuse saamiseks: Kolm paremat turniiri “Kolme klubi kohtumine” (turniiri ID = 41) edetabeli saamiseks (järjekorra number, nimi ja punktid) ning vormistada see vaatena v_kolmik.
CREATE VIEW v_kolmik (jrk_nr, nimi, punktid) AS
SELECT TOP 3 number(*), mangija, punkte
FROM v_edetabelid
WHERE turniir=41
ORDER BY punkte DESC;
