CREATE TABLE book_interactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  book_id UUID REFERENCES books(id) NOT NULL,
  interaction_type TEXT NOT NULL, -- 'view', 'borrow', 'save', etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Enable RLS
ALTER TABLE book_interactions ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own interactions
CREATE POLICY "Users can view their interactions" ON book_interactions
  FOR SELECT USING (auth.uid() = user_id);

-- Allow users to create their own interactions
CREATE POLICY "Users can create interactions" ON book_interactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- No updates allowed
CREATE POLICY "No updates allowed" ON book_interactions
  FOR UPDATE USING (false);

-- No deletes allowed (keep interaction history)
CREATE POLICY "No deletes allowed" ON book_interactions
  FOR DELETE USING (false);
