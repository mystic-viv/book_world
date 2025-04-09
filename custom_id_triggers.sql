-- Create trigger for users table to generate custom_id
CREATE TRIGGER set_user_custom_id
BEFORE INSERT ON users
FOR EACH ROW
WHEN (NEW.custom_id IS NULL)
EXECUTE FUNCTION generate_user_custom_id();

-- Create trigger for librarians table to generate custom_id
CREATE TRIGGER set_librarian_custom_id
BEFORE INSERT ON librarians
FOR EACH ROW
WHEN (NEW.custom_id IS NULL)
EXECUTE FUNCTION generate_librarian_custom_id();

-- Create trigger for books table to generate custom_id
CREATE TRIGGER set_book_custom_id
BEFORE INSERT ON books
FOR EACH ROW
WHEN (NEW.custom_id IS NULL)
EXECUTE FUNCTION generate_book_custom_id();
