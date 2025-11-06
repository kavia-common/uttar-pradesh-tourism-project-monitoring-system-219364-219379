# upstdc_database port configuration and readiness

This container defaults to PostgreSQL on port 5000 to match existing scripts and connection files.

How to change the port (e.g., to 3020):
- Set environment variables before starting:
  - PGHOST=127.0.0.1 (or the service name inside Docker)
  - PGPORT=3020
- The startup.sh script respects PGHOST/PGPORT and will:
  - start postgres on the specified port
  - generate db_connection.txt and db_visualizer/postgres.env using that port
  - print a pg_isready readiness command with the correct host:port

Readiness checks:
- Use the helper script:
  PGHOST=127.0.0.1 PGPORT=5000 ./wait_for_pg.sh 30
- Or call directly:
  sudo -u postgres /usr/lib/postgresql/$(ls /usr/lib/postgresql/ | head -1)/bin/pg_isready -h $PGHOST -p $PGPORT

Files that reflect the active port:
- db_connection.txt
- db_visualizer/postgres.env

Standard port decision:
- Default: 5000 (present across existing scripts).
- To align environments expecting 3020, export PGPORT=3020 prior to starting.
