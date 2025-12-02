PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- -----------------------------
-- Table: permissions
-- -----------------------------
CREATE TABLE permissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    permission TEXT NOT NULL, -- Example: Create users, Sales, Add products.
    description TEXT
);

-- -----------------------------
-- Table: user_types
-- -----------------------------
CREATE TABLE user_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_type TEXT NOT NULL UNIQUE, -- Example: Supervisor, cashier.
    description TEXT
);

-- -----------------------------
-- Table: users
-- -----------------------------
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL, -- Encrypted
    id_user_type INTEGER NOT NULL,
    estatus INTEGER NOT NULL DEFAULT 1, -- boolean as 0/1
    FOREIGN KEY (id_user_type) REFERENCES user_types(id)
);

CREATE INDEX idx_users_id_user_type ON users(id_user_type);
CREATE INDEX idx_users_estatus ON users(estatus);

-- -----------------------------
-- Table: user_types_permissions
-- (default permissions for a user type)
-- -----------------------------
CREATE TABLE user_types_permissions (
    id_user_type INTEGER NOT NULL,
    id_permission INTEGER NOT NULL,
    PRIMARY KEY (id_user_type, id_permission),
    FOREIGN KEY (id_user_type) REFERENCES user_types(id),
    FOREIGN KEY (id_permission) REFERENCES permissions(id)
);

CREATE INDEX idx_utp_perm_utype ON user_types_permissions(id_permission, id_user_type);
CREATE INDEX idx_utp_id_user_type ON user_types_permissions(id_user_type);
CREATE INDEX idx_utp_id_permission ON user_types_permissions(id_permission);

-- -----------------------------
-- Table: users_permissions
-- (extra permissions per user)
-- -----------------------------
CREATE TABLE users_permissions (
    id_user INTEGER NOT NULL,
    id_permission INTEGER NOT NULL,
    PRIMARY KEY (id_user, id_permission),
    FOREIGN KEY (id_user) REFERENCES users(id),
    FOREIGN KEY (id_permission) REFERENCES permissions(id)
);

CREATE INDEX idx_up_perm_user ON users_permissions(id_permission, id_user);
CREATE INDEX idx_up_id_user ON users_permissions(id_user);
CREATE INDEX idx_up_id_permission ON users_permissions(id_permission);

-- -----------------------------
-- Table: categories
-- -----------------------------
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL UNIQUE, -- Example: Drinks, Candys, Personal Hygiene
    description TEXT,
    estatus INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_categories_estatus ON categories(estatus);

-- -----------------------------
-- Table: unit_measure
-- -----------------------------
CREATE TABLE unit_measure (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_measure TEXT NOT NULL UNIQUE, -- Example: Liter, Kilograms, Libras
    symbol TEXT NOT NULL UNIQUE, -- Example: Lt, Kg, Lbs.
    estatus INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_unit_measure_estatus ON unit_measure(estatus);

-- -----------------------------
-- Table: tax_types
-- -----------------------------
CREATE TABLE tax_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tax_type TEXT NOT NULL UNIQUE, -- Example: IVA, Exempt IVA, 0%
    rate NUMERIC NOT NULL -- Example: 16.00, 0.00
);

-- -----------------------------
-- Table: products
-- -----------------------------
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product TEXT NOT NULL UNIQUE,
    barcode TEXT NOT NULL UNIQUE, -- char(13) represented as TEXT
    price NUMERIC NOT NULL, -- decimal(10,2)
    cost NUMERIC NOT NULL,  -- decimal(10,2)
    existence INTEGER NOT NULL,
    id_category INTEGER NOT NULL,
    id_unit_measure INTEGER NOT NULL,
    id_tax_type INTEGER NOT NULL,
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_category) REFERENCES categories(id),
    FOREIGN KEY (id_unit_measure) REFERENCES unit_measure(id),
    FOREIGN KEY (id_tax_type) REFERENCES tax_types(id)
);

CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_id_category ON products(id_category);
CREATE INDEX idx_products_id_unit_measure ON products(id_unit_measure);
CREATE INDEX idx_products_id_tax_type ON products(id_tax_type);
CREATE INDEX idx_products_estatus ON products(estatus);

-- -----------------------------
-- Table: entries_types
-- -----------------------------
CREATE TABLE entries_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entry_type TEXT NOT NULL UNIQUE, -- Example: Purchase, bonus.
    description TEXT,
    estatus INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_entries_types_estatus ON entries_types(estatus);

-- -----------------------------
-- Table: entries
-- -----------------------------
CREATE TABLE entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_entry_type INTEGER NOT NULL,
    date_entry TEXT DEFAULT (datetime('now')), -- stored as "YYYY-MM-DD HH:MM:SS" UTC
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_entry_type) REFERENCES entries_types(id)
);

CREATE INDEX idx_entries_id_entry_type ON entries(id_entry_type);
CREATE INDEX idx_entries_date_entry ON entries(date_entry);
CREATE INDEX idx_entries_estatus ON entries(estatus);

-- -----------------------------
-- Table: entries_details
-- -----------------------------
CREATE TABLE entries_details (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_entry INTEGER NOT NULL,
    id_product INTEGER NOT NULL,
    quantity NUMERIC NOT NULL, -- decimal(10,2)
    cost NUMERIC NOT NULL,     -- decimal(10,2)
    FOREIGN KEY (id_entry) REFERENCES entries(id),
    FOREIGN KEY (id_product) REFERENCES products(id)
);

CREATE INDEX idx_entries_details_id_entry ON entries_details(id_entry);
CREATE INDEX idx_entries_details_id_product ON entries_details(id_product);

-- -----------------------------
-- Table: outputs_types
-- -----------------------------
CREATE TABLE outputs_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    output_type TEXT NOT NULL UNIQUE, -- Example: Losses, damaged, fall
    description TEXT,
    estatus INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_outputs_types_estatus ON outputs_types(estatus);

-- -----------------------------
-- Table: outputs
-- -----------------------------
CREATE TABLE outputs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_output_type INTEGER NOT NULL,
    date_output TEXT DEFAULT (datetime('now')),
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_output_type) REFERENCES outputs_types(id)
);

CREATE INDEX idx_outputs_id_output_type ON outputs(id_output_type);
CREATE INDEX idx_outputs_date_output ON outputs(date_output);
CREATE INDEX idx_outputs_estatus ON outputs(estatus);

-- -----------------------------
-- Table: outputs_details
-- -----------------------------
CREATE TABLE outputs_details (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_output INTEGER NOT NULL,
    id_product INTEGER NOT NULL,
    quantity NUMERIC NOT NULL, -- decimal(10,2)
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_output) REFERENCES outputs(id),
    FOREIGN KEY (id_product) REFERENCES products(id)
);

CREATE INDEX idx_outputs_details_id_output ON outputs_details(id_output);
CREATE INDEX idx_outputs_details_id_product ON outputs_details(id_product);

-- -----------------------------
-- Table: cashier_shifts
-- -----------------------------
CREATE TABLE cashier_shifts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_user INTEGER NOT NULL,
    date_start_shift TEXT NOT NULL DEFAULT (datetime('now')),
    date_end_shift TEXT,
    total_cash_sale NUMERIC,
    total_card_sale NUMERIC,
    total_sale NUMERIC,
    total_cash_receive NUMERIC,
    total_card_receive NUMERIC,
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_user) REFERENCES users(id)
);

CREATE INDEX idx_cashier_shifts_id_user ON cashier_shifts(id_user);
CREATE INDEX idx_cashier_shifts_date_start_shift ON cashier_shifts(date_start_shift);
CREATE INDEX idx_cashier_shifts_date_end_shift ON cashier_shifts(date_end_shift);
CREATE INDEX idx_cashier_shifts_estatus ON cashier_shifts(estatus);

-- -----------------------------
-- Table: sales
-- -----------------------------
CREATE TABLE sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_sale TEXT NOT NULL DEFAULT (datetime('now')),
    subtotal NUMERIC NOT NULL,
    iva NUMERIC,
    total NUMERIC NOT NULL,
    id_user INTEGER NOT NULL,
    id_cashier_shift INTEGER NOT NULL,
    estatus INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (id_user) REFERENCES users(id),
    FOREIGN KEY (id_cashier_shift) REFERENCES cashier_shifts(id)
);

CREATE INDEX idx_sales_id_user ON sales(id_user);
CREATE INDEX idx_sales_id_cashier_shift ON sales(id_cashier_shift);
CREATE INDEX idx_sales_estatus ON sales(estatus);

-- -----------------------------
-- Table: sales_details
-- -----------------------------
CREATE TABLE sales_details (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_sale INTEGER NOT NULL,
    id_product INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    cost NUMERIC NOT NULL,
    price NUMERIC NOT NULL,
    iva NUMERIC,
    FOREIGN KEY (id_sale) REFERENCES sales(id),
    FOREIGN KEY (id_product) REFERENCES products(id)
);

CREATE INDEX idx_sales_details_id_sale ON sales_details(id_sale);
CREATE INDEX idx_sales_details_id_product ON sales_details(id_product);

-- -----------------------------
-- Table: canceled_sales
-- -----------------------------
CREATE TABLE canceled_sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_sale INTEGER NOT NULL,
    id_user_canceled INTEGER NOT NULL,
    date_canceled TEXT NOT NULL DEFAULT (datetime('now')),
    reason TEXT NOT NULL,
    FOREIGN KEY (id_sale) REFERENCES sales(id),
    FOREIGN KEY (id_user_canceled) REFERENCES users(id)
);

CREATE INDEX idx_canceled_sales_id_sale ON canceled_sales(id_sale);
CREATE INDEX idx_canceled_sales_date_canceled ON canceled_sales(date_canceled);

-- -----------------------------
-- Table: payment_methods
-- -----------------------------
CREATE TABLE payment_methods (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_method TEXT NOT NULL UNIQUE, -- Example: Cash, credit card, debit card.
    description TEXT,
    estatus INTEGER NOT NULL DEFAULT 1
);

-- -----------------------------
-- Table: payments_sales
-- -----------------------------
CREATE TABLE payments_sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_sale INTEGER NOT NULL,
    id_payment_method INTEGER NOT NULL,
    total_pay NUMERIC NOT NULL,
    FOREIGN KEY (id_sale) REFERENCES sales(id),
    FOREIGN KEY (id_payment_method) REFERENCES payment_methods(id)
);

CREATE INDEX idx_payments_sales_id_sale ON payments_sales(id_sale);
CREATE INDEX idx_payments_sales_id_payment_method ON payments_sales(id_payment_method);

COMMIT;
