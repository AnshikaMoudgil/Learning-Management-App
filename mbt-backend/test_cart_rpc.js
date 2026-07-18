const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function test() {
  const dummyUserId = '00000000-0000-0000-0000-000000000000'; // Need a valid UUID
  console.log('Testing RPC get_or_create_cart...');
  const { data, error } = await supabase.rpc('get_or_create_cart', {
    p_user_id: dummyUserId,
  });
  console.log('Result:', { data, error });
}

test();
