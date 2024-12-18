/* Função para tratar dos endereços/moradas */

CREATE OR REPLACE FUNCTION gerar_endereco() RETURNS VARCHAR AS $$
DECLARE
    codigo_postal VARCHAR(8);
    localidades TEXT[] := ARRAY[
        'Lisboa', 'Porto', 'Amadora', 'Braga', 'Coimbra',
        'Faro', 'Funchal', 'Leiria', 'Aveiro', 'Évora',
        'Guarda', 'Portalegre', 'Santarém', 'Setúbal', 'Viana do Castelo',
        'Vila Real', 'Viseu', 'Beja', 'Castelo Branco', 'Bragança',
        'Guimarães', 'Matosinhos', 'Oeiras', 'Sintra', 'Cascais',
        'Figueira da Foz', 'Barreiro', 'Almada', 'Tomar', 'Torres Vedras',
        'Ponta Delgada', 'Maia', 'Odivelas', 'Montijo', 'Seixal',
        'Vila Nova de Gaia', 'Loulé', 'Caldas da Rainha', 'Lagos', 'Albufeira',
        'Vila do Conde', 'Viseu', 'Paredes', 'Penafiel', 'Évora',
        'Alcobaça', 'Marinha Grande', 'Vila Franca de Xira', 'Sines', 'Santarém',
        'Évora', 'Tavira', 'Elvas', 'Oliveira de Azeméis', 'Trofa',
        'Covilhã', 'Gouveia', 'Serpa', 'Montemor-o-Novo', 'Espinho'
    ]; 
    ruas_list TEXT[] := ARRAY[
        'Rua das Eiralvas', 'Avenida da Liberdade', 'Rua Augusta', 'Rua de São Bento', 'Rua da Prata', 'Rua dos Douradores', 'Rua de Santa Catarina', 'Avenida dos Aliados', 'Rua de Cedofeita',
        'Rua do Ouro', 'Rua do Carmo', 'Rua de Santa Justa', 'Rua do Crucifixo', 'Rua da Madalena', 'Rua do Comércio', 'Rua do Alecrim', 'Rua do Diário de Notícias', 'Rua do Século', 'Rua do Norte',
        'Rua do Salitre', 'Rua do Conde', 'Rua do Sol', 'Rua do Jardim', 'Rua do Almada', 'Rua do Loreto', 'Rua do Crucifixo', 'Rua do Ouro', 'Rua do Alecrim', 'Rua do Diário de Notícias',
        'Rua das Flores', 'Rua dos Fanqueiros', 'Rua da Vitória', 'Rua do Carmo', 'Rua de São Pedro', 'Rua da Saudade', 'Rua da Esperança', 'Rua da Paz', 'Rua das Amoreiras', 'Rua das Laranjeiras',
        'Rua de São Paulo', 'Rua de São José', 'Rua do Patrocínio', 'Rua do Calvário', 'Rua do Campo Alegre', 'Rua do Prior', 'Rua do Meio', 'Rua da Escola Politécnica', 'Rua do Instituto',
        'Rua da Junqueira', 'Rua dos Anjos', 'Rua da Bica', 'Rua das Taipas', 'Rua das Escolas Gerais', 'Rua da Palmeira', 'Rua do Crucifixo', 'Rua do Recolhimento', 'Rua da Madalena', 'Rua de São Boaventura',
        'Rua de São Mamede', 'Rua de São Marçal', 'Rua do Alecrim', 'Rua de São João', 'Rua da Vinha', 'Rua do Poço dos Negros', 'Rua das Pretas', 'Rua do Cardal', 'Rua da Horta Seca', 'Rua do Teixeira',
        'Rua do Telhal', 'Rua das Trinas', 'Rua do Vale', 'Rua da Misericórdia', 'Rua do Norte', 'Rua do Século', 'Rua do Paraíso', 'Rua das Parreiras', 'Rua de São Lázaro', 'Rua da Rosa',
        'Avenida dos Combatentes', 'Avenida de Roma', 'Avenida da República', 'Avenida Infante Santo', 'Avenida de Berna', 'Avenida de Ceuta', 'Avenida da Índia', 'Avenida Marginal', 'Avenida 25 de Abril', 'Avenida dos Bombeiros Voluntários',
        'Largo do Rato', 'Largo de Camões', 'Praça do Comércio', 'Praça da Figueira', 'Travessa do Carmo', 'Travessa da Espera', 'Travessa da Palha', 'Travessa do Monte', 'Travessa do Marquês de Sampaio', 'Travessa das Pedras Negras'
    ];
    rua VARCHAR;
    numero INT;
    localidade VARCHAR;
BEGIN
    rua := ruas_list[1 + FLOOR(RANDOM() * ARRAY_LENGTH(ruas_list, 1))];
    numero := 1 + FLOOR(RANDOM() * 1000);
    codigo_postal := LPAD(CAST(FLOOR(RANDOM() * 10000) AS TEXT), 4, '0') || '-' || LPAD(CAST(FLOOR(RANDOM() * 1000) AS TEXT), 3, '0');
    localidade := localidades[1 + FLOOR(RANDOM() * ARRAY_LENGTH(localidades, 1))];
    RETURN rua || ', ' || numero || ', ' || codigo_postal || ' ' || localidade;
END;
$$ LANGUAGE plpgsql;

/* Função que trata de gerar nifs distintos entre 111111111 e 999999999 */

CREATE OR REPLACE FUNCTION gerar_nif_unico() RETURNS CHAR(9) AS $$
DECLARE
    novo_nif CHAR(9);
BEGIN
    LOOP
        novo_nif := LPAD(CAST(FLOOR(RANDOM() * (999999999 - 111111111 + 1) + 111111111) AS TEXT), 9, '0');
        IF NOT EXISTS (SELECT 1 FROM enfermeiro WHERE nif = novo_nif) THEN
            RETURN novo_nif;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/* Função que trata dos números de telefone das pessoas */

CREATE OR REPLACE FUNCTION gerar_telefone() RETURNS VARCHAR AS $$
DECLARE
    prefixo TEXT;
    numero TEXT;
BEGIN
    prefixo := CASE
                   WHEN RANDOM() < 0.33 THEN '91'
                   WHEN RANDOM() < 0.66 THEN '93'
                   ELSE '96'
               END;
    numero := LPAD(CAST(FLOOR(RANDOM() * 10000000) AS TEXT), 7, '0');
    RETURN prefixo || numero;
END;
$$ LANGUAGE plpgsql;

/* Função que gera os ssn únicos */

CREATE OR REPLACE FUNCTION gerar_ssn_unico() RETURNS CHAR(11) AS $$
DECLARE
    novo_snn CHAR(11);
BEGIN
    LOOP
        novo_snn := LPAD(CAST(FLOOR(RANDOM() * (99999999999 - 11111111111 + 1) + 11111111111) AS TEXT), 11, '0');
        IF NOT EXISTS (SELECT 1 FROM paciente WHERE ssn = novo_snn) THEN
            RETURN novo_snn;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


/*-----CLINICAS-----*/

INSERT INTO clinica (nome, telefone, morada) VALUES
('Clínica de Santo António', '217123456', 'Rua das Padarias, 14, 2710-611 Sintra'),
('Clínica Santa Maria de Belém', '218765432', 'Rua da Figueirinha, 17, 2780-289 Oeiras'),
('Clínica do Parque', '219876543', 'Rua João de Deus, 5, 2700-165 Amadora'),
('Clínica Médica da Estrela', '217654321', 'Rua Frederico Arouca, 2750-642 Cascais'),
('Clínica Saúde Mais', '216543210', 'Avenida da Liberdade, 1250-140 Lisboa');

/*-----ENFERMEIROS-----*/

INSERT INTO enfermeiro (nif, nome, telefone, morada, nome_clinica) VALUES
(gerar_nif_unico(), 'Ana Silva', gerar_telefone(), gerar_endereco(), 'Clínica de Santo António'),
(gerar_nif_unico(), 'Bruno Costa', gerar_telefone(), gerar_endereco(), 'Clínica de Santo António'),
(gerar_nif_unico(), 'Carla Mendes', gerar_telefone(), gerar_endereco(), 'Clínica de Santo António'),
(gerar_nif_unico(), 'Diana Oliveira', gerar_telefone(), gerar_endereco(), 'Clínica de Santo António'),
(gerar_nif_unico(), 'Eduardo Lima', gerar_telefone(), gerar_endereco(), 'Clínica de Santo António'),
(gerar_nif_unico(), 'Gabriela Fernandes', gerar_telefone(), gerar_endereco(), 'Clínica Santa Maria de Belém'),
(gerar_nif_unico(), 'Hugo Martins', gerar_telefone(), gerar_endereco(), 'Clínica Santa Maria de Belém'),
(gerar_nif_unico(), 'Inês Rocha', gerar_telefone(), gerar_endereco(), 'Clínica Santa Maria de Belém'),
(gerar_nif_unico(), 'João Cardoso', gerar_telefone(), gerar_endereco(), 'Clínica Santa Maria de Belém'),
(gerar_nif_unico(), 'Kátia Gonçalves', gerar_telefone(), gerar_endereco(), 'Clínica Santa Maria de Belém'),
(gerar_nif_unico(), 'Mariana Sousa', gerar_telefone(), gerar_endereco(), 'Clínica do Parque'),
(gerar_nif_unico(), 'Nuno Santos', gerar_telefone(), gerar_endereco(), 'Clínica do Parque'),
(gerar_nif_unico(), 'Olívia Matos', gerar_telefone(), gerar_endereco(), 'Clínica do Parque'),
(gerar_nif_unico(), 'Pedro Ribeiro', gerar_telefone(), gerar_endereco(), 'Clínica do Parque'),
(gerar_nif_unico(), 'Rafaela Pinto', gerar_telefone(), gerar_endereco(), 'Clínica do Parque'),
(gerar_nif_unico(), 'Teresa Barros', gerar_telefone(), gerar_endereco(), 'Clínica Médica da Estrela'),
(gerar_nif_unico(), 'Hugo Fernandes', gerar_telefone(), gerar_endereco(), 'Clínica Médica da Estrela'),
(gerar_nif_unico(), 'Vera Gomes', gerar_telefone(), gerar_endereco(), 'Clínica Médica da Estrela'),
(gerar_nif_unico(), 'Xavier Costa', gerar_telefone(), gerar_endereco(), 'Clínica Médica da Estrela'),
(gerar_nif_unico(), 'Yara Monteiro', gerar_telefone(), gerar_endereco(), 'Clínica Médica da Estrela'),
(gerar_nif_unico(), 'André Lopes', gerar_telefone(), gerar_endereco(), 'Clínica Saúde Mais'),
(gerar_nif_unico(), 'Beatriz Nogueira', gerar_telefone(), gerar_endereco(), 'Clínica Saúde Mais'),
(gerar_nif_unico(), 'Cátia Neves', gerar_telefone(), gerar_endereco(), 'Clínica Saúde Mais'),
(gerar_nif_unico(), 'Diogo Antunes', gerar_telefone(), gerar_endereco(), 'Clínica Saúde Mais'),
(gerar_nif_unico(), 'Eva Castro', gerar_telefone(), gerar_endereco(), 'Clínica Saúde Mais');


/*-----MÉDICOS-----*/

INSERT INTO medico (nif, nome, telefone, morada, especialidade) VALUES
(gerar_nif_unico(), 'Tomás Ferreira', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Diogo Oliveira', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Rodrigo Almeida', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Ana Costa', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Bruno Martins', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Carla Santos', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Diana Silva', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Eduardo Pinto', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Fábio Rocha', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Gabriela Pereira', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Hugo Santos', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Inês Lopes', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'João Pires', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Larissa Nunes', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Marcos Ribeiro', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Nuno Correia', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Patrícia Mendes', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Ricardo Azevedo', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Sara Martins', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Tiago Barros', gerar_telefone(), gerar_endereco(), 'Clínica Geral'),
(gerar_nif_unico(), 'Ana Cardoso', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Bruno Andrade', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Carla Ribeiro', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Diogo Azevedo', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Eduardo Julmar', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Fábio Costa', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Gabriela Lima', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Hugo Rocha', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Inês Azevedo', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'João Mendes', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Larissa Costa', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Marcos Lopes', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Nuno Fernandes', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Patrícia Cardoso', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Ricardo Martins', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Sara Rocha', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Tiago Ribeiro', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Vera Silva', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Xavier Silva', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Anabela Ferragudo', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Ambrósio Andrade', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Bruno Lopes', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Carla Jesus', gerar_telefone(), gerar_endereco(), 'Ortopedia'),
(gerar_nif_unico(), 'Diogo Santos', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Eduardo Silva', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Fábio Anacleto', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Gabriela Antonieta', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Hugo Jesus', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Inês António', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'João Vela', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Larissa Pinto', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Marcos Andrade', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Nuno Anjos', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Patrícia Santos', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Ricardo Manuel', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Sara Almeida', gerar_telefone(), gerar_endereco(), 'Neurologia'),
(gerar_nif_unico(), 'Tiago Geraldes', gerar_telefone(), gerar_endereco(), 'Dermatologia'),
(gerar_nif_unico(), 'Vera José', gerar_telefone(), gerar_endereco(), 'Cardiologia'),
(gerar_nif_unico(), 'Xavier Gregores', gerar_telefone(), gerar_endereco(), 'Pediatria'),
(gerar_nif_unico(), 'Anabela Cerejeira', gerar_telefone(), gerar_endereco(), 'Neurologia');
 

/*-----PACIENTES-----*/

CREATE OR REPLACE FUNCTION gerar_pacientes() RETURNS VOID AS $$
DECLARE
    i INT;
    ssn CHAR(11);
    nif CHAR(9);
    nome VARCHAR(80);
    telefone VARCHAR(15);
    morada VARCHAR(255);
    data_nasc DATE;
    nomes_proibidos TEXT[] := ARRAY[
        'Ana Silva', 'Bruno Costa', 'Carla Mendes', 'Diana Oliveira', 'Eduardo Lima',
        'Gabriela Fernandes', 'Hugo Martins', 'Inês Rocha', 'João Cardoso', 'Kátia Gonçalves',
        'Mariana Sousa', 'Nuno Santos', 'Olívia Matos', 'Pedro Ribeiro', 'Rafaela Pinto',
        'Teresa Barros', 'Hugo Fernandes', 'Vera Gomes', 'Xavier Costa', 'Yara Monteiro',
        'André Lopes', 'Beatriz Nogueira', 'Cátia Neves', 'Diogo Antunes', 'Eva Castro',
        'Tomás Ferreira', 'Diogo Oliveira', 'Rodrigo Almeida', 'Ana Costa', 'Bruno Martins',
        'Carla Santos', 'Diana Silva', 'Eduardo Pinto', 'Fábio Rocha', 'Gabriela Pereira',
        'Hugo Santos', 'Inês Lopes', 'João Pires', 'Larissa Nunes', 'Marcos Ribeiro',
        'Nuno Correia', 'Patrícia Mendes', 'Ricardo Azevedo', 'Sara Martins', 'Tiago Barros',
        'Ana Cardoso', 'Bruno Andrade', 'Carla Ribeiro', 'Diogo Azevedo', 'Eduardo Julmar',
        'Fábio Costa', 'Gabriela Lima', 'Hugo Rocha', 'Inês Azevedo', 'João Mendes',
        'Larissa Costa', 'Marcos Lopes', 'Nuno Fernandes', 'Patrícia Cardoso', 'Ricardo Martins',
        'Sara Rocha', 'Tiago Ribeiro', 'Vera Silva', 'Xavier Silva', 'Anabela Ferragudo',
        'Ambrósio Andrade', 'Bruno Lopes', 'Carla Jesus', 'Diogo Santos', 'Eduardo Silva',
        'Fábio Anacleto', 'Gabriela Antonieta', 'Hugo Jesus', 'Inês António', 'João Vela',
        'Larissa Pinto', 'Marcos Andrade', 'Nuno Anjos', 'Patrícia Santos', 'Ricardo Manuel',
        'Sara Almeida', 'Tiago Geraldes', 'Vera José', 'Xavier Gregores', 'Anabela Cerejeira'
    ];
    nomes_utilizados TEXT[] := ARRAY[]::TEXT[];
    nome_temp TEXT;
    sobrenome_temp TEXT;
    nomes TEXT[] := ARRAY[
        'Ana', 'Bruno', 'Carla', 'Diana', 'Eduardo', 
        'Fábio', 'Gabriela', 'Hugo', 'Inês', 'João', 
        'Larissa', 'Marcos', 'Nuno', 'Patrícia', 'Ricardo', 
        'Sara', 'Tiago', 'Vera', 'Xavier', 'Yara',
        'Alice', 'Bernardo', 'Catarina', 'Daniel', 'Elisa',
        'Francisco', 'Henrique', 'Isabela', 'Jorge', 'Karina',
        'Luís', 'Maria', 'Natália', 'Otávio', 'Paulo',
        'Quitéria', 'Raul', 'Sofia', 'Telmo', 'Uriel',
        'Vítor', 'Wagner', 'Ximena', 'Yolanda', 'Zaqueu',
        'Bianca', 'César', 'Débora', 'Fabiana', 'Gustavo',
        'Helena', 'Ícaro', 'Júlia', 'Kevin', 'Laura',
        'Miguel', 'Nícolas', 'Olívia', 'Pedro', 'Quirino',
        'Rute', 'Sérgio', 'Tereza', 'Ugo', 'Vitória',
        'Washington', 'Yasmin', 'Zélia',
        'Adriana', 'Bruno', 'Carla', 'Daniel', 'Elisa',
        'Francisco', 'Gabriela', 'Henrique', 'Isabela', 'Jorge',
        'Karina', 'Luís', 'Maria', 'Natália', 'Otávio',
        'Paulo', 'Quitéria', 'Raul', 'Sofia', 'Telmo',
        'Uriel', 'Vítor', 'Wagner', 'Ximena', 'Yolanda',
        'Zaqueu', 'Bianca', 'César', 'Débora', 'Eduardo',
        'Fabiana', 'Gustavo', 'Helena', 'Ícaro', 'Júlia',
        'Kevin', 'Laura', 'Miguel', 'Nícolas', 'Olívia',
        'Abel', 'Alexandra', 'Amélia', 'André', 'António',
        'Bárbara', 'Bartolomeu', 'Benedita', 'Caio', 'Camila',
        'Carlos', 'Cecília', 'Clara', 'Cláudio', 'Cristina',
        'David', 'Diego', 'Dinis', 'Domingos', 'Eduarda',
        'Emanuel', 'Emília', 'Estela', 'Eugénio', 'Eva',
        'Feliciano', 'Fernanda', 'Frederico', 'Gil', 'Gilda',
        'Gonçalo', 'Hélder', 'Hugo', 'Iara', 'Igor',
        'Irene', 'Isaac', 'Ivone', 'Jaime', 'Jéssica',
        'Josué', 'Júlio', 'Lara', 'Leonardo', 'Letícia',
        'Lourenço', 'Lúcia', 'Manuel', 'Margarida', 'Mateus',
        'Melissa', 'Moisés', 'Mónica', 'Nádia', 'Nelson',
        'Noé', 'Nuno', 'Orlando', 'Oscar', 'Patrícia',
        'Pilar', 'Rafael', 'Regina', 'Renato', 'Rogério',
        'Rosa', 'Rubens', 'Sandro', 'Simão', 'Tatiana',
        'Teodoro', 'Teresa', 'Tomás', 'Valentina', 'Vicente',
        'Wilson', 'Yara', 'Zélio', 'Zulmira'
    ];
    sobrenomes TEXT[] := ARRAY[
        'Ferreira', 'Oliveira', 'Almeida', 'Costa', 'Martins', 
        'Santos', 'Pinto', 'Rocha', 'Pereira', 'Lopes', 
        'Pires', 'Nunes', 'Ribeiro', 'Correia', 'Mendes', 
        'Azevedo', 'Martins', 'Barros', 'Cardoso', 'Andrade',
        'Barbosa', 'Cunha', 'Dias', 'Esteves', 'Farias',
        'Gonçalves', 'Henriques', 'Ignácio', 'Júnior', 'Kepler',
        'Lima', 'Nogueira', 'Queiroz', 'Teixeira', 'Ulisses',
        'Vasconcelos', 'Wanderley', 'Yanes', 'Zamora', 'Batista',
        'Carvalho', 'Delgado', 'Holanda', 'Inácio', 'Jardim',
        'Kalil', 'Leite', 'Neves', 'Ornelas', 'Pimentel',
        'Quintana', 'Rezende', 'Soares', 'Tavares', 'Uchôa',
        'Ventura', 'Wenzel', 'Xavier', 'Yamaguchi', 'Zambuja',
        'Alves', 'Batista', 'Cardoso', 'Duarte', 'Esteves',
        'Fernandes', 'Gomes', 'Henriques', 'Ignácio', 'Júnior',
        'Kepler', 'Lima', 'Mendes', 'Nogueira', 'Oliveira',
        'Pereira', 'Queiroz', 'Ribeiro', 'Santos', 'Tavares',
        'Freitas', 'Moura', 'Silva', 'Monteiro', 'Machado', 
        'Macedo', 'Vieira', 'Figueiredo', 'Martinho', 'Cavalcante',
        'Abranches', 'Albuquerque', 'Almeida', 'Alves', 'Amaral',
        'Amorim', 'Andrade', 'Anjos', 'Antunes', 'Araújo',
        'Assis', 'Avelar', 'Azevedo', 'Barbosa', 'Barros',
        'Bastos', 'Bento', 'Bernardo', 'Borges', 'Brito',
        'Caetano', 'Camacho', 'Campos', 'Carmo', 'Castro',
        'Coelho', 'Conceição', 'Correia', 'Cruz', 'Cunha',
        'Domingues', 'Duarte', 'Esteves', 'Farias', 'Fernandes',
        'Figueira', 'Fonseca', 'Freire', 'Frota', 'Furtado',
        'Gomes', 'Gonçalves', 'Goulart', 'Guimarães', 'Gusmão',
        'Henriques', 'Lemos', 'Leão', 'Lins', 'Lopes',
        'Macedo', 'Machado', 'Mansur', 'Marinho', 'Marques',
        'Martins', 'Melo', 'Mendes', 'Monteiro', 'Morais',
        'Mota', 'Muniz', 'Nascimento', 'Neves', 'Nogueira',
        'Nunes', 'Oliveira', 'Pacheco', 'Paiva', 'Pascoal',
        'Peixoto', 'Pereira', 'Pinto', 'Pires', 'Pontes',
        'Ramalho', 'Ramos', 'Reis', 'Ribeiro', 'Rocha',
        'Rodrigues', 'Salgado', 'Sampaio', 'Santos', 'Saraiva',
        'Sardinha', 'Sequeira', 'Silva', 'Simões', 'Soares',
        'Sousa', 'Tavares', 'Teixeira', 'Teles', 'Vasconcelos',
        'Vaz', 'Viana', 'Vieira', 'Vilaça', 'Xavier'
    ];
BEGIN
    FOR i IN 1..5000 LOOP
        LOOP
            nome_temp := nomes[FLOOR(RANDOM() * ARRAY_LENGTH(nomes, 1) + 1)];
            sobrenome_temp := sobrenomes[FLOOR(RANDOM() * ARRAY_LENGTH(sobrenomes, 1) + 1)];
            nome := nome_temp || ' ' || sobrenome_temp;
            IF nome != ALL(nomes_proibidos) AND nome != ALL(nomes_utilizados) THEN
                EXIT;
            
            END IF;
        END LOOP;
        nomes_utilizados := array_append(nomes_utilizados, nome);
        ssn := gerar_snn_unico();
        nif := gerar_nif_unico();
        telefone := gerar_telefone();
        morada := gerar_endereco();
        data_nasc := DATE '1970-01-01' + INTERVAL '1 day' * FLOOR(RANDOM() * 18250);
        INSERT INTO paciente (ssn, nif, nome, telefone, morada, data_nasc) VALUES
        (ssn, nif, nome, telefone, morada, data_nasc);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


/* Cada médico trabalha em pelo menos duas clinicas por semana */

INSERT INTO trabalha (nif, nome, dia_da_semana) VALUES
(705044260, 'Clínica de Santo António', 1), 
(705044260, 'Clínica Santa Maria de Belém', 2), 
(489732117, 'Clínica do Parque', 3), 
(489732117, 'Clínica Médica da Estrela', 4), 
(802578646, 'Clínica Saúde Mais', 5), 
(802578646, 'Clínica de Santo António', 6), 
(727490205, 'Clínica Santa Maria de Belém', 7), 
(727490205, 'Clínica do Parque', 1), 
(414824607, 'Clínica Médica da Estrela', 2), 
(414824607, 'Clínica Saúde Mais', 3), 
(798223784, 'Clínica de Santo António', 4),
(798223784, 'Clínica Santa Maria de Belém', 5),
(555853256, 'Clínica do Parque', 6), 
(555853256, 'Clínica Médica da Estrela', 7), 
(803110209, 'Clínica Saúde Mais', 1), 
(803110209, 'Clínica de Santo António', 2), 
(544513818, 'Clínica Santa Maria de Belém', 3), 
(544513818, 'Clínica do Parque', 4), 
(826410745, 'Clínica Médica da Estrela', 5), 
(826410745, 'Clínica Saúde Mais', 6),
(811380963, 'Clínica de Santo António', 7), 
(811380963, 'Clínica Santa Maria de Belém', 1), 
(336763479, 'Clínica do Parque', 2), 
(336763479, 'Clínica Médica da Estrela', 3), 
(373686722, 'Clínica Saúde Mais', 4), 
(373686722, 'Clínica de Santo António', 5), 
(577197537, 'Clínica Santa Maria de Belém', 6),
(577197537, 'Clínica do Parque', 7), 
(344301704, 'Clínica Médica da Estrela', 1), 
(344301704, 'Clínica Saúde Mais', 2), 
(196499832, 'Clínica de Santo António', 3), 
(196499832, 'Clínica Santa Maria de Belém', 4), 
(263916540, 'Clínica do Parque', 5), 
(263916540, 'Clínica Médica da Estrela', 6), 
(790063293, 'Clínica Saúde Mais', 7), 
(790063293, 'Clínica de Santo António', 1), 
(196374245, 'Clínica Santa Maria de Belém', 2), 
(196374245, 'Clínica do Parque', 3), 
(482525755, 'Clínica Médica da Estrela', 4),
(482525755, 'Clínica Saúde Mais', 5), 
(732371327, 'Clínica de Santo António', 6), 
(732371327, 'Clínica Santa Maria de Belém', 7), 
(833620874, 'Clínica do Parque', 1), 
(833620874, 'Clínica Médica da Estrela', 2), 
(547932427, 'Clínica Saúde Mais', 3), 
(547932427, 'Clínica de Santo António', 4), 
(628868600, 'Clínica Santa Maria de Belém', 5),
(628868600, 'Clínica do Parque', 6), 
(489102441, 'Clínica Médica da Estrela', 7), 
(489102441, 'Clínica Saúde Mais', 1), 
(799839199, 'Clínica de Santo António', 2),
(799839199, 'Clínica Santa Maria de Belém', 3), 
(952591327, 'Clínica do Parque', 4), 
(952591327, 'Clínica Médica da Estrela', 5), 
(620304255, 'Clínica Saúde Mais', 6), 
(620304255, 'Clínica de Santo António', 7), 
(938565414, 'Clínica Santa Maria de Belém', 1), 
(938565414, 'Clínica do Parque', 2), 
(257600356, 'Clínica Médica da Estrela', 3), 
(257600356, 'Clínica Saúde Mais', 4), 
(950927646, 'Clínica de Santo António', 5), 
(950927646, 'Clínica Santa Maria de Belém', 6), 
(528467353, 'Clínica do Parque', 7), 
(528467353, 'Clínica Médica da Estrela', 1), 
(806610236, 'Clínica Saúde Mais', 2), 
(806610236, 'Clínica de Santo António', 3), 
(247575260, 'Clínica Santa Maria de Belém', 4), 
(247575260, 'Clínica do Parque', 5), 
(742868618, 'Clínica Médica da Estrela', 6), 
(742868618, 'Clínica Saúde Mais', 7), 
(799267983, 'Clínica de Santo António', 1), 
(799267983, 'Clínica Santa Maria de Belém', 2), 
(741182818, 'Clínica do Parque', 3), 
(741182818, 'Clínica Médica da Estrela', 4), 
(714741162, 'Clínica Saúde Mais', 5), 
(714741162, 'Clínica de Santo António', 6), 
(764501898, 'Clínica Santa Maria de Belém', 7), 
(764501898, 'Clínica do Parque', 1), 
(896450276, 'Clínica Médica da Estrela', 2), 
(896450276, 'Clínica Saúde Mais', 3), 
(309968880, 'Clínica de Santo António', 4), 
(309968880, 'Clínica Santa Maria de Belém', 5), 
(971593199, 'Clínica do Parque', 6), 
(971593199, 'Clínica Médica da Estrela', 7), 
(193802049, 'Clínica Saúde Mais', 1), 
(193802049, 'Clínica de Santo António', 2), 
(436629852, 'Clínica Santa Maria de Belém', 3), 
(436629852, 'Clínica do Parque', 4), 
(961405342, 'Clínica Médica da Estrela', 5), 
(961405342, 'Clínica Saúde Mais', 6), 
(726105174, 'Clínica de Santo António', 7), 
(726105174, 'Clínica Santa Maria de Belém', 1), 
(613646588, 'Clínica do Parque', 2), 
(613646588, 'Clínica Médica da Estrela', 3), 
(964117327, 'Clínica Saúde Mais', 4), 
(964117327, 'Clínica de Santo António', 5), 
(825149616, 'Clínica Santa Maria de Belém', 6), 
(825149616, 'Clínica do Parque', 7), 
(853280320, 'Clínica Médica da Estrela', 1), 
(853280320, 'Clínica Saúde Mais', 2), 
(925240351, 'Clínica de Santo António', 3), 
(925240351, 'Clínica Santa Maria de Belém', 4), 
(925845546, 'Clínica do Parque', 5), 
(925845546, 'Clínica Médica da Estrela', 6), 
(748476235, 'Clínica Saúde Mais', 7), 
(748476235, 'Clínica de Santo António', 1), 
(897170754, 'Clínica Santa Maria de Belém', 2), 
(897170754, 'Clínica do Parque', 3), 
(586631239, 'Clínica Médica da Estrela', 4), 
(586631239, 'Clínica Saúde Mais', 5), 
(268910838, 'Clínica de Santo António', 6), 
(268910838, 'Clínica Santa Maria de Belém', 7), 
(925895540, 'Clínica do Parque', 1), 
(925895540, 'Clínica Médica da Estrela', 2), 
(413163469, 'Clínica Saúde Mais', 3), 
(413163469, 'Clínica de Santo António', 4), 
(463573590, 'Clínica Santa Maria de Belém', 5), 
(463573590, 'Clínica do Parque', 6), 
(601344122, 'Clínica Médica da Estrela', 7), 
(601344122, 'Clínica Saúde Mais', 1);



/* Não conseguimos terminar a povoação da Base de Dados, devido a constantes erros na criação do código. */