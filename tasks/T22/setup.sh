#!/bin/bash
# Runtime-инициализация задачи T22 "Обработай поток".
set -euo pipefail

TASK_FLAG="${TASK_FLAG:-flag{stream_processing}}"

# Генератор большого потока журнальных строк.  Значения TOKEN=
# повторяются; несколько токенов встречаются ровно один раз, и один
# из них — флаг.
cat > /opt/log-generator <<EOF
#!/bin/bash
# Генератор журнального потока.  Печатает строки в stdout.
for round in 1 2 3; do
    for i in \$(seq 1 200); do
        echo "INFO  worker[\$i] heartbeat ok"
        echo "DEBUG queue depth=\$((i % 7))"
        echo "TOKEN=node-\$(printf '%04d' \"\$i\")"
    done
done

# Токены, встречающиеся ровно один раз.
echo "TOKEN=build-deadbeef"
echo "TOKEN=deploy-cafebabe"

# Флаг.
echo "TOKEN=$TASK_FLAG"
EOF

chmod 0755 /opt/log-generator
chown ctf:ctf /opt/log-generator
