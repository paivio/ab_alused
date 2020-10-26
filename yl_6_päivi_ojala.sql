-- 1. Luua f-n klubiliikmete arvu leidmiseks klubi id põhjal f_klubisuurus(id)
CREATE FUNCTION f_klubisuurus (f_id INTEGER)
RETURNS INTEGER
BEGIN
    DECLARE liikmete_arv INTEGER;
    SELECT COUNT (klubi) INTO liikmete_arv FROM isikud
    WHERE klubi = f_id;
    RETURN liikmete_arv;
END;


-- 2. Luua f-n ees- ja perenime kokku liitmiseks eesti ametlikul viisil ("perenimi, eesnimi") f_nimi('Eesnimi', 'Perenimi').
CREATE FUNCTION f_nimi (f_eesnimi VARCHAR(20), f_perenimi VARCHAR(20))
RETURNS VARCHAR(50)
BEGIN
    DECLARE uus_nimi VARCHAR(50);
    SELECT (Perenimi || ', ' || Eesnimi) INTO uus_nimi FROM isikud
    WHERE Eesnimi = f_eesnimi AND Perenimi = f_perenimi;
    RETURN uus_nimi;
END;


-- 3. Luua f-n ühe mängija partiide koguarv f_mangija_koormus(id)
CREATE FUNCTION f_mangija_koormus (k_id INTEGER)
RETURNS INTEGER
BEGIN
    DECLARE partiide_arv INTEGER;
    SELECT COUNT (Id) INTO partiide_arv FROM partiid
    WHERE k_id = Valge OR k_id = Must;
    RETURN partiide_arv;
END;


-- 4. Luua f-n ühe mängija võitude arv turniiril f_mangija_voite_turniiril(isikud.id, turniirid.id)
CREATE FUNCTION f_mangija_voite_turniiril (m_id INTEGER, t_id INTEGER)
RETURNS INTEGER
BEGIN
    DECLARE voitude_arv INTEGER;
    SELECT COUNT (Id) INTO voitude_arv FROM partiid
    WHERE (m_id = Valge OR m_id = Must) AND t_id = Turniir 
    AND (Valge_tulemus = 2 OR Musta_tulemus = 2);
    RETURN voitude_arv;
END;


-- 5. Luua f-n ühe mängija punktisumma turniiril f_mangija_punktid_turniiril(isikud.id, turniirid.id)
CREATE FUNCTION f_mangija_punktid_turniiril (m_id INTEGER, t_id INTEGER)
RETURNS DECIMAL(4,1)
BEGIN
    DECLARE punktide_arv DECIMAL(4,1);
    SELECT SUM (punkt) INTO punktide_arv FROM v_punktid
    WHERE m_id = mangija AND t_id = turniir
    GROUP BY turniir;
    RETURN punktide_arv;
END;


-- 6. Luua protseduur sp_uus_isik, mis lisab eesnime ja perenimega määratud isiku etteantud numbriga klubisse ning paneb neljandasse parameetrisse uue isiku ID väärtuse. 
CREATE PROCEDURE sp_uus_isik (IN u_eesnimi VARCHAR(20), 
IN u_perenimi VARCHAR(20), IN u_klubi INTEGER, OUT u_id INTEGER)
BEGIN
    DECLARE i_id INTEGER;
    INSERT INTO isikud(eesnimi, perenimi, klubi)
    VALUES (u_eesnimi, u_perenimi, u_klubi);
    SELECT @@identity INTO i_id;
    SET u_id = i_id;
END;


-- 7. Luua tabelit väljastav protseduur sp_infopump() See peab andma välja unioniga kokku panduna järgmised asjad (kasutades varemdefineeritud võimalusi): 1) klubi nimi ja tema mängijate arv (kasutada funktsiooni f_klubisuurus) 2) turniiri nimi ja tema jooksul tehtud mängude arv (kasutada group by) 3) mängija nimi ja tema poolt mängitud partiide arv (kasutada f_nimi ja f_mangija_koormus) ning tulemus sorteerida nii, et klubide info oleks kõige ees, siis turniiride oma ja siis alles isikud. Iga grupi sees sorteerida nime järgi.
CREATE PROCEDURE sp_infopump()
RESULT (nimi VARCHAR(70), arv INTEGER, jrk INTEGER)
BEGIN
    SELECT klubid.nimi, f_klubisuurus(klubid.id), 1
    FROM klubid
    UNION
    SELECT turniirid.nimi, COUNT (partiid.id), 2
    FROM turniirid JOIN partiid ON turniirid.id = partiid.turniir
    GROUP BY turniirid.nimi
    UNION
    SELECT f_nimi(isikud.eesnimi, isikud.perenimi), f_mangija_koormus(isikud.id), 3
    FROM isikud
    ORDER BY 3;
END;


-- 8. Luua tabelit väljastav protseduur sp_top10, millel on üks parameeter - turniiri id, ja mis kasutab vaadet v_edetabelid ja annab tulemuseks kümme parimat etteantud turniiril.
CREATE PROCEDURE sp_top10 (IN t_id INTEGER)
RESULT(nimi VARCHAR(50), punktid DECIMAL(4,1))
BEGIN
    SELECT TOP 10 mangija, punkte 
    FROM v_edetabelid
    WHERE t_id = turniir
    ORDER BY punkte DESC;
END;


-- 9. Luua tabelit väljastav protseduur sp_voit_viik_kaotus, mis väljastab kõigi osalenud mängijate võitude, viikide ja kaotuste arvu etteantud turniiril. Tabeli struktuur: id, eesnimi, perenimi, võite, viike, kaotusi (f_mangija_voite_turniiril jt sarnased funktsioonid oleksid abiks ...)
CREATE PROCEDURE sp_voit_viik_kaotus()
RESULT(id INTEGER, eesnimi VARCHAR(20), perenimi VARCHAR(20), võite INTEGER, viike INTEGER, kaotusi INTEGER)
BEGIN
    SELECT DISTINCT partiid.turniir, isikud.eesnimi, isikud.perenimi, 
    f_mangija_voite_turniiril(isikud.id, partiid.turniir), 
    f_mangija_viike_turniiril(isikud.id, partiid.turniir),
    f_mangija_kaotusi_turniiril(isikud.id, partiid.turniir)
    FROM isikud JOIN partiid ON isikud.id = partiid.valge OR isikud.id = partiid.must;
END;


-- 10. Luua indeks turniiride algusaegade peale.
CREATE INDEX t_algus ON turniirid (alguskuupaev);


-- 11. Luua indeksid partiidele kahanevalt valge ja musta tulemuse peale.
CREATE INDEX i_valge ON partiid (valge_tulemus DESC);
CREATE INDEX i_must ON partiid (musta_tulemus DESC);
