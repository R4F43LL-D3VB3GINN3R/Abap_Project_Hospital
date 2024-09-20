*&---------------------------------------------------------------------*
*& Include          ZRLA_SCREENS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
"TELA DE PACIENTES

"TELAS QUE RECEBEM AS SUBTELAS
selection-screen: begin of tabbed block tb1 for 40 lines.
selection-screen: tab (20) tab1 user-command tab1 default screen 100, "TELA DE HOSPITAIS
                  tab (20) tab2 user-command tab2 default screen 101. "TELA DE PACIENTES
selection-screen: end of block tb1.

*include zrla_screen_hospital.
*include zrla_screen_paciente.

"------------------------------------------------------------------------------------------------------
"TELA DE HOSPITAIS

"DROPDOWN DE PROCURA
selection-screen: begin of screen 100 as subscreen.
selection-screen: begin of block f1 with frame.
selection-screen: begin of block c1 with frame title text-008.
parameters: p_nomes type zhospitais-id_hospital as listbox visible length 25.
selection-screen: end of block c1.

"ZHOSPITAIS
"-------------------------
*ID_HOSPITAL      INT4
*NOME_HOSPITAL    CHAR100
*NIF              CHAR9
*MORADA	          CHAR255
*CODIGO_POSTAL    CHAR8
*TELEFONE	        CHAR9
*EMAIL_CONTACTO	  CHAR100
*TIPO_HOSPITAL    ZTIPOH
*CAPACIDADE_CAMA  INT4
*ESPECIALIDADES	  CHAR255
*DATA_FUNDACAO    DATS
*DIRETOR_RESP	    CHAR100
*DATA_CRIACAO	    DATS
*DATA_MODIFICACAO	DATS
*STATUS	          CHAR1
"-------------------------

"CAMPOS DE INFORMACOES GERAIS
selection-screen: begin of block a1 with frame title text-007.
parameters: p_nome type zhospitais-nome_hospital,                              "nome
            p_nifh type zhospitais-nif default '000000000',                    "nif
            p_mord type zhospitais-morada,                                     "morada
            p_codp type zhospitais-codigo_postal default '00000000',           "codigo postal
            p_fone type zhospitais-telefone default '000000000',               "telefone
            p_mail type zhospitais-email_contacto,                             "email
            p_tipo type zhospitais-tipo_hospital as listbox visible length 25, "tipo de hospital
            p_cama type zhospitais-capacidade_cama.                            "capacidade de camas
selection-screen begin of line.
selection-screen position 30.
parameters p_act radiobutton group grp1 default 'X'.                           "hospital em atividade
selection-screen comment 32(10) text-040.
selection-screen position 50.
parameters p_noact radiobutton group grp1.                                     "hospital inativo
selection-screen comment 52(10) text-041.
selection-screen end of line.
selection-screen: end of block a1.

"ESPECIALIZACOES
selection-screen: begin of block d1 with frame title text-010.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec1 as checkbox.
selection-screen comment 3(20) text-020.
selection-screen position 24.
parameters p_spec2 as checkbox.
selection-screen comment 26(20) text-021.
selection-screen position 47.
parameters p_spec3 as checkbox.
selection-screen comment 49(20) text-022.
selection-screen position 70.
parameters p_spec4 as checkbox.
selection-screen comment 72(20) text-023.
selection-screen end of line.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec5 as checkbox.
selection-screen comment 3(20) text-024.
selection-screen position 24.
parameters p_spec6 as checkbox.
selection-screen comment 26(20) text-025.
selection-screen position 47.
parameters p_spec7 as checkbox.
selection-screen comment 49(20) text-026.
selection-screen position 70.
parameters p_spec8 as checkbox.
selection-screen comment 72(20) text-027.
selection-screen end of line.

selection-screen begin of line.
selection-screen position 1.
parameters p_spec9 as checkbox.
selection-screen comment 3(20) text-028.
selection-screen position 24.
parameters p_spec10 as checkbox.
selection-screen comment 26(20) text-029.
selection-screen position 47.
parameters p_spec11 as checkbox.
selection-screen comment 49(20) text-030.
selection-screen end of line.
selection-screen: end of block d1.

"INFORMACOES ADICIONAIS
selection-screen: begin of block e1 with frame title text-009.
parameters: p_fndc type zhospitais-data_fundacao, "data de fundacao
            p_dirt type zhospitais-diretor_resp.  "diretor responsavel
selection-screen: end of block e1.

"PUSHBUTTONS
selection-screen: begin of block b1 with frame title text-005.
selection-screen pushbutton 25(15) text-001 user-command insert.
selection-screen pushbutton 45(15) text-002 user-command edit.
selection-screen pushbutton 65(15) text-004 user-command read.
selection-screen: end of block b1.
selection-screen: end of block f1.
selection-screen: end of screen 100.

"------------------------------------------------------------------------------------------------------
"TELA DE PACIENTES

"CAMPOS DE PESQUISA
selection-screen: begin of screen 101 as subscreen.
selection-screen: begin of block p1 with frame.
selection-screen: begin of block p2 with frame title text-050.
parameters: p_nomesh type zhospitais-nome_hospital as listbox visible length 25.
parameters: p_nomesp type zpacientes-nome_paciente as listbox visible length 25.
selection-screen: end of block p2.
selection-screen: begin of block p3 with frame title text-051.

"ZPACIENTES
"-----------------------
*ID_PACIENTE      INT4
*ID_HOSPITAL      INT4
*NOME_PACIENTE    CHAR50
*DATA_NASCIMENTO  DATS
*SEXO              CHAR1
*ESTADO_CIVIL     CHAR15
"DATA_ALTERACAO   DATS
"ALTERADO_POR     UNAME
"-----------------------

parameters: p_nomep  type zpacientes-nome_paciente,                             "nome do paciente
            p_sexop  type zpacientes-sexo,                                      "sexo
            p_datanp type zpacientes-data_nascimento,                           "data de nascimento
            p_estcv  type zpacientes-estado_civil as listbox visible length 10. "estado civil
selection-screen: end of block p3.

"ZPAC_CONTACTOS
"----------------------------
*ID_CONTACTO          INT4
*ID_PACIENTE          INT4
*TELEFONE_PRINCIPAL    CHAR9
*TELEFONE_SECUNDARIO  CHAR9
*EMAIL_PACIENTE        CHAR20
*CONTACTO_EMERGENCIA  CHAR9
*NOME_CONTACTO_E      CHAR50
"DATA_ALTERACAO       DATS
"ALTERADO_POR         UNAME
"----------------------------

selection-screen: begin of block p4 with frame title text-052.
parameters: p_tel1  type zpac_contactos-telefone_principal,  "telefone principal
            p_tel2  type zpac_contactos-telefone_secundario, "telefone secundario
            p_mailp type zpac_contactos-email_paciente,      "email do paciente
            p_ct_em type zpac_contactos-contacto_emergencia, "contacto de emergencia
            p_nm_em type zpac_contactos-nome_contacto_e.     "nome do contacto de emergencia
selection-screen: end of block p4.

"ZPAC_DOCS
"-----------------------
*ID_DOCUMENTO      INT4
*ID_PACIENTE      INT4
*NIF              CHAR9
*CARTAO_CIDADAO    CHAR9
*NUMERO_UTENTE    CHAR9
*SUBSISTEMA_SAUDE  CHAR4
*NUMERO_SEGURO    CHAR10
*VALIDADE_SEGURO  DATS
"DATA_ALTERACAO   DATS
"ALTERADO_POR     UNAME
"-----------------------

selection-screen: begin of block p5 with frame title text-053.
parameters: p_nifp   type zpac_docs-nif,              "nif do paciente
            p_cc     type zpac_docs-cartao_cidadao,   "cartao cidadao
            p_utente type zpac_docs-numero_utente,    "numero do utente
            p_sub_ss type zpac_docs-subsistema_saude, "subsistema de saude
            p_nsecp  type zpac_docs-numero_seguro,    "numero seguro
            p_valsec type zpac_docs-validade_seguro.  "validade seguro
selection-screen: end of block p5.

"ZPAC_ENDERECOS
"-----------------------
*ID_LOCALIZACAO   INT4
*ID_PACIENTE     INT4
*MORADA_PACIENTE CHAR50
*CODIGO_POSTAL   CHAR8
*CONCELHO         CHAR50
*NACIONALIDADE   CHAR20
"DATA_ALTERACAO   DATS
"ALTERADO_POR     UNAME
"-----------------------

selection-screen: begin of block p6 with frame title text-054.
parameters: p_mordp  type zpac_enderecos-morada_paciente, "morada
            p_codpst type zpac_enderecos-codigo_postal,   "codigo postal
            p_cclh   type zpac_enderecos-concelho,        "concelho
            p_nacio  type zpac_enderecos-nacionalidade.   "nacionalidade
selection-screen: end of block p6.

"ZPAC_INFOPAC
"-----------------------------
*ID_INFO_PACIENTE     INT4
*ID_PACIENTE         INT4
*PESO                DECIMALS
*ALTURA              DECIMALS
*DATA_INSCRICAO       DATS
*ULTIMA_CONSULTA     DATS
*TIPO_SANGUE         CHAR3
*ALERGIAS             CHAR255
*DOENCAS_CRONICAS     CHAR255
*MEDICACAO_ATUAL     CHAR255
*HISTORICO_CIRURGICO CHAR100
*HABITOS_DROGAS       CHAR100
*OBSERVACOES         CHAR255
"DATA_ALTERACAO      DATS
"ALTERADO_POR        UNAME
"-----------------------------

selection-screen: begin of block p7 with frame title text-055.
parameters: p_peso   type zpac_infopac-peso,                "peso
            p_alt    type zpac_infopac-altura,              "altura
            p_dt_ins type zpac_infopac-data_inscricao,      "data inscricao
            p_ultc   type zpac_infopac-ultima_consulta,     "ultima consulta
            p_tps    type zpac_infopac-tipo_sangue,         "tipo sangue
            p_alrg   type zpac_infopac-alergias,            "alergias
            p_dncc   type zpac_infopac-doencas_cronicas,    "doencas cronicas
            p_medc   type zpac_infopac-medicacao_atual,     "medicacao atual
            p_hstc   type zpac_infopac-historico_cirurgico, "historico cirurgico
            p_hbtd   type zpac_infopac-habitos_drogas,      "habitos drogas
            p_obsp   type zpac_infopac-observacoes.         "observacoes
selection-screen: end of block p7.

"PUSHBUTTONS
selection-screen: begin of block p8 with frame title text-005.
selection-screen pushbutton 25(15) text-001 user-command p_insert.
selection-screen pushbutton 45(15) text-002 user-command p_edit.
selection-screen pushbutton 65(15) text-004 user-command p_read.
selection-screen: end of block p8.

selection-screen: end of block p1.
selection-screen: end of screen 101.

controls mytabstrip type tabstrip.
