import random
from datetime import datetime, timedelta

fecha_inicio = datetime(2026, 7, 1)
fecha_fin = datetime(2026, 10, 15)

# Ponderación de productos: (código, descripción, precio unitario, peso de probabilidad)
PRODUCTOS = [
    ('SAL-01', 'Salteña de Carne', 8.0, 0.40),
    ('SAL-02', 'Salteña de Pollo', 8.0, 0.30),
    ('SAL-03', 'Salteña Mixta', 9.0, 0.15),
    ('SAL-04', 'Salteña Picante', 9.0, 0.10),
    ('BEB-02', 'Jugo Mocochinchi', 5.0, 0.03),
    ('BEB-01', 'Gaseosa 500ml', 7.0, 0.02)
]

sql_lines = [
    "-- ============================================================",
    "-- CARGA HISTORICA MASIVA: VENTAS, COMPRAS Y PICOS DE MARKETING",
    "-- ============================================================",
    "SET NAMES utf8mb4;",
    "SET FOREIGN_KEY_CHECKS = 0;",
    "START TRANSACTION;",
    "",
    "-- 0. LIMPIEZA TOTAL DE REGISTROS SIMULADOS PREVIOS",
    "DELETE pf FROM llx_paiement_facture pf JOIN llx_facture f ON pf.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';",
    "DELETE FROM llx_paiement_facture WHERE fk_paiement IN (SELECT rowid FROM llx_paiement WHERE ref LIKE 'PAY26%');",
    "DELETE fd FROM llx_facturedet fd JOIN llx_facture f ON fd.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';",
    "DELETE FROM llx_paiement WHERE ref LIKE 'PAY26%';",
    "DELETE FROM llx_facture WHERE ref LIKE 'FA26%';",
    "",
    "DELETE pff FROM llx_paiementfourn_facturefourn pff JOIN llx_facture_fourn ff ON pff.fk_facturefourn = ff.rowid WHERE ff.ref LIKE 'SI26%' OR ff.ref_supplier LIKE 'FAC-PROV-%';",
    "DELETE FROM llx_paiementfourn_facturefourn WHERE fk_paiementfourn IN (SELECT rowid FROM llx_paiementfourn WHERE ref LIKE 'PMR26%');",
    "DELETE ffd FROM llx_facture_fourn_det ffd JOIN llx_facture_fourn ff ON ffd.fk_facture_fourn = ff.rowid WHERE ff.ref LIKE 'SI26%' OR ff.ref_supplier LIKE 'FAC-PROV-%';",
    "DELETE FROM llx_paiementfourn WHERE ref LIKE 'PMR26%';",
    "DELETE FROM llx_facture_fourn WHERE ref LIKE 'SI26%' OR ref_supplier LIKE 'FAC-PROV-%';",
    "",
    "-- 1. RESOLUCION DE IDENTIFICADORES MAESTROS",
    "SET @c_default = COALESCE((SELECT rowid FROM llx_societe WHERE client IN (1, 2, 3) LIMIT 1), 1);",
    "SET @c_mostrador = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Mostrador%' OR nom LIKE '%General%' LIMIT 1), @c_default);",
    "SET @c_san_agustin = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Agust%' LIMIT 1), @c_default);",
    "SET @c_juan = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Juan%' LIMIT 1), @c_default);",
    "SET @c_maria = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Maria%' OR nom LIKE '%López%' LIMIT 1), @c_default);",
    "",
    "SET @p_default = COALESCE((SELECT rowid FROM llx_societe WHERE fournisseur = 1 LIMIT 1), 1);",
    "SET @p_carne = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Carne%' OR nom LIKE '%Sofía%' LIMIT 1), @p_default);",
    "",
    "SET @prod_default = COALESCE((SELECT rowid FROM llx_product LIMIT 1), 1);",
    "SET @p_sal01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-01' LIMIT 1), @prod_default);",
    "SET @p_sal02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-02' LIMIT 1), @prod_default);",
    "SET @p_sal03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-03' LIMIT 1), @prod_default);",
    "SET @p_sal04 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-04' LIMIT 1), @prod_default);",
    "SET @p_beb01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-01' LIMIT 1), @prod_default);",
    "SET @p_beb02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-02' LIMIT 1), @prod_default);",
    "",
    "SET @p_ins01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-01' LIMIT 1), @prod_default);",
    "SET @p_ins02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-02' LIMIT 1), @prod_default);",
    "SET @p_ins03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-03' LIMIT 1), @prod_default);",
    "",
    "SET @pay_code = COALESCE((SELECT id FROM llx_c_paiement WHERE code IN ('LIQ', 'ESP') LIMIT 1), 4);",
    ""
]

prod_map = {
    'SAL-01': '@p_sal01', 'SAL-02': '@p_sal02', 'SAL-03': '@p_sal03',
    'SAL-04': '@p_sal04', 'BEB-01': '@p_beb01', 'BEB-02': '@p_beb02'
}

cur_date = fecha_inicio
factura_idx = 100
compra_idx = 100

while cur_date <= fecha_fin:
    d_str = cur_date.strftime('%Y-%m-%d')
    yy_mm = cur_date.strftime('%y%m')
    weekday = cur_date.weekday()

    # 1. Compras periódicas de insumos cada 5 días
    if cur_date.day in (1, 6, 11, 16, 21, 26):
        compra_idx += 1
        ref_c = f"SI{yy_mm}-{compra_idx:04d}"
        ref_prov = f"FAC-PROV-{compra_idx:03d}"
        ref_pay = f"PMR{yy_mm}-{compra_idx:04d}"
        total_c = 950.0

        sql_lines.append(f"-- Compra de insumos: {ref_c} ({d_str})")
        sql_lines.append(f"INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('{ref_c}', '{ref_prov}', 1, 0, @p_carne, '{d_str} 08:00:00', '{d_str}', '{d_str}', 1, {total_c}, 0, {total_c}, 2, 1, 1, 1, @pay_code);")
        sql_lines.append("SET @last_fourn_id = LAST_INSERT_ID();")
        sql_lines.append(f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);")
        sql_lines.append(f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);")
        sql_lines.append(f"INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);")
        sql_lines.append(f"INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('{ref_pay}', 1, '{d_str}', {total_c}, @pay_code, 1, 0);")
        sql_lines.append(f"INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, {total_c});")

    # 2. Distribución de volumen de ventas según día
    if weekday in (0, 1):       # Lunes y Martes (Valle bajo)
        num_ventas = random.randint(2, 4)
    elif weekday in (2, 3):     # Miércoles y Jueves (Medio)
        num_ventas = random.randint(4, 7)
    elif weekday == 4:          # Viernes (Pico corporativo)
        num_ventas = random.randint(7, 10)
    else:                       # Sábado y Domingo (Pico masivo mostrador)
        num_ventas = random.randint(12, 18)

    # 3. Pedidos B2B Colegio San Agustín (Viernes quincenales)
    if weekday == 4 and (cur_date.day in range(10, 16) or cur_date.day in range(25, 31)):
        factura_idx += 1
        ref_v = f"FA{yy_mm}-{factura_idx:04d}"
        ref_p = f"PAY{yy_mm}-{factura_idx:04d}"
        dt_str = f"{d_str} 09:15:00"

        cant_carne = random.randint(50, 70)
        cant_pollo = random.randint(30, 45)
        total_b2b = (cant_carne * 8.0) + (cant_pollo * 8.0)

        sql_lines.append(f"\n-- Venta B2B Institucional: {ref_v} ({d_str})")
        sql_lines.append(f"INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('{ref_v}', 1, 0, @c_san_agustin, '{dt_str}', '{d_str}', '{d_str}', 1, {total_b2b}, 0, {total_b2b}, 2, 1, 1, 1, @pay_code);")
        sql_lines.append("SET @last_fac_id = LAST_INSERT_ID();")
        sql_lines.append(f"INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, {cant_carne}, 0, {cant_carne * 8.0}, 0, {cant_carne * 8.0}, 0);")
        sql_lines.append(f"INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, {cant_pollo}, 0, {cant_pollo * 8.0}, 0, {cant_pollo * 8.0}, 0);")
        sql_lines.append(f"INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('{ref_p}', 1, '{d_str}', {total_b2b}, @pay_code, 1, 0);")
        sql_lines.append(f"INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, {total_b2b});")

    # 4. Ventas diarias de mostrador
    for _ in range(num_ventas):
        factura_idx += 1
        ref_v = f"FA{yy_mm}-{factura_idx:04d}"
        ref_p = f"PAY{yy_mm}-{factura_idx:04d}"

        # Concentración horaria matutina (8:30 a 11:50)
        h = random.choices([8, 9, 10, 11], weights=[0.15, 0.45, 0.30, 0.10])[0]
        m = random.randint(0, 59)
        dt_str = f"{d_str} {h:02d}:{m:02d}:00"

        soc = random.choices(['@c_mostrador', '@c_juan', '@c_maria'], weights=[0.70, 0.15, 0.15])[0]

        num_items = random.choices([1, 2, 3], weights=[0.55, 0.35, 0.10])[0]
        sampled_prods = random.choices(PRODUCTOS, weights=[p[3] for p in PRODUCTOS], k=num_items)

        lineas = []
        total_factura = 0.0

        for cod, desc, pu, _ in set(sampled_prods):
            qty = random.randint(2, 6) if weekday in (5, 6) else random.randint(1, 3)
            subtotal = qty * pu
            total_factura += subtotal
            lineas.append((cod, desc, pu, qty, subtotal))

        sql_lines.append(f"\n-- Venta {ref_v} ({dt_str})")
        sql_lines.append(f"INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('{ref_v}', 1, 0, {soc}, '{dt_str}', '{d_str}', '{d_str}', 1, {total_factura}, 0, {total_factura}, 2, 1, 1, 1, @pay_code);")
        sql_lines.append("SET @last_fac_id = LAST_INSERT_ID();")

        for cod, desc, pu, qty, subtotal in lineas:
            sql_lines.append(f"INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, {prod_map[cod]}, '{desc}', {pu}, {qty}, 0, {subtotal}, 0, {subtotal}, 0);")

        sql_lines.append(f"INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('{ref_p}', 1, '{d_str}', {total_factura}, @pay_code, 1, 0);")
        sql_lines.append(f"INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, {total_factura});")

    cur_date += timedelta(days=1)

sql_lines.append("\nCOMMIT;")
sql_lines.append("SET FOREIGN_KEY_CHECKS = 1;")

with open("carga_historica_3meses.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lines))

print(f"Carga generada exitosamente:")
print(f" - {factura_idx - 100} Ventas procesadas")
print(f" - {compra_idx - 100} Compras a proveedores generadas")