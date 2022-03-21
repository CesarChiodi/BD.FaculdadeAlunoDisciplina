USE Faculdade_Aluno_Disciplina

CREATE TABLE ALUNO
(
	RA						NUMERIC(8) NOT NULL,
	CONSTRAINT PK_RA PRIMARY KEY (RA),
	NOME_ALUNO				VARCHAR(100) NOT NULL
);

CREATE TABLE DISCIPLINA
(
	CODIGO_DISCIPLINA		VARCHAR(10) NOT NULL,
	CONSTRAINT PK_CODIGO_DISCIPLINA PRIMARY KEY (CODIGO_DISCIPLINA),
	NOME_DISCIPLINA			VARCHAR(100) NOT NULL,
	CARGA_HORARIA			INT NOT NULL,
);

CREATE TABLE MATRICULA_DISCIPLINA
(
	RA						NUMERIC(8) FOREIGN KEY
	REFERENCES ALUNO(RA),
	CODIGO_DISCIPLINA		VARCHAR(10)	FOREIGN KEY
	REFERENCES DISCIPLINA(CODIGO_DISCIPLINA),
	NOTA_AVALIACAO1			DECIMAL(4,2) NOT NULL,
	NOTA_AVALIACAO2			DECIMAL(4,2) NOT NULL,
	AVALIACAO_SUBSTITUTIVA	DECIMAL(4,2),
	MEDIA_AVALIACAO			DECIMAL(4,2),
	ANO						INT NOT NULL,
	SEMESTRE				INT NOT NULL,
	FALTAS					INT NOT NULL,
	STATUS_CONCLUSAO		VARCHAR(50)
);

INSERT INTO ALUNO(RA, NOME_ALUNO)
VALUES(22456310, 'ROBERTO CARLOS'),
(12345678, 'ANA'),
(02456000, 'ANTONIO MARCOS')

INSERT INTO DISCIPLINA(CODIGO_DISCIPLINA, NOME_DISCIPLINA, CARGA_HORARIA)
VALUES('BD-01', 'BANCO DE DADOS 1', 80),
('BDA-08','BANCO ANALISE DE DADOS 8', 80),
('CP-2', 'CONSTRUCAO PROJETOS 2', 50)


INSERT INTO MATRICULA_DISCIPLINA(RA, CODIGO_DISCIPLINA, NOTA_AVALIACAO1, NOTA_AVALIACAO2, AVALIACAO_SUBSTITUTIVA, MEDIA_AVALIACAO, ANO, SEMESTRE, FALTAS, STATUS_CONCLUSAO)
VALUES(22456310,'BD-01', 5.00, 7.00, 6.00, NULL, 2021, 2, 4,  NULL),
(22456310,'CP-2', 8.00, 9.00, 6.00, NULL, 2021, 2, 0,  NULL),
(12345678,'BDA-08', 5.00, 3.00, 4.00, NULL, 2021, 2, 7,  NULL),
(12345678,'BD-01', 6.00, 2.00, 5.00, NULL, 2021, 2, 3,  NULL),
(02456000,'CP-2', 5.00, 7.00, 6.00, NULL, 2021, 2, 15,  NULL),
(02456000,'BD-01', 10.00, 7.00, 9.00, NULL, 2021, 2, 1,  NULL)


select *
from ALUNO

select *
from DISCIPLINA

select *
from MATRICULA_DISCIPLINA

--

DROP TABLE ALUNO
DROP TABLE DISCIPLINA
DROP TABLE MATRICULA_DISCIPLINA

--

GO

CREATE PROCEDURE ATUALIZA_STATUS_CONCLUSAO_PROC
	
	@RA NUMERIC(8),
	@CODIGO_DISCIPLINA VARCHAR(10)
	
AS
BEGIN
	DECLARE @MEDIA_AVALIACAO DECIMAL(4,2), @CARGA_HORARIA INT, @FALTAS INT, @NOTA_AVALIACAO1 DECIMAL(4,2), @NOTA_AVALIACAO2 DECIMAL(4,2), @AVALIACAO_SUBSTITUTIVA DECIMAL(4,2)

		--UPDATE dbo.MATRICULA_DISCIPLINA SET AVALIACAO_SUBSTITUTIVA WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
	SELECT
		@MEDIA_AVALIACAO = ((NOTA_AVALIACAO1 + NOTA_AVALIACAO2)/2), @FALTAS = FALTAS, @NOTA_AVALIACAO1 = NOTA_AVALIACAO1, @NOTA_AVALIACAO2 = NOTA_AVALIACAO2, @AVALIACAO_SUBSTITUTIVA = AVALIACAO_SUBSTITUTIVA FROM MATRICULA_DISCIPLINA WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
		
	SELECT	
		  @CARGA_HORARIA = CARGA_HORARIA FROM DISCIPLINA
		  WHERE  CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA

		IF @FALTAS / @CARGA_HORARIA > 0.25
			BEGIN
				UPDATE dbo.MATRICULA_DISCIPLINA SET STATUS_CONCLUSAO = 'REPROVADO POR FALTA' WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
			END
		ELSE IF @MEDIA_AVALIACAO >= 5.00
			BEGIN
				UPDATE dbo.MATRICULA_DISCIPLINA SET MEDIA_AVALIACAO = @MEDIA_AVALIACAO WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
				UPDATE dbo.MATRICULA_DISCIPLINA SET STATUS_CONCLUSAO = 'APROVADO' WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
			 END
		ELSE
		BEGIN
			IF @NOTA_AVALIACAO1 > @NOTA_AVALIACAO2
			 BEGIN
				SET @MEDIA_AVALIACAO = (@NOTA_AVALIACAO1 + @AVALIACAO_SUBSTITUTIVA)/2
			 END
			ELSE IF @NOTA_AVALIACAO1 < @NOTA_AVALIACAO2
			BEGIN
				SET @MEDIA_AVALIACAO = (@NOTA_AVALIACAO2 + @AVALIACAO_SUBSTITUTIVA)/2
			 END
			IF @MEDIA_AVALIACAO >= 5.00
				BEGIN
					UPDATE dbo.MATRICULA_DISCIPLINA SET MEDIA_AVALIACAO = @MEDIA_AVALIACAO WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
					UPDATE dbo.MATRICULA_DISCIPLINA SET STATUS_CONCLUSAO = 'APROVADO' WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
				 END
			ELSE
				BEGIN
					UPDATE dbo.MATRICULA_DISCIPLINA SET MEDIA_AVALIACAO = @MEDIA_AVALIACAO WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
					UPDATE dbo.MATRICULA_DISCIPLINA SET STATUS_CONCLUSAO = 'REPROVADO POR NOTA' WHERE RA = @RA AND CODIGO_DISCIPLINA = @CODIGO_DISCIPLINA
				END
		END
END

EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 22456310, 'BD-01'
EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 22456310, 'CP-2'
EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 12345678,'BDA-08'
EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 12345678,'BD-01'
EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 02456000,'CP-2'
EXECUTE ATUALIZA_STATUS_CONCLUSAO_PROC 02456000,'BD-01'


SELECT ALUNO.RA, ALUNO.NOME_ALUNO, DISCIPLINA.CODIGO_DISCIPLINA, DISCIPLINA.NOME_DISCIPLINA, NOTA_AVALIACAO1, NOTA_AVALIACAO2, AVALIACAO_SUBSTITUTIVA, MEDIA_AVALIACAO, FALTAS, STATUS_CONCLUSAO, ANO, SEMESTRE FROM MATRICULA_DISCIPLINA 
	INNER JOIN DISCIPLINA
	ON MATRICULA_DISCIPLINA.CODIGO_DISCIPLINA = DISCIPLINA.CODIGO_DISCIPLINA

	INNER JOIN ALUNO
	ON MATRICULA_DISCIPLINA.RA = ALUNO.RA

	WHERE ANO = 2021 AND DISCIPLINA.CODIGO_DISCIPLINA = 'BD-01'



SELECT ALUNO.RA, ALUNO.NOME_ALUNO, DISCIPLINA.CODIGO_DISCIPLINA, DISCIPLINA.NOME_DISCIPLINA, NOTA_AVALIACAO1, NOTA_AVALIACAO2, AVALIACAO_SUBSTITUTIVA, MEDIA_AVALIACAO, FALTAS, STATUS_CONCLUSAO, ANO, SEMESTRE FROM MATRICULA_DISCIPLINA
	INNER JOIN ALUNO 
	ON MATRICULA_DISCIPLINA.RA = ALUNO.RA

	INNER JOIN DISCIPLINA
	ON MATRICULA_DISCIPLINA.CODIGO_DISCIPLINA = DISCIPLINA.CODIGO_DISCIPLINA

	WHERE ANO = 2021 AND SEMESTRE = 2 AND ALUNO.RA = 22456310 

SELECT ALUNO.RA, ALUNO.NOME_ALUNO, DISCIPLINA.CODIGO_DISCIPLINA, DISCIPLINA.NOME_DISCIPLINA, NOTA_AVALIACAO1, NOTA_AVALIACAO2, AVALIACAO_SUBSTITUTIVA, MEDIA_AVALIACAO, STATUS_CONCLUSAO, ANO, SEMESTRE FROM MATRICULA_DISCIPLINA
	INNER JOIN DISCIPLINA
	ON MATRICULA_DISCIPLINA.CODIGO_DISCIPLINA = DISCIPLINA.CODIGO_DISCIPLINA
	INNER JOIN ALUNO 
	ON MATRICULA_DISCIPLINA.RA = ALUNO.RA

	WHERE ANO = 2021 AND STATUS_CONCLUSAO = 'REPROVADO POR NOTA'
