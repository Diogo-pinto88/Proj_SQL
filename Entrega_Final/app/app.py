#!/usr/bin/python3
# Copyright (c) BDist Development Team
# Distributed under the terms of the Modified BSD License.
import os
from logging.config import dictConfig

from flask import Flask, jsonify, request
from psycopg.rows import namedtuple_row
from psycopg_pool import ConnectionPool
from datetime import datetime

# Use the DATABASE_URL environment variable if it exists, otherwise use the default.
# Use the format postgres://username:password@hostname/database_name to connect to the database.
DATABASE_URL = os.environ.get("DATABASE_URL", "postgres://Saude:Saude@postgres/Saude")

pool = ConnectionPool(
    conninfo=DATABASE_URL,
    kwargs={
        "autocommit": True,  # If True don’t start transactions automatically.
        "row_factory": namedtuple_row,
    },
    min_size=4,
    max_size=10,
    open=True,
    # check=ConnectionPool.check_connection,
    name="postgres_pool",
    timeout=5,
)

dictConfig(
    {
        "version": 1,
        "formatters": {
            "default": {
                "format": "[%(asctime)s] %(levelname)s in %(module)s:%(lineno)s - %(funcName)20s(): %(message)s",
            }
        },
        "handlers": {
            "wsgi": {
                "class": "logging.StreamHandler",
                "stream": "ext://flask.logging.wsgi_errors_stream",
                "formatter": "default",
            }
        },
        "root": {"level": "INFO", "handlers": ["wsgi"]},
    }
)

app = Flask(__name__)
app.config.from_prefixed_env()
log = app.logger
app.config["JSON_AS_ASCII"] = False

@app.route("/", methods=("GET",))
def clinica_index():
    """Mostra todas as clinicas."""

    with pool.connection() as conn:
        with conn.cursor() as cur:
            clinicas = cur.execute(
                """
                SELECT nome, morada
                FROM clinica
                """,
                {},
            ).fetchall()
            log.debug(f"Found {cur.rowcount} rows.")

    return jsonify(clinicas), 200


@app.route("/c/<clinica>", methods=("GET",))
def especialidades_clinicas(clinica):
    """Mostra as especialidades de uma clinica."""

    with pool.connection() as conn:
        with conn.cursor() as cur:
            especialidades = cur.execute(
                """
                SELECT DISTINCT especialidade
                FROM clinica
                JOIN trabalha ON clinica.nome = trabalha.nome
                JOIN medico ON trabalha.nif = medico.nif
                WHERE clinica.nome = %(clinica)s;
                """,
                {"clinica": clinica},
            ).fetchone()
            log.debug(f"Found {cur.rowcount} rows.")

    # At the end of the `connection()` context, the transaction is committed
    # or rolled back, and the connection returned to the pool.
    return jsonify(especialidades), 200

@app.route("/c/<clinica>/<especialidade>", methods=("GET",))
def medicos_especialidade(clinica, especialidade):
    """Lista os médicos da especialidade que trabalham na clinica, os primeiros 3 horarios disponiveis para consulta de cada um deles."""
    now = datetime.now()
    current_date = now.date()
    current_time = now.time()
    with pool.connection() as conn:
        with conn.cursor() as cur:
            medicos = cur.execute(
                """
                SELECT m.nome, h.data, h.hora
                FROM medico m
                JOIN trabalha t ON m.nif = t.nif
                JOIN horarios h ON t.dia_da_semana = EXTRACT (ISODOW FROM h.data)
                LEFT JOIN consulta c ON m.nif = c.nif AND c.data = h.data AND c.hora = h.hora
                WHERE m.especialidade = %(especialidade)s
                AND t.nome = %(clinica)s
                AND (
                    (h.data > %(current_date)s) OR
                    (h.data = %(current_date)s AND h.hora >= %(current_time)s)
                )
                ORDER BY h.data, h.hora
                LIMIT 3;
                """,
                {"clinica": clinica, "especialidade": especialidade, "now_date": current_date, "now_hour": current_time},
            ).fetchall()
            log.debug(f"Found {cur.rowcount} rows.")
        
    return jsonify(medicos), 200

@app.route("/a/<clinica>/registar/", methods=("POST", "PUT"))
def registar_consulta(clinica):
    """ Regista uma consulta na clinica."""
    paciente = request.args.get("paciente")
    medico = request.args.get("medico")
    data = request.args.get("data")
    hora = request.args.get("hora")

    # Verifica se todos os campos foram fornecidos

    if not paciente or not medico or not data or not hora:
        return jsonify({"message": "Falta de dados", "status": "error"}), 400

    # Verifica se a data de marcação é posterior à data atual

    now = datetime.now()
    if data < now.date() or (data == now.date() and hora < now.hour):
        return jsonify({"message": "Hora de marcação inválida.", "status": "error"}), 400

    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                # Verifica se o horário está disponivel.

                """
                SELECT 1
                FROM consulta
                WHERE nif = %(medico)s
                AND data = %(data)s
                AND hora = %(hora)s
                """,
                {"medico": medico, "data": data, "hora": hora},
            )
            if cur.fetchone():
                return jsonify({"message": "Consulta já marcada", "status": "error"}), 400
                
            # Registo da consulta
            cur.execute(
                """
                
                INSERT INTO consulta (ssn, nif, nome, data, hora, codigo_sns)
                VALUES ( %(ssn)s, %(nif)s, %(nome)s, %(data)s, %(hora)s, %(codigo_sns)s)
                """,
                {"ssn": paciente, "nif": medico, "nome": clinica, "data": data, "hora": hora},
            )
            # Sabemos que o codigo_sns deveria também ser preenchido, mas não conseguimos chegar a um consenso sobre o que deveria ser.
            log.debug(f"Consulta marcada para o paciente {paciente} com o médico {medico} na clinica {clinica} na {data} às {hora}.")
        return jsonify({"message": "Consulta marcada com sucesso.", "status": "success"}), 200
    


@app.route("/a/<clinica>/cancelar/", methods=("POST","PUT"))
def cancelar_consulta(clinica):
    """ Cancela uma consulta numa clinica."""
    paciente = request.args.get("paciente")
    medico = request.args.get("medico")
    data = request.args.get("data")
    hora = request.args.get("hora")

    # Verifica se todos os campos foram fornecidos
    if not paciente or not medico or not data or not hora:
        return jsonify({"message": "Falta de dados", "status": "error"}), 400

    # verificar se o horário é posterior ao momento do cancelamento, ou seja, a consulta ainda não se realizou
    now = datetime.now()
    if data < now.date() or (data == now.date() and hora < now.hour):
        return jsonify({"message": "Hora de marcação inválida.", "status": "error"}), 400

    # remove a entrada da respetiva tabela na base de dados
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                DELETE FROM consulta
                WHERE nome = %(clinica)s
                WHERE nif = %(medico)s
                AND ssn = %(paciente)s
                AND data = %(data)s
                AND hora = %(hora)s
                """,
                {"nome": clinica ,"ssn": paciente, "nif": medico, "data": data, "hora": hora},
            )
            log.debug(f"Consulta cancelada para o paciente {paciente} com o médico {medico} na clinica {clinica} na {data_consulta} às {hora_consulta}.")
        return jsonify({"message": "Consulta cancelada com sucesso.", "status": "success"}), 200
    




@app.route("/ping", methods=("GET",))
def ping():
    log.debug("ping!")
    return jsonify({"message": "pong!", "status": "success"})


if __name__ == "__main__":
    app.run()