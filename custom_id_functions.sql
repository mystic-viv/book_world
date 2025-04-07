-- Function for generating user custom IDs (BWU-001)
CREATE OR REPLACE FUNCTION generate_user_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  prefix TEXT := 'BWU-';
  last_id TEXT;
  new_number INTEGER;
BEGIN
  -- Get the last ID for this prefix
  SELECT custom_id INTO last_id 
  FROM users 
  WHERE custom_id LIKE prefix || '%' 
  ORDER BY custom_id DESC 
  LIMIT 1;
  
  -- Extract the number part or start with 1
  IF last_id IS NULL THEN
    new_number := 1;
  ELSE
    new_number := (REGEXP_REPLACE(last_id, '^' || prefix || '(\d+)$', '\1')::INTEGER) + 1;
  END IF;
  
  -- Format with leading zeros (e.g., BWU-001)
  NEW.custom_id := prefix || LPAD(new_number::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for generating librarian custom IDs (BWL-001)
CREATE OR REPLACE FUNCTION generate_librarian_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  prefix TEXT := 'BWL-';
  last_id TEXT;
  new_number INTEGER;
BEGIN
  -- Get the last ID for this prefix
  SELECT custom_id INTO last_id 
  FROM librarians 
  WHERE custom_id LIKE prefix || '%' 
  ORDER BY custom_id DESC 
  LIMIT 1;
  
  -- Extract the number part or start with 1
  IF last_id IS NULL THEN
    new_number := 1;
  ELSE
    new_number := (REGEXP_REPLACE(last_id, '^' || prefix || '(\d+)$', '\1')::INTEGER) + 1;
  END IF;
  
  -- Format with leading zeros (e.g., BWL-001)
  NEW.custom_id := prefix || LPAD(new_number::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for generating book custom IDs (BWB-001)
CREATE OR REPLACE FUNCTION generate_book_custom_id()
RETURNS TRIGGER AS $$
DECLARE
  prefix TEXT := 'BWB-';
  last_id TEXT;
  new_number INTEGER;
BEGIN
  -- Get the last ID for this prefix
  SELECT custom_id INTO last_id 
  FROM books 
  WHERE custom_id LIKE prefix || '%' 
  ORDER BY custom_id DESC 
  LIMIT 1;
  
  -- Extract the number part or start with 1
  IF last_id IS NULL THEN
    new_number := 1;
  ELSE
    new_number := (REGEXP_REPLACE(last_id, '^' || prefix || '(\d+)$', '\1')::INTEGER) + 1;
  END IF;
  
  -- Format with leading zeros (e.g., BWB-001)
  NEW.custom_id := prefix || LPAD(new_number::TEXT, 3, '0');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle new user creation from auth.users
CREATE OR REPLACE FUNCTION handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into users table
  INSERT INTO users (
    id,
    email,
    metadata,
    role
  ) VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data,
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle user updates from auth.users
CREATE OR REPLACE FUNCTION handle_auth_user_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Update users table
  UPDATE users
  SET
    email = NEW.email,
    metadata = NEW.raw_user_meta_data,
    role = COALESCE(NEW.raw_user_meta_data->>'role', 'user')
  WHERE
    id = NEW.id;
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
