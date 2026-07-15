-- ============================================
-- 岁里时光 - 数据库 SQL 脚本
-- 适用于 PostgreSQL (Supabase) 和 SQLite
-- ============================================

-- ========== PostgreSQL / Supabase 版本 ==========

-- 分类表（支持多级树形结构）
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL DEFAULT auth.uid(),
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(50),
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  type VARCHAR(10) NOT NULL CHECK (type IN ('income', 'expense')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type);

-- 收支记录表（敏感数据加密存储）
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL DEFAULT auth.uid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  type VARCHAR(10) NOT NULL CHECK (type IN ('income', 'expense')),
  encrypted_data TEXT NOT NULL,  -- AES-256加密: {"amount":"100.00","note":"午餐"}
  transaction_date VARCHAR(10) NOT NULL,  -- YYYY-MM-DD，明文用于查询索引
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date);

-- 预算表（金额加密存储）
CREATE TABLE IF NOT EXISTS budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL DEFAULT auth.uid(),
  month VARCHAR(7) NOT NULL,  -- YYYY-MM
  encrypted_amount TEXT NOT NULL,  -- AES-256加密: {"amount":"5000.00"}
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(user_id, month)
);

CREATE INDEX IF NOT EXISTS idx_budgets_user_id ON budgets(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month);

-- 用户个人资料表（敏感信息加密存储）
CREATE TABLE IF NOT EXISTS user_profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL DEFAULT auth.uid() UNIQUE,
  encrypted_profile TEXT NOT NULL,  -- AES-256加密: {"nickname":"...","phone":"...","birthday":"...","bio":"..."}
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_user_profile_user_id ON user_profile(user_id);

-- ========== RLS 行级安全策略 ==========
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profile ENABLE ROW LEVEL SECURITY;

-- Categories RLS
CREATE POLICY "categories_select" ON categories FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "categories_insert" ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "categories_update" ON categories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "categories_delete" ON categories FOR DELETE USING (auth.uid() = user_id);

-- Transactions RLS
CREATE POLICY "transactions_select" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "transactions_insert" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "transactions_update" ON transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "transactions_delete" ON transactions FOR DELETE USING (auth.uid() = user_id);

-- Budgets RLS
CREATE POLICY "budgets_select" ON budgets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "budgets_insert" ON budgets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "budgets_update" ON budgets FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "budgets_delete" ON budgets FOR DELETE USING (auth.uid() = user_id);

-- User Profile RLS
CREATE POLICY "user_profile_select" ON user_profile FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "user_profile_insert" ON user_profile FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "user_profile_update" ON user_profile FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "user_profile_delete" ON user_profile FOR DELETE USING (auth.uid() = user_id);

-- ========== 默认分类数据 ==========
INSERT INTO categories (name, icon, type, sort_order) VALUES
  ('餐饮', '🍜', 'expense', 1),
  ('交通', '🚌', 'expense', 2),
  ('购物', '🛒', 'expense', 3),
  ('娱乐', '🎮', 'expense', 4),
  ('居住', '🏠', 'expense', 5),
  ('医疗', '💊', 'expense', 6),
  ('教育', '📚', 'expense', 7),
  ('其他支出', '📦', 'expense', 8),
  ('工资', '💰', 'income', 1),
  ('奖金', '🎁', 'income', 2),
  ('投资', '📈', 'income', 3),
  ('兼职', '💼', 'income', 4),
  ('其他收入', '💵', 'income', 5);
