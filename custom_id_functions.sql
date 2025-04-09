-- Create sequences for custom IDs
CREATE SEQUENCE IF NOT EXISTS user_id_seq START WITH 1;
CREATE SEQUENCE IF NOT EXISTS librarian_id_seq START WITH 1;
CREATE SEQUENCE IF NOT EXISTS book_id_seq START WITH 1;

-- Function for generating user custom IDs (BWU-001)
CREATE OR REPLACE FUNCTION generate_user_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  next_val INTEGER;
BEGIN
  -- Get the next value from the sequence
  SELECT nextval('user_id_seq') INTO next_val;
  
  -- Format with leading zeros (e.g., BWU-001)
  NEW.custom_id := 'BWU-' || LPAD(next_val::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for generating librarian custom IDs (BWL-001)
CREATE OR REPLACE FUNCTION generate_librarian_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  next_val INTEGER;
BEGIN
  -- Get the next value from the sequence
  SELECT nextval('librarian_id_seq') INTO next_val;
  
  -- Format with leading zeros (e.g., BWL-001)
  NEW.custom_id := 'BWL-' || LPAD(next_val::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for generating book custom IDs (BWB-001)
CREATE OR REPLACE FUNCTION generate_book_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  next_val INTEGER;
BEGIN
  -- Get the next value from the sequence
  SELECT nextval('book_id_seq') INTO next_val;
  
  -- Format with leading zeros (e.g., BWB-001)
  NEW.custom_id := 'BWB-' || LPAD(next_val::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
