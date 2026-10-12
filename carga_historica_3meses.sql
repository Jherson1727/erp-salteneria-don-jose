-- ============================================================
-- CARGA MASIVA HISTÓRICA (3 MESES / TPS DOLIBARR)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- 0. Limpieza segura
DELETE FROM llx_paiement_facture WHERE fk_paiement IN (SELECT rowid FROM llx_paiement WHERE ref LIKE 'PAY26%');
DELETE pf FROM llx_paiement_facture pf JOIN llx_facture f ON pf.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';
DELETE fd FROM llx_facturedet fd JOIN llx_facture f ON fd.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';
DELETE FROM llx_paiement WHERE ref LIKE 'PAY26%';
DELETE FROM llx_facture WHERE ref LIKE 'FA26%';
DELETE FROM llx_paiementfourn_facturefourn WHERE fk_paiementfourn IN (SELECT rowid FROM llx_paiementfourn WHERE ref LIKE 'PMR26%');
DELETE pff FROM llx_paiementfourn_facturefourn pff JOIN llx_facture_fourn ff ON pff.fk_facturefourn = ff.rowid WHERE ff.ref_supplier LIKE 'FAC-PROV-%';
DELETE ffd FROM llx_facture_fourn_det ffd JOIN llx_facture_fourn ff ON ffd.fk_facture_fourn = ff.rowid WHERE ff.ref_supplier LIKE 'FAC-PROV-%';
DELETE FROM llx_paiementfourn WHERE ref LIKE 'PMR26%';
DELETE FROM llx_facture_fourn WHERE ref_supplier LIKE 'FAC-PROV-%';

-- 1. Resolución de IDs de Terceros
SET @c_default = COALESCE((SELECT rowid FROM llx_societe WHERE client IN (1, 2, 3) LIMIT 1), 1);
SET @c_mostrador = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Mostrador%' OR nom LIKE '%General%' LIMIT 1), @c_default);
SET @c_san_agustin = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Agust%' LIMIT 1), @c_default);
SET @c_juan = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Juan Carlos%' LIMIT 1), @c_default);
SET @c_maria = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Maria%' OR nom LIKE '%López%' LIMIT 1), @c_default);

-- Proveedores
SET @p_default = COALESCE((SELECT rowid FROM llx_societe WHERE fournisseur = 1 LIMIT 1), 1);
SET @p_harina = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Harina%' OR nom LIKE '%Molino%' LIMIT 1), @p_default);
SET @p_carne = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Carne%' OR nom LIKE '%Sofía%' LIMIT 1), @p_default);

-- Productos terminados
SET @prod_default = COALESCE((SELECT rowid FROM llx_product LIMIT 1), 1);
SET @p_sal01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-01' LIMIT 1), @prod_default);
SET @p_sal02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-02' LIMIT 1), @prod_default);
SET @p_sal03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-03' LIMIT 1), @prod_default);
SET @p_sal04 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-04' LIMIT 1), @prod_default);
SET @p_beb01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-01' LIMIT 1), @prod_default);
SET @p_beb02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-02' LIMIT 1), @prod_default);

-- Insumos
SET @p_ins01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-01' LIMIT 1), @prod_default);
SET @p_ins02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-02' LIMIT 1), @prod_default);
SET @p_ins03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-03' LIMIT 1), @prod_default);

-- Modalidad de pago Efectivo
SET @pay_code = COALESCE((SELECT id FROM llx_c_paiement WHERE code IN ('LIQ', 'ESP') LIMIT 1), 4);

-- Venta: FA2607-0100 (2026-07-12)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0100', 1, 0, @c_juan, '2026-07-12 10:30:00', '2026-07-12', '2026-07-12', 1, 71.0, 0, 71.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0100', 1, '2026-07-12', 71.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 71.0);

-- Venta: FA2607-0101 (2026-07-13)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0101', 1, 0, @c_juan, '2026-07-13 10:30:00', '2026-07-13', '2026-07-13', 1, 67.0, 0, 67.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0101', 1, '2026-07-13', 67.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 67.0);

-- Venta: FA2607-0102 (2026-07-14)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0102', 1, 0, @c_juan, '2026-07-14 10:30:00', '2026-07-14', '2026-07-14', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0102', 1, '2026-07-14', 24.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 24.0);

-- Venta: FA2607-0103 (2026-07-15)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0103', 1, 0, @c_maria, '2026-07-15 10:30:00', '2026-07-15', '2026-07-15', 1, 71.0, 0, 71.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0103', 1, '2026-07-15', 71.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 71.0);

-- Venta: FA2607-0104 (2026-07-16)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0104', 1, 0, @c_maria, '2026-07-16 10:30:00', '2026-07-16', '2026-07-16', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0104', 1, '2026-07-16', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2607-0105 (2026-07-17)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0105', 1, 0, @c_mostrador, '2026-07-17 10:30:00', '2026-07-17', '2026-07-17', 1, 78.0, 0, 78.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0105', 1, '2026-07-17', 78.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 78.0);

-- Venta: FA2607-0106 (2026-07-18)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0106', 1, 0, @c_juan, '2026-07-18 10:30:00', '2026-07-18', '2026-07-18', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0106', 1, '2026-07-18', 54.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 54.0);

-- Venta: FA2607-0107 (2026-07-18)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0107', 1, 0, @c_maria, '2026-07-18 10:30:00', '2026-07-18', '2026-07-18', 1, 73.0, 0, 73.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0107', 1, '2026-07-18', 73.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 73.0);

-- Venta: FA2607-0108 (2026-07-18)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0108', 1, 0, @c_san_agustin, '2026-07-18 10:30:00', '2026-07-18', '2026-07-18', 1, 648.0, 0, 648.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 81, 0, 648.0, 0, 648.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0108', 1, '2026-07-18', 648.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 648.0);

-- Venta: FA2607-0109 (2026-07-19)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0109', 1, 0, @c_mostrador, '2026-07-19 10:30:00', '2026-07-19', '2026-07-19', 1, 82.0, 0, 82.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0109', 1, '2026-07-19', 82.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 82.0);

-- Venta: FA2607-0110 (2026-07-19)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0110', 1, 0, @c_maria, '2026-07-19 10:30:00', '2026-07-19', '2026-07-19', 1, 87.0, 0, 87.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0110', 1, '2026-07-19', 87.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 87.0);

-- Venta: FA2607-0111 (2026-07-20)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0111', 1, 0, @c_juan, '2026-07-20 10:30:00', '2026-07-20', '2026-07-20', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0111', 1, '2026-07-20', 34.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 34.0);

-- Venta: FA2607-0112 (2026-07-20)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0112', 1, 0, @c_maria, '2026-07-20 10:30:00', '2026-07-20', '2026-07-20', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0112', 1, '2026-07-20', 50.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 50.0);

-- Venta: FA2607-0113 (2026-07-21)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0113', 1, 0, @c_juan, '2026-07-21 10:30:00', '2026-07-21', '2026-07-21', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0113', 1, '2026-07-21', 26.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 26.0);

-- Venta: FA2607-0114 (2026-07-22)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0114', 1, 0, @c_juan, '2026-07-22 10:30:00', '2026-07-22', '2026-07-22', 1, 123.0, 0, 123.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0114', 1, '2026-07-22', 123.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 123.0);

-- Venta: FA2607-0115 (2026-07-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0115', 1, 0, @c_maria, '2026-07-23 10:30:00', '2026-07-23', '2026-07-23', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0115', 1, '2026-07-23', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2607-0116 (2026-07-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0116', 1, 0, @c_juan, '2026-07-23 10:30:00', '2026-07-23', '2026-07-23', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0116', 1, '2026-07-23', 60.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 60.0);

-- Venta: FA2607-0117 (2026-07-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0117', 1, 0, @c_maria, '2026-07-24 10:30:00', '2026-07-24', '2026-07-24', 1, 14.0, 0, 14.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0117', 1, '2026-07-24', 14.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 14.0);

-- Venta: FA2607-0118 (2026-07-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0118', 1, 0, @c_maria, '2026-07-24 10:30:00', '2026-07-24', '2026-07-24', 1, 61.0, 0, 61.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0118', 1, '2026-07-24', 61.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 61.0);

-- Venta: FA2607-0119 (2026-07-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0119', 1, 0, @c_san_agustin, '2026-07-24 10:30:00', '2026-07-24', '2026-07-24', 1, 592.0, 0, 592.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 74, 0, 592.0, 0, 592.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0119', 1, '2026-07-24', 592.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 592.0);

-- Venta: FA2607-0120 (2026-07-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0120', 1, 0, @c_juan, '2026-07-25 10:30:00', '2026-07-25', '2026-07-25', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0120', 1, '2026-07-25', 40.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 40.0);

-- Venta: FA2607-0121 (2026-07-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0121', 1, 0, @c_maria, '2026-07-25 10:30:00', '2026-07-25', '2026-07-25', 1, 100.0, 0, 100.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0121', 1, '2026-07-25', 100.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 100.0);

-- Venta: FA2607-0122 (2026-07-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0122', 1, 0, @c_juan, '2026-07-26 10:30:00', '2026-07-26', '2026-07-26', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0122', 1, '2026-07-26', 58.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 58.0);

-- Venta: FA2607-0123 (2026-07-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0123', 1, 0, @c_mostrador, '2026-07-26 10:30:00', '2026-07-26', '2026-07-26', 1, 80.0, 0, 80.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0123', 1, '2026-07-26', 80.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 80.0);

-- Venta: FA2607-0124 (2026-07-27)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0124', 1, 0, @c_mostrador, '2026-07-27 10:30:00', '2026-07-27', '2026-07-27', 1, 93.0, 0, 93.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0124', 1, '2026-07-27', 93.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 93.0);

-- Venta: FA2607-0125 (2026-07-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0125', 1, 0, @c_mostrador, '2026-07-28 10:30:00', '2026-07-28', '2026-07-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0125', 1, '2026-07-28', 24.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 24.0);

-- Venta: FA2607-0126 (2026-07-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0126', 1, 0, @c_mostrador, '2026-07-28 10:30:00', '2026-07-28', '2026-07-28', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0126', 1, '2026-07-28', 54.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 54.0);

-- Venta: FA2607-0127 (2026-07-29)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0127', 1, 0, @c_juan, '2026-07-29 10:30:00', '2026-07-29', '2026-07-29', 1, 78.0, 0, 78.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0127', 1, '2026-07-29', 78.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 78.0);

-- Venta: FA2607-0128 (2026-07-29)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0128', 1, 0, @c_juan, '2026-07-29 10:30:00', '2026-07-29', '2026-07-29', 1, 22.0, 0, 22.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0128', 1, '2026-07-29', 22.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 22.0);

-- Venta: FA2607-0129 (2026-07-30)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0129', 1, 0, @c_juan, '2026-07-30 10:30:00', '2026-07-30', '2026-07-30', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0129', 1, '2026-07-30', 40.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 40.0);

-- Venta: FA2607-0130 (2026-07-30)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0130', 1, 0, @c_san_agustin, '2026-07-30 10:30:00', '2026-07-30', '2026-07-30', 1, 760.0, 0, 760.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 95, 0, 760.0, 0, 760.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0130', 1, '2026-07-30', 760.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 760.0);

-- Venta: FA2607-0131 (2026-07-31)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0131', 1, 0, @c_mostrador, '2026-07-31 10:30:00', '2026-07-31', '2026-07-31', 1, 52.0, 0, 52.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0131', 1, '2026-07-31', 52.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 52.0);

-- Venta: FA2608-0132 (2026-08-01)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0132', 1, 0, @c_juan, '2026-08-01 10:30:00', '2026-08-01', '2026-08-01', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0132', 1, '2026-08-01', 27.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 27.0);

-- Venta: FA2608-0133 (2026-08-01)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0133', 1, 0, @c_juan, '2026-08-01 10:30:00', '2026-08-01', '2026-08-01', 1, 14.0, 0, 14.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0133', 1, '2026-08-01', 14.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 14.0);

-- Venta: FA2608-0134 (2026-08-02)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0134', 1, 0, @c_mostrador, '2026-08-02 10:30:00', '2026-08-02', '2026-08-02', 1, 63.0, 0, 63.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0134', 1, '2026-08-02', 63.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 63.0);

-- Venta: FA2608-0135 (2026-08-03)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0135', 1, 0, @c_maria, '2026-08-03 10:30:00', '2026-08-03', '2026-08-03', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0135', 1, '2026-08-03', 42.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 42.0);

-- Venta: FA2608-0136 (2026-08-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0136', 1, 0, @c_mostrador, '2026-08-04 10:30:00', '2026-08-04', '2026-08-04', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0136', 1, '2026-08-04', 32.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 32.0);

-- Venta: FA2608-0137 (2026-08-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0137', 1, 0, @c_juan, '2026-08-05 10:30:00', '2026-08-05', '2026-08-05', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0137', 1, '2026-08-05', 75.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 75.0);

-- Venta: FA2608-0138 (2026-08-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0138', 1, 0, @c_maria, '2026-08-05 10:30:00', '2026-08-05', '2026-08-05', 1, 71.0, 0, 71.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0138', 1, '2026-08-05', 71.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 71.0);

-- Venta: FA2608-0139 (2026-08-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0139', 1, 0, @c_san_agustin, '2026-08-05 10:30:00', '2026-08-05', '2026-08-05', 1, 600.0, 0, 600.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 75, 0, 600.0, 0, 600.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0139', 1, '2026-08-05', 600.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 600.0);

-- Venta: FA2608-0140 (2026-08-06)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0140', 1, 0, @c_maria, '2026-08-06 10:30:00', '2026-08-06', '2026-08-06', 1, 41.0, 0, 41.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0140', 1, '2026-08-06', 41.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 41.0);

-- Venta: FA2608-0141 (2026-08-07)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0141', 1, 0, @c_mostrador, '2026-08-07 10:30:00', '2026-08-07', '2026-08-07', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0141', 1, '2026-08-07', 54.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 54.0);

-- Venta: FA2608-0142 (2026-08-07)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0142', 1, 0, @c_maria, '2026-08-07 10:30:00', '2026-08-07', '2026-08-07', 1, 41.0, 0, 41.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0142', 1, '2026-08-07', 41.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 41.0);

-- Venta: FA2608-0143 (2026-08-08)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0143', 1, 0, @c_mostrador, '2026-08-08 10:30:00', '2026-08-08', '2026-08-08', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0143', 1, '2026-08-08', 43.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 43.0);

-- Venta: FA2608-0144 (2026-08-09)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0144', 1, 0, @c_mostrador, '2026-08-09 10:30:00', '2026-08-09', '2026-08-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0144', 1, '2026-08-09', 24.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 24.0);

-- Venta: FA2608-0145 (2026-08-09)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0145', 1, 0, @c_mostrador, '2026-08-09 10:30:00', '2026-08-09', '2026-08-09', 1, 106.0, 0, 106.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0145', 1, '2026-08-09', 106.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 106.0);

-- Venta: FA2608-0146 (2026-08-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0146', 1, 0, @c_juan, '2026-08-10 10:30:00', '2026-08-10', '2026-08-10', 1, 147.0, 0, 147.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0146', 1, '2026-08-10', 147.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 147.0);

-- Venta: FA2608-0147 (2026-08-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0147', 1, 0, @c_mostrador, '2026-08-10 10:30:00', '2026-08-10', '2026-08-10', 1, 15.0, 0, 15.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0147', 1, '2026-08-10', 15.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 15.0);

-- Venta: FA2608-0148 (2026-08-11)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0148', 1, 0, @c_mostrador, '2026-08-11 10:30:00', '2026-08-11', '2026-08-11', 1, 74.0, 0, 74.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0148', 1, '2026-08-11', 74.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 74.0);

-- Venta: FA2608-0149 (2026-08-11)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0149', 1, 0, @c_san_agustin, '2026-08-11 10:30:00', '2026-08-11', '2026-08-11', 1, 536.0, 0, 536.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 67, 0, 536.0, 0, 536.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0149', 1, '2026-08-11', 536.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 536.0);

-- Venta: FA2608-0150 (2026-08-12)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0150', 1, 0, @c_mostrador, '2026-08-12 10:30:00', '2026-08-12', '2026-08-12', 1, 66.0, 0, 66.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0150', 1, '2026-08-12', 66.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 66.0);

-- Venta: FA2608-0151 (2026-08-13)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0151', 1, 0, @c_mostrador, '2026-08-13 10:30:00', '2026-08-13', '2026-08-13', 1, 120.0, 0, 120.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0151', 1, '2026-08-13', 120.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 120.0);

-- Venta: FA2608-0152 (2026-08-13)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0152', 1, 0, @c_mostrador, '2026-08-13 10:30:00', '2026-08-13', '2026-08-13', 1, 37.0, 0, 37.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0152', 1, '2026-08-13', 37.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 37.0);

-- Venta: FA2608-0153 (2026-08-14)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0153', 1, 0, @c_juan, '2026-08-14 10:30:00', '2026-08-14', '2026-08-14', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0153', 1, '2026-08-14', 40.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 40.0);

-- Venta: FA2608-0154 (2026-08-14)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0154', 1, 0, @c_mostrador, '2026-08-14 10:30:00', '2026-08-14', '2026-08-14', 1, 101.0, 0, 101.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0154', 1, '2026-08-14', 101.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 101.0);

-- Venta: FA2608-0155 (2026-08-15)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0155', 1, 0, @c_mostrador, '2026-08-15 10:30:00', '2026-08-15', '2026-08-15', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0155', 1, '2026-08-15', 10.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 10.0);

-- Venta: FA2608-0156 (2026-08-15)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0156', 1, 0, @c_maria, '2026-08-15 10:30:00', '2026-08-15', '2026-08-15', 1, 110.0, 0, 110.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0156', 1, '2026-08-15', 110.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 110.0);

-- Venta: FA2608-0157 (2026-08-16)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0157', 1, 0, @c_mostrador, '2026-08-16 10:30:00', '2026-08-16', '2026-08-16', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0157', 1, '2026-08-16', 18.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 18.0);

-- Venta: FA2608-0158 (2026-08-16)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0158', 1, 0, @c_maria, '2026-08-16 10:30:00', '2026-08-16', '2026-08-16', 1, 89.0, 0, 89.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0158', 1, '2026-08-16', 89.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 89.0);

-- Venta: FA2608-0159 (2026-08-17)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0159', 1, 0, @c_maria, '2026-08-17 10:30:00', '2026-08-17', '2026-08-17', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0159', 1, '2026-08-17', 58.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 58.0);

-- Venta: FA2608-0160 (2026-08-17)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0160', 1, 0, @c_juan, '2026-08-17 10:30:00', '2026-08-17', '2026-08-17', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0160', 1, '2026-08-17', 16.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 16.0);

-- Venta: FA2608-0161 (2026-08-17)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0161', 1, 0, @c_san_agustin, '2026-08-17 10:30:00', '2026-08-17', '2026-08-17', 1, 480.0, 0, 480.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 60, 0, 480.0, 0, 480.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0161', 1, '2026-08-17', 480.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 480.0);

-- Venta: FA2608-0162 (2026-08-18)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0162', 1, 0, @c_mostrador, '2026-08-18 10:30:00', '2026-08-18', '2026-08-18', 1, 94.0, 0, 94.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0162', 1, '2026-08-18', 94.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 94.0);

-- Venta: FA2608-0163 (2026-08-19)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0163', 1, 0, @c_maria, '2026-08-19 10:30:00', '2026-08-19', '2026-08-19', 1, 104.0, 0, 104.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0163', 1, '2026-08-19', 104.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 104.0);

-- Venta: FA2608-0164 (2026-08-20)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0164', 1, 0, @c_maria, '2026-08-20 10:30:00', '2026-08-20', '2026-08-20', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0164', 1, '2026-08-20', 36.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 36.0);

-- Venta: FA2608-0165 (2026-08-21)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0165', 1, 0, @c_mostrador, '2026-08-21 10:30:00', '2026-08-21', '2026-08-21', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0165', 1, '2026-08-21', 10.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 10.0);

-- Venta: FA2608-0166 (2026-08-21)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0166', 1, 0, @c_mostrador, '2026-08-21 10:30:00', '2026-08-21', '2026-08-21', 1, 55.0, 0, 55.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0166', 1, '2026-08-21', 55.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 55.0);

-- Venta: FA2608-0167 (2026-08-22)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0167', 1, 0, @c_maria, '2026-08-22 10:30:00', '2026-08-22', '2026-08-22', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0167', 1, '2026-08-22', 50.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 50.0);

-- Venta: FA2608-0168 (2026-08-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0168', 1, 0, @c_mostrador, '2026-08-23 10:30:00', '2026-08-23', '2026-08-23', 1, 21.0, 0, 21.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0168', 1, '2026-08-23', 21.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 21.0);

-- Venta: FA2608-0169 (2026-08-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0169', 1, 0, @c_san_agustin, '2026-08-23 10:30:00', '2026-08-23', '2026-08-23', 1, 536.0, 0, 536.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 67, 0, 536.0, 0, 536.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0169', 1, '2026-08-23', 536.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 536.0);

-- Venta: FA2608-0170 (2026-08-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0170', 1, 0, @c_maria, '2026-08-24 10:30:00', '2026-08-24', '2026-08-24', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0170', 1, '2026-08-24', 27.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 27.0);

-- Venta: FA2608-0171 (2026-08-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0171', 1, 0, @c_juan, '2026-08-25 10:30:00', '2026-08-25', '2026-08-25', 1, 62.0, 0, 62.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0171', 1, '2026-08-25', 62.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 62.0);

-- Venta: FA2608-0172 (2026-08-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0172', 1, 0, @c_juan, '2026-08-25 10:30:00', '2026-08-25', '2026-08-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0172', 1, '2026-08-25', 18.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 18.0);

-- Venta: FA2608-0173 (2026-08-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0173', 1, 0, @c_mostrador, '2026-08-26 10:30:00', '2026-08-26', '2026-08-26', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0173', 1, '2026-08-26', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2608-0174 (2026-08-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0174', 1, 0, @c_mostrador, '2026-08-26 10:30:00', '2026-08-26', '2026-08-26', 1, 131.0, 0, 131.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0174', 1, '2026-08-26', 131.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 131.0);

-- Venta: FA2608-0175 (2026-08-27)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0175', 1, 0, @c_mostrador, '2026-08-27 10:30:00', '2026-08-27', '2026-08-27', 1, 101.0, 0, 101.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0175', 1, '2026-08-27', 101.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 101.0);

-- Venta: FA2608-0176 (2026-08-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0176', 1, 0, @c_mostrador, '2026-08-28 10:30:00', '2026-08-28', '2026-08-28', 1, 55.0, 0, 55.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0176', 1, '2026-08-28', 55.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 55.0);

-- Venta: FA2608-0177 (2026-08-29)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0177', 1, 0, @c_juan, '2026-08-29 10:30:00', '2026-08-29', '2026-08-29', 1, 99.0, 0, 99.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0177', 1, '2026-08-29', 99.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 99.0);

-- Venta: FA2608-0178 (2026-08-29)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0178', 1, 0, @c_san_agustin, '2026-08-29 10:30:00', '2026-08-29', '2026-08-29', 1, 448.0, 0, 448.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 56, 0, 448.0, 0, 448.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0178', 1, '2026-08-29', 448.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 448.0);

-- Venta: FA2608-0179 (2026-08-30)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0179', 1, 0, @c_maria, '2026-08-30 10:30:00', '2026-08-30', '2026-08-30', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0179', 1, '2026-08-30', 36.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 36.0);

-- Venta: FA2608-0180 (2026-08-31)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0180', 1, 0, @c_juan, '2026-08-31 10:30:00', '2026-08-31', '2026-08-31', 1, 81.0, 0, 81.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0180', 1, '2026-08-31', 81.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 81.0);

-- Venta: FA2608-0181 (2026-08-31)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0181', 1, 0, @c_mostrador, '2026-08-31 10:30:00', '2026-08-31', '2026-08-31', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0181', 1, '2026-08-31', 16.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 16.0);

-- Venta: FA2609-0182 (2026-09-01)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0182', 1, 0, @c_mostrador, '2026-09-01 10:30:00', '2026-09-01', '2026-09-01', 1, 29.0, 0, 29.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0182', 1, '2026-09-01', 29.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 29.0);

-- Venta: FA2609-0183 (2026-09-01)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0183', 1, 0, @c_juan, '2026-09-01 10:30:00', '2026-09-01', '2026-09-01', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0183', 1, '2026-09-01', 43.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 43.0);

-- Venta: FA2609-0184 (2026-09-02)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0184', 1, 0, @c_maria, '2026-09-02 10:30:00', '2026-09-02', '2026-09-02', 1, 71.0, 0, 71.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0184', 1, '2026-09-02', 71.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 71.0);

-- Venta: FA2609-0185 (2026-09-03)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0185', 1, 0, @c_maria, '2026-09-03 10:30:00', '2026-09-03', '2026-09-03', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0185', 1, '2026-09-03', 45.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 45.0);

-- Venta: FA2609-0186 (2026-09-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0186', 1, 0, @c_mostrador, '2026-09-04 10:30:00', '2026-09-04', '2026-09-04', 1, 86.0, 0, 86.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0186', 1, '2026-09-04', 86.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 86.0);

-- Venta: FA2609-0187 (2026-09-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0187', 1, 0, @c_maria, '2026-09-04 10:30:00', '2026-09-04', '2026-09-04', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0187', 1, '2026-09-04', 69.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 69.0);

-- Venta: FA2609-0188 (2026-09-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0188', 1, 0, @c_san_agustin, '2026-09-04 10:30:00', '2026-09-04', '2026-09-04', 1, 488.0, 0, 488.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 61, 0, 488.0, 0, 488.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0188', 1, '2026-09-04', 488.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 488.0);

-- Venta: FA2609-0189 (2026-09-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0189', 1, 0, @c_juan, '2026-09-05 10:30:00', '2026-09-05', '2026-09-05', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0189', 1, '2026-09-05', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2609-0190 (2026-09-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0190', 1, 0, @c_mostrador, '2026-09-05 10:30:00', '2026-09-05', '2026-09-05', 1, 114.0, 0, 114.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0190', 1, '2026-09-05', 114.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 114.0);

-- Venta: FA2609-0191 (2026-09-06)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0191', 1, 0, @c_mostrador, '2026-09-06 10:30:00', '2026-09-06', '2026-09-06', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0191', 1, '2026-09-06', 36.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 36.0);

-- Venta: FA2609-0192 (2026-09-07)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0192', 1, 0, @c_mostrador, '2026-09-07 10:30:00', '2026-09-07', '2026-09-07', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0192', 1, '2026-09-07', 51.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 51.0);

-- Venta: FA2609-0193 (2026-09-07)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0193', 1, 0, @c_mostrador, '2026-09-07 10:30:00', '2026-09-07', '2026-09-07', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0193', 1, '2026-09-07', 40.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 40.0);

-- Venta: FA2609-0194 (2026-09-08)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0194', 1, 0, @c_mostrador, '2026-09-08 10:30:00', '2026-09-08', '2026-09-08', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0194', 1, '2026-09-08', 36.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 36.0);

-- Venta: FA2609-0195 (2026-09-09)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0195', 1, 0, @c_mostrador, '2026-09-09 10:30:00', '2026-09-09', '2026-09-09', 1, 67.0, 0, 67.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0195', 1, '2026-09-09', 67.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 67.0);

-- Venta: FA2609-0196 (2026-09-09)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0196', 1, 0, @c_mostrador, '2026-09-09 10:30:00', '2026-09-09', '2026-09-09', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0196', 1, '2026-09-09', 72.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 72.0);

-- Venta: FA2609-0197 (2026-09-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0197', 1, 0, @c_mostrador, '2026-09-10 10:30:00', '2026-09-10', '2026-09-10', 1, 70.0, 0, 70.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0197', 1, '2026-09-10', 70.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 70.0);

-- Venta: FA2609-0198 (2026-09-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0198', 1, 0, @c_juan, '2026-09-10 10:30:00', '2026-09-10', '2026-09-10', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0198', 1, '2026-09-10', 27.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 27.0);

-- Venta: FA2609-0199 (2026-09-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0199', 1, 0, @c_san_agustin, '2026-09-10 10:30:00', '2026-09-10', '2026-09-10', 1, 504.0, 0, 504.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 63, 0, 504.0, 0, 504.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0199', 1, '2026-09-10', 504.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 504.0);

-- Venta: FA2609-0200 (2026-09-11)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0200', 1, 0, @c_mostrador, '2026-09-11 10:30:00', '2026-09-11', '2026-09-11', 1, 73.0, 0, 73.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0200', 1, '2026-09-11', 73.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 73.0);

-- Venta: FA2609-0201 (2026-09-12)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0201', 1, 0, @c_maria, '2026-09-12 10:30:00', '2026-09-12', '2026-09-12', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0201', 1, '2026-09-12', 40.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 40.0);

-- Venta: FA2609-0202 (2026-09-13)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0202', 1, 0, @c_mostrador, '2026-09-13 10:30:00', '2026-09-13', '2026-09-13', 1, 7.0, 0, 7.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0202', 1, '2026-09-13', 7.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 7.0);

-- Venta: FA2609-0203 (2026-09-14)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0203', 1, 0, @c_juan, '2026-09-14 10:30:00', '2026-09-14', '2026-09-14', 1, 59.0, 0, 59.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0203', 1, '2026-09-14', 59.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 59.0);

-- Venta: FA2609-0204 (2026-09-15)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0204', 1, 0, @c_maria, '2026-09-15 10:30:00', '2026-09-15', '2026-09-15', 1, 117.0, 0, 117.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0204', 1, '2026-09-15', 117.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 117.0);

-- Venta: FA2609-0205 (2026-09-15)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0205', 1, 0, @c_juan, '2026-09-15 10:30:00', '2026-09-15', '2026-09-15', 1, 41.0, 0, 41.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0205', 1, '2026-09-15', 41.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 41.0);

-- Venta: FA2609-0206 (2026-09-16)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0206', 1, 0, @c_maria, '2026-09-16 10:30:00', '2026-09-16', '2026-09-16', 1, 105.0, 0, 105.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0206', 1, '2026-09-16', 105.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 105.0);

-- Venta: FA2609-0207 (2026-09-16)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0207', 1, 0, @c_san_agustin, '2026-09-16 10:30:00', '2026-09-16', '2026-09-16', 1, 952.0, 0, 952.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 119, 0, 952.0, 0, 952.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0207', 1, '2026-09-16', 952.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 952.0);

-- Venta: FA2609-0208 (2026-09-17)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0208', 1, 0, @c_mostrador, '2026-09-17 10:30:00', '2026-09-17', '2026-09-17', 1, 63.0, 0, 63.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0208', 1, '2026-09-17', 63.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 63.0);

-- Venta: FA2609-0209 (2026-09-18)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0209', 1, 0, @c_mostrador, '2026-09-18 10:30:00', '2026-09-18', '2026-09-18', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0209', 1, '2026-09-18', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2609-0210 (2026-09-19)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0210', 1, 0, @c_mostrador, '2026-09-19 10:30:00', '2026-09-19', '2026-09-19', 1, 86.0, 0, 86.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0210', 1, '2026-09-19', 86.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 86.0);

-- Venta: FA2609-0211 (2026-09-20)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0211', 1, 0, @c_juan, '2026-09-20 10:30:00', '2026-09-20', '2026-09-20', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0211', 1, '2026-09-20', 54.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 54.0);

-- Venta: FA2609-0212 (2026-09-21)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0212', 1, 0, @c_maria, '2026-09-21 10:30:00', '2026-09-21', '2026-09-21', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0212', 1, '2026-09-21', 16.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 16.0);

-- Venta: FA2609-0213 (2026-09-22)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0213', 1, 0, @c_mostrador, '2026-09-22 10:30:00', '2026-09-22', '2026-09-22', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0213', 1, '2026-09-22', 35.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 35.0);

-- Venta: FA2609-0214 (2026-09-22)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0214', 1, 0, @c_maria, '2026-09-22 10:30:00', '2026-09-22', '2026-09-22', 1, 62.0, 0, 62.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0214', 1, '2026-09-22', 62.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 62.0);

-- Venta: FA2609-0215 (2026-09-22)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0215', 1, 0, @c_san_agustin, '2026-09-22 10:30:00', '2026-09-22', '2026-09-22', 1, 856.0, 0, 856.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 107, 0, 856.0, 0, 856.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0215', 1, '2026-09-22', 856.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 856.0);

-- Venta: FA2609-0216 (2026-09-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0216', 1, 0, @c_maria, '2026-09-23 10:30:00', '2026-09-23', '2026-09-23', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0216', 1, '2026-09-23', 75.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 75.0);

-- Venta: FA2609-0217 (2026-09-23)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0217', 1, 0, @c_mostrador, '2026-09-23 10:30:00', '2026-09-23', '2026-09-23', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0217', 1, '2026-09-23', 34.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 34.0);

-- Venta: FA2609-0218 (2026-09-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0218', 1, 0, @c_maria, '2026-09-24 10:30:00', '2026-09-24', '2026-09-24', 1, 23.0, 0, 23.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0218', 1, '2026-09-24', 23.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 23.0);

-- Venta: FA2609-0219 (2026-09-24)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0219', 1, 0, @c_maria, '2026-09-24 10:30:00', '2026-09-24', '2026-09-24', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0219', 1, '2026-09-24', 54.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 54.0);

-- Venta: FA2609-0220 (2026-09-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0220', 1, 0, @c_maria, '2026-09-25 10:30:00', '2026-09-25', '2026-09-25', 1, 124.0, 0, 124.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0220', 1, '2026-09-25', 124.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 124.0);

-- Venta: FA2609-0221 (2026-09-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0221', 1, 0, @c_juan, '2026-09-26 10:30:00', '2026-09-26', '2026-09-26', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0221', 1, '2026-09-26', 45.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 45.0);

-- Venta: FA2609-0222 (2026-09-26)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0222', 1, 0, @c_juan, '2026-09-26 10:30:00', '2026-09-26', '2026-09-26', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0222', 1, '2026-09-26', 32.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 32.0);

-- Venta: FA2609-0223 (2026-09-27)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0223', 1, 0, @c_maria, '2026-09-27 10:30:00', '2026-09-27', '2026-09-27', 1, 28.0, 0, 28.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0223', 1, '2026-09-27', 28.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 28.0);

-- Venta: FA2609-0224 (2026-09-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0224', 1, 0, @c_maria, '2026-09-28 10:30:00', '2026-09-28', '2026-09-28', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0224', 1, '2026-09-28', 48.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 48.0);

-- Venta: FA2609-0225 (2026-09-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0225', 1, 0, @c_juan, '2026-09-28 10:30:00', '2026-09-28', '2026-09-28', 1, 57.0, 0, 57.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0225', 1, '2026-09-28', 57.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 57.0);

-- Venta: FA2609-0226 (2026-09-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0226', 1, 0, @c_san_agustin, '2026-09-28 10:30:00', '2026-09-28', '2026-09-28', 1, 944.0, 0, 944.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 118, 0, 944.0, 0, 944.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0226', 1, '2026-09-28', 944.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 944.0);

-- Venta: FA2609-0227 (2026-09-29)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0227', 1, 0, @c_juan, '2026-09-29 10:30:00', '2026-09-29', '2026-09-29', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0227', 1, '2026-09-29', 32.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 32.0);

-- Venta: FA2609-0228 (2026-09-30)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0228', 1, 0, @c_mostrador, '2026-09-30 10:30:00', '2026-09-30', '2026-09-30', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0228', 1, '2026-09-30', 34.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 34.0);

-- Venta: FA2610-0229 (2026-10-01)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0229', 1, 0, @c_maria, '2026-10-01 10:30:00', '2026-10-01', '2026-10-01', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0229', 1, '2026-10-01', 64.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 64.0);

-- Venta: FA2610-0230 (2026-10-02)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0230', 1, 0, @c_mostrador, '2026-10-02 10:30:00', '2026-10-02', '2026-10-02', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0230', 1, '2026-10-02', 69.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 69.0);

-- Venta: FA2610-0231 (2026-10-02)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0231', 1, 0, @c_maria, '2026-10-02 10:30:00', '2026-10-02', '2026-10-02', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0231', 1, '2026-10-02', 84.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 84.0);

-- Venta: FA2610-0232 (2026-10-03)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0232', 1, 0, @c_juan, '2026-10-03 10:30:00', '2026-10-03', '2026-10-03', 1, 70.0, 0, 70.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0232', 1, '2026-10-03', 70.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 70.0);

-- Venta: FA2610-0233 (2026-10-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0233', 1, 0, @c_mostrador, '2026-10-04 10:30:00', '2026-10-04', '2026-10-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0233', 1, '2026-10-04', 16.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 16.0);

-- Venta: FA2610-0234 (2026-10-04)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0234', 1, 0, @c_san_agustin, '2026-10-04 10:30:00', '2026-10-04', '2026-10-04', 1, 520.0, 0, 520.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 65, 0, 520.0, 0, 520.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0234', 1, '2026-10-04', 520.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 520.0);

-- Venta: FA2610-0235 (2026-10-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0235', 1, 0, @c_juan, '2026-10-05 10:30:00', '2026-10-05', '2026-10-05', 1, 78.0, 0, 78.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0235', 1, '2026-10-05', 78.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 78.0);

-- Venta: FA2610-0236 (2026-10-05)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0236', 1, 0, @c_juan, '2026-10-05 10:30:00', '2026-10-05', '2026-10-05', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0236', 1, '2026-10-05', 10.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 10.0);

-- Venta: FA2610-0237 (2026-10-06)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0237', 1, 0, @c_maria, '2026-10-06 10:30:00', '2026-10-06', '2026-10-06', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0237', 1, '2026-10-06', 84.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 84.0);

-- Venta: FA2610-0238 (2026-10-06)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0238', 1, 0, @c_juan, '2026-10-06 10:30:00', '2026-10-06', '2026-10-06', 1, 63.0, 0, 63.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0238', 1, '2026-10-06', 63.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 63.0);

-- Venta: FA2610-0239 (2026-10-07)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0239', 1, 0, @c_mostrador, '2026-10-07 10:30:00', '2026-10-07', '2026-10-07', 1, 71.0, 0, 71.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0239', 1, '2026-10-07', 71.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 71.0);

-- Venta: FA2610-0240 (2026-10-08)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0240', 1, 0, @c_juan, '2026-10-08 10:30:00', '2026-10-08', '2026-10-08', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0240', 1, '2026-10-08', 42.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 42.0);

-- Venta: FA2610-0241 (2026-10-09)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0241', 1, 0, @c_mostrador, '2026-10-09 10:30:00', '2026-10-09', '2026-10-09', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0241', 1, '2026-10-09', 32.0, @pay_code, 1, 0);
SET @last_pay_id = LAST_INSERT_ID();
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (@last_pay_id, @last_fac_id, 32.0);

-- Compra: SI2607-0100 (2026-07-12)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0100', 'FAC-PROV-100', 1, 0, @p_carne, '2026-07-12 08:00:00', '2026-07-12', '2026-07-12', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0100', 1, '2026-07-12', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2607-0101 (2026-07-17)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0101', 'FAC-PROV-101', 1, 0, @p_carne, '2026-07-17 08:00:00', '2026-07-17', '2026-07-17', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0101', 1, '2026-07-17', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2607-0102 (2026-07-22)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0102', 'FAC-PROV-102', 1, 0, @p_carne, '2026-07-22 08:00:00', '2026-07-22', '2026-07-22', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0102', 1, '2026-07-22', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2607-0103 (2026-07-27)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0103', 'FAC-PROV-103', 1, 0, @p_carne, '2026-07-27 08:00:00', '2026-07-27', '2026-07-27', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0103', 1, '2026-07-27', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0104 (2026-08-01)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0104', 'FAC-PROV-104', 1, 0, @p_carne, '2026-08-01 08:00:00', '2026-08-01', '2026-08-01', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0104', 1, '2026-08-01', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0105 (2026-08-06)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0105', 'FAC-PROV-105', 1, 0, @p_carne, '2026-08-06 08:00:00', '2026-08-06', '2026-08-06', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0105', 1, '2026-08-06', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0106 (2026-08-11)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0106', 'FAC-PROV-106', 1, 0, @p_carne, '2026-08-11 08:00:00', '2026-08-11', '2026-08-11', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0106', 1, '2026-08-11', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0107 (2026-08-16)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0107', 'FAC-PROV-107', 1, 0, @p_carne, '2026-08-16 08:00:00', '2026-08-16', '2026-08-16', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0107', 1, '2026-08-16', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0108 (2026-08-21)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0108', 'FAC-PROV-108', 1, 0, @p_carne, '2026-08-21 08:00:00', '2026-08-21', '2026-08-21', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0108', 1, '2026-08-21', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0109 (2026-08-26)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0109', 'FAC-PROV-109', 1, 0, @p_carne, '2026-08-26 08:00:00', '2026-08-26', '2026-08-26', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0109', 1, '2026-08-26', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2608-0110 (2026-08-31)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0110', 'FAC-PROV-110', 1, 0, @p_carne, '2026-08-31 08:00:00', '2026-08-31', '2026-08-31', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0110', 1, '2026-08-31', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0111 (2026-09-05)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0111', 'FAC-PROV-111', 1, 0, @p_carne, '2026-09-05 08:00:00', '2026-09-05', '2026-09-05', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0111', 1, '2026-09-05', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0112 (2026-09-10)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0112', 'FAC-PROV-112', 1, 0, @p_carne, '2026-09-10 08:00:00', '2026-09-10', '2026-09-10', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0112', 1, '2026-09-10', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0113 (2026-09-15)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0113', 'FAC-PROV-113', 1, 0, @p_carne, '2026-09-15 08:00:00', '2026-09-15', '2026-09-15', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0113', 1, '2026-09-15', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0114 (2026-09-20)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0114', 'FAC-PROV-114', 1, 0, @p_carne, '2026-09-20 08:00:00', '2026-09-20', '2026-09-20', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0114', 1, '2026-09-20', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0115 (2026-09-25)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0115', 'FAC-PROV-115', 1, 0, @p_carne, '2026-09-25 08:00:00', '2026-09-25', '2026-09-25', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0115', 1, '2026-09-25', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2609-0116 (2026-09-30)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0116', 'FAC-PROV-116', 1, 0, @p_carne, '2026-09-30 08:00:00', '2026-09-30', '2026-09-30', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0116', 1, '2026-09-30', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2610-0117 (2026-10-05)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2610-0117', 'FAC-PROV-117', 1, 0, @p_carne, '2026-10-05 08:00:00', '2026-10-05', '2026-10-05', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2610-0117', 1, '2026-10-05', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

-- Compra: SI2610-0118 (2026-10-10)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2610-0118', 'FAC-PROV-118', 1, 0, @p_carne, '2026-10-10 08:00:00', '2026-10-10', '2026-10-10', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2610-0118', 1, '2026-10-10', 950.0, @pay_code, 1, 0);
SET @last_payfourn_id = LAST_INSERT_ID();
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (@last_payfourn_id, @last_fourn_id, 950.0);

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;