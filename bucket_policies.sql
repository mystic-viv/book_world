-- Create a bucket for storing book covers
supabase storage create book-covers

-- Create a bucket for storing book PDFs
supabase storage create book-pdfs

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
