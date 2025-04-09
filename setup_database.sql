-- Creating Users Table
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  custom_id TEXT UNIQUE,
  email TEXT NOT NULL UNIQUE,
  username TEXT UNIQUE,
  name TEXT,
  mobile TEXT UNIQUE,
  date_of_birth DATE,
  local_address TEXT,
  permanent_address TEXT,
  profile_picture_url TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Creating Librarians Table
CREATE TABLE librarians (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  custom_id TEXT UNIQUE,
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  mobile TEXT UNIQUE,
  date_of_birth TIMESTAMP,
  work_address TEXT,
  home_address TEXT,
  library_branch TEXT NOT NULL,
  profile_picture_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  role TEXT NOT NULL DEFAULT 'librarian',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Creating Books Table
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  custom_id TEXT UNIQUE,
  book_name TEXT NOT NULL,
  author_name TEXT NOT NULL,
  description TEXT,
  genres TEXT[],
  physical_copies INTEGER DEFAULT 0,
  available_copies INTEGER DEFAULT 0,
  book_cover_url TEXT,
  book_pdf_url TEXT,
  publication_year INTEGER,
  added_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_ebook BOOLEAN DEFAULT TRUE,
);
