ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can view books" 
ON "public"."books"
FOR SELECT
USING (auth.role() != 'anon');

CREATE POLICY "Only librarians and admins can add books" 
ON "public"."books"
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid() AND (users.role = 'librarian' OR users.role = 'admin')
  )
);

CREATE POLICY "Only librarians and admins can update books" 
ON "public"."books"
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid() AND (users.role = 'librarian' OR users.role = 'admin')
  )
);

CREATE POLICY "Only admins can delete books" 
ON "public"."books"
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);