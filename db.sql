
-- Users profile table
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  bio text,
  location text,
  schedule text,
  avatar_emoji text default '🧑',
  created_at timestamp with time zone default now()
);

-- Habit categories
create table habits (
  id serial primary key,
  icon text, name text
);
insert into habits (icon, name) values
  ('🏋️','Fitness'),('📚','Reading'),('🧘','Meditation'),('🥗','Nutrition'),
  ('💧','Hydration'),('🚶','Walking'),('✍️','Journaling'),('💻','Coding'),
  ('🎨','Art & Create'),('🌱','Sustainability'),('😴','Sleep'),('🧠','Learning');

-- User ↔ habit link
create table user_habits (
  user_id uuid references profiles(id) on delete cascade,
  habit_id int references habits(id),
  primary key (user_id, habit_id)
);

-- Connections between users
create table connections (
  id serial primary key,
  from_user uuid references profiles(id),
  to_user uuid references profiles(id),
  status text default 'pending',
  created_at timestamp with time zone default now()
);

-- Daily check-ins
create table checkins (
  id serial primary key,
  user_id uuid references profiles(id),
  checked_date date default current_date,
  unique(user_id, checked_date)
);

-- Enable Row Level Security
alter table profiles enable row level security;
alter table user_habits enable row level security;
alter table connections enable row level security;
alter table checkins enable row level security;

-- Policies: users can read all profiles (for matching), write own
create policy "Public profiles" on profiles for select using (true);
create policy "Own profile" on profiles for all using (auth.uid() = id);
create policy "Public user_habits" on user_habits for select using (true);
create policy "Own user_habits" on user_habits for all using (auth.uid() = user_id);
create policy "Public connections" on connections for select using (true);
create policy "Own connections" on connections for all using (auth.uid() = from_user);
create policy "Own checkins" on checkins for all using (auth.uid() = user_id);
create policy "Public checkins read" on checkins for select using (true);
