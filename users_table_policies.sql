ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow user creation during signup" 
ON "public"."users"
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Users can view their own profile" 
ON "public"."users"
FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON "public"."users"
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

