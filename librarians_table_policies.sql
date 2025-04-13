ALTER TABLE public.librarians ENABLE ROW LEVEL SECURITY;

-- Allow public access to check if an email exists (needed for signup verification)
CREATE POLICY "Allow email verification for signup"
ON "public"."librarians"
FOR SELECT
USING (true);

-- Allow updates to the librarians table when the email matches
CREATE POLICY "Users can update their own librarian record" 
ON public.librarians
FOR UPDATE
USING (auth.email() = email);

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
