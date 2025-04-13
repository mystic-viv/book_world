ALTER TABLE public.librarians ENABLE ROW LEVEL SECURITY;

-- Allow public access to check if an email exists (needed for signup verification)
CREATE POLICY "Allow email verification for signup"
ON "public"."librarians"
FOR SELECT
USING (true);

-- Librarians can read their own profile
CREATE POLICY "Librarians can read their own profile"
ON "public"."librarians"
FOR SELECT
USING (
  auth.uid() = id OR
  email = (SELECT email FROM auth.users WHERE id = auth.uid())
);

-- Librarians can update their own profile
CREATE POLICY "Librarians can update their own profile" 
ON "public"."librarians"
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- System can update id during signup
CREATE POLICY "Allow id update during signup"
ON "public"."librarians"
FOR UPDATE
USING (
  -- Allow updating when email matches the authenticated user's email
  email = (SELECT email FROM auth.users WHERE id = auth.uid())
)
WITH CHECK (
  -- Only allow updating the id to the current user's ID
  id = auth.uid()
);

-- Admins can manage all librarian records
CREATE POLICY "Admins can manage librarians" 
ON "public"."librarians"
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);
