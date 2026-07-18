const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const dbUrl = "postgresql://postgres:TensorikMbtApp10072026@db.iwzcltjnulmwuhomrsuq.supabase.co:5432/postgres";

async function applyMigration() {
  const client = new Client({ connectionString: dbUrl });
  try {
    await client.connect();
    console.log("Connected to database");

    const sqlPath = path.join(__dirname, 'supabase', 'migrations', '20260716150000_create_wishlists_table.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    await client.query(sql);
    console.log("Migration applied successfully!");
  } catch (error) {
    console.error("Migration failed:", error);
  } finally {
    await client.end();
  }
}

applyMigration();
