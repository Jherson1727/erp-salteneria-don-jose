-- ============================================================
-- CARGA HISTORICA MASIVA: VENTAS, COMPRAS Y PICOS DE MARKETING
-- ============================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;

-- 0. LIMPIEZA TOTAL DE REGISTROS SIMULADOS PREVIOS
DELETE pf FROM llx_paiement_facture pf JOIN llx_facture f ON pf.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';
DELETE FROM llx_paiement_facture WHERE fk_paiement IN (SELECT rowid FROM llx_paiement WHERE ref LIKE 'PAY26%');
DELETE fd FROM llx_facturedet fd JOIN llx_facture f ON fd.fk_facture = f.rowid WHERE f.ref LIKE 'FA26%';
DELETE FROM llx_paiement WHERE ref LIKE 'PAY26%';
DELETE FROM llx_facture WHERE ref LIKE 'FA26%';

DELETE pff FROM llx_paiementfourn_facturefourn pff JOIN llx_facture_fourn ff ON pff.fk_facturefourn = ff.rowid WHERE ff.ref LIKE 'SI26%' OR ff.ref_supplier LIKE 'FAC-PROV-%';
DELETE FROM llx_paiementfourn_facturefourn WHERE fk_paiementfourn IN (SELECT rowid FROM llx_paiementfourn WHERE ref LIKE 'PMR26%');
DELETE ffd FROM llx_facture_fourn_det ffd JOIN llx_facture_fourn ff ON ffd.fk_facture_fourn = ff.rowid WHERE ff.ref LIKE 'SI26%' OR ff.ref_supplier LIKE 'FAC-PROV-%';
DELETE FROM llx_paiementfourn WHERE ref LIKE 'PMR26%';
DELETE FROM llx_facture_fourn WHERE ref LIKE 'SI26%' OR ref_supplier LIKE 'FAC-PROV-%';

-- 1. RESOLUCION DE IDENTIFICADORES MAESTROS
SET @c_default = COALESCE((SELECT rowid FROM llx_societe WHERE client IN (1, 2, 3) LIMIT 1), 1);
SET @c_mostrador = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Mostrador%' OR nom LIKE '%General%' LIMIT 1), @c_default);
SET @c_san_agustin = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Agust%' LIMIT 1), @c_default);
SET @c_juan = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Juan%' LIMIT 1), @c_default);
SET @c_maria = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Maria%' OR nom LIKE '%López%' LIMIT 1), @c_default);

SET @p_default = COALESCE((SELECT rowid FROM llx_societe WHERE fournisseur = 1 LIMIT 1), 1);
SET @p_carne = COALESCE((SELECT rowid FROM llx_societe WHERE nom LIKE '%Carne%' OR nom LIKE '%Sofía%' LIMIT 1), @p_default);

SET @prod_default = COALESCE((SELECT rowid FROM llx_product LIMIT 1), 1);
SET @p_sal01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-01' LIMIT 1), @prod_default);
SET @p_sal02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-02' LIMIT 1), @prod_default);
SET @p_sal03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-03' LIMIT 1), @prod_default);
SET @p_sal04 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'SAL-04' LIMIT 1), @prod_default);
SET @p_beb01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-01' LIMIT 1), @prod_default);
SET @p_beb02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'BEB-02' LIMIT 1), @prod_default);

SET @p_ins01 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-01' LIMIT 1), @prod_default);
SET @p_ins02 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-02' LIMIT 1), @prod_default);
SET @p_ins03 = COALESCE((SELECT rowid FROM llx_product WHERE ref = 'INS-03' LIMIT 1), @prod_default);

SET @pay_code = COALESCE((SELECT id FROM llx_c_paiement WHERE code IN ('LIQ', 'ESP') LIMIT 1), 4);

-- Compra de insumos: SI2607-0101 (2026-07-01)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0101', 'FAC-PROV-101', 1, 0, @p_carne, '2026-07-01 08:00:00', '2026-07-01', '2026-07-01', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0101', 1, '2026-07-01', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0101 (2026-07-01 10:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0101', 1, 0, @c_mostrador, '2026-07-01 10:28:00', '2026-07-01', '2026-07-01', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0101', 1, '2026-07-01', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0102 (2026-07-01 08:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0102', 1, 0, @c_mostrador, '2026-07-01 08:12:00', '2026-07-01', '2026-07-01', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0102', 1, '2026-07-01', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0103 (2026-07-01 08:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0103', 1, 0, @c_juan, '2026-07-01 08:05:00', '2026-07-01', '2026-07-01', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0103', 1, '2026-07-01', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0104 (2026-07-01 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0104', 1, 0, @c_maria, '2026-07-01 09:56:00', '2026-07-01', '2026-07-01', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0104', 1, '2026-07-01', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0105 (2026-07-01 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0105', 1, 0, @c_mostrador, '2026-07-01 09:21:00', '2026-07-01', '2026-07-01', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0105', 1, '2026-07-01', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2607-0106 (2026-07-01 11:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0106', 1, 0, @c_mostrador, '2026-07-01 11:53:00', '2026-07-01', '2026-07-01', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0106', 1, '2026-07-01', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0107 (2026-07-02 08:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0107', 1, 0, @c_mostrador, '2026-07-02 08:57:00', '2026-07-02', '2026-07-02', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0107', 1, '2026-07-02', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2607-0108 (2026-07-02 09:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0108', 1, 0, @c_mostrador, '2026-07-02 09:39:00', '2026-07-02', '2026-07-02', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0108', 1, '2026-07-02', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0109 (2026-07-02 10:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0109', 1, 0, @c_mostrador, '2026-07-02 10:27:00', '2026-07-02', '2026-07-02', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0109', 1, '2026-07-02', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0110 (2026-07-02 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0110', 1, 0, @c_juan, '2026-07-02 09:55:00', '2026-07-02', '2026-07-02', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0110', 1, '2026-07-02', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2607-0111 (2026-07-03 08:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0111', 1, 0, @c_mostrador, '2026-07-03 08:11:00', '2026-07-03', '2026-07-03', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0111', 1, '2026-07-03', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0112 (2026-07-03 08:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0112', 1, 0, @c_mostrador, '2026-07-03 08:42:00', '2026-07-03', '2026-07-03', 1, 5.0, 0, 5.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0112', 1, '2026-07-03', 5.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 5.0);

-- Venta FA2607-0113 (2026-07-03 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0113', 1, 0, @c_mostrador, '2026-07-03 09:25:00', '2026-07-03', '2026-07-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0113', 1, '2026-07-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0114 (2026-07-03 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0114', 1, 0, @c_juan, '2026-07-03 09:58:00', '2026-07-03', '2026-07-03', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0114', 1, '2026-07-03', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2607-0115 (2026-07-03 10:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0115', 1, 0, @c_maria, '2026-07-03 10:36:00', '2026-07-03', '2026-07-03', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0115', 1, '2026-07-03', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2607-0116 (2026-07-03 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0116', 1, 0, @c_maria, '2026-07-03 09:22:00', '2026-07-03', '2026-07-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0116', 1, '2026-07-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0117 (2026-07-03 10:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0117', 1, 0, @c_juan, '2026-07-03 10:18:00', '2026-07-03', '2026-07-03', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0117', 1, '2026-07-03', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2607-0118 (2026-07-03 09:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0118', 1, 0, @c_mostrador, '2026-07-03 09:32:00', '2026-07-03', '2026-07-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0118', 1, '2026-07-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0119 (2026-07-03 09:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0119', 1, 0, @c_mostrador, '2026-07-03 09:23:00', '2026-07-03', '2026-07-03', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0119', 1, '2026-07-03', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0120 (2026-07-04 11:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0120', 1, 0, @c_maria, '2026-07-04 11:33:00', '2026-07-04', '2026-07-04', 1, 94.0, 0, 94.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0120', 1, '2026-07-04', 94.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 94.0);

-- Venta FA2607-0121 (2026-07-04 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0121', 1, 0, @c_juan, '2026-07-04 09:31:00', '2026-07-04', '2026-07-04', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0121', 1, '2026-07-04', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0122 (2026-07-04 08:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0122', 1, 0, @c_juan, '2026-07-04 08:37:00', '2026-07-04', '2026-07-04', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0122', 1, '2026-07-04', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2607-0123 (2026-07-04 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0123', 1, 0, @c_juan, '2026-07-04 09:25:00', '2026-07-04', '2026-07-04', 1, 88.0, 0, 88.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0123', 1, '2026-07-04', 88.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 88.0);

-- Venta FA2607-0124 (2026-07-04 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0124', 1, 0, @c_mostrador, '2026-07-04 10:59:00', '2026-07-04', '2026-07-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0124', 1, '2026-07-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0125 (2026-07-04 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0125', 1, 0, @c_mostrador, '2026-07-04 10:06:00', '2026-07-04', '2026-07-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0125', 1, '2026-07-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0126 (2026-07-04 10:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0126', 1, 0, @c_maria, '2026-07-04 10:44:00', '2026-07-04', '2026-07-04', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0126', 1, '2026-07-04', 60.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 60.0);

-- Venta FA2607-0127 (2026-07-04 09:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0127', 1, 0, @c_juan, '2026-07-04 09:38:00', '2026-07-04', '2026-07-04', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0127', 1, '2026-07-04', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0128 (2026-07-04 10:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0128', 1, 0, @c_maria, '2026-07-04 10:23:00', '2026-07-04', '2026-07-04', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0128', 1, '2026-07-04', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2607-0129 (2026-07-04 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0129', 1, 0, @c_maria, '2026-07-04 09:52:00', '2026-07-04', '2026-07-04', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0129', 1, '2026-07-04', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0130 (2026-07-04 09:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0130', 1, 0, @c_mostrador, '2026-07-04 09:02:00', '2026-07-04', '2026-07-04', 1, 102.0, 0, 102.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 6, 0, 30.0, 0, 30.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0130', 1, '2026-07-04', 102.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 102.0);

-- Venta FA2607-0131 (2026-07-04 09:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0131', 1, 0, @c_maria, '2026-07-04 09:51:00', '2026-07-04', '2026-07-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0131', 1, '2026-07-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0132 (2026-07-04 11:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0132', 1, 0, @c_mostrador, '2026-07-04 11:29:00', '2026-07-04', '2026-07-04', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0132', 1, '2026-07-04', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0133 (2026-07-04 08:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0133', 1, 0, @c_juan, '2026-07-04 08:57:00', '2026-07-04', '2026-07-04', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0133', 1, '2026-07-04', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0134 (2026-07-04 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0134', 1, 0, @c_maria, '2026-07-04 10:37:00', '2026-07-04', '2026-07-04', 1, 102.0, 0, 102.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0134', 1, '2026-07-04', 102.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 102.0);

-- Venta FA2607-0135 (2026-07-04 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0135', 1, 0, @c_mostrador, '2026-07-04 10:46:00', '2026-07-04', '2026-07-04', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0135', 1, '2026-07-04', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0136 (2026-07-04 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0136', 1, 0, @c_mostrador, '2026-07-04 10:04:00', '2026-07-04', '2026-07-04', 1, 85.0, 0, 85.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0136', 1, '2026-07-04', 85.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 85.0);

-- Venta FA2607-0137 (2026-07-04 11:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0137', 1, 0, @c_mostrador, '2026-07-04 11:11:00', '2026-07-04', '2026-07-04', 1, 66.0, 0, 66.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0137', 1, '2026-07-04', 66.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 66.0);

-- Venta FA2607-0138 (2026-07-05 09:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0138', 1, 0, @c_mostrador, '2026-07-05 09:29:00', '2026-07-05', '2026-07-05', 1, 68.0, 0, 68.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0138', 1, '2026-07-05', 68.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 68.0);

-- Venta FA2607-0139 (2026-07-05 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0139', 1, 0, @c_mostrador, '2026-07-05 10:46:00', '2026-07-05', '2026-07-05', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0139', 1, '2026-07-05', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0140 (2026-07-05 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0140', 1, 0, @c_mostrador, '2026-07-05 09:43:00', '2026-07-05', '2026-07-05', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0140', 1, '2026-07-05', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0141 (2026-07-05 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0141', 1, 0, @c_mostrador, '2026-07-05 10:06:00', '2026-07-05', '2026-07-05', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0141', 1, '2026-07-05', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0142 (2026-07-05 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0142', 1, 0, @c_mostrador, '2026-07-05 10:14:00', '2026-07-05', '2026-07-05', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0142', 1, '2026-07-05', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0143 (2026-07-05 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0143', 1, 0, @c_mostrador, '2026-07-05 09:34:00', '2026-07-05', '2026-07-05', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0143', 1, '2026-07-05', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0144 (2026-07-05 11:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0144', 1, 0, @c_mostrador, '2026-07-05 11:45:00', '2026-07-05', '2026-07-05', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0144', 1, '2026-07-05', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0145 (2026-07-05 08:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0145', 1, 0, @c_mostrador, '2026-07-05 08:09:00', '2026-07-05', '2026-07-05', 1, 94.0, 0, 94.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0145', 1, '2026-07-05', 94.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 94.0);

-- Venta FA2607-0146 (2026-07-05 10:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0146', 1, 0, @c_juan, '2026-07-05 10:48:00', '2026-07-05', '2026-07-05', 1, 80.0, 0, 80.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0146', 1, '2026-07-05', 80.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 80.0);

-- Venta FA2607-0147 (2026-07-05 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0147', 1, 0, @c_mostrador, '2026-07-05 10:49:00', '2026-07-05', '2026-07-05', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0147', 1, '2026-07-05', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0148 (2026-07-05 08:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0148', 1, 0, @c_juan, '2026-07-05 08:23:00', '2026-07-05', '2026-07-05', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0148', 1, '2026-07-05', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0149 (2026-07-05 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0149', 1, 0, @c_mostrador, '2026-07-05 10:21:00', '2026-07-05', '2026-07-05', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0149', 1, '2026-07-05', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0150 (2026-07-05 08:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0150', 1, 0, @c_mostrador, '2026-07-05 08:03:00', '2026-07-05', '2026-07-05', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0150', 1, '2026-07-05', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0151 (2026-07-05 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0151', 1, 0, @c_mostrador, '2026-07-05 09:25:00', '2026-07-05', '2026-07-05', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0151', 1, '2026-07-05', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0152 (2026-07-05 09:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0152', 1, 0, @c_mostrador, '2026-07-05 09:01:00', '2026-07-05', '2026-07-05', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0152', 1, '2026-07-05', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0153 (2026-07-05 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0153', 1, 0, @c_juan, '2026-07-05 09:13:00', '2026-07-05', '2026-07-05', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0153', 1, '2026-07-05', 84.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 84.0);

-- Venta FA2607-0154 (2026-07-05 08:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0154', 1, 0, @c_mostrador, '2026-07-05 08:39:00', '2026-07-05', '2026-07-05', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0154', 1, '2026-07-05', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2607-0155 (2026-07-05 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0155', 1, 0, @c_maria, '2026-07-05 09:22:00', '2026-07-05', '2026-07-05', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0155', 1, '2026-07-05', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);
-- Compra de insumos: SI2607-0102 (2026-07-06)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0102', 'FAC-PROV-102', 1, 0, @p_carne, '2026-07-06 08:00:00', '2026-07-06', '2026-07-06', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0102', 1, '2026-07-06', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0156 (2026-07-06 09:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0156', 1, 0, @c_mostrador, '2026-07-06 09:54:00', '2026-07-06', '2026-07-06', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0156', 1, '2026-07-06', 58.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 58.0);

-- Venta FA2607-0157 (2026-07-06 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0157', 1, 0, @c_mostrador, '2026-07-06 09:24:00', '2026-07-06', '2026-07-06', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0157', 1, '2026-07-06', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2607-0158 (2026-07-07 08:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0158', 1, 0, @c_mostrador, '2026-07-07 08:39:00', '2026-07-07', '2026-07-07', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0158', 1, '2026-07-07', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0159 (2026-07-07 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0159', 1, 0, @c_mostrador, '2026-07-07 09:21:00', '2026-07-07', '2026-07-07', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0159', 1, '2026-07-07', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0160 (2026-07-07 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0160', 1, 0, @c_mostrador, '2026-07-07 09:53:00', '2026-07-07', '2026-07-07', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0160', 1, '2026-07-07', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0161 (2026-07-08 11:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0161', 1, 0, @c_mostrador, '2026-07-08 11:21:00', '2026-07-08', '2026-07-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0161', 1, '2026-07-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0162 (2026-07-08 08:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0162', 1, 0, @c_mostrador, '2026-07-08 08:18:00', '2026-07-08', '2026-07-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0162', 1, '2026-07-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0163 (2026-07-08 09:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0163', 1, 0, @c_mostrador, '2026-07-08 09:26:00', '2026-07-08', '2026-07-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0163', 1, '2026-07-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0164 (2026-07-08 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0164', 1, 0, @c_mostrador, '2026-07-08 09:49:00', '2026-07-08', '2026-07-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0164', 1, '2026-07-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0165 (2026-07-08 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0165', 1, 0, @c_mostrador, '2026-07-08 10:49:00', '2026-07-08', '2026-07-08', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0165', 1, '2026-07-08', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0166 (2026-07-08 10:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0166', 1, 0, @c_mostrador, '2026-07-08 10:36:00', '2026-07-08', '2026-07-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0166', 1, '2026-07-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0167 (2026-07-09 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0167', 1, 0, @c_mostrador, '2026-07-09 10:24:00', '2026-07-09', '2026-07-09', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0167', 1, '2026-07-09', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0168 (2026-07-09 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0168', 1, 0, @c_mostrador, '2026-07-09 10:47:00', '2026-07-09', '2026-07-09', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0168', 1, '2026-07-09', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0169 (2026-07-09 08:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0169', 1, 0, @c_mostrador, '2026-07-09 08:59:00', '2026-07-09', '2026-07-09', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0169', 1, '2026-07-09', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0170 (2026-07-09 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0170', 1, 0, @c_maria, '2026-07-09 09:00:00', '2026-07-09', '2026-07-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0170', 1, '2026-07-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0171 (2026-07-09 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0171', 1, 0, @c_mostrador, '2026-07-09 10:50:00', '2026-07-09', '2026-07-09', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0171', 1, '2026-07-09', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta B2B Institucional: FA2607-0172 (2026-07-10)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0172', 1, 0, @c_san_agustin, '2026-07-10 09:15:00', '2026-07-10', '2026-07-10', 1, 744.0, 0, 744.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 50, 0, 400.0, 0, 400.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 43, 0, 344.0, 0, 344.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0172', 1, '2026-07-10', 744.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 744.0);

-- Venta FA2607-0173 (2026-07-10 08:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0173', 1, 0, @c_mostrador, '2026-07-10 08:57:00', '2026-07-10', '2026-07-10', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0173', 1, '2026-07-10', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0174 (2026-07-10 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0174', 1, 0, @c_juan, '2026-07-10 10:10:00', '2026-07-10', '2026-07-10', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0174', 1, '2026-07-10', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2607-0175 (2026-07-10 10:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0175', 1, 0, @c_juan, '2026-07-10 10:03:00', '2026-07-10', '2026-07-10', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0175', 1, '2026-07-10', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0176 (2026-07-10 11:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0176', 1, 0, @c_juan, '2026-07-10 11:38:00', '2026-07-10', '2026-07-10', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0176', 1, '2026-07-10', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0177 (2026-07-10 11:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0177', 1, 0, @c_juan, '2026-07-10 11:46:00', '2026-07-10', '2026-07-10', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0177', 1, '2026-07-10', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0178 (2026-07-10 10:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0178', 1, 0, @c_mostrador, '2026-07-10 10:12:00', '2026-07-10', '2026-07-10', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0178', 1, '2026-07-10', 35.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 35.0);

-- Venta FA2607-0179 (2026-07-10 10:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0179', 1, 0, @c_mostrador, '2026-07-10 10:29:00', '2026-07-10', '2026-07-10', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0179', 1, '2026-07-10', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0180 (2026-07-10 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0180', 1, 0, @c_mostrador, '2026-07-10 09:25:00', '2026-07-10', '2026-07-10', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0180', 1, '2026-07-10', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);
-- Compra de insumos: SI2607-0103 (2026-07-11)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0103', 'FAC-PROV-103', 1, 0, @p_carne, '2026-07-11 08:00:00', '2026-07-11', '2026-07-11', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0103', 1, '2026-07-11', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0181 (2026-07-11 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0181', 1, 0, @c_mostrador, '2026-07-11 09:44:00', '2026-07-11', '2026-07-11', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0181', 1, '2026-07-11', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0182 (2026-07-11 08:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0182', 1, 0, @c_mostrador, '2026-07-11 08:35:00', '2026-07-11', '2026-07-11', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0182', 1, '2026-07-11', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2607-0183 (2026-07-11 08:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0183', 1, 0, @c_mostrador, '2026-07-11 08:54:00', '2026-07-11', '2026-07-11', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0183', 1, '2026-07-11', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0184 (2026-07-11 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0184', 1, 0, @c_mostrador, '2026-07-11 09:40:00', '2026-07-11', '2026-07-11', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0184', 1, '2026-07-11', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0185 (2026-07-11 09:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0185', 1, 0, @c_mostrador, '2026-07-11 09:27:00', '2026-07-11', '2026-07-11', 1, 78.0, 0, 78.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0185', 1, '2026-07-11', 78.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 78.0);

-- Venta FA2607-0186 (2026-07-11 11:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0186', 1, 0, @c_maria, '2026-07-11 11:19:00', '2026-07-11', '2026-07-11', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0186', 1, '2026-07-11', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0187 (2026-07-11 10:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0187', 1, 0, @c_maria, '2026-07-11 10:01:00', '2026-07-11', '2026-07-11', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0187', 1, '2026-07-11', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0188 (2026-07-11 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0188', 1, 0, @c_mostrador, '2026-07-11 09:35:00', '2026-07-11', '2026-07-11', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0188', 1, '2026-07-11', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0189 (2026-07-11 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0189', 1, 0, @c_mostrador, '2026-07-11 09:56:00', '2026-07-11', '2026-07-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0189', 1, '2026-07-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0190 (2026-07-11 08:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0190', 1, 0, @c_mostrador, '2026-07-11 08:39:00', '2026-07-11', '2026-07-11', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0190', 1, '2026-07-11', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0191 (2026-07-11 09:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0191', 1, 0, @c_mostrador, '2026-07-11 09:46:00', '2026-07-11', '2026-07-11', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0191', 1, '2026-07-11', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0192 (2026-07-11 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0192', 1, 0, @c_mostrador, '2026-07-11 09:50:00', '2026-07-11', '2026-07-11', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0192', 1, '2026-07-11', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2607-0193 (2026-07-11 09:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0193', 1, 0, @c_mostrador, '2026-07-11 09:18:00', '2026-07-11', '2026-07-11', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0193', 1, '2026-07-11', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0194 (2026-07-11 09:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0194', 1, 0, @c_mostrador, '2026-07-11 09:10:00', '2026-07-11', '2026-07-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0194', 1, '2026-07-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0195 (2026-07-11 09:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0195', 1, 0, @c_mostrador, '2026-07-11 09:04:00', '2026-07-11', '2026-07-11', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0195', 1, '2026-07-11', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2607-0196 (2026-07-12 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0196', 1, 0, @c_mostrador, '2026-07-12 09:57:00', '2026-07-12', '2026-07-12', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0196', 1, '2026-07-12', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0197 (2026-07-12 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0197', 1, 0, @c_juan, '2026-07-12 09:48:00', '2026-07-12', '2026-07-12', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0197', 1, '2026-07-12', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0198 (2026-07-12 10:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0198', 1, 0, @c_mostrador, '2026-07-12 10:28:00', '2026-07-12', '2026-07-12', 1, 80.0, 0, 80.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0198', 1, '2026-07-12', 80.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 80.0);

-- Venta FA2607-0199 (2026-07-12 09:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0199', 1, 0, @c_juan, '2026-07-12 09:32:00', '2026-07-12', '2026-07-12', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0199', 1, '2026-07-12', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0200 (2026-07-12 09:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0200', 1, 0, @c_maria, '2026-07-12 09:19:00', '2026-07-12', '2026-07-12', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0200', 1, '2026-07-12', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0201 (2026-07-12 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0201', 1, 0, @c_mostrador, '2026-07-12 10:24:00', '2026-07-12', '2026-07-12', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0201', 1, '2026-07-12', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0202 (2026-07-12 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0202', 1, 0, @c_mostrador, '2026-07-12 09:16:00', '2026-07-12', '2026-07-12', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0202', 1, '2026-07-12', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0203 (2026-07-12 09:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0203', 1, 0, @c_maria, '2026-07-12 09:11:00', '2026-07-12', '2026-07-12', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0203', 1, '2026-07-12', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2607-0204 (2026-07-12 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0204', 1, 0, @c_mostrador, '2026-07-12 09:37:00', '2026-07-12', '2026-07-12', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0204', 1, '2026-07-12', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0205 (2026-07-12 10:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0205', 1, 0, @c_mostrador, '2026-07-12 10:44:00', '2026-07-12', '2026-07-12', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0205', 1, '2026-07-12', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0206 (2026-07-12 10:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0206', 1, 0, @c_mostrador, '2026-07-12 10:15:00', '2026-07-12', '2026-07-12', 1, 77.0, 0, 77.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0206', 1, '2026-07-12', 77.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 77.0);

-- Venta FA2607-0207 (2026-07-12 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0207', 1, 0, @c_juan, '2026-07-12 10:46:00', '2026-07-12', '2026-07-12', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0207', 1, '2026-07-12', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0208 (2026-07-12 08:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0208', 1, 0, @c_mostrador, '2026-07-12 08:43:00', '2026-07-12', '2026-07-12', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0208', 1, '2026-07-12', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0209 (2026-07-12 10:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0209', 1, 0, @c_juan, '2026-07-12 10:23:00', '2026-07-12', '2026-07-12', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0209', 1, '2026-07-12', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0210 (2026-07-12 10:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0210', 1, 0, @c_mostrador, '2026-07-12 10:11:00', '2026-07-12', '2026-07-12', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0210', 1, '2026-07-12', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2607-0211 (2026-07-12 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0211', 1, 0, @c_mostrador, '2026-07-12 09:31:00', '2026-07-12', '2026-07-12', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0211', 1, '2026-07-12', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2607-0212 (2026-07-13 09:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0212', 1, 0, @c_mostrador, '2026-07-13 09:32:00', '2026-07-13', '2026-07-13', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0212', 1, '2026-07-13', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0213 (2026-07-13 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0213', 1, 0, @c_mostrador, '2026-07-13 09:35:00', '2026-07-13', '2026-07-13', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0213', 1, '2026-07-13', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0214 (2026-07-13 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0214', 1, 0, @c_maria, '2026-07-13 09:14:00', '2026-07-13', '2026-07-13', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0214', 1, '2026-07-13', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2607-0215 (2026-07-14 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0215', 1, 0, @c_juan, '2026-07-14 09:34:00', '2026-07-14', '2026-07-14', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0215', 1, '2026-07-14', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0216 (2026-07-14 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0216', 1, 0, @c_mostrador, '2026-07-14 09:09:00', '2026-07-14', '2026-07-14', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0216', 1, '2026-07-14', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2607-0217 (2026-07-15 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0217', 1, 0, @c_mostrador, '2026-07-15 09:24:00', '2026-07-15', '2026-07-15', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0217', 1, '2026-07-15', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0218 (2026-07-15 10:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0218', 1, 0, @c_mostrador, '2026-07-15 10:45:00', '2026-07-15', '2026-07-15', 1, 37.0, 0, 37.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0218', 1, '2026-07-15', 37.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 37.0);

-- Venta FA2607-0219 (2026-07-15 08:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0219', 1, 0, @c_mostrador, '2026-07-15 08:35:00', '2026-07-15', '2026-07-15', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0219', 1, '2026-07-15', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0220 (2026-07-15 08:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0220', 1, 0, @c_mostrador, '2026-07-15 08:22:00', '2026-07-15', '2026-07-15', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0220', 1, '2026-07-15', 35.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 35.0);
-- Compra de insumos: SI2607-0104 (2026-07-16)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0104', 'FAC-PROV-104', 1, 0, @p_carne, '2026-07-16 08:00:00', '2026-07-16', '2026-07-16', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0104', 1, '2026-07-16', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0221 (2026-07-16 08:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0221', 1, 0, @c_juan, '2026-07-16 08:42:00', '2026-07-16', '2026-07-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0221', 1, '2026-07-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0222 (2026-07-16 09:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0222', 1, 0, @c_mostrador, '2026-07-16 09:01:00', '2026-07-16', '2026-07-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0222', 1, '2026-07-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0223 (2026-07-16 08:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0223', 1, 0, @c_mostrador, '2026-07-16 08:18:00', '2026-07-16', '2026-07-16', 1, 23.0, 0, 23.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0223', 1, '2026-07-16', 23.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 23.0);

-- Venta FA2607-0224 (2026-07-16 10:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0224', 1, 0, @c_mostrador, '2026-07-16 10:43:00', '2026-07-16', '2026-07-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0224', 1, '2026-07-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0225 (2026-07-16 10:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0225', 1, 0, @c_mostrador, '2026-07-16 10:42:00', '2026-07-16', '2026-07-16', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0225', 1, '2026-07-16', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0226 (2026-07-16 10:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0226', 1, 0, @c_mostrador, '2026-07-16 10:29:00', '2026-07-16', '2026-07-16', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0226', 1, '2026-07-16', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0227 (2026-07-16 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0227', 1, 0, @c_mostrador, '2026-07-16 09:07:00', '2026-07-16', '2026-07-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0227', 1, '2026-07-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0228 (2026-07-17 10:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0228', 1, 0, @c_juan, '2026-07-17 10:31:00', '2026-07-17', '2026-07-17', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0228', 1, '2026-07-17', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0229 (2026-07-17 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0229', 1, 0, @c_juan, '2026-07-17 09:16:00', '2026-07-17', '2026-07-17', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0229', 1, '2026-07-17', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0230 (2026-07-17 11:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0230', 1, 0, @c_mostrador, '2026-07-17 11:47:00', '2026-07-17', '2026-07-17', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0230', 1, '2026-07-17', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0231 (2026-07-17 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0231', 1, 0, @c_mostrador, '2026-07-17 09:37:00', '2026-07-17', '2026-07-17', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0231', 1, '2026-07-17', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0232 (2026-07-17 08:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0232', 1, 0, @c_mostrador, '2026-07-17 08:58:00', '2026-07-17', '2026-07-17', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0232', 1, '2026-07-17', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0233 (2026-07-17 09:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0233', 1, 0, @c_mostrador, '2026-07-17 09:23:00', '2026-07-17', '2026-07-17', 1, 66.0, 0, 66.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0233', 1, '2026-07-17', 66.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 66.0);

-- Venta FA2607-0234 (2026-07-17 10:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0234', 1, 0, @c_mostrador, '2026-07-17 10:07:00', '2026-07-17', '2026-07-17', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0234', 1, '2026-07-17', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0235 (2026-07-17 11:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0235', 1, 0, @c_maria, '2026-07-17 11:09:00', '2026-07-17', '2026-07-17', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0235', 1, '2026-07-17', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0236 (2026-07-17 09:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0236', 1, 0, @c_mostrador, '2026-07-17 09:01:00', '2026-07-17', '2026-07-17', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0236', 1, '2026-07-17', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0237 (2026-07-17 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0237', 1, 0, @c_mostrador, '2026-07-17 09:16:00', '2026-07-17', '2026-07-17', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0237', 1, '2026-07-17', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0238 (2026-07-18 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0238', 1, 0, @c_mostrador, '2026-07-18 10:17:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0238', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0239 (2026-07-18 11:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0239', 1, 0, @c_mostrador, '2026-07-18 11:10:00', '2026-07-18', '2026-07-18', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0239', 1, '2026-07-18', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2607-0240 (2026-07-18 10:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0240', 1, 0, @c_mostrador, '2026-07-18 10:07:00', '2026-07-18', '2026-07-18', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0240', 1, '2026-07-18', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0241 (2026-07-18 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0241', 1, 0, @c_juan, '2026-07-18 09:20:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0241', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0242 (2026-07-18 10:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0242', 1, 0, @c_mostrador, '2026-07-18 10:53:00', '2026-07-18', '2026-07-18', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0242', 1, '2026-07-18', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0243 (2026-07-18 09:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0243', 1, 0, @c_mostrador, '2026-07-18 09:12:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0243', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0244 (2026-07-18 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0244', 1, 0, @c_maria, '2026-07-18 09:22:00', '2026-07-18', '2026-07-18', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0244', 1, '2026-07-18', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0245 (2026-07-18 08:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0245', 1, 0, @c_mostrador, '2026-07-18 08:28:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0245', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0246 (2026-07-18 09:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0246', 1, 0, @c_mostrador, '2026-07-18 09:04:00', '2026-07-18', '2026-07-18', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0246', 1, '2026-07-18', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0247 (2026-07-18 09:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0247', 1, 0, @c_maria, '2026-07-18 09:18:00', '2026-07-18', '2026-07-18', 1, 79.0, 0, 79.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0247', 1, '2026-07-18', 79.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 79.0);

-- Venta FA2607-0248 (2026-07-18 09:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0248', 1, 0, @c_mostrador, '2026-07-18 09:12:00', '2026-07-18', '2026-07-18', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0248', 1, '2026-07-18', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0249 (2026-07-18 10:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0249', 1, 0, @c_juan, '2026-07-18 10:56:00', '2026-07-18', '2026-07-18', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0249', 1, '2026-07-18', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0250 (2026-07-18 08:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0250', 1, 0, @c_juan, '2026-07-18 08:58:00', '2026-07-18', '2026-07-18', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0250', 1, '2026-07-18', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0251 (2026-07-18 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0251', 1, 0, @c_mostrador, '2026-07-18 10:46:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0251', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0252 (2026-07-18 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0252', 1, 0, @c_mostrador, '2026-07-18 09:20:00', '2026-07-18', '2026-07-18', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0252', 1, '2026-07-18', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0253 (2026-07-18 11:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0253', 1, 0, @c_mostrador, '2026-07-18 11:33:00', '2026-07-18', '2026-07-18', 1, 85.0, 0, 85.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0253', 1, '2026-07-18', 85.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 85.0);

-- Venta FA2607-0254 (2026-07-18 08:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0254', 1, 0, @c_maria, '2026-07-18 08:43:00', '2026-07-18', '2026-07-18', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0254', 1, '2026-07-18', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0255 (2026-07-19 11:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0255', 1, 0, @c_mostrador, '2026-07-19 11:59:00', '2026-07-19', '2026-07-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0255', 1, '2026-07-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0256 (2026-07-19 11:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0256', 1, 0, @c_maria, '2026-07-19 11:14:00', '2026-07-19', '2026-07-19', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0256', 1, '2026-07-19', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0257 (2026-07-19 10:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0257', 1, 0, @c_mostrador, '2026-07-19 10:09:00', '2026-07-19', '2026-07-19', 1, 96.0, 0, 96.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0257', 1, '2026-07-19', 96.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 96.0);

-- Venta FA2607-0258 (2026-07-19 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0258', 1, 0, @c_mostrador, '2026-07-19 09:13:00', '2026-07-19', '2026-07-19', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0258', 1, '2026-07-19', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2607-0259 (2026-07-19 09:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0259', 1, 0, @c_juan, '2026-07-19 09:42:00', '2026-07-19', '2026-07-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0259', 1, '2026-07-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0260 (2026-07-19 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0260', 1, 0, @c_mostrador, '2026-07-19 10:10:00', '2026-07-19', '2026-07-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0260', 1, '2026-07-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0261 (2026-07-19 08:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0261', 1, 0, @c_maria, '2026-07-19 08:13:00', '2026-07-19', '2026-07-19', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0261', 1, '2026-07-19', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0262 (2026-07-19 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0262', 1, 0, @c_mostrador, '2026-07-19 09:57:00', '2026-07-19', '2026-07-19', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0262', 1, '2026-07-19', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2607-0263 (2026-07-19 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0263', 1, 0, @c_mostrador, '2026-07-19 09:37:00', '2026-07-19', '2026-07-19', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0263', 1, '2026-07-19', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0264 (2026-07-19 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0264', 1, 0, @c_mostrador, '2026-07-19 10:33:00', '2026-07-19', '2026-07-19', 1, 70.0, 0, 70.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0264', 1, '2026-07-19', 70.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 70.0);

-- Venta FA2607-0265 (2026-07-19 11:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0265', 1, 0, @c_mostrador, '2026-07-19 11:20:00', '2026-07-19', '2026-07-19', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0265', 1, '2026-07-19', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0266 (2026-07-19 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0266', 1, 0, @c_maria, '2026-07-19 09:41:00', '2026-07-19', '2026-07-19', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0266', 1, '2026-07-19', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0267 (2026-07-20 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0267', 1, 0, @c_maria, '2026-07-20 09:34:00', '2026-07-20', '2026-07-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0267', 1, '2026-07-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0268 (2026-07-20 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0268', 1, 0, @c_mostrador, '2026-07-20 10:17:00', '2026-07-20', '2026-07-20', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0268', 1, '2026-07-20', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0269 (2026-07-20 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0269', 1, 0, @c_mostrador, '2026-07-20 09:13:00', '2026-07-20', '2026-07-20', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0269', 1, '2026-07-20', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0270 (2026-07-20 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0270', 1, 0, @c_mostrador, '2026-07-20 09:56:00', '2026-07-20', '2026-07-20', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0270', 1, '2026-07-20', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);
-- Compra de insumos: SI2607-0105 (2026-07-21)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0105', 'FAC-PROV-105', 1, 0, @p_carne, '2026-07-21 08:00:00', '2026-07-21', '2026-07-21', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0105', 1, '2026-07-21', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0271 (2026-07-21 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0271', 1, 0, @c_mostrador, '2026-07-21 10:46:00', '2026-07-21', '2026-07-21', 1, 33.0, 0, 33.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0271', 1, '2026-07-21', 33.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 33.0);

-- Venta FA2607-0272 (2026-07-21 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0272', 1, 0, @c_mostrador, '2026-07-21 10:33:00', '2026-07-21', '2026-07-21', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0272', 1, '2026-07-21', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2607-0273 (2026-07-21 10:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0273', 1, 0, @c_mostrador, '2026-07-21 10:53:00', '2026-07-21', '2026-07-21', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0273', 1, '2026-07-21', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0274 (2026-07-22 11:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0274', 1, 0, @c_mostrador, '2026-07-22 11:30:00', '2026-07-22', '2026-07-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0274', 1, '2026-07-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0275 (2026-07-22 11:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0275', 1, 0, @c_mostrador, '2026-07-22 11:49:00', '2026-07-22', '2026-07-22', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0275', 1, '2026-07-22', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0276 (2026-07-22 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0276', 1, 0, @c_mostrador, '2026-07-22 10:39:00', '2026-07-22', '2026-07-22', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0276', 1, '2026-07-22', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0277 (2026-07-22 11:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0277', 1, 0, @c_juan, '2026-07-22 11:07:00', '2026-07-22', '2026-07-22', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0277', 1, '2026-07-22', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2607-0278 (2026-07-22 10:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0278', 1, 0, @c_mostrador, '2026-07-22 10:56:00', '2026-07-22', '2026-07-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0278', 1, '2026-07-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0279 (2026-07-22 10:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0279', 1, 0, @c_maria, '2026-07-22 10:45:00', '2026-07-22', '2026-07-22', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0279', 1, '2026-07-22', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0280 (2026-07-22 09:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0280', 1, 0, @c_juan, '2026-07-22 09:27:00', '2026-07-22', '2026-07-22', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0280', 1, '2026-07-22', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0281 (2026-07-23 08:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0281', 1, 0, @c_mostrador, '2026-07-23 08:52:00', '2026-07-23', '2026-07-23', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0281', 1, '2026-07-23', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0282 (2026-07-23 10:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0282', 1, 0, @c_mostrador, '2026-07-23 10:35:00', '2026-07-23', '2026-07-23', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0282', 1, '2026-07-23', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0283 (2026-07-23 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0283', 1, 0, @c_mostrador, '2026-07-23 10:39:00', '2026-07-23', '2026-07-23', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0283', 1, '2026-07-23', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0284 (2026-07-23 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0284', 1, 0, @c_mostrador, '2026-07-23 10:04:00', '2026-07-23', '2026-07-23', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0284', 1, '2026-07-23', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2607-0285 (2026-07-24 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0285', 1, 0, @c_mostrador, '2026-07-24 09:22:00', '2026-07-24', '2026-07-24', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0285', 1, '2026-07-24', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0286 (2026-07-24 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0286', 1, 0, @c_mostrador, '2026-07-24 10:59:00', '2026-07-24', '2026-07-24', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0286', 1, '2026-07-24', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0287 (2026-07-24 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0287', 1, 0, @c_mostrador, '2026-07-24 09:40:00', '2026-07-24', '2026-07-24', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0287', 1, '2026-07-24', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0288 (2026-07-24 09:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0288', 1, 0, @c_mostrador, '2026-07-24 09:26:00', '2026-07-24', '2026-07-24', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0288', 1, '2026-07-24', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0289 (2026-07-24 09:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0289', 1, 0, @c_mostrador, '2026-07-24 09:02:00', '2026-07-24', '2026-07-24', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0289', 1, '2026-07-24', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0290 (2026-07-24 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0290', 1, 0, @c_juan, '2026-07-24 09:07:00', '2026-07-24', '2026-07-24', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0290', 1, '2026-07-24', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0291 (2026-07-24 08:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0291', 1, 0, @c_mostrador, '2026-07-24 08:11:00', '2026-07-24', '2026-07-24', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0291', 1, '2026-07-24', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0292 (2026-07-25 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0292', 1, 0, @c_mostrador, '2026-07-25 09:05:00', '2026-07-25', '2026-07-25', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0292', 1, '2026-07-25', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0293 (2026-07-25 10:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0293', 1, 0, @c_mostrador, '2026-07-25 10:30:00', '2026-07-25', '2026-07-25', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0293', 1, '2026-07-25', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0294 (2026-07-25 09:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0294', 1, 0, @c_mostrador, '2026-07-25 09:12:00', '2026-07-25', '2026-07-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0294', 1, '2026-07-25', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0295 (2026-07-25 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0295', 1, 0, @c_juan, '2026-07-25 09:05:00', '2026-07-25', '2026-07-25', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0295', 1, '2026-07-25', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2607-0296 (2026-07-25 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0296', 1, 0, @c_mostrador, '2026-07-25 10:06:00', '2026-07-25', '2026-07-25', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0296', 1, '2026-07-25', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0297 (2026-07-25 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0297', 1, 0, @c_maria, '2026-07-25 09:52:00', '2026-07-25', '2026-07-25', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0297', 1, '2026-07-25', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2607-0298 (2026-07-25 09:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0298', 1, 0, @c_juan, '2026-07-25 09:01:00', '2026-07-25', '2026-07-25', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0298', 1, '2026-07-25', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0299 (2026-07-25 08:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0299', 1, 0, @c_maria, '2026-07-25 08:47:00', '2026-07-25', '2026-07-25', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0299', 1, '2026-07-25', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0300 (2026-07-25 10:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0300', 1, 0, @c_mostrador, '2026-07-25 10:58:00', '2026-07-25', '2026-07-25', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0300', 1, '2026-07-25', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0301 (2026-07-25 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0301', 1, 0, @c_mostrador, '2026-07-25 09:44:00', '2026-07-25', '2026-07-25', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0301', 1, '2026-07-25', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0302 (2026-07-25 08:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0302', 1, 0, @c_mostrador, '2026-07-25 08:12:00', '2026-07-25', '2026-07-25', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0302', 1, '2026-07-25', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2607-0303 (2026-07-25 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0303', 1, 0, @c_maria, '2026-07-25 09:36:00', '2026-07-25', '2026-07-25', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0303', 1, '2026-07-25', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0304 (2026-07-25 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0304', 1, 0, @c_mostrador, '2026-07-25 10:59:00', '2026-07-25', '2026-07-25', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0304', 1, '2026-07-25', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);
-- Compra de insumos: SI2607-0106 (2026-07-26)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2607-0106', 'FAC-PROV-106', 1, 0, @p_carne, '2026-07-26 08:00:00', '2026-07-26', '2026-07-26', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2607-0106', 1, '2026-07-26', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2607-0305 (2026-07-26 08:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0305', 1, 0, @c_juan, '2026-07-26 08:01:00', '2026-07-26', '2026-07-26', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0305', 1, '2026-07-26', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0306 (2026-07-26 10:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0306', 1, 0, @c_mostrador, '2026-07-26 10:08:00', '2026-07-26', '2026-07-26', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0306', 1, '2026-07-26', 75.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 75.0);

-- Venta FA2607-0307 (2026-07-26 11:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0307', 1, 0, @c_mostrador, '2026-07-26 11:19:00', '2026-07-26', '2026-07-26', 1, 76.0, 0, 76.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0307', 1, '2026-07-26', 76.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 76.0);

-- Venta FA2607-0308 (2026-07-26 08:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0308', 1, 0, @c_maria, '2026-07-26 08:09:00', '2026-07-26', '2026-07-26', 1, 61.0, 0, 61.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0308', 1, '2026-07-26', 61.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 61.0);

-- Venta FA2607-0309 (2026-07-26 08:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0309', 1, 0, @c_mostrador, '2026-07-26 08:41:00', '2026-07-26', '2026-07-26', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0309', 1, '2026-07-26', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0310 (2026-07-26 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0310', 1, 0, @c_mostrador, '2026-07-26 09:41:00', '2026-07-26', '2026-07-26', 1, 96.0, 0, 96.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0310', 1, '2026-07-26', 96.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 96.0);

-- Venta FA2607-0311 (2026-07-26 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0311', 1, 0, @c_juan, '2026-07-26 09:00:00', '2026-07-26', '2026-07-26', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0311', 1, '2026-07-26', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0312 (2026-07-26 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0312', 1, 0, @c_mostrador, '2026-07-26 09:17:00', '2026-07-26', '2026-07-26', 1, 93.0, 0, 93.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0312', 1, '2026-07-26', 93.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 93.0);

-- Venta FA2607-0313 (2026-07-26 08:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0313', 1, 0, @c_mostrador, '2026-07-26 08:27:00', '2026-07-26', '2026-07-26', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0313', 1, '2026-07-26', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2607-0314 (2026-07-26 08:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0314', 1, 0, @c_maria, '2026-07-26 08:13:00', '2026-07-26', '2026-07-26', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0314', 1, '2026-07-26', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2607-0315 (2026-07-26 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0315', 1, 0, @c_mostrador, '2026-07-26 09:55:00', '2026-07-26', '2026-07-26', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 4, 0, 20.0, 0, 20.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0315', 1, '2026-07-26', 60.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 60.0);

-- Venta FA2607-0316 (2026-07-26 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0316', 1, 0, @c_mostrador, '2026-07-26 09:55:00', '2026-07-26', '2026-07-26', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0316', 1, '2026-07-26', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0317 (2026-07-26 10:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0317', 1, 0, @c_juan, '2026-07-26 10:32:00', '2026-07-26', '2026-07-26', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0317', 1, '2026-07-26', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2607-0318 (2026-07-26 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0318', 1, 0, @c_maria, '2026-07-26 09:49:00', '2026-07-26', '2026-07-26', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0318', 1, '2026-07-26', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0319 (2026-07-26 08:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0319', 1, 0, @c_juan, '2026-07-26 08:47:00', '2026-07-26', '2026-07-26', 1, 59.0, 0, 59.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0319', 1, '2026-07-26', 59.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 59.0);

-- Venta FA2607-0320 (2026-07-27 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0320', 1, 0, @c_mostrador, '2026-07-27 09:07:00', '2026-07-27', '2026-07-27', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0320', 1, '2026-07-27', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0321 (2026-07-27 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0321', 1, 0, @c_mostrador, '2026-07-27 10:21:00', '2026-07-27', '2026-07-27', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0321', 1, '2026-07-27', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0322 (2026-07-27 10:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0322', 1, 0, @c_mostrador, '2026-07-27 10:53:00', '2026-07-27', '2026-07-27', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0322', 1, '2026-07-27', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2607-0323 (2026-07-28 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0323', 1, 0, @c_mostrador, '2026-07-28 09:21:00', '2026-07-28', '2026-07-28', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0323', 1, '2026-07-28', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0324 (2026-07-28 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0324', 1, 0, @c_juan, '2026-07-28 09:34:00', '2026-07-28', '2026-07-28', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0324', 1, '2026-07-28', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0325 (2026-07-28 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0325', 1, 0, @c_mostrador, '2026-07-28 09:43:00', '2026-07-28', '2026-07-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0325', 1, '2026-07-28', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0326 (2026-07-28 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0326', 1, 0, @c_maria, '2026-07-28 09:22:00', '2026-07-28', '2026-07-28', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0326', 1, '2026-07-28', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2607-0327 (2026-07-29 08:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0327', 1, 0, @c_maria, '2026-07-29 08:21:00', '2026-07-29', '2026-07-29', 1, 44.0, 0, 44.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0327', 1, '2026-07-29', 44.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 44.0);

-- Venta FA2607-0328 (2026-07-29 09:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0328', 1, 0, @c_mostrador, '2026-07-29 09:42:00', '2026-07-29', '2026-07-29', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0328', 1, '2026-07-29', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2607-0329 (2026-07-29 08:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0329', 1, 0, @c_mostrador, '2026-07-29 08:08:00', '2026-07-29', '2026-07-29', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0329', 1, '2026-07-29', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2607-0330 (2026-07-29 09:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0330', 1, 0, @c_juan, '2026-07-29 09:46:00', '2026-07-29', '2026-07-29', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0330', 1, '2026-07-29', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0331 (2026-07-29 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0331', 1, 0, @c_juan, '2026-07-29 09:21:00', '2026-07-29', '2026-07-29', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0331', 1, '2026-07-29', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2607-0332 (2026-07-29 11:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0332', 1, 0, @c_mostrador, '2026-07-29 11:14:00', '2026-07-29', '2026-07-29', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0332', 1, '2026-07-29', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0333 (2026-07-29 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0333', 1, 0, @c_mostrador, '2026-07-29 10:47:00', '2026-07-29', '2026-07-29', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0333', 1, '2026-07-29', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0334 (2026-07-30 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0334', 1, 0, @c_mostrador, '2026-07-30 09:35:00', '2026-07-30', '2026-07-30', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0334', 1, '2026-07-30', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0335 (2026-07-30 08:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0335', 1, 0, @c_maria, '2026-07-30 08:52:00', '2026-07-30', '2026-07-30', 1, 44.0, 0, 44.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0335', 1, '2026-07-30', 44.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 44.0);

-- Venta FA2607-0336 (2026-07-30 08:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0336', 1, 0, @c_mostrador, '2026-07-30 08:27:00', '2026-07-30', '2026-07-30', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0336', 1, '2026-07-30', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0337 (2026-07-30 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0337', 1, 0, @c_mostrador, '2026-07-30 09:16:00', '2026-07-30', '2026-07-30', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0337', 1, '2026-07-30', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0338 (2026-07-31 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0338', 1, 0, @c_mostrador, '2026-07-31 09:09:00', '2026-07-31', '2026-07-31', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0338', 1, '2026-07-31', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0339 (2026-07-31 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0339', 1, 0, @c_mostrador, '2026-07-31 10:55:00', '2026-07-31', '2026-07-31', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0339', 1, '2026-07-31', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2607-0340 (2026-07-31 09:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0340', 1, 0, @c_mostrador, '2026-07-31 09:01:00', '2026-07-31', '2026-07-31', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0340', 1, '2026-07-31', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2607-0341 (2026-07-31 10:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0341', 1, 0, @c_juan, '2026-07-31 10:23:00', '2026-07-31', '2026-07-31', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0341', 1, '2026-07-31', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0342 (2026-07-31 10:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0342', 1, 0, @c_juan, '2026-07-31 10:38:00', '2026-07-31', '2026-07-31', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0342', 1, '2026-07-31', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0343 (2026-07-31 08:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0343', 1, 0, @c_mostrador, '2026-07-31 08:55:00', '2026-07-31', '2026-07-31', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0343', 1, '2026-07-31', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2607-0344 (2026-07-31 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0344', 1, 0, @c_maria, '2026-07-31 09:22:00', '2026-07-31', '2026-07-31', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0344', 1, '2026-07-31', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0345 (2026-07-31 09:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0345', 1, 0, @c_juan, '2026-07-31 09:47:00', '2026-07-31', '2026-07-31', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0345', 1, '2026-07-31', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0346 (2026-07-31 08:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0346', 1, 0, @c_maria, '2026-07-31 08:19:00', '2026-07-31', '2026-07-31', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0346', 1, '2026-07-31', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2607-0347 (2026-07-31 08:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2607-0347', 1, 0, @c_mostrador, '2026-07-31 08:13:00', '2026-07-31', '2026-07-31', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2607-0347', 1, '2026-07-31', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);
-- Compra de insumos: SI2608-0107 (2026-08-01)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0107', 'FAC-PROV-107', 1, 0, @p_carne, '2026-08-01 08:00:00', '2026-08-01', '2026-08-01', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0107', 1, '2026-08-01', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0348 (2026-08-01 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0348', 1, 0, @c_mostrador, '2026-08-01 10:14:00', '2026-08-01', '2026-08-01', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0348', 1, '2026-08-01', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0349 (2026-08-01 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0349', 1, 0, @c_juan, '2026-08-01 10:14:00', '2026-08-01', '2026-08-01', 1, 110.0, 0, 110.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0349', 1, '2026-08-01', 110.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 110.0);

-- Venta FA2608-0350 (2026-08-01 10:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0350', 1, 0, @c_juan, '2026-08-01 10:42:00', '2026-08-01', '2026-08-01', 1, 102.0, 0, 102.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0350', 1, '2026-08-01', 102.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 102.0);

-- Venta FA2608-0351 (2026-08-01 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0351', 1, 0, @c_juan, '2026-08-01 09:56:00', '2026-08-01', '2026-08-01', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0351', 1, '2026-08-01', 60.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 60.0);

-- Venta FA2608-0352 (2026-08-01 09:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0352', 1, 0, @c_mostrador, '2026-08-01 09:38:00', '2026-08-01', '2026-08-01', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0352', 1, '2026-08-01', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0353 (2026-08-01 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0353', 1, 0, @c_maria, '2026-08-01 10:33:00', '2026-08-01', '2026-08-01', 1, 38.0, 0, 38.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0353', 1, '2026-08-01', 38.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 38.0);

-- Venta FA2608-0354 (2026-08-01 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0354', 1, 0, @c_maria, '2026-08-01 09:14:00', '2026-08-01', '2026-08-01', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0354', 1, '2026-08-01', 60.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 60.0);

-- Venta FA2608-0355 (2026-08-01 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0355', 1, 0, @c_mostrador, '2026-08-01 09:17:00', '2026-08-01', '2026-08-01', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0355', 1, '2026-08-01', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0356 (2026-08-01 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0356', 1, 0, @c_mostrador, '2026-08-01 09:49:00', '2026-08-01', '2026-08-01', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0356', 1, '2026-08-01', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2608-0357 (2026-08-01 08:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0357', 1, 0, @c_mostrador, '2026-08-01 08:56:00', '2026-08-01', '2026-08-01', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0357', 1, '2026-08-01', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2608-0358 (2026-08-01 08:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0358', 1, 0, @c_mostrador, '2026-08-01 08:48:00', '2026-08-01', '2026-08-01', 1, 102.0, 0, 102.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0358', 1, '2026-08-01', 102.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 102.0);

-- Venta FA2608-0359 (2026-08-01 10:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0359', 1, 0, @c_juan, '2026-08-01 10:43:00', '2026-08-01', '2026-08-01', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0359', 1, '2026-08-01', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2608-0360 (2026-08-01 11:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0360', 1, 0, @c_mostrador, '2026-08-01 11:56:00', '2026-08-01', '2026-08-01', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0360', 1, '2026-08-01', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0361 (2026-08-01 08:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0361', 1, 0, @c_juan, '2026-08-01 08:00:00', '2026-08-01', '2026-08-01', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0361', 1, '2026-08-01', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0362 (2026-08-02 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0362', 1, 0, @c_mostrador, '2026-08-02 10:55:00', '2026-08-02', '2026-08-02', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0362', 1, '2026-08-02', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0363 (2026-08-02 09:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0363', 1, 0, @c_mostrador, '2026-08-02 09:47:00', '2026-08-02', '2026-08-02', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0363', 1, '2026-08-02', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2608-0364 (2026-08-02 08:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0364', 1, 0, @c_mostrador, '2026-08-02 08:28:00', '2026-08-02', '2026-08-02', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0364', 1, '2026-08-02', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0365 (2026-08-02 09:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0365', 1, 0, @c_mostrador, '2026-08-02 09:27:00', '2026-08-02', '2026-08-02', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0365', 1, '2026-08-02', 75.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 75.0);

-- Venta FA2608-0366 (2026-08-02 10:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0366', 1, 0, @c_mostrador, '2026-08-02 10:09:00', '2026-08-02', '2026-08-02', 1, 57.0, 0, 57.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0366', 1, '2026-08-02', 57.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 57.0);

-- Venta FA2608-0367 (2026-08-02 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0367', 1, 0, @c_mostrador, '2026-08-02 09:34:00', '2026-08-02', '2026-08-02', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0367', 1, '2026-08-02', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0368 (2026-08-02 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0368', 1, 0, @c_mostrador, '2026-08-02 10:21:00', '2026-08-02', '2026-08-02', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0368', 1, '2026-08-02', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0369 (2026-08-02 08:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0369', 1, 0, @c_juan, '2026-08-02 08:40:00', '2026-08-02', '2026-08-02', 1, 39.0, 0, 39.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0369', 1, '2026-08-02', 39.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 39.0);

-- Venta FA2608-0370 (2026-08-02 09:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0370', 1, 0, @c_maria, '2026-08-02 09:04:00', '2026-08-02', '2026-08-02', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0370', 1, '2026-08-02', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0371 (2026-08-02 10:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0371', 1, 0, @c_maria, '2026-08-02 10:02:00', '2026-08-02', '2026-08-02', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0371', 1, '2026-08-02', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0372 (2026-08-02 08:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0372', 1, 0, @c_maria, '2026-08-02 08:45:00', '2026-08-02', '2026-08-02', 1, 52.0, 0, 52.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0372', 1, '2026-08-02', 52.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 52.0);

-- Venta FA2608-0373 (2026-08-02 10:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0373', 1, 0, @c_mostrador, '2026-08-02 10:57:00', '2026-08-02', '2026-08-02', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0373', 1, '2026-08-02', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0374 (2026-08-02 09:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0374', 1, 0, @c_juan, '2026-08-02 09:18:00', '2026-08-02', '2026-08-02', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0374', 1, '2026-08-02', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0375 (2026-08-02 08:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0375', 1, 0, @c_mostrador, '2026-08-02 08:17:00', '2026-08-02', '2026-08-02', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0375', 1, '2026-08-02', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0376 (2026-08-02 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0376', 1, 0, @c_maria, '2026-08-02 09:14:00', '2026-08-02', '2026-08-02', 1, 74.0, 0, 74.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0376', 1, '2026-08-02', 74.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 74.0);

-- Venta FA2608-0377 (2026-08-02 09:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0377', 1, 0, @c_mostrador, '2026-08-02 09:59:00', '2026-08-02', '2026-08-02', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0377', 1, '2026-08-02', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2608-0378 (2026-08-02 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0378', 1, 0, @c_maria, '2026-08-02 09:22:00', '2026-08-02', '2026-08-02', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0378', 1, '2026-08-02', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0379 (2026-08-03 11:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0379', 1, 0, @c_maria, '2026-08-03 11:16:00', '2026-08-03', '2026-08-03', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0379', 1, '2026-08-03', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0380 (2026-08-03 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0380', 1, 0, @c_mostrador, '2026-08-03 09:22:00', '2026-08-03', '2026-08-03', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0380', 1, '2026-08-03', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2608-0381 (2026-08-03 10:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0381', 1, 0, @c_mostrador, '2026-08-03 10:57:00', '2026-08-03', '2026-08-03', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0381', 1, '2026-08-03', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0382 (2026-08-04 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0382', 1, 0, @c_maria, '2026-08-04 09:36:00', '2026-08-04', '2026-08-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0382', 1, '2026-08-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0383 (2026-08-04 11:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0383', 1, 0, @c_mostrador, '2026-08-04 11:44:00', '2026-08-04', '2026-08-04', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0383', 1, '2026-08-04', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0384 (2026-08-04 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0384', 1, 0, @c_mostrador, '2026-08-04 09:43:00', '2026-08-04', '2026-08-04', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0384', 1, '2026-08-04', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0385 (2026-08-05 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0385', 1, 0, @c_mostrador, '2026-08-05 09:36:00', '2026-08-05', '2026-08-05', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0385', 1, '2026-08-05', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0386 (2026-08-05 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0386', 1, 0, @c_mostrador, '2026-08-05 09:43:00', '2026-08-05', '2026-08-05', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0386', 1, '2026-08-05', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0387 (2026-08-05 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0387', 1, 0, @c_juan, '2026-08-05 10:37:00', '2026-08-05', '2026-08-05', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0387', 1, '2026-08-05', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0388 (2026-08-05 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0388', 1, 0, @c_mostrador, '2026-08-05 09:00:00', '2026-08-05', '2026-08-05', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0388', 1, '2026-08-05', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0389 (2026-08-05 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0389', 1, 0, @c_maria, '2026-08-05 09:37:00', '2026-08-05', '2026-08-05', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0389', 1, '2026-08-05', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0390 (2026-08-05 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0390', 1, 0, @c_mostrador, '2026-08-05 09:13:00', '2026-08-05', '2026-08-05', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0390', 1, '2026-08-05', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);
-- Compra de insumos: SI2608-0108 (2026-08-06)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0108', 'FAC-PROV-108', 1, 0, @p_carne, '2026-08-06 08:00:00', '2026-08-06', '2026-08-06', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0108', 1, '2026-08-06', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0391 (2026-08-06 08:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0391', 1, 0, @c_juan, '2026-08-06 08:57:00', '2026-08-06', '2026-08-06', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0391', 1, '2026-08-06', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0392 (2026-08-06 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0392', 1, 0, @c_mostrador, '2026-08-06 09:05:00', '2026-08-06', '2026-08-06', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0392', 1, '2026-08-06', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0393 (2026-08-06 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0393', 1, 0, @c_mostrador, '2026-08-06 09:17:00', '2026-08-06', '2026-08-06', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0393', 1, '2026-08-06', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2608-0394 (2026-08-06 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0394', 1, 0, @c_mostrador, '2026-08-06 10:17:00', '2026-08-06', '2026-08-06', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0394', 1, '2026-08-06', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2608-0395 (2026-08-07 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0395', 1, 0, @c_mostrador, '2026-08-07 09:44:00', '2026-08-07', '2026-08-07', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0395', 1, '2026-08-07', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0396 (2026-08-07 11:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0396', 1, 0, @c_mostrador, '2026-08-07 11:49:00', '2026-08-07', '2026-08-07', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0396', 1, '2026-08-07', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0397 (2026-08-07 11:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0397', 1, 0, @c_mostrador, '2026-08-07 11:18:00', '2026-08-07', '2026-08-07', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0397', 1, '2026-08-07', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0398 (2026-08-07 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0398', 1, 0, @c_mostrador, '2026-08-07 09:35:00', '2026-08-07', '2026-08-07', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0398', 1, '2026-08-07', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0399 (2026-08-07 10:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0399', 1, 0, @c_mostrador, '2026-08-07 10:26:00', '2026-08-07', '2026-08-07', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0399', 1, '2026-08-07', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0400 (2026-08-07 11:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0400', 1, 0, @c_maria, '2026-08-07 11:51:00', '2026-08-07', '2026-08-07', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0400', 1, '2026-08-07', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0401 (2026-08-07 10:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0401', 1, 0, @c_mostrador, '2026-08-07 10:36:00', '2026-08-07', '2026-08-07', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0401', 1, '2026-08-07', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0402 (2026-08-08 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0402', 1, 0, @c_maria, '2026-08-08 10:24:00', '2026-08-08', '2026-08-08', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0402', 1, '2026-08-08', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0403 (2026-08-08 09:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0403', 1, 0, @c_juan, '2026-08-08 09:51:00', '2026-08-08', '2026-08-08', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0403', 1, '2026-08-08', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0404 (2026-08-08 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0404', 1, 0, @c_mostrador, '2026-08-08 09:50:00', '2026-08-08', '2026-08-08', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0404', 1, '2026-08-08', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2608-0405 (2026-08-08 10:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0405', 1, 0, @c_mostrador, '2026-08-08 10:58:00', '2026-08-08', '2026-08-08', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0405', 1, '2026-08-08', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0406 (2026-08-08 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0406', 1, 0, @c_mostrador, '2026-08-08 09:24:00', '2026-08-08', '2026-08-08', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0406', 1, '2026-08-08', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0407 (2026-08-08 08:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0407', 1, 0, @c_mostrador, '2026-08-08 08:12:00', '2026-08-08', '2026-08-08', 1, 68.0, 0, 68.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0407', 1, '2026-08-08', 68.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 68.0);

-- Venta FA2608-0408 (2026-08-08 09:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0408', 1, 0, @c_mostrador, '2026-08-08 09:39:00', '2026-08-08', '2026-08-08', 1, 68.0, 0, 68.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0408', 1, '2026-08-08', 68.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 68.0);

-- Venta FA2608-0409 (2026-08-08 08:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0409', 1, 0, @c_mostrador, '2026-08-08 08:51:00', '2026-08-08', '2026-08-08', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0409', 1, '2026-08-08', 84.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 84.0);

-- Venta FA2608-0410 (2026-08-08 11:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0410', 1, 0, @c_mostrador, '2026-08-08 11:02:00', '2026-08-08', '2026-08-08', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0410', 1, '2026-08-08', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0411 (2026-08-08 11:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0411', 1, 0, @c_mostrador, '2026-08-08 11:58:00', '2026-08-08', '2026-08-08', 1, 28.0, 0, 28.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 4, 0, 28.0, 0, 28.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0411', 1, '2026-08-08', 28.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 28.0);

-- Venta FA2608-0412 (2026-08-08 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0412', 1, 0, @c_mostrador, '2026-08-08 09:37:00', '2026-08-08', '2026-08-08', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0412', 1, '2026-08-08', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2608-0413 (2026-08-08 09:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0413', 1, 0, @c_maria, '2026-08-08 09:39:00', '2026-08-08', '2026-08-08', 1, 63.0, 0, 63.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0413', 1, '2026-08-08', 63.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 63.0);

-- Venta FA2608-0414 (2026-08-08 09:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0414', 1, 0, @c_mostrador, '2026-08-08 09:23:00', '2026-08-08', '2026-08-08', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0414', 1, '2026-08-08', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2608-0415 (2026-08-08 09:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0415', 1, 0, @c_juan, '2026-08-08 09:29:00', '2026-08-08', '2026-08-08', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0415', 1, '2026-08-08', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2608-0416 (2026-08-09 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0416', 1, 0, @c_maria, '2026-08-09 09:55:00', '2026-08-09', '2026-08-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0416', 1, '2026-08-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0417 (2026-08-09 08:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0417', 1, 0, @c_juan, '2026-08-09 08:39:00', '2026-08-09', '2026-08-09', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0417', 1, '2026-08-09', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2608-0418 (2026-08-09 10:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0418', 1, 0, @c_mostrador, '2026-08-09 10:07:00', '2026-08-09', '2026-08-09', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0418', 1, '2026-08-09', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2608-0419 (2026-08-09 09:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0419', 1, 0, @c_mostrador, '2026-08-09 09:28:00', '2026-08-09', '2026-08-09', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0419', 1, '2026-08-09', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0420 (2026-08-09 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0420', 1, 0, @c_mostrador, '2026-08-09 09:57:00', '2026-08-09', '2026-08-09', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0420', 1, '2026-08-09', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0421 (2026-08-09 08:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0421', 1, 0, @c_mostrador, '2026-08-09 08:21:00', '2026-08-09', '2026-08-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0421', 1, '2026-08-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0422 (2026-08-09 08:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0422', 1, 0, @c_mostrador, '2026-08-09 08:27:00', '2026-08-09', '2026-08-09', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0422', 1, '2026-08-09', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2608-0423 (2026-08-09 08:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0423', 1, 0, @c_mostrador, '2026-08-09 08:58:00', '2026-08-09', '2026-08-09', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0423', 1, '2026-08-09', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0424 (2026-08-09 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0424', 1, 0, @c_juan, '2026-08-09 10:14:00', '2026-08-09', '2026-08-09', 1, 94.0, 0, 94.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0424', 1, '2026-08-09', 94.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 94.0);

-- Venta FA2608-0425 (2026-08-09 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0425', 1, 0, @c_mostrador, '2026-08-09 10:21:00', '2026-08-09', '2026-08-09', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0425', 1, '2026-08-09', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0426 (2026-08-09 10:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0426', 1, 0, @c_mostrador, '2026-08-09 10:18:00', '2026-08-09', '2026-08-09', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0426', 1, '2026-08-09', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0427 (2026-08-09 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0427', 1, 0, @c_maria, '2026-08-09 09:57:00', '2026-08-09', '2026-08-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0427', 1, '2026-08-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0428 (2026-08-10 11:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0428', 1, 0, @c_mostrador, '2026-08-10 11:39:00', '2026-08-10', '2026-08-10', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0428', 1, '2026-08-10', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2608-0429 (2026-08-10 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0429', 1, 0, @c_juan, '2026-08-10 10:59:00', '2026-08-10', '2026-08-10', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0429', 1, '2026-08-10', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);
-- Compra de insumos: SI2608-0109 (2026-08-11)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0109', 'FAC-PROV-109', 1, 0, @p_carne, '2026-08-11 08:00:00', '2026-08-11', '2026-08-11', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0109', 1, '2026-08-11', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0430 (2026-08-11 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0430', 1, 0, @c_maria, '2026-08-11 09:55:00', '2026-08-11', '2026-08-11', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0430', 1, '2026-08-11', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0431 (2026-08-11 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0431', 1, 0, @c_mostrador, '2026-08-11 10:24:00', '2026-08-11', '2026-08-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0431', 1, '2026-08-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0432 (2026-08-12 10:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0432', 1, 0, @c_juan, '2026-08-12 10:54:00', '2026-08-12', '2026-08-12', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0432', 1, '2026-08-12', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0433 (2026-08-12 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0433', 1, 0, @c_mostrador, '2026-08-12 09:53:00', '2026-08-12', '2026-08-12', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0433', 1, '2026-08-12', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0434 (2026-08-12 09:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0434', 1, 0, @c_mostrador, '2026-08-12 09:42:00', '2026-08-12', '2026-08-12', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0434', 1, '2026-08-12', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0435 (2026-08-12 11:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0435', 1, 0, @c_mostrador, '2026-08-12 11:59:00', '2026-08-12', '2026-08-12', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0435', 1, '2026-08-12', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0436 (2026-08-12 10:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0436', 1, 0, @c_juan, '2026-08-12 10:40:00', '2026-08-12', '2026-08-12', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0436', 1, '2026-08-12', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0437 (2026-08-13 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0437', 1, 0, @c_juan, '2026-08-13 10:49:00', '2026-08-13', '2026-08-13', 1, 14.0, 0, 14.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 2, 0, 14.0, 0, 14.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0437', 1, '2026-08-13', 14.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 14.0);

-- Venta FA2608-0438 (2026-08-13 08:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0438', 1, 0, @c_mostrador, '2026-08-13 08:02:00', '2026-08-13', '2026-08-13', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0438', 1, '2026-08-13', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0439 (2026-08-13 10:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0439', 1, 0, @c_juan, '2026-08-13 10:16:00', '2026-08-13', '2026-08-13', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0439', 1, '2026-08-13', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0440 (2026-08-13 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0440', 1, 0, @c_mostrador, '2026-08-13 09:52:00', '2026-08-13', '2026-08-13', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0440', 1, '2026-08-13', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0441 (2026-08-13 10:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0441', 1, 0, @c_maria, '2026-08-13 10:01:00', '2026-08-13', '2026-08-13', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0441', 1, '2026-08-13', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0442 (2026-08-13 10:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0442', 1, 0, @c_mostrador, '2026-08-13 10:05:00', '2026-08-13', '2026-08-13', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0442', 1, '2026-08-13', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta B2B Institucional: FA2608-0443 (2026-08-14)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0443', 1, 0, @c_san_agustin, '2026-08-14 09:15:00', '2026-08-14', '2026-08-14', 1, 856.0, 0, 856.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 67, 0, 536.0, 0, 536.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 40, 0, 320.0, 0, 320.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0443', 1, '2026-08-14', 856.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 856.0);

-- Venta FA2608-0444 (2026-08-14 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0444', 1, 0, @c_mostrador, '2026-08-14 10:14:00', '2026-08-14', '2026-08-14', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0444', 1, '2026-08-14', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2608-0445 (2026-08-14 10:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0445', 1, 0, @c_mostrador, '2026-08-14 10:03:00', '2026-08-14', '2026-08-14', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0445', 1, '2026-08-14', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0446 (2026-08-14 09:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0446', 1, 0, @c_mostrador, '2026-08-14 09:11:00', '2026-08-14', '2026-08-14', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0446', 1, '2026-08-14', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0447 (2026-08-14 10:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0447', 1, 0, @c_maria, '2026-08-14 10:35:00', '2026-08-14', '2026-08-14', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0447', 1, '2026-08-14', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2608-0448 (2026-08-14 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0448', 1, 0, @c_mostrador, '2026-08-14 09:40:00', '2026-08-14', '2026-08-14', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0448', 1, '2026-08-14', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0449 (2026-08-14 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0449', 1, 0, @c_mostrador, '2026-08-14 10:04:00', '2026-08-14', '2026-08-14', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0449', 1, '2026-08-14', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0450 (2026-08-14 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0450', 1, 0, @c_mostrador, '2026-08-14 10:39:00', '2026-08-14', '2026-08-14', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0450', 1, '2026-08-14', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2608-0451 (2026-08-14 10:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0451', 1, 0, @c_juan, '2026-08-14 10:57:00', '2026-08-14', '2026-08-14', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0451', 1, '2026-08-14', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0452 (2026-08-14 08:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0452', 1, 0, @c_mostrador, '2026-08-14 08:28:00', '2026-08-14', '2026-08-14', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0452', 1, '2026-08-14', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0453 (2026-08-15 11:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0453', 1, 0, @c_mostrador, '2026-08-15 11:44:00', '2026-08-15', '2026-08-15', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0453', 1, '2026-08-15', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0454 (2026-08-15 09:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0454', 1, 0, @c_juan, '2026-08-15 09:10:00', '2026-08-15', '2026-08-15', 1, 126.0, 0, 126.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0454', 1, '2026-08-15', 126.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 126.0);

-- Venta FA2608-0455 (2026-08-15 09:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0455', 1, 0, @c_mostrador, '2026-08-15 09:06:00', '2026-08-15', '2026-08-15', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0455', 1, '2026-08-15', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2608-0456 (2026-08-15 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0456', 1, 0, @c_juan, '2026-08-15 10:33:00', '2026-08-15', '2026-08-15', 1, 44.0, 0, 44.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 4, 0, 20.0, 0, 20.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0456', 1, '2026-08-15', 44.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 44.0);

-- Venta FA2608-0457 (2026-08-15 08:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0457', 1, 0, @c_maria, '2026-08-15 08:30:00', '2026-08-15', '2026-08-15', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0457', 1, '2026-08-15', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0458 (2026-08-15 11:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0458', 1, 0, @c_mostrador, '2026-08-15 11:31:00', '2026-08-15', '2026-08-15', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0458', 1, '2026-08-15', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0459 (2026-08-15 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0459', 1, 0, @c_mostrador, '2026-08-15 09:20:00', '2026-08-15', '2026-08-15', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0459', 1, '2026-08-15', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2608-0460 (2026-08-15 09:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0460', 1, 0, @c_mostrador, '2026-08-15 09:39:00', '2026-08-15', '2026-08-15', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0460', 1, '2026-08-15', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0461 (2026-08-15 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0461', 1, 0, @c_mostrador, '2026-08-15 09:41:00', '2026-08-15', '2026-08-15', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0461', 1, '2026-08-15', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0462 (2026-08-15 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0462', 1, 0, @c_juan, '2026-08-15 09:09:00', '2026-08-15', '2026-08-15', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0462', 1, '2026-08-15', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2608-0463 (2026-08-15 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0463', 1, 0, @c_mostrador, '2026-08-15 09:36:00', '2026-08-15', '2026-08-15', 1, 115.0, 0, 115.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0463', 1, '2026-08-15', 115.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 115.0);

-- Venta FA2608-0464 (2026-08-15 11:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0464', 1, 0, @c_mostrador, '2026-08-15 11:58:00', '2026-08-15', '2026-08-15', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0464', 1, '2026-08-15', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2608-0465 (2026-08-15 11:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0465', 1, 0, @c_juan, '2026-08-15 11:03:00', '2026-08-15', '2026-08-15', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0465', 1, '2026-08-15', 84.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 84.0);

-- Venta FA2608-0466 (2026-08-15 10:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0466', 1, 0, @c_mostrador, '2026-08-15 10:00:00', '2026-08-15', '2026-08-15', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0466', 1, '2026-08-15', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);
-- Compra de insumos: SI2608-0110 (2026-08-16)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0110', 'FAC-PROV-110', 1, 0, @p_carne, '2026-08-16 08:00:00', '2026-08-16', '2026-08-16', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0110', 1, '2026-08-16', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0467 (2026-08-16 10:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0467', 1, 0, @c_maria, '2026-08-16 10:15:00', '2026-08-16', '2026-08-16', 1, 20.0, 0, 20.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 4, 0, 20.0, 0, 20.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0467', 1, '2026-08-16', 20.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 20.0);

-- Venta FA2608-0468 (2026-08-16 09:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0468', 1, 0, @c_mostrador, '2026-08-16 09:18:00', '2026-08-16', '2026-08-16', 1, 39.0, 0, 39.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0468', 1, '2026-08-16', 39.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 39.0);

-- Venta FA2608-0469 (2026-08-16 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0469', 1, 0, @c_maria, '2026-08-16 10:21:00', '2026-08-16', '2026-08-16', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0469', 1, '2026-08-16', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0470 (2026-08-16 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0470', 1, 0, @c_mostrador, '2026-08-16 09:52:00', '2026-08-16', '2026-08-16', 1, 59.0, 0, 59.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 5, 0, 35.0, 0, 35.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0470', 1, '2026-08-16', 59.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 59.0);

-- Venta FA2608-0471 (2026-08-16 10:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0471', 1, 0, @c_mostrador, '2026-08-16 10:22:00', '2026-08-16', '2026-08-16', 1, 115.0, 0, 115.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0471', 1, '2026-08-16', 115.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 115.0);

-- Venta FA2608-0472 (2026-08-16 08:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0472', 1, 0, @c_maria, '2026-08-16 08:40:00', '2026-08-16', '2026-08-16', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0472', 1, '2026-08-16', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0473 (2026-08-16 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0473', 1, 0, @c_mostrador, '2026-08-16 09:35:00', '2026-08-16', '2026-08-16', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0473', 1, '2026-08-16', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0474 (2026-08-16 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0474', 1, 0, @c_juan, '2026-08-16 10:06:00', '2026-08-16', '2026-08-16', 1, 86.0, 0, 86.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0474', 1, '2026-08-16', 86.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 86.0);

-- Venta FA2608-0475 (2026-08-16 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0475', 1, 0, @c_mostrador, '2026-08-16 09:44:00', '2026-08-16', '2026-08-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0475', 1, '2026-08-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0476 (2026-08-16 10:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0476', 1, 0, @c_maria, '2026-08-16 10:54:00', '2026-08-16', '2026-08-16', 1, 61.0, 0, 61.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0476', 1, '2026-08-16', 61.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 61.0);

-- Venta FA2608-0477 (2026-08-16 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0477', 1, 0, @c_mostrador, '2026-08-16 10:55:00', '2026-08-16', '2026-08-16', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0477', 1, '2026-08-16', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0478 (2026-08-16 10:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0478', 1, 0, @c_mostrador, '2026-08-16 10:58:00', '2026-08-16', '2026-08-16', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0478', 1, '2026-08-16', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0479 (2026-08-16 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0479', 1, 0, @c_mostrador, '2026-08-16 09:24:00', '2026-08-16', '2026-08-16', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0479', 1, '2026-08-16', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0480 (2026-08-16 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0480', 1, 0, @c_mostrador, '2026-08-16 09:35:00', '2026-08-16', '2026-08-16', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0480', 1, '2026-08-16', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2608-0481 (2026-08-17 10:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0481', 1, 0, @c_mostrador, '2026-08-17 10:58:00', '2026-08-17', '2026-08-17', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0481', 1, '2026-08-17', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0482 (2026-08-17 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0482', 1, 0, @c_mostrador, '2026-08-17 09:56:00', '2026-08-17', '2026-08-17', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0482', 1, '2026-08-17', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0483 (2026-08-17 08:18:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0483', 1, 0, @c_mostrador, '2026-08-17 08:18:00', '2026-08-17', '2026-08-17', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0483', 1, '2026-08-17', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0484 (2026-08-18 09:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0484', 1, 0, @c_mostrador, '2026-08-18 09:19:00', '2026-08-18', '2026-08-18', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0484', 1, '2026-08-18', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0485 (2026-08-18 09:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0485', 1, 0, @c_mostrador, '2026-08-18 09:06:00', '2026-08-18', '2026-08-18', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0485', 1, '2026-08-18', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0486 (2026-08-19 10:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0486', 1, 0, @c_mostrador, '2026-08-19 10:54:00', '2026-08-19', '2026-08-19', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0486', 1, '2026-08-19', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0487 (2026-08-19 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0487', 1, 0, @c_mostrador, '2026-08-19 09:48:00', '2026-08-19', '2026-08-19', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0487', 1, '2026-08-19', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2608-0488 (2026-08-19 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0488', 1, 0, @c_mostrador, '2026-08-19 09:09:00', '2026-08-19', '2026-08-19', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0488', 1, '2026-08-19', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0489 (2026-08-19 08:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0489', 1, 0, @c_mostrador, '2026-08-19 08:03:00', '2026-08-19', '2026-08-19', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0489', 1, '2026-08-19', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2608-0490 (2026-08-19 10:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0490', 1, 0, @c_mostrador, '2026-08-19 10:26:00', '2026-08-19', '2026-08-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0490', 1, '2026-08-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0491 (2026-08-19 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0491', 1, 0, @c_mostrador, '2026-08-19 10:55:00', '2026-08-19', '2026-08-19', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0491', 1, '2026-08-19', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2608-0492 (2026-08-19 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0492', 1, 0, @c_mostrador, '2026-08-19 09:50:00', '2026-08-19', '2026-08-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0492', 1, '2026-08-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0493 (2026-08-20 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0493', 1, 0, @c_mostrador, '2026-08-20 10:50:00', '2026-08-20', '2026-08-20', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0493', 1, '2026-08-20', 35.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 35.0);

-- Venta FA2608-0494 (2026-08-20 09:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0494', 1, 0, @c_mostrador, '2026-08-20 09:03:00', '2026-08-20', '2026-08-20', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0494', 1, '2026-08-20', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2608-0495 (2026-08-20 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0495', 1, 0, @c_mostrador, '2026-08-20 10:37:00', '2026-08-20', '2026-08-20', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0495', 1, '2026-08-20', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2608-0496 (2026-08-20 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0496', 1, 0, @c_mostrador, '2026-08-20 09:07:00', '2026-08-20', '2026-08-20', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0496', 1, '2026-08-20', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0497 (2026-08-20 08:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0497', 1, 0, @c_mostrador, '2026-08-20 08:10:00', '2026-08-20', '2026-08-20', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0497', 1, '2026-08-20', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);
-- Compra de insumos: SI2608-0111 (2026-08-21)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0111', 'FAC-PROV-111', 1, 0, @p_carne, '2026-08-21 08:00:00', '2026-08-21', '2026-08-21', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0111', 1, '2026-08-21', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0498 (2026-08-21 09:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0498', 1, 0, @c_juan, '2026-08-21 09:15:00', '2026-08-21', '2026-08-21', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0498', 1, '2026-08-21', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2608-0499 (2026-08-21 09:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0499', 1, 0, @c_mostrador, '2026-08-21 09:08:00', '2026-08-21', '2026-08-21', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0499', 1, '2026-08-21', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2608-0500 (2026-08-21 11:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0500', 1, 0, @c_mostrador, '2026-08-21 11:15:00', '2026-08-21', '2026-08-21', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0500', 1, '2026-08-21', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2608-0501 (2026-08-21 09:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0501', 1, 0, @c_mostrador, '2026-08-21 09:02:00', '2026-08-21', '2026-08-21', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0501', 1, '2026-08-21', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0502 (2026-08-21 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0502', 1, 0, @c_juan, '2026-08-21 09:24:00', '2026-08-21', '2026-08-21', 1, 23.0, 0, 23.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0502', 1, '2026-08-21', 23.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 23.0);

-- Venta FA2608-0503 (2026-08-21 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0503', 1, 0, @c_mostrador, '2026-08-21 10:10:00', '2026-08-21', '2026-08-21', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0503', 1, '2026-08-21', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0504 (2026-08-21 10:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0504', 1, 0, @c_juan, '2026-08-21 10:21:00', '2026-08-21', '2026-08-21', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0504', 1, '2026-08-21', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0505 (2026-08-22 08:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0505', 1, 0, @c_mostrador, '2026-08-22 08:05:00', '2026-08-22', '2026-08-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0505', 1, '2026-08-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0506 (2026-08-22 10:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0506', 1, 0, @c_juan, '2026-08-22 10:09:00', '2026-08-22', '2026-08-22', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0506', 1, '2026-08-22', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0507 (2026-08-22 10:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0507', 1, 0, @c_juan, '2026-08-22 10:02:00', '2026-08-22', '2026-08-22', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0507', 1, '2026-08-22', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0508 (2026-08-22 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0508', 1, 0, @c_mostrador, '2026-08-22 09:44:00', '2026-08-22', '2026-08-22', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0508', 1, '2026-08-22', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2608-0509 (2026-08-22 09:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0509', 1, 0, @c_maria, '2026-08-22 09:30:00', '2026-08-22', '2026-08-22', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0509', 1, '2026-08-22', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0510 (2026-08-22 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0510', 1, 0, @c_mostrador, '2026-08-22 09:58:00', '2026-08-22', '2026-08-22', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0510', 1, '2026-08-22', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0511 (2026-08-22 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0511', 1, 0, @c_mostrador, '2026-08-22 09:53:00', '2026-08-22', '2026-08-22', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0511', 1, '2026-08-22', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0512 (2026-08-22 11:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0512', 1, 0, @c_mostrador, '2026-08-22 11:44:00', '2026-08-22', '2026-08-22', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0512', 1, '2026-08-22', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2608-0513 (2026-08-22 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0513', 1, 0, @c_mostrador, '2026-08-22 10:24:00', '2026-08-22', '2026-08-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0513', 1, '2026-08-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0514 (2026-08-22 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0514', 1, 0, @c_mostrador, '2026-08-22 10:59:00', '2026-08-22', '2026-08-22', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0514', 1, '2026-08-22', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2608-0515 (2026-08-22 11:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0515', 1, 0, @c_maria, '2026-08-22 11:05:00', '2026-08-22', '2026-08-22', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0515', 1, '2026-08-22', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2608-0516 (2026-08-22 08:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0516', 1, 0, @c_maria, '2026-08-22 08:26:00', '2026-08-22', '2026-08-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0516', 1, '2026-08-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0517 (2026-08-22 09:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0517', 1, 0, @c_mostrador, '2026-08-22 09:28:00', '2026-08-22', '2026-08-22', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0517', 1, '2026-08-22', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2608-0518 (2026-08-23 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0518', 1, 0, @c_mostrador, '2026-08-23 09:37:00', '2026-08-23', '2026-08-23', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0518', 1, '2026-08-23', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0519 (2026-08-23 10:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0519', 1, 0, @c_mostrador, '2026-08-23 10:08:00', '2026-08-23', '2026-08-23', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0519', 1, '2026-08-23', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0520 (2026-08-23 09:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0520', 1, 0, @c_mostrador, '2026-08-23 09:33:00', '2026-08-23', '2026-08-23', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0520', 1, '2026-08-23', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0521 (2026-08-23 10:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0521', 1, 0, @c_maria, '2026-08-23 10:38:00', '2026-08-23', '2026-08-23', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0521', 1, '2026-08-23', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0522 (2026-08-23 10:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0522', 1, 0, @c_mostrador, '2026-08-23 10:20:00', '2026-08-23', '2026-08-23', 1, 78.0, 0, 78.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0522', 1, '2026-08-23', 78.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 78.0);

-- Venta FA2608-0523 (2026-08-23 08:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0523', 1, 0, @c_mostrador, '2026-08-23 08:49:00', '2026-08-23', '2026-08-23', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0523', 1, '2026-08-23', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0524 (2026-08-23 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0524', 1, 0, @c_mostrador, '2026-08-23 10:04:00', '2026-08-23', '2026-08-23', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0524', 1, '2026-08-23', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0525 (2026-08-23 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0525', 1, 0, @c_juan, '2026-08-23 09:00:00', '2026-08-23', '2026-08-23', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0525', 1, '2026-08-23', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2608-0526 (2026-08-23 09:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0526', 1, 0, @c_juan, '2026-08-23 09:06:00', '2026-08-23', '2026-08-23', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0526', 1, '2026-08-23', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0527 (2026-08-23 11:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0527', 1, 0, @c_juan, '2026-08-23 11:10:00', '2026-08-23', '2026-08-23', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0527', 1, '2026-08-23', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0528 (2026-08-23 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0528', 1, 0, @c_maria, '2026-08-23 10:59:00', '2026-08-23', '2026-08-23', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0528', 1, '2026-08-23', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0529 (2026-08-23 09:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0529', 1, 0, @c_mostrador, '2026-08-23 09:04:00', '2026-08-23', '2026-08-23', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0529', 1, '2026-08-23', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0530 (2026-08-24 09:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0530', 1, 0, @c_maria, '2026-08-24 09:33:00', '2026-08-24', '2026-08-24', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0530', 1, '2026-08-24', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0531 (2026-08-24 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0531', 1, 0, @c_mostrador, '2026-08-24 10:06:00', '2026-08-24', '2026-08-24', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0531', 1, '2026-08-24', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0532 (2026-08-24 10:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0532', 1, 0, @c_mostrador, '2026-08-24 10:08:00', '2026-08-24', '2026-08-24', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0532', 1, '2026-08-24', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0533 (2026-08-24 09:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0533', 1, 0, @c_mostrador, '2026-08-24 09:51:00', '2026-08-24', '2026-08-24', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0533', 1, '2026-08-24', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0534 (2026-08-25 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0534', 1, 0, @c_maria, '2026-08-25 09:48:00', '2026-08-25', '2026-08-25', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0534', 1, '2026-08-25', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0535 (2026-08-25 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0535', 1, 0, @c_mostrador, '2026-08-25 10:47:00', '2026-08-25', '2026-08-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0535', 1, '2026-08-25', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0536 (2026-08-25 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0536', 1, 0, @c_mostrador, '2026-08-25 10:24:00', '2026-08-25', '2026-08-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0536', 1, '2026-08-25', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);
-- Compra de insumos: SI2608-0112 (2026-08-26)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2608-0112', 'FAC-PROV-112', 1, 0, @p_carne, '2026-08-26 08:00:00', '2026-08-26', '2026-08-26', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2608-0112', 1, '2026-08-26', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2608-0537 (2026-08-26 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0537', 1, 0, @c_mostrador, '2026-08-26 09:17:00', '2026-08-26', '2026-08-26', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0537', 1, '2026-08-26', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0538 (2026-08-26 08:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0538', 1, 0, @c_juan, '2026-08-26 08:25:00', '2026-08-26', '2026-08-26', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0538', 1, '2026-08-26', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2608-0539 (2026-08-26 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0539', 1, 0, @c_mostrador, '2026-08-26 09:16:00', '2026-08-26', '2026-08-26', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0539', 1, '2026-08-26', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2608-0540 (2026-08-26 11:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0540', 1, 0, @c_mostrador, '2026-08-26 11:40:00', '2026-08-26', '2026-08-26', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0540', 1, '2026-08-26', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0541 (2026-08-27 09:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0541', 1, 0, @c_juan, '2026-08-27 09:19:00', '2026-08-27', '2026-08-27', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0541', 1, '2026-08-27', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2608-0542 (2026-08-27 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0542', 1, 0, @c_maria, '2026-08-27 09:57:00', '2026-08-27', '2026-08-27', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0542', 1, '2026-08-27', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0543 (2026-08-27 08:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0543', 1, 0, @c_mostrador, '2026-08-27 08:04:00', '2026-08-27', '2026-08-27', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0543', 1, '2026-08-27', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0544 (2026-08-27 09:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0544', 1, 0, @c_juan, '2026-08-27 09:47:00', '2026-08-27', '2026-08-27', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0544', 1, '2026-08-27', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0545 (2026-08-27 08:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0545', 1, 0, @c_mostrador, '2026-08-27 08:19:00', '2026-08-27', '2026-08-27', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0545', 1, '2026-08-27', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0546 (2026-08-27 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0546', 1, 0, @c_mostrador, '2026-08-27 09:48:00', '2026-08-27', '2026-08-27', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0546', 1, '2026-08-27', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta B2B Institucional: FA2608-0547 (2026-08-28)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0547', 1, 0, @c_san_agustin, '2026-08-28 09:15:00', '2026-08-28', '2026-08-28', 1, 720.0, 0, 720.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 51, 0, 408.0, 0, 408.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 39, 0, 312.0, 0, 312.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0547', 1, '2026-08-28', 720.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 720.0);

-- Venta FA2608-0548 (2026-08-28 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0548', 1, 0, @c_mostrador, '2026-08-28 09:24:00', '2026-08-28', '2026-08-28', 1, 41.0, 0, 41.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0548', 1, '2026-08-28', 41.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 41.0);

-- Venta FA2608-0549 (2026-08-28 10:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0549', 1, 0, @c_juan, '2026-08-28 10:42:00', '2026-08-28', '2026-08-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0549', 1, '2026-08-28', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0550 (2026-08-28 10:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0550', 1, 0, @c_mostrador, '2026-08-28 10:51:00', '2026-08-28', '2026-08-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0550', 1, '2026-08-28', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0551 (2026-08-28 09:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0551', 1, 0, @c_mostrador, '2026-08-28 09:38:00', '2026-08-28', '2026-08-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0551', 1, '2026-08-28', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0552 (2026-08-28 10:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0552', 1, 0, @c_juan, '2026-08-28 10:45:00', '2026-08-28', '2026-08-28', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0552', 1, '2026-08-28', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0553 (2026-08-28 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0553', 1, 0, @c_mostrador, '2026-08-28 10:33:00', '2026-08-28', '2026-08-28', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0553', 1, '2026-08-28', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0554 (2026-08-28 08:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0554', 1, 0, @c_juan, '2026-08-28 08:29:00', '2026-08-28', '2026-08-28', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0554', 1, '2026-08-28', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2608-0555 (2026-08-29 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0555', 1, 0, @c_mostrador, '2026-08-29 10:19:00', '2026-08-29', '2026-08-29', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0555', 1, '2026-08-29', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0556 (2026-08-29 11:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0556', 1, 0, @c_mostrador, '2026-08-29 11:16:00', '2026-08-29', '2026-08-29', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0556', 1, '2026-08-29', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2608-0557 (2026-08-29 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0557', 1, 0, @c_mostrador, '2026-08-29 09:37:00', '2026-08-29', '2026-08-29', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0557', 1, '2026-08-29', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0558 (2026-08-29 08:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0558', 1, 0, @c_mostrador, '2026-08-29 08:17:00', '2026-08-29', '2026-08-29', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0558', 1, '2026-08-29', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2608-0559 (2026-08-29 11:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0559', 1, 0, @c_mostrador, '2026-08-29 11:57:00', '2026-08-29', '2026-08-29', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0559', 1, '2026-08-29', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2608-0560 (2026-08-29 09:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0560', 1, 0, @c_mostrador, '2026-08-29 09:04:00', '2026-08-29', '2026-08-29', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0560', 1, '2026-08-29', 75.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 75.0);

-- Venta FA2608-0561 (2026-08-29 09:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0561', 1, 0, @c_mostrador, '2026-08-29 09:46:00', '2026-08-29', '2026-08-29', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0561', 1, '2026-08-29', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0562 (2026-08-29 10:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0562', 1, 0, @c_mostrador, '2026-08-29 10:09:00', '2026-08-29', '2026-08-29', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0562', 1, '2026-08-29', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0563 (2026-08-29 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0563', 1, 0, @c_juan, '2026-08-29 10:47:00', '2026-08-29', '2026-08-29', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0563', 1, '2026-08-29', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2608-0564 (2026-08-29 10:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0564', 1, 0, @c_maria, '2026-08-29 10:25:00', '2026-08-29', '2026-08-29', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0564', 1, '2026-08-29', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0565 (2026-08-29 11:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0565', 1, 0, @c_juan, '2026-08-29 11:28:00', '2026-08-29', '2026-08-29', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0565', 1, '2026-08-29', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2608-0566 (2026-08-29 10:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0566', 1, 0, @c_mostrador, '2026-08-29 10:48:00', '2026-08-29', '2026-08-29', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0566', 1, '2026-08-29', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2608-0567 (2026-08-29 10:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0567', 1, 0, @c_mostrador, '2026-08-29 10:28:00', '2026-08-29', '2026-08-29', 1, 15.0, 0, 15.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0567', 1, '2026-08-29', 15.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 15.0);

-- Venta FA2608-0568 (2026-08-29 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0568', 1, 0, @c_mostrador, '2026-08-29 10:19:00', '2026-08-29', '2026-08-29', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0568', 1, '2026-08-29', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0569 (2026-08-29 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0569', 1, 0, @c_mostrador, '2026-08-29 09:14:00', '2026-08-29', '2026-08-29', 1, 134.0, 0, 134.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0569', 1, '2026-08-29', 134.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 134.0);

-- Venta FA2608-0570 (2026-08-30 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0570', 1, 0, @c_mostrador, '2026-08-30 09:41:00', '2026-08-30', '2026-08-30', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0570', 1, '2026-08-30', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0571 (2026-08-30 10:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0571', 1, 0, @c_maria, '2026-08-30 10:56:00', '2026-08-30', '2026-08-30', 1, 77.0, 0, 77.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0571', 1, '2026-08-30', 77.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 77.0);

-- Venta FA2608-0572 (2026-08-30 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0572', 1, 0, @c_juan, '2026-08-30 09:07:00', '2026-08-30', '2026-08-30', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0572', 1, '2026-08-30', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0573 (2026-08-30 08:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0573', 1, 0, @c_juan, '2026-08-30 08:50:00', '2026-08-30', '2026-08-30', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0573', 1, '2026-08-30', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0574 (2026-08-30 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0574', 1, 0, @c_juan, '2026-08-30 10:19:00', '2026-08-30', '2026-08-30', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0574', 1, '2026-08-30', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2608-0575 (2026-08-30 10:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0575', 1, 0, @c_mostrador, '2026-08-30 10:41:00', '2026-08-30', '2026-08-30', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0575', 1, '2026-08-30', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0576 (2026-08-30 11:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0576', 1, 0, @c_juan, '2026-08-30 11:56:00', '2026-08-30', '2026-08-30', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0576', 1, '2026-08-30', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0577 (2026-08-30 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0577', 1, 0, @c_juan, '2026-08-30 10:04:00', '2026-08-30', '2026-08-30', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0577', 1, '2026-08-30', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2608-0578 (2026-08-30 08:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0578', 1, 0, @c_mostrador, '2026-08-30 08:07:00', '2026-08-30', '2026-08-30', 1, 91.0, 0, 91.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 5, 0, 35.0, 0, 35.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0578', 1, '2026-08-30', 91.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 91.0);

-- Venta FA2608-0579 (2026-08-30 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0579', 1, 0, @c_mostrador, '2026-08-30 09:56:00', '2026-08-30', '2026-08-30', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0579', 1, '2026-08-30', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2608-0580 (2026-08-30 11:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0580', 1, 0, @c_juan, '2026-08-30 11:24:00', '2026-08-30', '2026-08-30', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0580', 1, '2026-08-30', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2608-0581 (2026-08-30 10:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0581', 1, 0, @c_juan, '2026-08-30 10:08:00', '2026-08-30', '2026-08-30', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 5, 0, 25.0, 0, 25.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0581', 1, '2026-08-30', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2608-0582 (2026-08-30 10:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0582', 1, 0, @c_maria, '2026-08-30 10:59:00', '2026-08-30', '2026-08-30', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0582', 1, '2026-08-30', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2608-0583 (2026-08-31 11:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0583', 1, 0, @c_mostrador, '2026-08-31 11:29:00', '2026-08-31', '2026-08-31', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0583', 1, '2026-08-31', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2608-0584 (2026-08-31 08:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0584', 1, 0, @c_mostrador, '2026-08-31 08:28:00', '2026-08-31', '2026-08-31', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0584', 1, '2026-08-31', 58.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 58.0);

-- Venta FA2608-0585 (2026-08-31 08:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2608-0585', 1, 0, @c_mostrador, '2026-08-31 08:50:00', '2026-08-31', '2026-08-31', 1, 33.0, 0, 33.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2608-0585', 1, '2026-08-31', 33.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 33.0);
-- Compra de insumos: SI2609-0113 (2026-09-01)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0113', 'FAC-PROV-113', 1, 0, @p_carne, '2026-09-01 08:00:00', '2026-09-01', '2026-09-01', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0113', 1, '2026-09-01', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2609-0586 (2026-09-01 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0586', 1, 0, @c_mostrador, '2026-09-01 09:21:00', '2026-09-01', '2026-09-01', 1, 33.0, 0, 33.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0586', 1, '2026-09-01', 33.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 33.0);

-- Venta FA2609-0587 (2026-09-01 09:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0587', 1, 0, @c_mostrador, '2026-09-01 09:23:00', '2026-09-01', '2026-09-01', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0587', 1, '2026-09-01', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2609-0588 (2026-09-01 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0588', 1, 0, @c_mostrador, '2026-09-01 09:09:00', '2026-09-01', '2026-09-01', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0588', 1, '2026-09-01', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2609-0589 (2026-09-02 08:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0589', 1, 0, @c_mostrador, '2026-09-02 08:23:00', '2026-09-02', '2026-09-02', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0589', 1, '2026-09-02', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0590 (2026-09-02 09:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0590', 1, 0, @c_mostrador, '2026-09-02 09:30:00', '2026-09-02', '2026-09-02', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0590', 1, '2026-09-02', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0591 (2026-09-02 10:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0591', 1, 0, @c_mostrador, '2026-09-02 10:07:00', '2026-09-02', '2026-09-02', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0591', 1, '2026-09-02', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2609-0592 (2026-09-02 09:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0592', 1, 0, @c_mostrador, '2026-09-02 09:03:00', '2026-09-02', '2026-09-02', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0592', 1, '2026-09-02', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0593 (2026-09-03 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0593', 1, 0, @c_mostrador, '2026-09-03 09:31:00', '2026-09-03', '2026-09-03', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0593', 1, '2026-09-03', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0594 (2026-09-03 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0594', 1, 0, @c_mostrador, '2026-09-03 09:13:00', '2026-09-03', '2026-09-03', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0594', 1, '2026-09-03', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0595 (2026-09-03 09:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0595', 1, 0, @c_juan, '2026-09-03 09:57:00', '2026-09-03', '2026-09-03', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0595', 1, '2026-09-03', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0596 (2026-09-03 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0596', 1, 0, @c_mostrador, '2026-09-03 10:46:00', '2026-09-03', '2026-09-03', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0596', 1, '2026-09-03', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0597 (2026-09-03 08:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0597', 1, 0, @c_mostrador, '2026-09-03 08:46:00', '2026-09-03', '2026-09-03', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0597', 1, '2026-09-03', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0598 (2026-09-03 10:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0598', 1, 0, @c_mostrador, '2026-09-03 10:32:00', '2026-09-03', '2026-09-03', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0598', 1, '2026-09-03', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0599 (2026-09-03 09:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0599', 1, 0, @c_mostrador, '2026-09-03 09:42:00', '2026-09-03', '2026-09-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0599', 1, '2026-09-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0600 (2026-09-04 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0600', 1, 0, @c_mostrador, '2026-09-04 10:39:00', '2026-09-04', '2026-09-04', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0600', 1, '2026-09-04', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0601 (2026-09-04 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0601', 1, 0, @c_mostrador, '2026-09-04 09:21:00', '2026-09-04', '2026-09-04', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0601', 1, '2026-09-04', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0602 (2026-09-04 10:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0602', 1, 0, @c_mostrador, '2026-09-04 10:11:00', '2026-09-04', '2026-09-04', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0602', 1, '2026-09-04', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0603 (2026-09-04 10:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0603', 1, 0, @c_mostrador, '2026-09-04 10:43:00', '2026-09-04', '2026-09-04', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0603', 1, '2026-09-04', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0604 (2026-09-04 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0604', 1, 0, @c_mostrador, '2026-09-04 09:43:00', '2026-09-04', '2026-09-04', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0604', 1, '2026-09-04', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0605 (2026-09-04 08:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0605', 1, 0, @c_mostrador, '2026-09-04 08:12:00', '2026-09-04', '2026-09-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0605', 1, '2026-09-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0606 (2026-09-04 10:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0606', 1, 0, @c_mostrador, '2026-09-04 10:52:00', '2026-09-04', '2026-09-04', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0606', 1, '2026-09-04', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2609-0607 (2026-09-05 08:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0607', 1, 0, @c_mostrador, '2026-09-05 08:59:00', '2026-09-05', '2026-09-05', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0607', 1, '2026-09-05', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0608 (2026-09-05 10:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0608', 1, 0, @c_juan, '2026-09-05 10:27:00', '2026-09-05', '2026-09-05', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0608', 1, '2026-09-05', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0609 (2026-09-05 08:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0609', 1, 0, @c_maria, '2026-09-05 08:43:00', '2026-09-05', '2026-09-05', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0609', 1, '2026-09-05', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2609-0610 (2026-09-05 10:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0610', 1, 0, @c_mostrador, '2026-09-05 10:03:00', '2026-09-05', '2026-09-05', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0610', 1, '2026-09-05', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0611 (2026-09-05 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0611', 1, 0, @c_mostrador, '2026-09-05 09:17:00', '2026-09-05', '2026-09-05', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0611', 1, '2026-09-05', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0612 (2026-09-05 10:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0612', 1, 0, @c_mostrador, '2026-09-05 10:26:00', '2026-09-05', '2026-09-05', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0612', 1, '2026-09-05', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0613 (2026-09-05 10:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0613', 1, 0, @c_mostrador, '2026-09-05 10:26:00', '2026-09-05', '2026-09-05', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0613', 1, '2026-09-05', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0614 (2026-09-05 11:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0614', 1, 0, @c_maria, '2026-09-05 11:20:00', '2026-09-05', '2026-09-05', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0614', 1, '2026-09-05', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0615 (2026-09-05 10:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0615', 1, 0, @c_juan, '2026-09-05 10:34:00', '2026-09-05', '2026-09-05', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0615', 1, '2026-09-05', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0616 (2026-09-05 09:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0616', 1, 0, @c_mostrador, '2026-09-05 09:29:00', '2026-09-05', '2026-09-05', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0616', 1, '2026-09-05', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2609-0617 (2026-09-05 08:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0617', 1, 0, @c_juan, '2026-09-05 08:35:00', '2026-09-05', '2026-09-05', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0617', 1, '2026-09-05', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2609-0618 (2026-09-05 09:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0618', 1, 0, @c_mostrador, '2026-09-05 09:15:00', '2026-09-05', '2026-09-05', 1, 20.0, 0, 20.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 4, 0, 20.0, 0, 20.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0618', 1, '2026-09-05', 20.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 20.0);

-- Venta FA2609-0619 (2026-09-05 09:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0619', 1, 0, @c_mostrador, '2026-09-05 09:06:00', '2026-09-05', '2026-09-05', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0619', 1, '2026-09-05', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0620 (2026-09-05 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0620', 1, 0, @c_mostrador, '2026-09-05 09:37:00', '2026-09-05', '2026-09-05', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0620', 1, '2026-09-05', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0621 (2026-09-05 10:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0621', 1, 0, @c_mostrador, '2026-09-05 10:57:00', '2026-09-05', '2026-09-05', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0621', 1, '2026-09-05', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);
-- Compra de insumos: SI2609-0114 (2026-09-06)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0114', 'FAC-PROV-114', 1, 0, @p_carne, '2026-09-06 08:00:00', '2026-09-06', '2026-09-06', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0114', 1, '2026-09-06', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2609-0622 (2026-09-06 11:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0622', 1, 0, @c_juan, '2026-09-06 11:04:00', '2026-09-06', '2026-09-06', 1, 77.0, 0, 77.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0622', 1, '2026-09-06', 77.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 77.0);

-- Venta FA2609-0623 (2026-09-06 10:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0623', 1, 0, @c_mostrador, '2026-09-06 10:20:00', '2026-09-06', '2026-09-06', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0623', 1, '2026-09-06', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0624 (2026-09-06 10:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0624', 1, 0, @c_mostrador, '2026-09-06 10:12:00', '2026-09-06', '2026-09-06', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0624', 1, '2026-09-06', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0625 (2026-09-06 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0625', 1, 0, @c_mostrador, '2026-09-06 09:22:00', '2026-09-06', '2026-09-06', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0625', 1, '2026-09-06', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0626 (2026-09-06 08:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0626', 1, 0, @c_mostrador, '2026-09-06 08:06:00', '2026-09-06', '2026-09-06', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0626', 1, '2026-09-06', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0627 (2026-09-06 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0627', 1, 0, @c_mostrador, '2026-09-06 10:24:00', '2026-09-06', '2026-09-06', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0627', 1, '2026-09-06', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0628 (2026-09-06 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0628', 1, 0, @c_maria, '2026-09-06 09:50:00', '2026-09-06', '2026-09-06', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0628', 1, '2026-09-06', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0629 (2026-09-06 09:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0629', 1, 0, @c_mostrador, '2026-09-06 09:59:00', '2026-09-06', '2026-09-06', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0629', 1, '2026-09-06', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0630 (2026-09-06 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0630', 1, 0, @c_mostrador, '2026-09-06 10:37:00', '2026-09-06', '2026-09-06', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0630', 1, '2026-09-06', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2609-0631 (2026-09-06 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0631', 1, 0, @c_mostrador, '2026-09-06 09:07:00', '2026-09-06', '2026-09-06', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0631', 1, '2026-09-06', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0632 (2026-09-06 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0632', 1, 0, @c_mostrador, '2026-09-06 10:14:00', '2026-09-06', '2026-09-06', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0632', 1, '2026-09-06', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0633 (2026-09-06 08:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0633', 1, 0, @c_mostrador, '2026-09-06 08:28:00', '2026-09-06', '2026-09-06', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0633', 1, '2026-09-06', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2609-0634 (2026-09-06 10:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0634', 1, 0, @c_mostrador, '2026-09-06 10:45:00', '2026-09-06', '2026-09-06', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0634', 1, '2026-09-06', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0635 (2026-09-07 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0635', 1, 0, @c_mostrador, '2026-09-07 10:10:00', '2026-09-07', '2026-09-07', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0635', 1, '2026-09-07', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0636 (2026-09-07 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0636', 1, 0, @c_juan, '2026-09-07 09:09:00', '2026-09-07', '2026-09-07', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0636', 1, '2026-09-07', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0637 (2026-09-07 11:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0637', 1, 0, @c_mostrador, '2026-09-07 11:33:00', '2026-09-07', '2026-09-07', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0637', 1, '2026-09-07', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0638 (2026-09-08 09:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0638', 1, 0, @c_mostrador, '2026-09-08 09:28:00', '2026-09-08', '2026-09-08', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0638', 1, '2026-09-08', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0639 (2026-09-08 11:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0639', 1, 0, @c_maria, '2026-09-08 11:38:00', '2026-09-08', '2026-09-08', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0639', 1, '2026-09-08', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2609-0640 (2026-09-08 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0640', 1, 0, @c_mostrador, '2026-09-08 10:04:00', '2026-09-08', '2026-09-08', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0640', 1, '2026-09-08', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2609-0641 (2026-09-08 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0641', 1, 0, @c_mostrador, '2026-09-08 09:09:00', '2026-09-08', '2026-09-08', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0641', 1, '2026-09-08', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0642 (2026-09-09 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0642', 1, 0, @c_mostrador, '2026-09-09 09:24:00', '2026-09-09', '2026-09-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0642', 1, '2026-09-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0643 (2026-09-09 09:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0643', 1, 0, @c_mostrador, '2026-09-09 09:38:00', '2026-09-09', '2026-09-09', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0643', 1, '2026-09-09', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2609-0644 (2026-09-09 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0644', 1, 0, @c_mostrador, '2026-09-09 09:20:00', '2026-09-09', '2026-09-09', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0644', 1, '2026-09-09', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0645 (2026-09-09 10:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0645', 1, 0, @c_mostrador, '2026-09-09 10:07:00', '2026-09-09', '2026-09-09', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0645', 1, '2026-09-09', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0646 (2026-09-10 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0646', 1, 0, @c_juan, '2026-09-10 10:19:00', '2026-09-10', '2026-09-10', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0646', 1, '2026-09-10', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2609-0647 (2026-09-10 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0647', 1, 0, @c_maria, '2026-09-10 10:17:00', '2026-09-10', '2026-09-10', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0647', 1, '2026-09-10', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2609-0648 (2026-09-10 10:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0648', 1, 0, @c_mostrador, '2026-09-10 10:15:00', '2026-09-10', '2026-09-10', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0648', 1, '2026-09-10', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0649 (2026-09-10 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0649', 1, 0, @c_maria, '2026-09-10 09:49:00', '2026-09-10', '2026-09-10', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0649', 1, '2026-09-10', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0650 (2026-09-10 10:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0650', 1, 0, @c_juan, '2026-09-10 10:52:00', '2026-09-10', '2026-09-10', 1, 57.0, 0, 57.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0650', 1, '2026-09-10', 57.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 57.0);
-- Compra de insumos: SI2609-0115 (2026-09-11)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0115', 'FAC-PROV-115', 1, 0, @p_carne, '2026-09-11 08:00:00', '2026-09-11', '2026-09-11', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0115', 1, '2026-09-11', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta B2B Institucional: FA2609-0651 (2026-09-11)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0651', 1, 0, @c_san_agustin, '2026-09-11 09:15:00', '2026-09-11', '2026-09-11', 1, 672.0, 0, 672.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 52, 0, 416.0, 0, 416.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 32, 0, 256.0, 0, 256.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0651', 1, '2026-09-11', 672.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 672.0);

-- Venta FA2609-0652 (2026-09-11 11:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0652', 1, 0, @c_juan, '2026-09-11 11:51:00', '2026-09-11', '2026-09-11', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0652', 1, '2026-09-11', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0653 (2026-09-11 10:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0653', 1, 0, @c_mostrador, '2026-09-11 10:05:00', '2026-09-11', '2026-09-11', 1, 31.0, 0, 31.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 1, 0, 7.0, 0, 7.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0653', 1, '2026-09-11', 31.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 31.0);

-- Venta FA2609-0654 (2026-09-11 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0654', 1, 0, @c_maria, '2026-09-11 09:58:00', '2026-09-11', '2026-09-11', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0654', 1, '2026-09-11', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2609-0655 (2026-09-11 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0655', 1, 0, @c_mostrador, '2026-09-11 10:49:00', '2026-09-11', '2026-09-11', 1, 21.0, 0, 21.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0655', 1, '2026-09-11', 21.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 21.0);

-- Venta FA2609-0656 (2026-09-11 08:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0656', 1, 0, @c_mostrador, '2026-09-11 08:45:00', '2026-09-11', '2026-09-11', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0656', 1, '2026-09-11', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0657 (2026-09-11 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0657', 1, 0, @c_mostrador, '2026-09-11 09:55:00', '2026-09-11', '2026-09-11', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0657', 1, '2026-09-11', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0658 (2026-09-11 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0658', 1, 0, @c_mostrador, '2026-09-11 09:40:00', '2026-09-11', '2026-09-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0658', 1, '2026-09-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0659 (2026-09-11 10:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0659', 1, 0, @c_juan, '2026-09-11 10:40:00', '2026-09-11', '2026-09-11', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0659', 1, '2026-09-11', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2609-0660 (2026-09-11 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0660', 1, 0, @c_maria, '2026-09-11 09:48:00', '2026-09-11', '2026-09-11', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0660', 1, '2026-09-11', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2609-0661 (2026-09-11 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0661', 1, 0, @c_maria, '2026-09-11 10:19:00', '2026-09-11', '2026-09-11', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0661', 1, '2026-09-11', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0662 (2026-09-12 10:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0662', 1, 0, @c_mostrador, '2026-09-12 10:28:00', '2026-09-12', '2026-09-12', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0662', 1, '2026-09-12', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0663 (2026-09-12 09:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0663', 1, 0, @c_maria, '2026-09-12 09:47:00', '2026-09-12', '2026-09-12', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0663', 1, '2026-09-12', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2609-0664 (2026-09-12 08:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0664', 1, 0, @c_mostrador, '2026-09-12 08:05:00', '2026-09-12', '2026-09-12', 1, 75.0, 0, 75.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0664', 1, '2026-09-12', 75.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 75.0);

-- Venta FA2609-0665 (2026-09-12 08:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0665', 1, 0, @c_maria, '2026-09-12 08:01:00', '2026-09-12', '2026-09-12', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0665', 1, '2026-09-12', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0666 (2026-09-12 11:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0666', 1, 0, @c_mostrador, '2026-09-12 11:44:00', '2026-09-12', '2026-09-12', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0666', 1, '2026-09-12', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0667 (2026-09-12 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0667', 1, 0, @c_mostrador, '2026-09-12 09:58:00', '2026-09-12', '2026-09-12', 1, 20.0, 0, 20.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 4, 0, 20.0, 0, 20.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0667', 1, '2026-09-12', 20.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 20.0);

-- Venta FA2609-0668 (2026-09-12 09:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0668', 1, 0, @c_mostrador, '2026-09-12 09:02:00', '2026-09-12', '2026-09-12', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0668', 1, '2026-09-12', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0669 (2026-09-12 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0669', 1, 0, @c_mostrador, '2026-09-12 09:31:00', '2026-09-12', '2026-09-12', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0669', 1, '2026-09-12', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0670 (2026-09-12 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0670', 1, 0, @c_juan, '2026-09-12 09:25:00', '2026-09-12', '2026-09-12', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0670', 1, '2026-09-12', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0671 (2026-09-12 11:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0671', 1, 0, @c_mostrador, '2026-09-12 11:38:00', '2026-09-12', '2026-09-12', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0671', 1, '2026-09-12', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0672 (2026-09-12 09:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0672', 1, 0, @c_mostrador, '2026-09-12 09:11:00', '2026-09-12', '2026-09-12', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0672', 1, '2026-09-12', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0673 (2026-09-12 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0673', 1, 0, @c_mostrador, '2026-09-12 10:50:00', '2026-09-12', '2026-09-12', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0673', 1, '2026-09-12', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0674 (2026-09-13 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0674', 1, 0, @c_mostrador, '2026-09-13 09:52:00', '2026-09-13', '2026-09-13', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0674', 1, '2026-09-13', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0675 (2026-09-13 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0675', 1, 0, @c_mostrador, '2026-09-13 10:17:00', '2026-09-13', '2026-09-13', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0675', 1, '2026-09-13', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0676 (2026-09-13 08:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0676', 1, 0, @c_maria, '2026-09-13 08:33:00', '2026-09-13', '2026-09-13', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0676', 1, '2026-09-13', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0677 (2026-09-13 09:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0677', 1, 0, @c_mostrador, '2026-09-13 09:03:00', '2026-09-13', '2026-09-13', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0677', 1, '2026-09-13', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0678 (2026-09-13 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0678', 1, 0, @c_mostrador, '2026-09-13 10:47:00', '2026-09-13', '2026-09-13', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0678', 1, '2026-09-13', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0679 (2026-09-13 09:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0679', 1, 0, @c_mostrador, '2026-09-13 09:29:00', '2026-09-13', '2026-09-13', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0679', 1, '2026-09-13', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0680 (2026-09-13 09:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0680', 1, 0, @c_mostrador, '2026-09-13 09:38:00', '2026-09-13', '2026-09-13', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0680', 1, '2026-09-13', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0681 (2026-09-13 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0681', 1, 0, @c_mostrador, '2026-09-13 09:41:00', '2026-09-13', '2026-09-13', 1, 88.0, 0, 88.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0681', 1, '2026-09-13', 88.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 88.0);

-- Venta FA2609-0682 (2026-09-13 10:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0682', 1, 0, @c_maria, '2026-09-13 10:09:00', '2026-09-13', '2026-09-13', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0682', 1, '2026-09-13', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0683 (2026-09-13 08:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0683', 1, 0, @c_mostrador, '2026-09-13 08:42:00', '2026-09-13', '2026-09-13', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0683', 1, '2026-09-13', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0684 (2026-09-13 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0684', 1, 0, @c_mostrador, '2026-09-13 10:50:00', '2026-09-13', '2026-09-13', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0684', 1, '2026-09-13', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0685 (2026-09-13 08:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0685', 1, 0, @c_maria, '2026-09-13 08:59:00', '2026-09-13', '2026-09-13', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0685', 1, '2026-09-13', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0686 (2026-09-13 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0686', 1, 0, @c_mostrador, '2026-09-13 09:44:00', '2026-09-13', '2026-09-13', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0686', 1, '2026-09-13', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0687 (2026-09-13 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0687', 1, 0, @c_mostrador, '2026-09-13 10:39:00', '2026-09-13', '2026-09-13', 1, 67.0, 0, 67.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0687', 1, '2026-09-13', 67.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 67.0);

-- Venta FA2609-0688 (2026-09-14 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0688', 1, 0, @c_maria, '2026-09-14 09:36:00', '2026-09-14', '2026-09-14', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0688', 1, '2026-09-14', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0689 (2026-09-14 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0689', 1, 0, @c_mostrador, '2026-09-14 09:55:00', '2026-09-14', '2026-09-14', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0689', 1, '2026-09-14', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0690 (2026-09-14 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0690', 1, 0, @c_mostrador, '2026-09-14 09:50:00', '2026-09-14', '2026-09-14', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0690', 1, '2026-09-14', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0691 (2026-09-14 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0691', 1, 0, @c_mostrador, '2026-09-14 09:55:00', '2026-09-14', '2026-09-14', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0691', 1, '2026-09-14', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0692 (2026-09-15 11:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0692', 1, 0, @c_juan, '2026-09-15 11:51:00', '2026-09-15', '2026-09-15', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0692', 1, '2026-09-15', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2609-0693 (2026-09-15 10:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0693', 1, 0, @c_juan, '2026-09-15 10:05:00', '2026-09-15', '2026-09-15', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0693', 1, '2026-09-15', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);
-- Compra de insumos: SI2609-0116 (2026-09-16)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0116', 'FAC-PROV-116', 1, 0, @p_carne, '2026-09-16 08:00:00', '2026-09-16', '2026-09-16', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0116', 1, '2026-09-16', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2609-0694 (2026-09-16 08:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0694', 1, 0, @c_maria, '2026-09-16 08:21:00', '2026-09-16', '2026-09-16', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0694', 1, '2026-09-16', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2609-0695 (2026-09-16 09:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0695', 1, 0, @c_mostrador, '2026-09-16 09:27:00', '2026-09-16', '2026-09-16', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0695', 1, '2026-09-16', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2609-0696 (2026-09-16 10:06:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0696', 1, 0, @c_mostrador, '2026-09-16 10:06:00', '2026-09-16', '2026-09-16', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0696', 1, '2026-09-16', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0697 (2026-09-16 10:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0697', 1, 0, @c_mostrador, '2026-09-16 10:23:00', '2026-09-16', '2026-09-16', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0697', 1, '2026-09-16', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0698 (2026-09-16 08:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0698', 1, 0, @c_mostrador, '2026-09-16 08:41:00', '2026-09-16', '2026-09-16', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0698', 1, '2026-09-16', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0699 (2026-09-16 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0699', 1, 0, @c_mostrador, '2026-09-16 09:25:00', '2026-09-16', '2026-09-16', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0699', 1, '2026-09-16', 35.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 35.0);

-- Venta FA2609-0700 (2026-09-17 10:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0700', 1, 0, @c_mostrador, '2026-09-17 10:13:00', '2026-09-17', '2026-09-17', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0700', 1, '2026-09-17', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2609-0701 (2026-09-17 09:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0701', 1, 0, @c_mostrador, '2026-09-17 09:46:00', '2026-09-17', '2026-09-17', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0701', 1, '2026-09-17', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0702 (2026-09-17 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0702', 1, 0, @c_juan, '2026-09-17 09:05:00', '2026-09-17', '2026-09-17', 1, 5.0, 0, 5.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0702', 1, '2026-09-17', 5.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 5.0);

-- Venta FA2609-0703 (2026-09-17 08:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0703', 1, 0, @c_mostrador, '2026-09-17 08:11:00', '2026-09-17', '2026-09-17', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0703', 1, '2026-09-17', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0704 (2026-09-18 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0704', 1, 0, @c_mostrador, '2026-09-18 09:36:00', '2026-09-18', '2026-09-18', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0704', 1, '2026-09-18', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0705 (2026-09-18 10:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0705', 1, 0, @c_juan, '2026-09-18 10:52:00', '2026-09-18', '2026-09-18', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0705', 1, '2026-09-18', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0706 (2026-09-18 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0706', 1, 0, @c_mostrador, '2026-09-18 09:50:00', '2026-09-18', '2026-09-18', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0706', 1, '2026-09-18', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2609-0707 (2026-09-18 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0707', 1, 0, @c_mostrador, '2026-09-18 09:22:00', '2026-09-18', '2026-09-18', 1, 21.0, 0, 21.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0707', 1, '2026-09-18', 21.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 21.0);

-- Venta FA2609-0708 (2026-09-18 11:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0708', 1, 0, @c_juan, '2026-09-18 11:37:00', '2026-09-18', '2026-09-18', 1, 34.0, 0, 34.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0708', 1, '2026-09-18', 34.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 34.0);

-- Venta FA2609-0709 (2026-09-18 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0709', 1, 0, @c_maria, '2026-09-18 09:43:00', '2026-09-18', '2026-09-18', 1, 33.0, 0, 33.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0709', 1, '2026-09-18', 33.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 33.0);

-- Venta FA2609-0710 (2026-09-18 08:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0710', 1, 0, @c_mostrador, '2026-09-18 08:56:00', '2026-09-18', '2026-09-18', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0710', 1, '2026-09-18', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2609-0711 (2026-09-18 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0711', 1, 0, @c_maria, '2026-09-18 09:22:00', '2026-09-18', '2026-09-18', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0711', 1, '2026-09-18', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0712 (2026-09-19 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0712', 1, 0, @c_mostrador, '2026-09-19 09:48:00', '2026-09-19', '2026-09-19', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0712', 1, '2026-09-19', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0713 (2026-09-19 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0713', 1, 0, @c_mostrador, '2026-09-19 09:16:00', '2026-09-19', '2026-09-19', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0713', 1, '2026-09-19', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2609-0714 (2026-09-19 08:38:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0714', 1, 0, @c_mostrador, '2026-09-19 08:38:00', '2026-09-19', '2026-09-19', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0714', 1, '2026-09-19', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0715 (2026-09-19 08:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0715', 1, 0, @c_mostrador, '2026-09-19 08:51:00', '2026-09-19', '2026-09-19', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0715', 1, '2026-09-19', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2609-0716 (2026-09-19 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0716', 1, 0, @c_mostrador, '2026-09-19 10:50:00', '2026-09-19', '2026-09-19', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0716', 1, '2026-09-19', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0717 (2026-09-19 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0717', 1, 0, @c_mostrador, '2026-09-19 09:13:00', '2026-09-19', '2026-09-19', 1, 125.0, 0, 125.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0717', 1, '2026-09-19', 125.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 125.0);

-- Venta FA2609-0718 (2026-09-19 08:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0718', 1, 0, @c_mostrador, '2026-09-19 08:45:00', '2026-09-19', '2026-09-19', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0718', 1, '2026-09-19', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0719 (2026-09-19 10:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0719', 1, 0, @c_mostrador, '2026-09-19 10:43:00', '2026-09-19', '2026-09-19', 1, 72.0, 0, 72.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0719', 1, '2026-09-19', 72.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 72.0);

-- Venta FA2609-0720 (2026-09-19 08:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0720', 1, 0, @c_mostrador, '2026-09-19 08:24:00', '2026-09-19', '2026-09-19', 1, 84.0, 0, 84.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0720', 1, '2026-09-19', 84.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 84.0);

-- Venta FA2609-0721 (2026-09-19 10:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0721', 1, 0, @c_mostrador, '2026-09-19 10:16:00', '2026-09-19', '2026-09-19', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0721', 1, '2026-09-19', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0722 (2026-09-19 08:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0722', 1, 0, @c_mostrador, '2026-09-19 08:25:00', '2026-09-19', '2026-09-19', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0722', 1, '2026-09-19', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0723 (2026-09-19 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0723', 1, 0, @c_juan, '2026-09-19 09:07:00', '2026-09-19', '2026-09-19', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0723', 1, '2026-09-19', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0724 (2026-09-20 11:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0724', 1, 0, @c_mostrador, '2026-09-20 11:26:00', '2026-09-20', '2026-09-20', 1, 52.0, 0, 52.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0724', 1, '2026-09-20', 52.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 52.0);

-- Venta FA2609-0725 (2026-09-20 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0725', 1, 0, @c_mostrador, '2026-09-20 09:20:00', '2026-09-20', '2026-09-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0725', 1, '2026-09-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0726 (2026-09-20 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0726', 1, 0, @c_mostrador, '2026-09-20 09:52:00', '2026-09-20', '2026-09-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0726', 1, '2026-09-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0727 (2026-09-20 11:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0727', 1, 0, @c_maria, '2026-09-20 11:57:00', '2026-09-20', '2026-09-20', 1, 96.0, 0, 96.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0727', 1, '2026-09-20', 96.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 96.0);

-- Venta FA2609-0728 (2026-09-20 09:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0728', 1, 0, @c_mostrador, '2026-09-20 09:15:00', '2026-09-20', '2026-09-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0728', 1, '2026-09-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0729 (2026-09-20 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0729', 1, 0, @c_maria, '2026-09-20 10:49:00', '2026-09-20', '2026-09-20', 1, 138.0, 0, 138.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0729', 1, '2026-09-20', 138.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 138.0);

-- Venta FA2609-0730 (2026-09-20 11:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0730', 1, 0, @c_juan, '2026-09-20 11:36:00', '2026-09-20', '2026-09-20', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0730', 1, '2026-09-20', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0731 (2026-09-20 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0731', 1, 0, @c_juan, '2026-09-20 09:41:00', '2026-09-20', '2026-09-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0731', 1, '2026-09-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0732 (2026-09-20 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0732', 1, 0, @c_mostrador, '2026-09-20 09:44:00', '2026-09-20', '2026-09-20', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0732', 1, '2026-09-20', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0733 (2026-09-20 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0733', 1, 0, @c_mostrador, '2026-09-20 09:53:00', '2026-09-20', '2026-09-20', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0733', 1, '2026-09-20', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0734 (2026-09-20 08:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0734', 1, 0, @c_mostrador, '2026-09-20 08:19:00', '2026-09-20', '2026-09-20', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0734', 1, '2026-09-20', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0735 (2026-09-20 09:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0735', 1, 0, @c_mostrador, '2026-09-20 09:33:00', '2026-09-20', '2026-09-20', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0735', 1, '2026-09-20', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0736 (2026-09-20 09:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0736', 1, 0, @c_juan, '2026-09-20 09:25:00', '2026-09-20', '2026-09-20', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0736', 1, '2026-09-20', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0737 (2026-09-20 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0737', 1, 0, @c_mostrador, '2026-09-20 10:37:00', '2026-09-20', '2026-09-20', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0737', 1, '2026-09-20', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0738 (2026-09-20 08:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0738', 1, 0, @c_juan, '2026-09-20 08:02:00', '2026-09-20', '2026-09-20', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0738', 1, '2026-09-20', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);
-- Compra de insumos: SI2609-0117 (2026-09-21)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0117', 'FAC-PROV-117', 1, 0, @p_carne, '2026-09-21 08:00:00', '2026-09-21', '2026-09-21', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0117', 1, '2026-09-21', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2609-0739 (2026-09-21 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0739', 1, 0, @c_maria, '2026-09-21 09:00:00', '2026-09-21', '2026-09-21', 1, 21.0, 0, 21.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 3, 0, 21.0, 0, 21.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0739', 1, '2026-09-21', 21.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 21.0);

-- Venta FA2609-0740 (2026-09-21 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0740', 1, 0, @c_mostrador, '2026-09-21 09:44:00', '2026-09-21', '2026-09-21', 1, 35.0, 0, 35.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0740', 1, '2026-09-21', 35.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 35.0);

-- Venta FA2609-0741 (2026-09-21 09:29:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0741', 1, 0, @c_mostrador, '2026-09-21 09:29:00', '2026-09-21', '2026-09-21', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0741', 1, '2026-09-21', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2609-0742 (2026-09-21 08:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0742', 1, 0, @c_juan, '2026-09-21 08:04:00', '2026-09-21', '2026-09-21', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0742', 1, '2026-09-21', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0743 (2026-09-22 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0743', 1, 0, @c_mostrador, '2026-09-22 09:21:00', '2026-09-22', '2026-09-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0743', 1, '2026-09-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0744 (2026-09-22 10:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0744', 1, 0, @c_mostrador, '2026-09-22 10:37:00', '2026-09-22', '2026-09-22', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0744', 1, '2026-09-22', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2609-0745 (2026-09-22 11:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0745', 1, 0, @c_maria, '2026-09-22 11:35:00', '2026-09-22', '2026-09-22', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0745', 1, '2026-09-22', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0746 (2026-09-23 10:54:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0746', 1, 0, @c_mostrador, '2026-09-23 10:54:00', '2026-09-23', '2026-09-23', 1, 26.0, 0, 26.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0746', 1, '2026-09-23', 26.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 26.0);

-- Venta FA2609-0747 (2026-09-23 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0747', 1, 0, @c_mostrador, '2026-09-23 10:10:00', '2026-09-23', '2026-09-23', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0747', 1, '2026-09-23', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0748 (2026-09-23 10:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0748', 1, 0, @c_mostrador, '2026-09-23 10:50:00', '2026-09-23', '2026-09-23', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0748', 1, '2026-09-23', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0749 (2026-09-23 10:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0749', 1, 0, @c_maria, '2026-09-23 10:31:00', '2026-09-23', '2026-09-23', 1, 33.0, 0, 33.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0749', 1, '2026-09-23', 33.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 33.0);

-- Venta FA2609-0750 (2026-09-23 10:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0750', 1, 0, @c_mostrador, '2026-09-23 10:53:00', '2026-09-23', '2026-09-23', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0750', 1, '2026-09-23', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0751 (2026-09-23 08:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0751', 1, 0, @c_mostrador, '2026-09-23 08:53:00', '2026-09-23', '2026-09-23', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0751', 1, '2026-09-23', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2609-0752 (2026-09-24 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0752', 1, 0, @c_mostrador, '2026-09-24 09:49:00', '2026-09-24', '2026-09-24', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0752', 1, '2026-09-24', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0753 (2026-09-24 09:30:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0753', 1, 0, @c_mostrador, '2026-09-24 09:30:00', '2026-09-24', '2026-09-24', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0753', 1, '2026-09-24', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0754 (2026-09-24 09:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0754', 1, 0, @c_mostrador, '2026-09-24 09:33:00', '2026-09-24', '2026-09-24', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0754', 1, '2026-09-24', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0755 (2026-09-24 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0755', 1, 0, @c_mostrador, '2026-09-24 10:14:00', '2026-09-24', '2026-09-24', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0755', 1, '2026-09-24', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2609-0756 (2026-09-24 10:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0756', 1, 0, @c_mostrador, '2026-09-24 10:39:00', '2026-09-24', '2026-09-24', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0756', 1, '2026-09-24', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta B2B Institucional: FA2609-0757 (2026-09-25)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0757', 1, 0, @c_san_agustin, '2026-09-25 09:15:00', '2026-09-25', '2026-09-25', 1, 744.0, 0, 744.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 60, 0, 480.0, 0, 480.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 33, 0, 264.0, 0, 264.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0757', 1, '2026-09-25', 744.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 744.0);

-- Venta FA2609-0758 (2026-09-25 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0758', 1, 0, @c_maria, '2026-09-25 10:10:00', '2026-09-25', '2026-09-25', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0758', 1, '2026-09-25', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0759 (2026-09-25 11:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0759', 1, 0, @c_mostrador, '2026-09-25 11:16:00', '2026-09-25', '2026-09-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0759', 1, '2026-09-25', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0760 (2026-09-25 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0760', 1, 0, @c_maria, '2026-09-25 09:37:00', '2026-09-25', '2026-09-25', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0760', 1, '2026-09-25', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0761 (2026-09-25 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0761', 1, 0, @c_mostrador, '2026-09-25 09:34:00', '2026-09-25', '2026-09-25', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0761', 1, '2026-09-25', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0762 (2026-09-25 08:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0762', 1, 0, @c_juan, '2026-09-25 08:01:00', '2026-09-25', '2026-09-25', 1, 37.0, 0, 37.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0762', 1, '2026-09-25', 37.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 37.0);

-- Venta FA2609-0763 (2026-09-25 09:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0763', 1, 0, @c_mostrador, '2026-09-25 09:19:00', '2026-09-25', '2026-09-25', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0763', 1, '2026-09-25', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0764 (2026-09-25 08:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0764', 1, 0, @c_maria, '2026-09-25 08:24:00', '2026-09-25', '2026-09-25', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0764', 1, '2026-09-25', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0765 (2026-09-25 10:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0765', 1, 0, @c_mostrador, '2026-09-25 10:01:00', '2026-09-25', '2026-09-25', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0765', 1, '2026-09-25', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0766 (2026-09-25 09:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0766', 1, 0, @c_mostrador, '2026-09-25 09:39:00', '2026-09-25', '2026-09-25', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0766', 1, '2026-09-25', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2609-0767 (2026-09-25 09:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0767', 1, 0, @c_mostrador, '2026-09-25 09:26:00', '2026-09-25', '2026-09-25', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0767', 1, '2026-09-25', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);
-- Compra de insumos: SI2609-0118 (2026-09-26)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2609-0118', 'FAC-PROV-118', 1, 0, @p_carne, '2026-09-26 08:00:00', '2026-09-26', '2026-09-26', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2609-0118', 1, '2026-09-26', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2609-0768 (2026-09-26 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0768', 1, 0, @c_maria, '2026-09-26 09:14:00', '2026-09-26', '2026-09-26', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0768', 1, '2026-09-26', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2609-0769 (2026-09-26 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0769', 1, 0, @c_maria, '2026-09-26 09:09:00', '2026-09-26', '2026-09-26', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0769', 1, '2026-09-26', 58.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 58.0);

-- Venta FA2609-0770 (2026-09-26 10:57:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0770', 1, 0, @c_mostrador, '2026-09-26 10:57:00', '2026-09-26', '2026-09-26', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0770', 1, '2026-09-26', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0771 (2026-09-26 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0771', 1, 0, @c_mostrador, '2026-09-26 10:49:00', '2026-09-26', '2026-09-26', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0771', 1, '2026-09-26', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0772 (2026-09-26 10:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0772', 1, 0, @c_juan, '2026-09-26 10:15:00', '2026-09-26', '2026-09-26', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0772', 1, '2026-09-26', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0773 (2026-09-26 11:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0773', 1, 0, @c_maria, '2026-09-26 11:12:00', '2026-09-26', '2026-09-26', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0773', 1, '2026-09-26', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0774 (2026-09-26 10:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0774', 1, 0, @c_mostrador, '2026-09-26 10:34:00', '2026-09-26', '2026-09-26', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0774', 1, '2026-09-26', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0775 (2026-09-26 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0775', 1, 0, @c_juan, '2026-09-26 09:44:00', '2026-09-26', '2026-09-26', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0775', 1, '2026-09-26', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0776 (2026-09-26 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0776', 1, 0, @c_mostrador, '2026-09-26 09:31:00', '2026-09-26', '2026-09-26', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0776', 1, '2026-09-26', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0777 (2026-09-26 08:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0777', 1, 0, @c_mostrador, '2026-09-26 08:02:00', '2026-09-26', '2026-09-26', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0777', 1, '2026-09-26', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0778 (2026-09-26 09:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0778', 1, 0, @c_mostrador, '2026-09-26 09:44:00', '2026-09-26', '2026-09-26', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0778', 1, '2026-09-26', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0779 (2026-09-26 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0779', 1, 0, @c_mostrador, '2026-09-26 09:40:00', '2026-09-26', '2026-09-26', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0779', 1, '2026-09-26', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0780 (2026-09-26 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0780', 1, 0, @c_maria, '2026-09-26 10:55:00', '2026-09-26', '2026-09-26', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0780', 1, '2026-09-26', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0781 (2026-09-26 08:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0781', 1, 0, @c_maria, '2026-09-26 08:15:00', '2026-09-26', '2026-09-26', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0781', 1, '2026-09-26', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0782 (2026-09-26 10:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0782', 1, 0, @c_mostrador, '2026-09-26 10:40:00', '2026-09-26', '2026-09-26', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0782', 1, '2026-09-26', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2609-0783 (2026-09-26 10:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0783', 1, 0, @c_juan, '2026-09-26 10:22:00', '2026-09-26', '2026-09-26', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0783', 1, '2026-09-26', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0784 (2026-09-26 11:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0784', 1, 0, @c_mostrador, '2026-09-26 11:52:00', '2026-09-26', '2026-09-26', 1, 41.0, 0, 41.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 5, 0, 25.0, 0, 25.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0784', 1, '2026-09-26', 41.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 41.0);

-- Venta FA2609-0785 (2026-09-27 09:07:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0785', 1, 0, @c_juan, '2026-09-27 09:07:00', '2026-09-27', '2026-09-27', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0785', 1, '2026-09-27', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0786 (2026-09-27 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0786', 1, 0, @c_mostrador, '2026-09-27 09:24:00', '2026-09-27', '2026-09-27', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0786', 1, '2026-09-27', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2609-0787 (2026-09-27 09:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0787', 1, 0, @c_mostrador, '2026-09-27 09:26:00', '2026-09-27', '2026-09-27', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0787', 1, '2026-09-27', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0788 (2026-09-27 10:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0788', 1, 0, @c_mostrador, '2026-09-27 10:13:00', '2026-09-27', '2026-09-27', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0788', 1, '2026-09-27', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2609-0789 (2026-09-27 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0789', 1, 0, @c_mostrador, '2026-09-27 09:53:00', '2026-09-27', '2026-09-27', 1, 94.0, 0, 94.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0789', 1, '2026-09-27', 94.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 94.0);

-- Venta FA2609-0790 (2026-09-27 09:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0790', 1, 0, @c_mostrador, '2026-09-27 09:03:00', '2026-09-27', '2026-09-27', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0790', 1, '2026-09-27', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2609-0791 (2026-09-27 09:56:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0791', 1, 0, @c_mostrador, '2026-09-27 09:56:00', '2026-09-27', '2026-09-27', 1, 56.0, 0, 56.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0791', 1, '2026-09-27', 56.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 56.0);

-- Venta FA2609-0792 (2026-09-27 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0792', 1, 0, @c_mostrador, '2026-09-27 09:49:00', '2026-09-27', '2026-09-27', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0792', 1, '2026-09-27', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2609-0793 (2026-09-27 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0793', 1, 0, @c_mostrador, '2026-09-27 09:41:00', '2026-09-27', '2026-09-27', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0793', 1, '2026-09-27', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2609-0794 (2026-09-27 09:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0794', 1, 0, @c_mostrador, '2026-09-27 09:20:00', '2026-09-27', '2026-09-27', 1, 88.0, 0, 88.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0794', 1, '2026-09-27', 88.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 88.0);

-- Venta FA2609-0795 (2026-09-27 09:13:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0795', 1, 0, @c_mostrador, '2026-09-27 09:13:00', '2026-09-27', '2026-09-27', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0795', 1, '2026-09-27', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0796 (2026-09-27 11:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0796', 1, 0, @c_mostrador, '2026-09-27 11:41:00', '2026-09-27', '2026-09-27', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0796', 1, '2026-09-27', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2609-0797 (2026-09-27 11:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0797', 1, 0, @c_mostrador, '2026-09-27 11:10:00', '2026-09-27', '2026-09-27', 1, 69.0, 0, 69.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0797', 1, '2026-09-27', 69.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 69.0);

-- Venta FA2609-0798 (2026-09-27 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0798', 1, 0, @c_maria, '2026-09-27 09:09:00', '2026-09-27', '2026-09-27', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0798', 1, '2026-09-27', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2609-0799 (2026-09-27 11:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0799', 1, 0, @c_mostrador, '2026-09-27 11:58:00', '2026-09-27', '2026-09-27', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0799', 1, '2026-09-27', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0800 (2026-09-27 10:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0800', 1, 0, @c_juan, '2026-09-27 10:34:00', '2026-09-27', '2026-09-27', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0800', 1, '2026-09-27', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0801 (2026-09-28 09:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0801', 1, 0, @c_mostrador, '2026-09-28 09:59:00', '2026-09-28', '2026-09-28', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0801', 1, '2026-09-28', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2609-0802 (2026-09-28 08:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0802', 1, 0, @c_maria, '2026-09-28 08:55:00', '2026-09-28', '2026-09-28', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0802', 1, '2026-09-28', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2609-0803 (2026-09-28 09:53:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0803', 1, 0, @c_mostrador, '2026-09-28 09:53:00', '2026-09-28', '2026-09-28', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0803', 1, '2026-09-28', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0804 (2026-09-28 10:28:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0804', 1, 0, @c_mostrador, '2026-09-28 10:28:00', '2026-09-28', '2026-09-28', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0804', 1, '2026-09-28', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0805 (2026-09-29 11:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0805', 1, 0, @c_juan, '2026-09-29 11:51:00', '2026-09-29', '2026-09-29', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0805', 1, '2026-09-29', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2609-0806 (2026-09-29 11:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0806', 1, 0, @c_mostrador, '2026-09-29 11:46:00', '2026-09-29', '2026-09-29', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0806', 1, '2026-09-29', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0807 (2026-09-30 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0807', 1, 0, @c_mostrador, '2026-09-30 09:22:00', '2026-09-30', '2026-09-30', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0807', 1, '2026-09-30', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2609-0808 (2026-09-30 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0808', 1, 0, @c_maria, '2026-09-30 09:00:00', '2026-09-30', '2026-09-30', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0808', 1, '2026-09-30', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2609-0809 (2026-09-30 10:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0809', 1, 0, @c_mostrador, '2026-09-30 10:48:00', '2026-09-30', '2026-09-30', 1, 25.0, 0, 25.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0809', 1, '2026-09-30', 25.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 25.0);

-- Venta FA2609-0810 (2026-09-30 10:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0810', 1, 0, @c_mostrador, '2026-09-30 10:41:00', '2026-09-30', '2026-09-30', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0810', 1, '2026-09-30', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2609-0811 (2026-09-30 10:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2609-0811', 1, 0, @c_maria, '2026-09-30 10:48:00', '2026-09-30', '2026-09-30', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2609-0811', 1, '2026-09-30', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);
-- Compra de insumos: SI2610-0119 (2026-10-01)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2610-0119', 'FAC-PROV-119', 1, 0, @p_carne, '2026-10-01 08:00:00', '2026-10-01', '2026-10-01', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2610-0119', 1, '2026-10-01', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2610-0812 (2026-10-01 10:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0812', 1, 0, @c_mostrador, '2026-10-01 10:04:00', '2026-10-01', '2026-10-01', 1, 17.0, 0, 17.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0812', 1, '2026-10-01', 17.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 17.0);

-- Venta FA2610-0813 (2026-10-01 09:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0813', 1, 0, @c_mostrador, '2026-10-01 09:43:00', '2026-10-01', '2026-10-01', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0813', 1, '2026-10-01', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2610-0814 (2026-10-01 09:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0814', 1, 0, @c_mostrador, '2026-10-01 09:41:00', '2026-10-01', '2026-10-01', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0814', 1, '2026-10-01', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0815 (2026-10-01 08:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0815', 1, 0, @c_mostrador, '2026-10-01 08:17:00', '2026-10-01', '2026-10-01', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0815', 1, '2026-10-01', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0816 (2026-10-02 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0816', 1, 0, @c_mostrador, '2026-10-02 09:16:00', '2026-10-02', '2026-10-02', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0816', 1, '2026-10-02', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0817 (2026-10-02 10:20:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0817', 1, 0, @c_mostrador, '2026-10-02 10:20:00', '2026-10-02', '2026-10-02', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0817', 1, '2026-10-02', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0818 (2026-10-02 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0818', 1, 0, @c_mostrador, '2026-10-02 09:50:00', '2026-10-02', '2026-10-02', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0818', 1, '2026-10-02', 58.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 58.0);

-- Venta FA2610-0819 (2026-10-02 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0819', 1, 0, @c_mostrador, '2026-10-02 09:37:00', '2026-10-02', '2026-10-02', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0819', 1, '2026-10-02', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0820 (2026-10-02 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0820', 1, 0, @c_mostrador, '2026-10-02 09:05:00', '2026-10-02', '2026-10-02', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0820', 1, '2026-10-02', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0821 (2026-10-02 10:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0821', 1, 0, @c_mostrador, '2026-10-02 10:27:00', '2026-10-02', '2026-10-02', 1, 15.0, 0, 15.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0821', 1, '2026-10-02', 15.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 15.0);

-- Venta FA2610-0822 (2026-10-02 08:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0822', 1, 0, @c_mostrador, '2026-10-02 08:01:00', '2026-10-02', '2026-10-02', 1, 58.0, 0, 58.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0822', 1, '2026-10-02', 58.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 58.0);

-- Venta FA2610-0823 (2026-10-02 10:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0823', 1, 0, @c_mostrador, '2026-10-02 10:14:00', '2026-10-02', '2026-10-02', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0823', 1, '2026-10-02', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0824 (2026-10-03 08:59:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0824', 1, 0, @c_mostrador, '2026-10-03 08:59:00', '2026-10-03', '2026-10-03', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0824', 1, '2026-10-03', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0825 (2026-10-03 10:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0825', 1, 0, @c_mostrador, '2026-10-03 10:40:00', '2026-10-03', '2026-10-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0825', 1, '2026-10-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0826 (2026-10-03 09:09:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0826', 1, 0, @c_maria, '2026-10-03 09:09:00', '2026-10-03', '2026-10-03', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0826', 1, '2026-10-03', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0827 (2026-10-03 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0827', 1, 0, @c_mostrador, '2026-10-03 09:21:00', '2026-10-03', '2026-10-03', 1, 77.0, 0, 77.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0827', 1, '2026-10-03', 77.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 77.0);

-- Venta FA2610-0828 (2026-10-03 10:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0828', 1, 0, @c_maria, '2026-10-03 10:46:00', '2026-10-03', '2026-10-03', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0828', 1, '2026-10-03', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0829 (2026-10-03 09:16:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0829', 1, 0, @c_mostrador, '2026-10-03 09:16:00', '2026-10-03', '2026-10-03', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0829', 1, '2026-10-03', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0830 (2026-10-03 10:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0830', 1, 0, @c_juan, '2026-10-03 10:15:00', '2026-10-03', '2026-10-03', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0830', 1, '2026-10-03', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2610-0831 (2026-10-03 08:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0831', 1, 0, @c_mostrador, '2026-10-03 08:36:00', '2026-10-03', '2026-10-03', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0831', 1, '2026-10-03', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0832 (2026-10-03 09:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0832', 1, 0, @c_mostrador, '2026-10-03 09:52:00', '2026-10-03', '2026-10-03', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0832', 1, '2026-10-03', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0833 (2026-10-03 08:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0833', 1, 0, @c_maria, '2026-10-03 08:52:00', '2026-10-03', '2026-10-03', 1, 68.0, 0, 68.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0833', 1, '2026-10-03', 68.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 68.0);

-- Venta FA2610-0834 (2026-10-03 09:02:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0834', 1, 0, @c_mostrador, '2026-10-03 09:02:00', '2026-10-03', '2026-10-03', 1, 10.0, 0, 10.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0834', 1, '2026-10-03', 10.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 10.0);

-- Venta FA2610-0835 (2026-10-03 10:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0835', 1, 0, @c_mostrador, '2026-10-03 10:12:00', '2026-10-03', '2026-10-03', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0835', 1, '2026-10-03', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2610-0836 (2026-10-03 11:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0836', 1, 0, @c_maria, '2026-10-03 11:03:00', '2026-10-03', '2026-10-03', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0836', 1, '2026-10-03', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2610-0837 (2026-10-04 10:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0837', 1, 0, @c_mostrador, '2026-10-04 10:45:00', '2026-10-04', '2026-10-04', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0837', 1, '2026-10-04', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2610-0838 (2026-10-04 10:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0838', 1, 0, @c_mostrador, '2026-10-04 10:55:00', '2026-10-04', '2026-10-04', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0838', 1, '2026-10-04', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0839 (2026-10-04 09:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0839', 1, 0, @c_juan, '2026-10-04 09:34:00', '2026-10-04', '2026-10-04', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0839', 1, '2026-10-04', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0840 (2026-10-04 10:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0840', 1, 0, @c_mostrador, '2026-10-04 10:51:00', '2026-10-04', '2026-10-04', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0840', 1, '2026-10-04', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0841 (2026-10-04 09:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0841', 1, 0, @c_mostrador, '2026-10-04 09:10:00', '2026-10-04', '2026-10-04', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0841', 1, '2026-10-04', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0842 (2026-10-04 08:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0842', 1, 0, @c_mostrador, '2026-10-04 08:40:00', '2026-10-04', '2026-10-04', 1, 92.0, 0, 92.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0842', 1, '2026-10-04', 92.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 92.0);

-- Venta FA2610-0843 (2026-10-04 10:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0843', 1, 0, @c_juan, '2026-10-04 10:27:00', '2026-10-04', '2026-10-04', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0843', 1, '2026-10-04', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0844 (2026-10-04 09:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0844', 1, 0, @c_mostrador, '2026-10-04 09:05:00', '2026-10-04', '2026-10-04', 1, 80.0, 0, 80.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0844', 1, '2026-10-04', 80.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 80.0);

-- Venta FA2610-0845 (2026-10-04 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0845', 1, 0, @c_mostrador, '2026-10-04 09:37:00', '2026-10-04', '2026-10-04', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0845', 1, '2026-10-04', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0846 (2026-10-04 08:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0846', 1, 0, @c_mostrador, '2026-10-04 08:08:00', '2026-10-04', '2026-10-04', 1, 45.0, 0, 45.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0846', 1, '2026-10-04', 45.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 45.0);

-- Venta FA2610-0847 (2026-10-04 09:14:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0847', 1, 0, @c_maria, '2026-10-04 09:14:00', '2026-10-04', '2026-10-04', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0847', 1, '2026-10-04', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0848 (2026-10-04 11:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0848', 1, 0, @c_mostrador, '2026-10-04 11:47:00', '2026-10-04', '2026-10-04', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0848', 1, '2026-10-04', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0849 (2026-10-04 09:11:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0849', 1, 0, @c_maria, '2026-10-04 09:11:00', '2026-10-04', '2026-10-04', 1, 61.0, 0, 61.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0849', 1, '2026-10-04', 61.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 61.0);

-- Venta FA2610-0850 (2026-10-04 08:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0850', 1, 0, @c_mostrador, '2026-10-04 08:51:00', '2026-10-04', '2026-10-04', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0850', 1, '2026-10-04', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0851 (2026-10-05 11:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0851', 1, 0, @c_mostrador, '2026-10-05 11:24:00', '2026-10-05', '2026-10-05', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0851', 1, '2026-10-05', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0852 (2026-10-05 10:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0852', 1, 0, @c_mostrador, '2026-10-05 10:12:00', '2026-10-05', '2026-10-05', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0852', 1, '2026-10-05', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);
-- Compra de insumos: SI2610-0120 (2026-10-06)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2610-0120', 'FAC-PROV-120', 1, 0, @p_carne, '2026-10-06 08:00:00', '2026-10-06', '2026-10-06', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2610-0120', 1, '2026-10-06', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2610-0853 (2026-10-06 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0853', 1, 0, @c_mostrador, '2026-10-06 09:58:00', '2026-10-06', '2026-10-06', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0853', 1, '2026-10-06', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0854 (2026-10-06 10:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0854', 1, 0, @c_mostrador, '2026-10-06 10:22:00', '2026-10-06', '2026-10-06', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0854', 1, '2026-10-06', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0855 (2026-10-06 10:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0855', 1, 0, @c_mostrador, '2026-10-06 10:34:00', '2026-10-06', '2026-10-06', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0855', 1, '2026-10-06', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0856 (2026-10-06 10:10:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0856', 1, 0, @c_mostrador, '2026-10-06 10:10:00', '2026-10-06', '2026-10-06', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0856', 1, '2026-10-06', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0857 (2026-10-07 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0857', 1, 0, @c_mostrador, '2026-10-07 09:17:00', '2026-10-07', '2026-10-07', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0857', 1, '2026-10-07', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0858 (2026-10-07 09:42:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0858', 1, 0, @c_mostrador, '2026-10-07 09:42:00', '2026-10-07', '2026-10-07', 1, 60.0, 0, 60.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0858', 1, '2026-10-07', 60.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 60.0);

-- Venta FA2610-0859 (2026-10-07 09:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0859', 1, 0, @c_mostrador, '2026-10-07 09:51:00', '2026-10-07', '2026-10-07', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0859', 1, '2026-10-07', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2610-0860 (2026-10-07 11:41:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0860', 1, 0, @c_maria, '2026-10-07 11:41:00', '2026-10-07', '2026-10-07', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0860', 1, '2026-10-07', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0861 (2026-10-08 10:27:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0861', 1, 0, @c_mostrador, '2026-10-08 10:27:00', '2026-10-08', '2026-10-08', 1, 28.0, 0, 28.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 2, 0, 10.0, 0, 10.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0861', 1, '2026-10-08', 28.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 28.0);

-- Venta FA2610-0862 (2026-10-08 09:08:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0862', 1, 0, @c_maria, '2026-10-08 09:08:00', '2026-10-08', '2026-10-08', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0862', 1, '2026-10-08', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0863 (2026-10-08 09:45:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0863', 1, 0, @c_mostrador, '2026-10-08 09:45:00', '2026-10-08', '2026-10-08', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0863', 1, '2026-10-08', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0864 (2026-10-08 11:04:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0864', 1, 0, @c_mostrador, '2026-10-08 11:04:00', '2026-10-08', '2026-10-08', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0864', 1, '2026-10-08', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0865 (2026-10-08 09:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0865', 1, 0, @c_mostrador, '2026-10-08 09:12:00', '2026-10-08', '2026-10-08', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0865', 1, '2026-10-08', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0866 (2026-10-09 11:43:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0866', 1, 0, @c_juan, '2026-10-09 11:43:00', '2026-10-09', '2026-10-09', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0866', 1, '2026-10-09', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2610-0867 (2026-10-09 10:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0867', 1, 0, @c_mostrador, '2026-10-09 10:19:00', '2026-10-09', '2026-10-09', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0867', 1, '2026-10-09', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2610-0868 (2026-10-09 10:44:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0868', 1, 0, @c_mostrador, '2026-10-09 10:44:00', '2026-10-09', '2026-10-09', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0868', 1, '2026-10-09', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2610-0869 (2026-10-09 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0869', 1, 0, @c_mostrador, '2026-10-09 09:48:00', '2026-10-09', '2026-10-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0869', 1, '2026-10-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0870 (2026-10-09 11:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0870', 1, 0, @c_mostrador, '2026-10-09 11:21:00', '2026-10-09', '2026-10-09', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0870', 1, '2026-10-09', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0871 (2026-10-09 10:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0871', 1, 0, @c_mostrador, '2026-10-09 10:12:00', '2026-10-09', '2026-10-09', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0871', 1, '2026-10-09', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0872 (2026-10-09 11:26:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0872', 1, 0, @c_juan, '2026-10-09 11:26:00', '2026-10-09', '2026-10-09', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0872', 1, '2026-10-09', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0873 (2026-10-09 09:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0873', 1, 0, @c_mostrador, '2026-10-09 09:24:00', '2026-10-09', '2026-10-09', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0873', 1, '2026-10-09', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2610-0874 (2026-10-09 11:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0874', 1, 0, @c_mostrador, '2026-10-09 11:47:00', '2026-10-09', '2026-10-09', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0874', 1, '2026-10-09', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0875 (2026-10-10 09:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0875', 1, 0, @c_mostrador, '2026-10-10 09:31:00', '2026-10-10', '2026-10-10', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0875', 1, '2026-10-10', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0876 (2026-10-10 09:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0876', 1, 0, @c_mostrador, '2026-10-10 09:33:00', '2026-10-10', '2026-10-10', 1, 28.0, 0, 28.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 4, 0, 28.0, 0, 28.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0876', 1, '2026-10-10', 28.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 28.0);

-- Venta FA2610-0877 (2026-10-10 11:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0877', 1, 0, @c_mostrador, '2026-10-10 11:58:00', '2026-10-10', '2026-10-10', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0877', 1, '2026-10-10', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2610-0878 (2026-10-10 10:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0878', 1, 0, @c_mostrador, '2026-10-10 10:25:00', '2026-10-10', '2026-10-10', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0878', 1, '2026-10-10', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0879 (2026-10-10 09:51:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0879', 1, 0, @c_maria, '2026-10-10 09:51:00', '2026-10-10', '2026-10-10', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0879', 1, '2026-10-10', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0880 (2026-10-10 08:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0880', 1, 0, @c_mostrador, '2026-10-10 08:40:00', '2026-10-10', '2026-10-10', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0880', 1, '2026-10-10', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0881 (2026-10-10 09:22:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0881', 1, 0, @c_mostrador, '2026-10-10 09:22:00', '2026-10-10', '2026-10-10', 1, 48.0, 0, 48.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0881', 1, '2026-10-10', 48.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 48.0);

-- Venta FA2610-0882 (2026-10-10 09:21:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0882', 1, 0, @c_mostrador, '2026-10-10 09:21:00', '2026-10-10', '2026-10-10', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0882', 1, '2026-10-10', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0883 (2026-10-10 09:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0883', 1, 0, @c_juan, '2026-10-10 09:47:00', '2026-10-10', '2026-10-10', 1, 43.0, 0, 43.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0883', 1, '2026-10-10', 43.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 43.0);

-- Venta FA2610-0884 (2026-10-10 10:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0884', 1, 0, @c_mostrador, '2026-10-10 10:17:00', '2026-10-10', '2026-10-10', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0884', 1, '2026-10-10', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2610-0885 (2026-10-10 09:37:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0885', 1, 0, @c_juan, '2026-10-10 09:37:00', '2026-10-10', '2026-10-10', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0885', 1, '2026-10-10', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0886 (2026-10-10 10:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0886', 1, 0, @c_mostrador, '2026-10-10 10:49:00', '2026-10-10', '2026-10-10', 1, 90.0, 0, 90.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb01, 'Gaseosa 500ml', 7.0, 6, 0, 42.0, 0, 42.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0886', 1, '2026-10-10', 90.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 90.0);

-- Venta FA2610-0887 (2026-10-10 08:39:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0887', 1, 0, @c_mostrador, '2026-10-10 08:39:00', '2026-10-10', '2026-10-10', 1, 64.0, 0, 64.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0887', 1, '2026-10-10', 64.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 64.0);

-- Venta FA2610-0888 (2026-10-10 09:12:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0888', 1, 0, @c_mostrador, '2026-10-10 09:12:00', '2026-10-10', '2026-10-10', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0888', 1, '2026-10-10', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);
-- Compra de insumos: SI2610-0121 (2026-10-11)
INSERT INTO llx_facture_fourn (ref, ref_supplier, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('SI2610-0121', 'FAC-PROV-121', 1, 0, @p_carne, '2026-10-11 08:00:00', '2026-10-11', '2026-10-11', 1, 950.0, 0, 950.0, 2, 1, 1, 1, @pay_code);
SET @last_fourn_id = LAST_INSERT_ID();
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins02, 'Carne de res', 38.00, 15, 0, 570.00, 0, 570.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins03, 'Pollo pechuga', 26.00, 10, 0, 260.00, 0, 260.00, 0);
INSERT INTO llx_facture_fourn_det (fk_facture_fourn, fk_product, description, pu_ht, qty, tva_tx, total_ht, tva, total_ttc, product_type) VALUES (@last_fourn_id, @p_ins01, 'Harina especial', 12.00, 10, 0, 120.00, 0, 120.00, 0);
INSERT INTO llx_paiementfourn (ref, entity, datep, amount, fk_paiement, fk_user_author, fk_bank) VALUES ('PMR2610-0121', 1, '2026-10-11', 950.0, @pay_code, 1, 0);
INSERT INTO llx_paiementfourn_facturefourn (fk_paiementfourn, fk_facturefourn, amount) VALUES (LAST_INSERT_ID(), @last_fourn_id, 950.0);

-- Venta FA2610-0889 (2026-10-11 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0889', 1, 0, @c_maria, '2026-10-11 09:58:00', '2026-10-11', '2026-10-11', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0889', 1, '2026-10-11', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0890 (2026-10-11 10:47:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0890', 1, 0, @c_mostrador, '2026-10-11 10:47:00', '2026-10-11', '2026-10-11', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0890', 1, '2026-10-11', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0891 (2026-10-11 10:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0891', 1, 0, @c_juan, '2026-10-11 10:32:00', '2026-10-11', '2026-10-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0891', 1, '2026-10-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0892 (2026-10-11 08:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0892', 1, 0, @c_mostrador, '2026-10-11 08:25:00', '2026-10-11', '2026-10-11', 1, 50.0, 0, 50.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0892', 1, '2026-10-11', 50.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 50.0);

-- Venta FA2610-0893 (2026-10-11 09:15:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0893', 1, 0, @c_maria, '2026-10-11 09:15:00', '2026-10-11', '2026-10-11', 1, 102.0, 0, 102.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0893', 1, '2026-10-11', 102.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 102.0);

-- Venta FA2610-0894 (2026-10-11 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0894', 1, 0, @c_mostrador, '2026-10-11 09:36:00', '2026-10-11', '2026-10-11', 1, 40.0, 0, 40.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 5, 0, 40.0, 0, 40.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0894', 1, '2026-10-11', 40.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 40.0);

-- Venta FA2610-0895 (2026-10-11 09:00:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0895', 1, 0, @c_mostrador, '2026-10-11 09:00:00', '2026-10-11', '2026-10-11', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0895', 1, '2026-10-11', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0896 (2026-10-11 09:58:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0896', 1, 0, @c_mostrador, '2026-10-11 09:58:00', '2026-10-11', '2026-10-11', 1, 77.0, 0, 77.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 5, 0, 45.0, 0, 45.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0896', 1, '2026-10-11', 77.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 77.0);

-- Venta FA2610-0897 (2026-10-11 09:35:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0897', 1, 0, @c_juan, '2026-10-11 09:35:00', '2026-10-11', '2026-10-11', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0897', 1, '2026-10-11', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2610-0898 (2026-10-11 10:05:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0898', 1, 0, @c_juan, '2026-10-11 10:05:00', '2026-10-11', '2026-10-11', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 4, 0, 36.0, 0, 36.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0898', 1, '2026-10-11', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2610-0899 (2026-10-11 09:48:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0899', 1, 0, @c_mostrador, '2026-10-11 09:48:00', '2026-10-11', '2026-10-11', 1, 66.0, 0, 66.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 6, 0, 48.0, 0, 48.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0899', 1, '2026-10-11', 66.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 66.0);

-- Venta FA2610-0900 (2026-10-11 10:32:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0900', 1, 0, @c_mostrador, '2026-10-11 10:32:00', '2026-10-11', '2026-10-11', 1, 54.0, 0, 54.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 6, 0, 54.0, 0, 54.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0900', 1, '2026-10-11', 54.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 54.0);

-- Venta FA2610-0901 (2026-10-11 09:03:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0901', 1, 0, @c_mostrador, '2026-10-11 09:03:00', '2026-10-11', '2026-10-11', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0901', 1, '2026-10-11', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0902 (2026-10-11 09:36:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0902', 1, 0, @c_mostrador, '2026-10-11 09:36:00', '2026-10-11', '2026-10-11', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0902', 1, '2026-10-11', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0903 (2026-10-11 10:24:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0903', 1, 0, @c_mostrador, '2026-10-11 10:24:00', '2026-10-11', '2026-10-11', 1, 32.0, 0, 32.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 4, 0, 32.0, 0, 32.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0903', 1, '2026-10-11', 32.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 32.0);

-- Venta FA2610-0904 (2026-10-12 08:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0904', 1, 0, @c_mostrador, '2026-10-12 08:49:00', '2026-10-12', '2026-10-12', 1, 18.0, 0, 18.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0904', 1, '2026-10-12', 18.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 18.0);

-- Venta FA2610-0905 (2026-10-12 09:49:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0905', 1, 0, @c_mostrador, '2026-10-12 09:49:00', '2026-10-12', '2026-10-12', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0905', 1, '2026-10-12', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0906 (2026-10-13 10:34:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0906', 1, 0, @c_juan, '2026-10-13 10:34:00', '2026-10-13', '2026-10-13', 1, 42.0, 0, 42.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 2, 0, 18.0, 0, 18.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0906', 1, '2026-10-13', 42.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 42.0);

-- Venta FA2610-0907 (2026-10-13 09:19:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0907', 1, 0, @c_mostrador, '2026-10-13 09:19:00', '2026-10-13', '2026-10-13', 1, 27.0, 0, 27.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0907', 1, '2026-10-13', 27.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 27.0);

-- Venta FA2610-0908 (2026-10-13 11:01:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0908', 1, 0, @c_mostrador, '2026-10-13 11:01:00', '2026-10-13', '2026-10-13', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0908', 1, '2026-10-13', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0909 (2026-10-13 10:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0909', 1, 0, @c_mostrador, '2026-10-13 10:23:00', '2026-10-13', '2026-10-13', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0909', 1, '2026-10-13', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0910 (2026-10-14 09:23:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0910', 1, 0, @c_mostrador, '2026-10-14 09:23:00', '2026-10-14', '2026-10-14', 1, 51.0, 0, 51.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0910', 1, '2026-10-14', 51.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 51.0);

-- Venta FA2610-0911 (2026-10-14 09:46:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0911', 1, 0, @c_mostrador, '2026-10-14 09:46:00', '2026-10-14', '2026-10-14', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0911', 1, '2026-10-14', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2610-0912 (2026-10-14 10:31:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0912', 1, 0, @c_mostrador, '2026-10-14 10:31:00', '2026-10-14', '2026-10-14', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0912', 1, '2026-10-14', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0913 (2026-10-14 09:17:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0913', 1, 0, @c_juan, '2026-10-14 09:17:00', '2026-10-14', '2026-10-14', 1, 23.0, 0, 23.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 3, 0, 15.0, 0, 15.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0913', 1, '2026-10-14', 23.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 23.0);

-- Venta FA2610-0914 (2026-10-14 09:55:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0914', 1, 0, @c_maria, '2026-10-14 09:55:00', '2026-10-14', '2026-10-14', 1, 24.0, 0, 24.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 3, 0, 24.0, 0, 24.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0914', 1, '2026-10-14', 24.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 24.0);

-- Venta FA2610-0915 (2026-10-15 10:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0915', 1, 0, @c_mostrador, '2026-10-15 10:40:00', '2026-10-15', '2026-10-15', 1, 36.0, 0, 36.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal04, 'Salteña Picante', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 3, 0, 27.0, 0, 27.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0915', 1, '2026-10-15', 36.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 36.0);

-- Venta FA2610-0916 (2026-10-15 09:50:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0916', 1, 0, @c_mostrador, '2026-10-15 09:50:00', '2026-10-15', '2026-10-15', 1, 9.0, 0, 9.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal03, 'Salteña Mixta', 9.0, 1, 0, 9.0, 0, 9.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0916', 1, '2026-10-15', 9.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 9.0);

-- Venta FA2610-0917 (2026-10-15 10:33:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0917', 1, 0, @c_mostrador, '2026-10-15 10:33:00', '2026-10-15', '2026-10-15', 1, 5.0, 0, 5.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_beb02, 'Jugo Mocochinchi', 5.0, 1, 0, 5.0, 0, 5.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0917', 1, '2026-10-15', 5.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 5.0);

-- Venta FA2610-0918 (2026-10-15 08:25:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0918', 1, 0, @c_mostrador, '2026-10-15 08:25:00', '2026-10-15', '2026-10-15', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal01, 'Salteña de Carne', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0918', 1, '2026-10-15', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

-- Venta FA2610-0919 (2026-10-15 09:40:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0919', 1, 0, @c_mostrador, '2026-10-15 09:40:00', '2026-10-15', '2026-10-15', 1, 16.0, 0, 16.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 2, 0, 16.0, 0, 16.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0919', 1, '2026-10-15', 16.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 16.0);

-- Venta FA2610-0920 (2026-10-15 11:52:00)
INSERT INTO llx_facture (ref, entity, type, fk_soc, datec, datef, date_valid, paye, total_ht, total_tva, total_ttc, fk_statut, fk_user_author, fk_user_valid, fk_cond_reglement, fk_mode_reglement) VALUES ('FA2610-0920', 1, 0, @c_mostrador, '2026-10-15 11:52:00', '2026-10-15', '2026-10-15', 1, 8.0, 0, 8.0, 2, 1, 1, 1, @pay_code);
SET @last_fac_id = LAST_INSERT_ID();
INSERT INTO llx_facturedet (fk_facture, fk_product, description, subprice, qty, tva_tx, total_ht, total_tva, total_ttc, product_type) VALUES (@last_fac_id, @p_sal02, 'Salteña de Pollo', 8.0, 1, 0, 8.0, 0, 8.0, 0);
INSERT INTO llx_paiement (ref, entity, datep, amount, fk_paiement, fk_user_creat, fk_bank) VALUES ('PAY2610-0920', 1, '2026-10-15', 8.0, @pay_code, 1, 0);
INSERT INTO llx_paiement_facture (fk_paiement, fk_facture, amount) VALUES (LAST_INSERT_ID(), @last_fac_id, 8.0);

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;