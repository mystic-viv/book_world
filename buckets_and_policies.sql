-- Create a bucket for storing book covers
supabase storage create book-covers

-- Create a bucket for storing book PDFs
supabase storage create book-pdfs

-- Create a bucket for storing user profile images
supabase storage create user-profiles

-- For the book-pdfs bucket
-- Allow public read access to book covers
CREATE POLICY "Public Read Access for book-covers"
ON storage.objects
FOR SELECT
USING (
  bucket_id = 'book-covers'
);

-- Allow only librarians to upload book covers
CREATE POLICY "Librarian Upload Access for book-covers"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'book-covers' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

-- Allow librarians to update/delete book covers
CREATE POLICY "Librarian Update/Delete Access for book-covers"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'book-covers' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

CREATE POLICY "Librarian Delete Access for book-covers"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'book-covers' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

-- For the book-pdfs bucket
-- Allow only authenticated users to read PDFs
CREATE POLICY "Authenticated Read Access for book-pdfs"
ON storage.objects
FOR SELECT
USING (
  bucket_id = 'book-pdfs' AND
  auth.role() = 'authenticated'
);

-- Allow only librarians to upload PDFs
CREATE POLICY "Librarian Upload Access for book-pdfs"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'book-pdfs' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

-- Allow librarians to update/delete PDFs
CREATE POLICY "Librarian Update/Delete Access for book-pdfs"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'book-pdfs' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

CREATE POLICY "Librarian Delete Access for book-pdfs"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'book-pdfs' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM librarians
    WHERE librarians.id = auth.uid() AND librarians.is_active = true
  )
);

-- For the user-profiles bucket
-- Allow only users to read profile images
CREATE POLICY "Allow public access to profile pictures" 
ON storage.objects 
FOR SELECT 
TO public 
USING (
  bucket_id = 'user-profiles' AND 
  (storage.foldername(name))[1] = 'profile_pictures'
);

-- Allow only authenticated users to upload profile images
CREATE POLICY "Allow authenticated users to upload their own profile pictures" 
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (
  bucket_id = 'user-profiles' AND 
  (storage.foldername(name))[1] = 'profile_pictures' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

--Allow users to update thier own profile pictures
CREATE POLICY "Allow users to update their own profile pictures" 
ON storage.objects 
FOR UPDATE 
TO authenticated 
USING (
  bucket_id = 'user-profiles' AND 
  (storage.foldername(name))[1] = 'profile_pictures' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Allow users to delete their own profile pictures
CREATE POLICY "Allow users to delete their own profile pictures" 
ON storage.objects 
FOR DELETE 
TO authenticated 
USING (
  bucket_id = 'user-profiles' AND 
  (storage.foldername(name))[1] = 'profile_pictures' AND
  (storage.foldername(name))[2] = auth.uid()::text
);
