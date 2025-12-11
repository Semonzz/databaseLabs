CREATE OR REPLACE FUNCTION check_max_sentence()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.max_sentence > 25 THEN
        RAISE EXCEPTION 'Максимальный срок не должен превышать 25 лет.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_sentence_before_insert
BEFORE INSERT ON "Case"
FOR EACH ROW
EXECUTE FUNCTION check_max_sentence();

INSERT INTO "Case" (start_date, max_sentence, case_type_id, client_id) 
VALUES ('2024-01-01', 30, 1, 1);

-----------------------------------------------------

CREATE OR REPLACE FUNCTION check_actual_sentence()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.actual_sentence > NEW.max_sentence THEN
        RAISE EXCEPTION 'Полученный срок не может быть больше максимального';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_actual_sentence_before_update
BEFORE UPDATE ON "Case"
FOR EACH ROW
EXECUTE FUNCTION check_actual_sentence();

UPDATE "Case" SET actual_sentence = 10 WHERE max_sentence = 5;


---------------------------------------------------------

CREATE OR REPLACE FUNCTION handle_lawyer_delete()
RETURNS TRIGGER AS $$
DECLARE
    new_lawyer_id INTEGER;
BEGIN
    SELECT l.id INTO new_lawyer_id
    FROM Lawyer l
    WHERE l.id != OLD.id AND l.is_active = true
    ORDER BY (
        SELECT COUNT(*) FROM Lawyer_Case WHERE lawyer_id = l.id
    ) ASC
    LIMIT 1;
    
    IF new_lawyer_id IS NOT NULL THEN
        INSERT INTO Lawyer_Case (lawyer_id, case_id)
        SELECT new_lawyer_id, case_id
        FROM Lawyer_Case 
        WHERE lawyer_id = OLD.id
        ON CONFLICT DO NOTHING;
    END IF;

	DELETE FROM Lawyer_Case WHERE lawyer_id = OLD.id;
    DELETE FROM Lawyer_Client WHERE lawyer_id = OLD.id;
    DELETE FROM Lawyer_Specialization WHERE lawyer_id = OLD.id;
	
    DELETE FROM "Case" 
    WHERE id IN (
        SELECT lc.case_id 
        FROM Lawyer_Case lc 
        WHERE lc.lawyer_id = OLD.id
    ) 
    AND end_date IS NOT NULL;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_lawyer
BEFORE DELETE ON Lawyer
FOR EACH ROW
EXECUTE FUNCTION handle_lawyer_delete();

DELETE FROM Lawyer WHERE id = 2;