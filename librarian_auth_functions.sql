-- Function to link librarian record to auth user
CREATE OR REPLACE FUNCTION public.link_librarian_to_auth_user(auth_user_id UUID, librarian_email TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.librarians
  SET id = auth_user_id
  WHERE email = librarian_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


