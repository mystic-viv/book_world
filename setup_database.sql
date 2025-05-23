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
  id UUID REFERENCES auth.users(id),
  custom_id TEXT UNIQUE,
  email TEXT NOT NULL UNIQUE PRIMARY KEY,
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
  total_copies INTEGER DEFAULT 0,
  available_copies INTEGER DEFAULT 0,
  book_cover_url TEXT,
  book_pdf_url TEXT,
  publication_year INTEGER,
  added_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_ebook BOOLEAN DEFAULT TRUE
);

-- Creating Saved Books Table
CREATE TABLE saved_books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  book_id UUID REFERENCES books(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- Creating Reading Progress Table
CREATE TABLE reading_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  book_id UUID REFERENCES books(id) NOT NULL,
  last_read_page INTEGER NOT NULL DEFAULT 0,
  last_read_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- Creating Bookmarks Table
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  book_id UUID REFERENCES books(id) NOT NULL,
  page_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster bookmark lookups
CREATE INDEX idx_bookmarks_user_book ON bookmarks(user_id, book_id);

-- Creating PDF Metadata Table
CREATE TABLE pdf_metadata (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id UUID REFERENCES books(id) UNIQUE NOT NULL,
  total_pages INTEGER,
  file_size_bytes BIGINT,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_searchable BOOLEAN DEFAULT FALSE,
  has_toc BOOLEAN DEFAULT FALSE
);

-- Creating PDF Downloads Table
CREATE TABLE pdf_downloads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  book_id UUID REFERENCES books(id) NOT NULL,
  downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  device_info TEXT
);
