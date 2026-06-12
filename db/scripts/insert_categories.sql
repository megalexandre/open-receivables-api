-- Migração das categorias legadas para a tabela `categories`.
-- member_type traduzido do id legado: 1 = Sócio Fundador, 2 = Sócio Efetivo, 3 = Sócio Temporário.
-- Ids legados preservados (9 e 12 não existiam na origem) para manter o vínculo com `links.id_categoria_socio`.

INSERT INTO categories
  (id, name, descricao, member_type, amount_water, amount_partner, has_hydrometer, created_at, updated_at)
VALUES
  (1,  'Sócio Contribuinte Temporário', 'São aqueles que contribuem, regularmente com o pagamento da taxa do sistema de abastecimento de agua de lages, desde que comprovem, com documento, que soa propietarios de imovel em que residem ou inquilinios que tenham contrato de alguel, devidamenteo autenticados em cartorio.', 'Sócio Temporário', 30.00, 0.00, 0, NOW(), NOW()),
  (2,  'Sócio Contribuinte efetivo', 'São aqueles que estiverem devidamente casdastrados na acal e que estejam cumprindo seus deveres na forma desse estatuto.', 'Sócio Efetivo', 27.00, 3.00, 0, NOW(), NOW()),
  (3,  'Sócio Fundador', NULL, 'Sócio Fundador', 30.00, 0.00, 0, NOW(), NOW()),
  (4,  'Sócio Contribuinte Efetivo (Hidrômetro) A', 'Categoria dos Hidrometros', 'Sócio Efetivo', 27.00, 3.00, 1, NOW(), NOW()),
  (5,  'Sócio Contribuinte Temporario (Hidrômetro)', 'Hidrometros ativo paga taxa de R$ 20,00', 'Sócio Temporário', 30.00, 0.00, 1, NOW(), NOW()),
  (6,  'Hidrômetro Associado Desligado', 'Hidrometros Associado Desligado', 'Sócio Temporário', 24.00, 0.00, 1, NOW(), NOW()),
  (7,  'Contribuinte [INATIVO]', 'fazenda umbaumba', 'Sócio Temporário', 30.00, 3.00, 0, NOW(), NOW()),
  (8,  '(Contribuinte Efetivo (dupla residencia))...', 'Socios que possuirem dupla residencia', 'Sócio Efetivo', 54.00, 6.00, 0, NOW(), NOW()),
  (10, 'Dupla Residencia Socio Temporário', NULL, 'Sócio Temporário', 60.00, 0.00, 0, NOW(), NOW()),
  (11, 'Socio Não Residente', 'Contribuiente efetivo, São aqueles que estiverem devidamente cadastrado na Acal e que estejam cumprindo os seus deveres na forma deste Estatuto.', 'Sócio Efetivo', 9.00, 0.00, 0, NOW(), NOW()),
  (13, 'Contribuinte efetivo', NULL, 'Sócio Efetivo', 30.00, 3.00, 0, NOW(), NOW()),
  (14, 'Restaurante', NULL, 'Sócio Temporário', 48.80, 0.00, 0, NOW(), NOW()),
  (15, '(Sócio Contribuinte efetivo)', 'São aqueles que estiverem devidamente cadastrado na ACAL e que estejam cumprindo os seus deveres na forma deste estatuto.', 'Sócio Efetivo', 9.00, 0.00, 0, NOW(), NOW()),
  (16, '((CONTRIBUINTE EFETIVO)', NULL, 'Sócio Efetivo', 30.00, 3.00, 0, NOW(), NOW()),
  (17, 'FAZENDA', NULL, 'Sócio Temporário', 24.00, 0.00, 0, NOW(), NOW()),
  (18, 'Prefeitura', 'Categoria para cadastro dos predios da prefeitura', 'Sócio Temporário', 97.60, 0.00, 0, NOW(), NOW()),
  (19, 'Sócio Contribuinte Efetivo (hidrometro) B', 'fazenda de socio contribuinte efetivo.', 'Sócio Efetivo', 43.92, 4.88, 1, NOW(), NOW()),
  (20, 'Hidrômetro temporario', NULL, 'Sócio Temporário', 30.00, 0.00, 1, NOW(), NOW()),
  (21, 'Hidrômetro taxa minina 12', NULL, 'Sócio Temporário', 30.00, 0.00, 1, NOW(), NOW()),
  (22, 'sitio ...', NULL, 'Sócio Temporário', 48.80, 0.00, 0, NOW(), NOW()),
  (23, 'sitio....', NULL, 'Sócio Temporário', 48.80, 0.00, 0, NOW(), NOW()),
  (24, 'Contribuiente Temporario..', NULL, 'Sócio Temporário', 39.00, 0.00, 0, NOW(), NOW()),
  (25, 'categoria Exclusiva', NULL, 'Sócio Temporário', 30.00, 0.00, 0, NOW(), NOW()),
  (26, 'Contribuinte temporario', NULL, 'Sócio Temporário', 39.00, 0.00, 0, NOW(), NOW()),
  (27, 'Hidrômetro - Prefeitura', NULL, 'Sócio Temporário', 97.60, 0.00, 1, NOW(), NOW()),
  (28, 'Socio abril a dezembro 2013', NULL, 'Sócio Temporário', 3.90, 0.00, 0, NOW(), NOW()),
  (29, 'SÓCIO CONTRIBUINTE EFETIVO (Hidrômetro) C', NULL, 'Sócio Efetivo', 27.00, 3.00, 1, NOW(), NOW()),
  (30, 'SÓCIO TEMPORARIO (Hidrômetro)', NULL, 'Sócio Temporário', 48.80, 0.00, 1, NOW(), NOW()),
  (31, 'SÓCIO EFETIVO(Hidrômetro comercial)', NULL, 'Sócio Efetivo', 43.92, 4.88, 1, NOW(), NOW()),
  (32, 'Socio Temporario (Comercio)', NULL, 'Sócio Temporário', 48.80, 0.00, 0, NOW(), NOW());
