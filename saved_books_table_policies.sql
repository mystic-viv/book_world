-- Enable RLS
ALTER TABLE saved_books ENABLE ROW LEVEL SECURITY;

-- Allow users to view only their saved books
CREATE POLICY "Users can view their saved books" ON saved_books
  FOR SELECT USING (auth.uid() = user_id);

-- Allow users to save books
CREATE POLICY "Users can save books" ON saved_books
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to unsave their books
CREATE POLICY "Users can unsave their books" ON saved_books
  FOR DELETE USING (auth.uid() = user_id);

-- Prevent updates (books can only be saved or unsaved)
CREATE POLICY "No updates allowed" ON saved_books
  FOR UPDATE USING (false);
