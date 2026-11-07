
import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = 'nesma.mekki_db',
    password = 'Nesma3162A!!',
    host = 'sqledu.univ-eiffel.fr',
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn