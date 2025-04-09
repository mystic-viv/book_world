ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Allow anyone to create a user during signup
CREATE POLICY "Allow user creation during signup" 
ON "public"."users"
FOR INSERT
WITH CHECK (true);

-- Users can view their own profile
CREATE POLICY "Users can view their own profile" 
ON "public"."users"
FOR SELECT
USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" 
ON "public"."users"
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Librarians and admins can view all profiles
CREATE POLICY "Librarians and admins can view all profiles" 
ON "public"."users"
FOR SELECT
USING (auth.jwt() ->> 'role' IN ('librarian', 'admin'));

-- Librarians can update limited user information
CREATE POLICY "Librarians can update limited user information" 
ON "public"."users"
FOR UPDATE
USING (auth.jwt() ->> 'role' = 'librarian')
WITH CHECK (auth.jwt() ->> 'role' = 'librarian');

-- Admins have full control over user profiles
CREATE POLICY "Admins have full control over user profiles" 
ON "public"."users"
FOR ALL
USING (auth.jwt() ->> 'role' = 'admin');