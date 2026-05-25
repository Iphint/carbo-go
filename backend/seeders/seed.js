import dotenv from "dotenv";
import mysql from "mysql2/promise";
import { readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

dotenv.config();

const __dirname = dirname(fileURLToPath(import.meta.url));
const schemaPath = join(__dirname, "../../database/schema.sql");

const sql = await readFile(schemaPath, "utf8");
const statements = sql
  .split(/;\s*$/m)
  .map((statement) => statement.trim())
  .filter(Boolean);

const pool = await mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  multipleStatements: false
});

async function ensureActivityI18nColumnsIfNeeded() {
  await pool.query(`USE \`${process.env.DB_NAME || "carbon_go"}\``);
  const [tables] = await pool.query("SHOW TABLES LIKE 'activities'");
  if (!tables.length) return;

  const [columns] = await pool.query("SHOW COLUMNS FROM activities");
  const columnNames = new Set(columns.map((column) => column.Field));

  if (!columnNames.has("name_en")) {
    await pool.query("ALTER TABLE activities ADD COLUMN name_en VARCHAR(180) NULL AFTER name");
  }
  if (!columnNames.has("name_id")) {
    await pool.query("ALTER TABLE activities ADD COLUMN name_id VARCHAR(180) NULL AFTER name_en");
  }
  if (!columnNames.has("feedback_en")) {
    await pool.query("ALTER TABLE activities ADD COLUMN feedback_en TEXT NULL AFTER carbon_value");
  }
  if (!columnNames.has("feedback_id")) {
    await pool.query("ALTER TABLE activities ADD COLUMN feedback_id TEXT NULL AFTER feedback_en");
  }

  await pool.query(
    `UPDATE activities
     SET name_en = COALESCE(name_en, name),
         name_id = COALESCE(name_id, name),
         feedback_en = COALESCE(feedback_en, ''),
         feedback_id = COALESCE(feedback_id, '')`
  );
}

await pool.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || "carbon_go"}\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci`);
await ensureActivityI18nColumnsIfNeeded();

for (const statement of statements) {
  await pool.query(statement);
}

await pool.end();
console.log("Database schema and seed data applied.");
