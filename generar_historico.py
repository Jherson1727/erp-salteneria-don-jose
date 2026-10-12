import datetime
import random

OUTPUT_FILE = "carga_historica_3meses.sql"

# Rango de 3 meses operativos (12 Julio 2026 a 10 Octubre 2026)
start_date = datetime.date(2026, 7, 12)
end_date = datetime.date(2026, 10, 10)
total_days = (end_date - start_date).days

sql_lines = [
    "-- ============================================================",
    "-- CARGA MASIVA HISTÓRICA (3 MESES / TPS DOLIBARR)",
    "-- ============================================================",
    "SET FOREIGN_KEY_CHECKS = 0;",
    "START TRANSACTION;\n",
    "-- 0. Limpieza segura",
    "DELETE FROM llx_paiement_facture WHERE fk_paiement IN (SELECT rowid FROM llx_paiement WHERE ref LIKE 'PAY26%');",
    "DELETE pf FROM llx_paiement_facture pf JOIN llx_facture f ON pf.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';",
    "DELETE fd FROM llx_facturedet fd JOIN llx_facture f ON fd.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';",
    "DELETE FROM llx_paiement WHERE ref LIKE 'PAY26%';",
    "DELETE FROM llx_facture WHERE ref LIKE 'FA26%';",
    "DELETE FROM llx_paiementfourn_facturefourn WHERE fk_paiementfourn IN (SELECT rowid FROM llx_paiementfourn WHERE ref LIKE 'PMR26%');",
    "DELETE pff FROM llx_paiementfourn_facturefourn pff JOIN llx_facture_fourn ff ON pff.fk_facturefourn = ff.rowid WHERE ff.ref_supplier LIKE 'FAC-PROV-%';",
    "DELETE ffd FROM llx_facture_fourn_det ffd JOIN llx_facture_fourn ff ON ffd.fk_facture_fourn = ff.rowid WHERE ff.ref_supplier LIKE 'FAC-PROV-%';",
    "DELETE FROM llx_paiementfourn WHERE ref LIKE 'PMR26%';",
    "DELETE FROM llx_facture_fourn WHERE ref_supplier LIKE 'FAC-PROV-%';\n",
    "-- 1. Resolución de IDs de Terceros",
    "SET @c_default = COALESCE((SELECT rowid FROM llx_societe WHERE client IN (1, 2, 3) LIMIT 1), 1);",
    "SET @c_mostrador = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Mostrador%' OR nom LIKE '%General%' LIMIT 1), @c_default);",
    "SET @c_san_agustin = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Agust%' LIMIT 1), @c_default);",
    "SET @c_juan = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Juan Carlos%' LIMIT 1), @c_default);",
    "SET @c_maria = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Maria%' OR nom LIKE '%López%' LIMIT 1), @c_default);",
    "",
    "-- Proveedores",
    "SET @p_default = COALESCE((SELECT rowid FROM llx_societe WHERE fournisseur = 1 LIMIT 1), 1);",
    "SET @p_harina = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Harina%' OR nom LIKE '%Molino%' LIMIT 1), @p_default);",
    "SET @p_carne = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Carne%' OR nom LIKE '%Sofía%' LIMIT 1), @p_default);",
    "",
    "-- Productos terminados",
    "SET @prod_default = COALESCE((SELECT rowid FROM llx_product LIMIT 1), 1);",
    "SET @p_sal01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-01' LIMIT 1), @prod_default);",
    "SET @p_sal02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-02' LIMIT 1), @prod_default);",
    "SET @p_sal03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-03' LIMIT 1), @prod_default);",
    "SET @p_sal04 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-04' LIMIT 1), @prod_default);",
    "SET @p_beb01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-01' LIMIT 1), @prod_default);",
    "SET @p_beb02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-02' LIMIT 1), @prod_default);",
    "",
    "-- Insumos",
    "SET @p_ins01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-01' LIMIT 1), @prod_default);",
    "SET @p_ins02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-02' LIMIT 1), @prod_default);",
    "SET @p_ins03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-03' LIMIT 1), @prod_default);",
    "",
    "-- Modalidad de pago Efectivo",
    "SET @pay_code = COALESCE((SELECT id FROM llx_c_paiement WHERE code IN ('LIQ', 'ESP') LIMIT 1), 4);\n"
]

factura_idx = 100
pago_idx = 100
factura_fourn_idx = 100
pago_fourn_idx = 100

PRODUCTOS_VENTA = [
    ("@p_sal01", "Salteña de Carne", 8.0),
    ("@p_sal02", "Salteña de Pollo", 8.0),
    ("@p_sal03", "Salteña Mixta", 9.0),
    ("@p_sal04", "Salteña Picante", 9.0),
    ("@p_beb01", "Gaseosa 500ml", 7.0),
    ("@p_beb02", "Jugo Mocochinchi", 5.0)
]

# 1. GENERACIÓN DE VENTAS HISTÓRICAS
fechas_ventas = []
for day in range(total_days):
    d = start_date + datetime.timedelta(days=day)
    fechas_ventas.append((d, "mostrador"))
    if random.random() > 0.60:
        fechas_ventas.append((d, "mostrador"))
    if day % 6 == 0 and day > 0:
        fechas_ventas.append((d, "institucional"))

for fecha, tipo in fechas_ventas:
    ref_fac = f"FA{fecha.strftime('%y%m')}-{factura_idx:04d}"
    ref_pago = f"PAY{fecha.strftime('%y%m')}-{pago_idx:04d}"
    
    if tipo == "mostrador":
        fk_soc = random.choice(["@c_mostrador", "@c_mostrador", "@c_juan", "@c_maria"])
        num_items = random.randint(1, 3)
        items = random.sample(PRODUCTOS_VENTA, num_items)
        lineas = []
        tot_ht = 0.0
        for p_var, desc, pu in items:
            qty = random.randint(2, 6) if "sal" in p_var else random.randint(1, 3)
            tot_linea = round(qty * pu, 2)
            tot_ht += tot_linea
            lineas.append((p_var, desc, qty, pu, tot_linea))
    else:
        fk_soc = "@c_san_agustin"
        qty_sal = random.randint(50, 120)
        p_var, desc, pu = random.choice(PRODUCTOS_VENTA[:2])
        tot_linea = round(qty_sal * pu, 2)
        tot_ht = tot_linea
        lineas = [(p_var, desc, qty_sal, pu, tot_linea)]

    tot_ttc = tot_ht
    fecha_str = fecha.strftime('%Y-%m-%d')

    sql_lines.append(f"-- Venta: {ref_fac} ({fecha_str})")
    sql_lines.append(
        f"INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) "
        f"VALUES ('{ref_fac}', 1, 0, {fk_soc}, '{fecha_str} 10:30:00', '{fecha_str}', '{fecha_str}', 1, {tot_ht}, 0, {tot_ttc}, 2, 1, 1, 1, @pay_code);"
    )
    sql_lines.append("SET @last_fac_id = LAST_INSERT_ID();")

    for p_var, desc, qty, pu, tot in lineas:
        sql_lines.append(
            f"INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) "
            f"VALUES (@last_fac_id, {p_var}, '{desc}', {pu}, {qty}, 0, {tot}, 0, {tot}, 0);"
        )

    # Añadido: fk_bank = 0
    sql_lines.append(
        f"INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) "
        f"VALUES ('{ref_pago}', 1, '{fecha_str}', {tot_ttc}, @pay_code, 1, 0);"
    )
    sql_lines.append("SET @last_pay_id = LAST_INSERT_ID();")
    sql_lines.append(
        f"INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, {tot_ttc});\n"
    )

    factura_idx += 1
    pago_idx += 1

# 2. GENERACIÓN DE COMPRAS A PROVEEDORES
fecha_compra = start_date
while fecha_compra <= end_date:
    ref_fourn = f"SI{fecha_compra.strftime('%y%m')}-{factura_fourn_idx:04d}"
    ref_prov = f"FAC-PROV-{factura_fourn_idx:03d}"
    ref_pago_fourn = f"PMR{fecha_compra.strftime('%y%m')}-{pago_fourn_idx:04d}"
    fecha_str = fecha_compra.strftime('%Y-%m-%d')
    costo_compra = 950.00

    sql_lines.append(f"-- Compra: {ref_fourn} ({fecha_str})")
    sql_lines.append(
        f"INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) "
        f"VALUES ('{ref_fourn}', '{ref_prov}', 1, 0, @p_carne, '{fecha_str} 08:00:00', '{fecha_str}', '{fecha_str}', 1, {costo_compra}, 0, {costo_compra}, 2, 1, 1, 1, @pay_code);"
    )
    sql_lines.append("SET @last_fourn_id = LAST_INSERT_ID();")
    sql_lines.append(
        f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) "
        f"VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);"
    )
    sql_lines.append(
        f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) "
        f"VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);"
    )
    sql_lines.append(
        f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) "
        f"VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);"
    )

    # Añadido: fk_bank = 0
    sql_lines.append(
        f"INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) "
        f"VALUES ('{ref_pago_fourn}', 1, '{fecha_str}', {costo_compra}, @pay_code, 1, 0);"
    )
    sql_lines.append("SET @last_payfourn_id = LAST_INSERT_ID();")
    sql_lines.append(
        f"INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) "
        f"VALUES (@last_payfourn_id, @last_fourn_id, {costo_compra});\n"
    )

    fecha_compra += datetime.timedelta(days=5)
    factura_fourn_idx += 1
    pago_fourn_idx += 1

sql_lines.append("COMMIT;")
sql_lines.append("SET FOREIGN_KEY_CHECKS = 1;")

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lines))

print(f"[OK] Archivo SQL corregido generado: {OUTPUT_FILE}")