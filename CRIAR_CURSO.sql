CREATE TABLE ALUNO 
(   
    COD_ALUNO INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(30) NOT NULL,
 	CPF VARCHAR(11),
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR(30) NOT NULL,
    SENHA VARCHAR(30) NOT NULL,
    SALDO FLOAT
);

CREATE TABLE PROFESSOR
(   
    COD_PROFESSOR INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(30) NOT NULL,
    CPF VARCHAR(11),
    DATA_NASCIMENTO DATE NOT NULL,
    EMAIL VARCHAR(30) NOT NULL,
    SENHA VARCHAR(30) NOT NULL,
    SALDO FLOAT DEFAULT 0
);

CREATE TABLE CURSO
(   
    COD_CURSO INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(60) NOT NULL,
    DESCRICAO VARCHAR(300),
    DURACAO INT DEFAULT 0,
    PRECO FLOAT,
    NUMERO_MODULOS INT DEFAULT 0,
    NOTA_AVALIACAO_MEDIA TEXT DEFAULT 'SEM NOTA NO MOMENTO',
    NOTA_QUALIDADE TEXT DEFAULT 'SEM NOTA NO MOMENTO',
	PUBLICADO BOOLEAN DEFAULT FALSE,
	DISPONIBILIDADE BOOLEAN DEFAULT FALSE,
    COD_PROFESSOR INT NOT NULL REFERENCES PROFESSOR(COD_PROFESSOR) ON DELETE CASCADE
);

CREATE TABLE ALUNO_CURSO
(   
    COD_ALUNO_CURSO INT NOT NULL PRIMARY KEY,
    DATA_COMPRA DATE,
    NOTA_AVALIACAO FLOAT,
    COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO) ON DELETE CASCADE,
    COD_CURSO INT NOT NULL REFERENCES CURSO(COD_CURSO) ON DELETE CASCADE
);

CREATE TABLE MODULO
(   
    COD_MODULO SERIAL PRIMARY KEY,
    NOME VARCHAR(100),
    DESCRICAO VARCHAR(300),
    DURACAO INT,
    COD_CURSO INT NOT NULL REFERENCES CURSO(COD_CURSO) ON DELETE CASCADE
);

CREATE TABLE PRE_REQUESITO
(   
    COD_PRE_REQUESITO INT NOT NULL PRIMARY KEY,
    COD_MODULO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE
);

CREATE TABLE DISCIPLINA
(   
    COD_DISCIPLINA SERIAL PRIMARY KEY,
    NOME VARCHAR(100),
    DESCRICAO VARCHAR(300),
    COD_MODULO INT NOT NULL REFERENCES MODULO(COD_MODULO) ON DELETE CASCADE,
    COD_PROFESSOR INT NOT NULL REFERENCES PROFESSOR(COD_PROFESSOR) ON DELETE CASCADE
);

CREATE TABLE VIDEO_AULA
(   
    COD_VIDEO_AULA SERIAL PRIMARY KEY,
    NOME VARCHAR(30) NOT NULL,
    DESCRICAO VARCHAR(300),
    DURACAO FLOAT,
    COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE ALUNO_VIDEO_AULA
(   
    COD_ALUNO_VIDEO_AULA INT NOT NULL PRIMARY KEY,
    TEMPO_ASSISTIDO FLOAT,
    COD_ALUNO INT NOT NULL REFERENCES ALUNO(COD_ALUNO) ON DELETE CASCADE,
    COD_VIDEO_AULA INT NOT NULL REFERENCES VIDEO_AULA(COD_VIDEO_AULA) ON DELETE CASCADE
);

CREATE TABLE QUESTAO
(   
    COD_QUESTAO INT NOT NULL PRIMARY KEY,
    TEXTO VARCHAR(500),
    COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE QUESTIONARIO
(   
    COD_QUESTIONARIO INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(30),
    COD_DISCIPLINA INT NOT NULL REFERENCES DISCIPLINA(COD_DISCIPLINA) ON DELETE CASCADE
);

CREATE TABLE QUESTAO_QUESTIONARIO
(   
    COD_QUESTAO_QUESTIONARIO INT NOT NULL PRIMARY KEY,
    COD_QUESTAO INT NOT NULL REFERENCES QUESTAO(COD_QUESTAO) ON DELETE CASCADE,
    COD_QUESTIONARIO INT NOT NULL REFERENCES QUESTIONARIO(COD_QUESTIONARIO) ON DELETE CASCADE
);

CREATE TABLE QUESTAO_ALUNO
(   
    COD_QUESTAO_ALUNO INT NOT NULL PRIMARY KEY,
    RESPOSTAR_ALUNO VARCHAR(500),
    RESPOSTA_CORRETA BOOLEAN
);



							-- ################################################## --
							-- #################### FUNCTIONS ################### --
							-- ################################################## --

--------------------------------------------------------------------------------------------------------------------------------

/* RETORNA COD_PROFESSOR */
CREATE OR REPLACE FUNCTION RETORNA_COD_PROFESSOR(CPF_PROFESSOR TEXT)
RETURNS TABLE (PROFESSOR_CODIGO INT)
AS $$
BEGIN
    RETURN QUERY SELECT COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* CURSO EXISTENTE */
CREATE OR REPLACE FUNCTION CURSO_EXISTE(CODIGO_CURSO INT)
RETURNS INT
AS $$
DECLARE
	CURSO_EXISTE INT;
BEGIN
	SELECT C_R.COD_CURSO INTO CURSO_EXISTE FROM CURSO C_R WHERE C_R.COD_CURSO = CODIGO_CURSO;
	
	IF CURSO_EXISTE IS NOT NULL THEN
		RETURN CURSO_EXISTE;
		
	ELSE
		RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE! INFORME O CODIGO DE UM CURSO EXISTENTE...';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* MODULO EXISTENTE */
CREATE OR REPLACE FUNCTION MODULO_EXISTE(CODIGO_CURSO INT, CODIGO_MODULO INT)
RETURNS INT
AS $$
DECLARE
	CURSO_EXISTE INT := CURSO_EXISTE(CODIGO_CURSO);
	MODULO_EXISTE INT;
BEGIN
	IF CURSO_EXISTE IS NOT NULL THEN
		SELECT M_D.COD_MODULO INTO MODULO_EXISTE FROM CURSO C_R INNER JOIN MODULO M_D ON
		C_R.COD_CURSO = M_D.COD_CURSO WHERE M_D.COD_MODULO = CODIGO_MODULO;	
		
		IF MODULO_EXISTE IS NOT NULL THEN
			RETURN MODULO_EXISTE;
			
		ELSE
			RAISE EXCEPTION 'ESSE MODULO NÃO EXISTE! INFORME O CODIGO DE UM MODULO EXISTENTE...';
		END IF;
		
	ELSE
		RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, DIGITE UM COD_CURSO VALIDO!';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* DISCIPLINA EXISTENTE */
CREATE OR REPLACE FUNCTION DISCIPLINA_EXISTENTE(CODIGO_CURSO INT, CODIGO_MODULO INT, CODIGO_DISCIPLINA INT)
RETURNS INT
AS $$
DECLARE
	MODULO_EXISTE INT := MODULO_EXISTE(CODIGO_CURSO, CODIGO_MODULO);
	DISCIPLINA_EXISTENTE INT;
BEGIN
	IF MODULO_EXISTE IS NOT NULL THEN
		SELECT D_C.COD_DISCIPLINA INTO DISCIPLINA_EXISTENTE FROM CURSO C_R INNER JOIN MODULO M_D ON
		C_R.COD_CURSO = M_D.COD_CURSO INNER JOIN DISCIPLINA D_C ON
		M_D.COD_MODULO = D_C.COD_MODULO WHERE M_D.COD_MODULO = CODIGO_MODULO AND 
		D_C.COD_DISCIPLINA = CODIGO_DISCIPLINA;	
		
		IF DISCIPLINA_EXISTENTE IS NOT NULL THEN
			RETURN DISCIPLINA_EXISTENTE;
			
		ELSE
			RAISE EXCEPTION 'ESSA DISCIPLINA NÃO EXISTE! INFORME O CODIGO DE UMA DISCIPLINA EXISTENTE...';
		END IF;
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------
/* DELETANDO VIDEO */
CREATE OR REPLACE FUNCTION DELETAR_VIDEO(CPF_PROFESSOR TEXT, 
CODIGO_CURSO INT, COD_MODULO INT, COD_DISCIPLINA INT, CODIGO_VIDEO_AULA INT)
RETURNS VOID
AS $$
DECLARE
	DISCIPLINA_EXISTENTE INT = DISCIPLINA_EXISTENTE(CODIGO_CURSO, COD_MODULO, COD_DISCIPLINA);
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
BEGIN
	
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_PERTENCE_PROF IS NOT NULL THEN
			IF DISCIPLINA_EXISTENTE IS NOT NULL THEN
				DELETE FROM VIDEO_AULA V_A WHERE V_A.COD_VIDEO_AULA = CODIGO_VIDEO_AULA;
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;

END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------
/* DELETANDO DISCIPLINA */
CREATE OR REPLACE FUNCTION DELETAR_DISCIPLINA(CPF_PROFESSOR TEXT, 
CODIGO_CURSO INT, COD_MODULO INT, CODIGO_DISCIPLINA INT)
RETURNS VOID
AS $$
DECLARE
	DISCIPLINA_EXISTENTE INT = DISCIPLINA_EXISTENTE(CODIGO_CURSO, COD_MODULO, CODIGO_DISCIPLINA);
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
BEGIN
	
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_PERTENCE_PROF IS NOT NULL THEN
			IF DISCIPLINA_EXISTENTE IS NOT NULL THEN
				DELETE FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = CODIGO_DISCIPLINA;
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;
	
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------
/* DELETANDO MODULO */
CREATE OR REPLACE FUNCTION DELETAR_MODULO(CPF_PROFESSOR TEXT, CODIGO_CURSO INT, CODIGO_MODULO INT)
RETURNS VOID
AS $$
DECLARE
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
BEGIN
	
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_PERTENCE_PROF IS NOT NULL THEN
			DELETE FROM MODULO M_D WHERE M_D.COD_MODULO = CODIGO_MODULO;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;
	
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* ADICIONANDO VIDEO AULAS AS DISCIPLINAS  */
CREATE OR REPLACE FUNCTION ADICIONAR_VIDEO_AULA(CPF_PROFESSOR TEXT, CODIGO_CURSO INT, COD_MODULO INT, 
COD_DISCIPLINA INT, TITULO_VIDEO TEXT[], DESCRICAO TEXT[], DURACAO INT[])
RETURNS VOID
AS $$
DECLARE
	DISCIPLINA_EXISTENTE INT = DISCIPLINA_EXISTENTE(CODIGO_CURSO, COD_MODULO, COD_DISCIPLINA);
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
	CONTADOR INT := 1;
BEGIN
	
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_PERTENCE_PROF IS NOT NULL THEN
			IF DISCIPLINA_EXISTENTE IS NOT NULL THEN
				WHILE CONTADOR <= ARRAY_LENGTH(TITULO_VIDEO,1) LOOP
					INSERT INTO VIDEO_AULA VALUES (DEFAULT, TITULO_VIDEO[CONTADOR], DESCRICAO[CONTADOR], DURACAO[CONTADOR], COD_DISCIPLINA);
					CONTADOR := CONTADOR + 1;
				END LOOP;
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* CRIANDO UMA DISCIPLINAS PARA ALGUM MODULO */
CREATE OR REPLACE FUNCTION CRIAR_DISCIPLINAS(CPF_PROFESSOR TEXT, 
CODIGO_CURSO INT, CODIGO_MODULO INT, NOME_DISCIPLINA TEXT[], DESCRICAO_DISCIPLINA TEXT[])
RETURNS VOID
AS $$
DECLARE
	MODULO_EXISTENTE INT := MODULO_EXISTE(CODIGO_CURSO, CODIGO_MODULO);
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
	CONTADOR INT := 1;
BEGIN
	
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_PERTENCE_PROF IS NOT NULL THEN
			IF MODULO_EXISTENTE IS NOT NULL THEN
				WHILE CONTADOR <= ARRAY_LENGTH(NOME_DISCIPLINA,1) LOOP
					INSERT INTO DISCIPLINA VALUES (DEFAULT, NOME_DISCIPLINA[CONTADOR], DESCRICAO_DISCIPLINA[CONTADOR],
					CODIGO_MODULO, CODIGO_PROFESSOR);
					CONTADOR := CONTADOR + 1;
				END LOOP;
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* CRIAR MODULOS */
CREATE OR REPLACE FUNCTION CRIAR_MODULO(CPF_PROFESSOR TEXT, 
CODIGO_CURSO INT, NOME_MODULO TEXT[], DESCRICAO_MODULO TEXT[], DURACAO_MODULO INT[])
RETURNS VOID
AS $$
DECLARE
	CURSO_EXISTE INT := CURSO_EXISTE(CODIGO_CURSO);
	CODIGO_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_PERTENCE_PROF INT := (SELECT C_R.COD_CURSO FROM CURSO C_R WHERE C_R.COD_PROFESSOR = CODIGO_PROFESSOR AND C_R.COD_CURSO = CODIGO_CURSO);
	CONTADOR INT := 1;
BEGIN
	IF CODIGO_PROFESSOR IS NOT NULL THEN
		IF CURSO_EXISTE IS NOT NULL THEN
			IF CURSO_PERTENCE_PROF IS NOT NULL THEN
				WHILE CONTADOR <= ARRAY_LENGTH(NOME_MODULO,1) LOOP
					INSERT INTO MODULO VALUES (DEFAULT, 
					NOME_MODULO[CONTADOR], DESCRICAO_MODULO[CONTADOR], DURACAO_MODULO[CONTADOR], CODIGO_CURSO);
					CONTADOR := CONTADOR + 1;
				END LOOP;
			ELSE
				RAISE EXCEPTION 'ESSE CURSO NÃO PERCENTE A ESSE PROFESSOR!';
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, DIGITE UM COD_CURSO VALIDO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, INSIRA UM CPF VALIDO!';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------
 
/* CRIAR CURSO */
CREATE OR REPLACE FUNCTION CRIAR_CURSO(CPF_PROFESSOR TEXT, COD_CURSO INT, NOME_CURSO TEXT,
DESCRICAO TEXT, PRECO FLOAT)
RETURNS VOID
AS $$
DECLARE
	COD_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
BEGIN
	
	IF COD_PROFESSOR IS NOT NULL THEN
		INSERT INTO CURSO VALUES (COD_CURSO, NOME_CURSO, DESCRICAO, DEFAULT,
		PRECO, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, COD_PROFESSOR);
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, CPF INVALIDO!';
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

/* PUBLICAR CURSO */
CREATE OR REPLACE FUNCTION PUBLICAR_CURSO(CPF_PROFESSOR TEXT, CODIGO_CURSO INT)
RETURNS VOID
AS $$
DECLARE
	COD_PROFESSOR INT := (SELECT P_F.COD_PROFESSOR FROM PROFESSOR P_F WHERE P_F.CPF = CPF_PROFESSOR);
	CURSO_EXISTE INT := CURSO_EXISTE(CODIGO_CURSO);
	DISPONIBILIDADE BOOLEAN := (SELECT C_S.DISPONIBILIDADE FROM CURSO C_S WHERE C_S.COD_CURSO = CODIGO_CURSO);
BEGIN

	IF COD_PROFESSOR IS NOT NULL THEN
		IF CURSO_EXISTE IS NOT NULL THEN
			IF DISPONIBILIDADE = TRUE THEN
				UPDATE CURSO SET PUBLICADO = TRUE WHERE COD_CURSO = CODIGO_CURSO;
			ELSE
				RAISE EXCEPTION 'O CURSO NÃO ATENDE OS REQUESITOS NO MOMENTO PARA SER PUBLICADO, ATENDA OS REQUESITOS';
			END IF;
		ELSE
			RAISE EXCEPTION 'ESSE CURSO NÃO EXISTE, DIGITE UM COD_CURSO VALIDO!';
		END IF;
	ELSE
		RAISE EXCEPTION 'ESSE PROFESSOR NÃO EXISTE, CPF INVALIDO!';
	END IF;
	
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

						-- ############################################################### --
						-- ############ FUNCTIONS DA TRIGGER DISPONIBILIDADE ############ --
						-- ############################################################### --

CREATE OR REPLACE FUNCTION VALIDAR_DISCIPLINA(CODIGO_DISCIPLINA INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_VIDEOS INT := (SELECT COUNT(*) FROM VIDEO_AULA V_A WHERE V_A.COD_DISCIPLINA = CODIGO_DISCIPLINA);
BEGIN
	
	IF NUM_VIDEOS >= 2 THEN
		RAISE NOTICE 'TRUE';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'FALSE';
		RETURN FALSE;
	END IF;
END
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION VALIDAR_MODULO(CODIGO_MODULO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_DISCIPLINAS_VALIDAS INT := 0;
	REGISTRO_DISCIPLINA RECORD;
BEGIN
	
	FOR REGISTRO_DISCIPLINA IN (SELECT * FROM DISCIPLINA D_P WHERE D_P.COD_MODULO = CODIGO_MODULO) LOOP
		IF VALIDAR_DISCIPLINA(REGISTRO_DISCIPLINA.COD_DISCIPLINA) = TRUE THEN
			NUM_DISCIPLINAS_VALIDAS := NUM_DISCIPLINAS_VALIDAS + 1;
		END IF;
	END LOOP;
	
	IF NUM_DISCIPLINAS_VALIDAS >= 3 THEN
		RAISE NOTICE 'TRUE';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'FALSE';
		RETURN FALSE;
	END IF;
END
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION VALIDAR_CURSO(CODIGO_CURSO INT)
RETURNS BOOLEAN
AS $$
DECLARE
	NUM_MODULOS_VALIDOS INT := 0;
	REGISTRO_MODULO RECORD;
BEGIN
	
	FOR REGISTRO_MODULO IN (SELECT * FROM MODULO M_D WHERE M_D.COD_CURSO = CODIGO_CURSO) LOOP
		IF VALIDAR_MODULO(REGISTRO_MODULO.COD_MODULO) = TRUE THEN
			NUM_MODULOS_VALIDOS := NUM_MODULOS_VALIDOS + 1;
		END IF;
	END LOOP;
	
	IF NUM_MODULOS_VALIDOS >= 3 THEN
		RAISE NOTICE 'TRUE';
		RETURN TRUE;
	ELSE
		RAISE NOTICE 'FALSE';
		RETURN FALSE;
	END IF;
END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------
							-- ################################################## --
							-- ######## TRIGGER COM AFTER DISPONIBILIDADE ####### --
							-- ################################################## --

CREATE OR REPLACE FUNCTION EVENTO_MODULO_CURSO()
RETURNS TRIGGER
AS $$
BEGIN
	
	IF TG_OP = 'DELETE' THEN
		IF VALIDAR_CURSO(OLD.COD_CURSO) = FALSE THEN
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD.COD_CURSO;
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD.COD_CURSO;
		END IF;
	END IF;
	
	RETURN NEW;

END
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION EVENTO_DISCIPLINA_CURSO()
RETURNS TRIGGER
AS $$
DECLARE
	OLD_COD_CURSO INT := (SELECT COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO = OLD.COD_MODULO);
BEGIN
	
	IF TG_OP = 'DELETE' THEN
		IF VALIDAR_CURSO(OLD_COD_CURSO) = FALSE THEN
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
		END IF;
	END IF;

	RETURN NEW;
	
END
$$ LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION EVENTO_VIDEO_CURSO()
RETURNS TRIGGER
AS $$
DECLARE
	NEW_COD_CURSO INT := (SELECT COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO = 
	(SELECT D_C.COD_MODULO FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = NEW.COD_DISCIPLINA));
	OLD_COD_CURSO INT := (SELECT COD_CURSO FROM MODULO M_D WHERE M_D.COD_MODULO = 
	(SELECT D_C.COD_MODULO FROM DISCIPLINA D_C WHERE D_C.COD_DISCIPLINA = OLD.COD_DISCIPLINA));
BEGIN
	
	IF TG_OP = 'INSERT' THEN
		IF VALIDAR_CURSO(NEW_COD_CURSO) = TRUE THEN
			UPDATE CURSO SET DISPONIBILIDADE = TRUE WHERE COD_CURSO = NEW_COD_CURSO;
		END IF;
		
	ELSIF TG_OP = 'DELETE' THEN
		IF VALIDAR_CURSO(OLD_COD_CURSO) = FALSE THEN
			UPDATE CURSO SET DISPONIBILIDADE = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
			UPDATE CURSO SET PUBLICADO = FALSE WHERE COD_CURSO = OLD_COD_CURSO;
		END IF;
	END IF;
	
	RETURN NEW;

END
$$ LANGUAGE plpgsql

--------------------------------------------------------------------------------------------------------------------------------

							-- ################################################## --
							-- ############# TRIGGER DISPONIBILIDADE ############ --
							-- ################################################## --

CREATE TRIGGER EVENTO_ANALISA_DISPONIBILIDADE_CURSO_VIDEO
AFTER INSERT OR DELETE ON VIDEO_AULA
FOR EACH ROW
EXECUTE PROCEDURE EVENTO_VIDEO_CURSO();

CREATE TRIGGER EVENTO_ANALISA_DISPONIBILIDADE_CURSO_DISCIPLINA
AFTER DELETE ON DISCIPLINA
FOR EACH ROW
EXECUTE PROCEDURE EVENTO_DISCIPLINA_CURSO();

CREATE TRIGGER EVENTO_ANALISA_DISPONIBILIDADE_CURSO_MODULO
AFTER DELETE ON MODULO
FOR EACH ROW
EXECUTE PROCEDURE EVENTO_MODULO_CURSO();

-------------------------------------------------------------------------------------------------------------------------------

							-- ################################################## --
							-- ################### EXECUÇÕES #################### --
							-- ################################################## --

SELECT * FROM PROFESSOR
SELECT * FROM CURSO
SELECT * FROM MODULO
SELECT * FROM DISCIPLINA
SELECT * FROM VIDEO_AULA

INSERT INTO PROFESSOR VALUES 
(1, 'FELIPE', '12345', '2019-01-01', 'FELIPE@GMAIL.COM', '123', DEFAULT);

/* PARAMENTROS CPF, TITULO_CURSO, DESCRICAO_CURSO, VALOR_CURSO */
SELECT FROM CRIAR_CURSO
('12345', 1, 'MATEMATICA', 'APRENDENDO A FAZER CALCULOS', 100);

/* PARAMETROS CPF, COD_CURSO, ARRAY DE MODULO/S, ARRAY DESCRICAO/OES, ARRAY TEMPO_DISCIPLINA */
SELECT FROM CRIAR_MODULO
('12345', 1,
ARRAY ['MODULO 1', 'MODULO 2', 'MODULO 3'],
ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'],
ARRAY [10, 20, 30])

/* PARAMETROS CPF, COD_CURSO, COD_MODULO, ARRAY DISCIPLINA/S ARRAY DESCRICAO/OES */
SELECT FROM CRIAR_DISCIPLINAS
('12345', 1, 1, 
ARRAY ['APRENDENDO A SOMAR', 'APRENDENDO A DIVIDIR', 'APRENDENDO A SUBTRAIR'],
ARRAY ['DESCRICAO 1', 'DESCRICAO 2', 'DESCRICAO 3'])

/* PARAMETROS CPF, COD_CURSO, COD_MODULO, COD_DISCIPLINA, ARRAY VIDEO/S, ARRAY DESCRICAO/OES, ARRAY TEMPO_VIDEO */
SELECT FROM ADICIONAR_VIDEO_AULA
('12345', 1, 3, 9, 
ARRAY ['VIDEO 1', 'VIDEO 2', 'VIDEO 3'],
ARRAY ['DESC 1', 'DESC 2', 'DESC 3'],
ARRAY [10, 5, 3]);

/* PARAMETROS CPF, COD_CURSO, COD_MODULO, COD_DISCIPLINA, COD_VIDEO_AULA */
SELECT FROM DELETAR_VIDEO('12345', 1, 2, 6, 17)

/* PARAMETROS CPF, COD_CURSO, COD_MODULO, COD_DISCIPLINA */
SELECT FROM DELETAR_DISCIPLINA('12345', 1, 1, 1)

/* PARAMETROS CPF, COD_CURSO, COD_MODULO */
SELECT FROM DELETAR_MODULO('12345', 1, 1)

/* PARAMETROS CPF, COD_CURSO*/
SELECT FROM PUBLICAR_CURSO('12345', 1)
