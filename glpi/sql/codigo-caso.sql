-- Numeración propia de tickets con prefijo (AT = clientes, IN = internos),
-- cada serie con su contador, sin plugins.
-- GLPI tiene un solo contador y su ID solo admite números: el código se escribe
-- al inicio del título justo antes de guardar el ticket.
-- Ejecutar: sudo mariadb glpi < codigo-caso.sql
SET NAMES utf8mb4;

CREATE TABLE contadores_caso (
  prefijo CHAR(2) PRIMARY KEY,
  ultimo  INT NOT NULL
) ENGINE=InnoDB;

-- Cada serie parte en el número siguiente al guardado aquí
INSERT INTO contadores_caso VALUES ('IN', 11499), ('AT', 11599);

DELIMITER //
CREATE TRIGGER codigo_caso
BEFORE INSERT ON glpi_tickets
FOR EACH ROW
BEGIN
  DECLARE pref CHAR(2);
  DECLARE num INT;

  -- La entidad interna (id 3 en esta instalación) lleva IN; el resto, AT
  SET pref = IF(NEW.entities_id = 3, 'IN', 'AT');

  -- FOR UPDATE bloquea la fila un instante: dos tickets simultáneos no repiten número
  SELECT ultimo + 1 INTO num FROM contadores_caso
   WHERE prefijo = pref FOR UPDATE;
  UPDATE contadores_caso SET ultimo = num WHERE prefijo = pref;

  SET NEW.name = IF(NEW.name IS NULL OR NEW.name = '',
                    CONCAT(pref, '-', num),
                    CONCAT(pref, '-', num, ' · ', NEW.name));
END//
DELIMITER ;
