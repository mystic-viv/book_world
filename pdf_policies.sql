-- Enable RLS on the new tables
ALTER TABLE reading_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE pdf_downloads ENABLE ROW LEVEL SECURITY;

-- Reading Progress policies
CREATE POLICY "Users can view their own reading progress" 
  ON reading_progress FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own reading progress" 
  ON reading_progress FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own reading progress" 
  ON reading_progress FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Bookmark policies
CREATE POLICY "Users can view their own bookmarks" 
  ON bookmarks FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own bookmarks" 
  ON bookmarks FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookmarks" 
  ON bookmarks FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own bookmarks" 
  ON bookmarks FOR DELETE 
  USING (auth.uid() = user_id);

-- PDF Metadata policies (librarians and admins can manage)
CREATE POLICY "Anyone can view PDF metadata" 
  ON pdf_metadata FOR SELECT 
  USING (true);

CREATE POLICY "Only librarians and admins can update PDF metadata" 
  ON pdf_metadata FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND (users.role = 'librarian' OR users.role = 'admin')
    )
  );

-- PDF Downloads policies
CREATE POLICY "Users can view their own download history" 
  ON pdf_downloads FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own download records" 
  ON pdf_downloads FOR INSERT 
  WITH CHECK (auth.uid() = user_id);
