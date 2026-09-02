const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

const doc = new PDFDocument({
  size: 'A4',
  margins: { top: 40, bottom: 40, left: 45, right: 45 }
});

const outputPath = path.join(__dirname, 'CalculaCLT_Proposta_e_Rentabilidade.pdf');
const writeStream = fs.createWriteStream(outputPath);
doc.pipe(writeStream);

// Cores Oficiais
const PRIMARY = '#1E3A8A';
const SECONDARY = '#2563EB';
const EMERALD = '#059669';
const DARK = '#0F172A';
const MUTED = '#475569';
const LIGHT_BG = '#F1F5F9';
const LINE_COLOR = '#E2E8F0';

// ==========================================
// CABEÇALHO / BANNER SUPERIOR
// ==========================================
doc.rect(0, 0, 595.28, 70).fill(PRIMARY);

doc.fillColor('#FFFFFF')
   .fontSize(22)
   .font('Helvetica-Bold')
   .text('Calcula', 45, 22, { continued: true });
doc.fillColor('#10B981')
   .text('CLT');

doc.fillColor('#CBD5E1')
   .fontSize(10)
   .font('Helvetica')
   .text('DOCUMENTO EXECUTIVO DE PROPOSTA DE VALOR E RENTABILIDADE', 45, 46);

doc.moveDown(3);

// ==========================================
// SEÇÃO 1: VISÃO GERAL E PROPOSTA DE VALOR
// ==========================================
doc.fillColor(PRIMARY)
   .fontSize(14)
   .font('Helvetica-Bold')
   .text('1. O Problema do Mercado e a Solução do CalculaCLT');

doc.strokeColor(LINE_COLOR).lineWidth(1)
   .moveTo(45, doc.y + 3).lineTo(550, doc.y + 3).stroke();
doc.moveDown(0.8);

doc.fillColor(MUTED).fontSize(10).font('Helvetica');
doc.text('No Brasil, ocorrem mais de 15 milhoes de rescisoes contratuais formais (CLT) a cada ano. Dentre esse contingente, estima-se que mais de 70% dos trabalhadores demitidos tenham duvidas concretas se a empresa calculou a rescisao de forma correta, mas enfrentam barreiras como:');
doc.moveDown(0.4);

doc.fillColor(DARK).font('Helvetica-Bold').fontSize(9.5);
doc.text('• Barreiras do Trabalhador:', { indent: 10 });
doc.font('Helvetica').fillColor(MUTED);
doc.text('- Incompreensao do juridiques e das rubricas do Termo de Rescisao (TRCT);', { indent: 20 });
doc.text('- Desconhecimento de regras fundamentais como o aviso proporcional da Lei 12.506/11 e a multa rescisoria;', { indent: 20 });
doc.text('- Custo elevado para contratar advogados ou contadores apenas para uma simples conferencia;', { indent: 20 });
doc.text('- Falta de informacao sobre o prazo legal de 10 dias da CLT e a multa de 1 salario integral por atraso (Art. 477).', { indent: 20 });

doc.moveDown(0.6);
doc.fillColor(DARK).font('Helvetica-Bold').fontSize(9.5);
doc.text('• A Solucao do CalculaCLT:', { indent: 10 });
doc.font('Helvetica').fillColor(MUTED);
doc.text('O CalculaCLT atua como o "Copiloto do Trabalhador Brasileiro", entregando uma interface limpa estilo fintech (padrao Apple/Nubank), livre de juridiques, com calculos 100% fieis a CLT vigente, comparador inteligente de cenarios de demissao, validador de TRCT da empresa, checklist passo a passo e gerador de cartas formais prontas para impressao em PDF.', { indent: 20 });

doc.moveDown(1.2);

// ==========================================
// SEÇÃO 2: OS 5 MODELOS DE RENTABILIDADE
// ==========================================
doc.fillColor(PRIMARY)
   .fontSize(14)
   .font('Helvetica-Bold')
   .text('2. Modelos de Monetizacao e Rentabilidade');

doc.strokeColor(LINE_COLOR).lineWidth(1)
   .moveTo(45, doc.y + 3).lineTo(550, doc.y + 3).stroke();
doc.moveDown(0.8);

// Modelo 1
doc.fillColor(SECONDARY).font('Helvetica-Bold').fontSize(11);
doc.text('Canal 1: Venda Direta do Relatorio Oficial Timbrado via PIX (R$ 19,90)');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('O trabalhador esta prestes a receber de R$ 3.000 a R$ 25.000 em seu acerto rescisorio. Pagar R$ 19,90 via Pix instantaneo para ter um relatorio timbrado completo com memoria oficial de calculo e fundamentacao legal artigo por artigo e uma decisao financeiramente irrecusavel ("no-brainer").');
doc.moveDown(0.6);

// Modelo 2
doc.fillColor(SECONDARY).font('Helvetica-Bold').fontSize(11);
doc.text('Canal 2: Geracao e Venda de Leads Qualificados para Advogados Trabalhistas');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('O "Validador de TRCT" do CalculaCLT compara o valor da empresa com o valor legal. Ao detectar diferencas (ex: "Faltam R$ 1.850 na sua rescisao"), o aplicativo exibe o canal direto para conectar o usuario a escritorios de advocacia parceiros. Advogados pagam de R$ 30 a R$ 80 por lead qualificado ou comissao de 10% a 20% no exito de acoes trabalhistas.');
doc.moveDown(0.6);

// Modelo 3
doc.fillColor(SECONDARY).font('Helvetica-Bold').fontSize(11);
doc.text('Canal 3: Afiliados de Antecipacao de Saque-Aniversario do FGTS');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('Quem pede demissao fica com o FGTS retido na Caixa. O CalculaCLT disponibiliza a opcao de antecipar ate 10 parcelas do FGTS com fintechs de credito consignado parceiras (ex: Meutudo, Digio, QI Tech). Cada contrato formalizado gera comissao de R$ 50 a R$ 200 para o app.');
doc.moveDown(0.6);

// Modelo 4
doc.fillColor(SECONDARY).font('Helvetica-Bold').fontSize(11);
doc.text('Canal 4: Publicidade Programatica (Google AdMob e AdSense)');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('O termo "calculo de rescisao" soma mais de 1,8 milhao de buscas mensais no Brasil. Com publicidade nativa e banners discretos no Google Play e na web, gera renda passiva e recorrente em dolares ($) todos os meses.');
doc.moveDown(0.6);

// Modelo 5
doc.fillColor(SECONDARY).font('Helvetica-Bold').fontSize(11);
doc.text('Canal 5: Assinatura para Contadores e Pequenas Empresas (B2B - R$ 49,90/mes)');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('Planos mensais para escritorios de contabilidade e departamentos de RH simularem rescisoes com personalizacao da logomarca do escritorio e emissao ilimitada de relatorios analiticos.');

// ==========================================
// NOVA PÁGINA: PROJEÇÃO E ESTRATÉGIA
// ==========================================
doc.addPage();

// Cabeçalho da Página 2
doc.rect(0, 0, 595.28, 45).fill(PRIMARY);
doc.fillColor('#FFFFFF').fontSize(12).font('Helvetica-Bold').text('CalculaCLT - Projecao Financeira e Estrategia de Crescimento', 45, 16);

doc.y = 65;

doc.fillColor(PRIMARY)
   .fontSize(14)
   .font('Helvetica-Bold')
   .text('3. Projecao Financeira Mensal (Cenario Conservador)');

doc.strokeColor(LINE_COLOR).lineWidth(1)
   .moveTo(45, doc.y + 3).lineTo(550, doc.y + 3).stroke();
doc.moveDown(0.8);

doc.fillColor(MUTED).fontSize(9.5).font('Helvetica');
doc.text('Simulacao estimada com base em um volume de 5.000 usuarios mensais ativos (alcancavel organicamente no Google Play e redes sociais):');
doc.moveDown(0.8);

// Tabela de Projeção
const tableTop = doc.y;
doc.rect(45, tableTop, 505, 24).fill(LIGHT_BG);
doc.fillColor(DARK).font('Helvetica-Bold').fontSize(9);
doc.text('Canal de Receita', 55, tableTop + 7);
doc.text('Metrica / Conversao', 230, tableTop + 7);
doc.text('Ticket / Comissao', 370, tableTop + 7);
doc.text('Total Mensal', 475, tableTop + 7);

let rowY = tableTop + 24;

const rows = [
  ['Relatorios PRO (Pix)', '2,5% conv. (125 vendas)', 'R$ 19,90 / venda', 'R$ 2.487,50'],
  ['Leads para Advogados', '35 contatos qualificados', 'R$ 50,00 / lead', 'R$ 1.750,00'],
  ['Afiliados FGTS Retido', '20 saques antecipados', 'R$ 90,00 / contrato', 'R$ 1.800,00'],
  ['Google AdMob (Anuncios)', '40.000 visualizacoes', 'RPM medio R$ 15', 'R$ 600,00'],
  ['Assinaturas B2B (Contadores)', '10 escritorios', 'R$ 49,90 / mes', 'R$ 499,00']
];

rows.forEach((r, i) => {
  doc.strokeColor(LINE_COLOR).lineWidth(0.5).moveTo(45, rowY).lineTo(550, rowY).stroke();
  doc.fillColor(MUTED).font('Helvetica').fontSize(9);
  doc.text(r[0], 55, rowY + 6);
  doc.text(r[1], 230, rowY + 6);
  doc.text(r[2], 370, rowY + 6);
  doc.fillColor(DARK).font('Helvetica-Bold').text(r[3], 475, rowY + 6);
  rowY += 22;
});

// Total da Tabela
doc.rect(45, rowY, 505, 26).fill('#ECFDF5');
doc.strokeColor(EMERALD).lineWidth(1).rect(45, rowY, 505, 26).stroke();
doc.fillColor(EMERALD).font('Helvetica-Bold').fontSize(10);
doc.text('FATURAMENTO ESTIMADO TOTAL:', 55, rowY + 8);
doc.text('R$ 7.136,50 / mes', 450, rowY + 8);

doc.y = rowY + 40;

// ==========================================
// SEÇÃO 4: ESTRATÉGIA DE GO-TO-MARKET
// ==========================================
doc.fillColor(PRIMARY)
   .fontSize(14)
   .font('Helvetica-Bold')
   .text('4. Estrategia de Aquisicao e Viralizacao (Crescimento)');

doc.strokeColor(LINE_COLOR).lineWidth(1)
   .moveTo(45, doc.y + 3).lineTo(550, doc.y + 3).stroke();
doc.moveDown(0.8);

doc.fillColor(DARK).font('Helvetica-Bold').fontSize(10);
doc.text('1. Google Play Store (TWA / ASO Organico):');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('O aplicativo ja esta preparado com o pacote TWA (manifest.json, assetlinks.json, icon-512.png e feature-graphic.png). O posicionamento em buscas de alta intencao como "calculadora rescisao" garante fluxo constante de downloads sem custo de midia paga.', { indent: 10 });
doc.moveDown(0.6);

doc.fillColor(DARK).font('Helvetica-Bold').fontSize(10);
doc.text('2. Conteudo de Alerta no TikTok / Reels / Shorts:');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('Videos curtos de 30 segundos abordando temas que geram alta indignacao e engajamento: "A empresa atrasou seu acerto em mais de 10 dias? Veja como cobrar +1 salario integral de multa pelo Art. 477" ou "Como saber se o RH errou suas ferias". Esse tipo de video ultrapassa facilmente centenas de milhares de visualizacoes organicas.', { indent: 10 });
doc.moveDown(0.6);

doc.fillColor(DARK).font('Helvetica-Bold').fontSize(10);
doc.text('3. Retencao com PWA e Memoria Local:');
doc.fillColor(MUTED).font('Helvetica').fontSize(9.5);
doc.text('Como o CalculaCLT pode ser instalado diretamente na tela inicial do smartphone sem passar pela loja e guarda os dados no aparelho, o trabalhador consulta o checklist durante todos os 10 a 30 dias do seu processo de demissao.', { indent: 10 });

// Rodapé
doc.fillColor('#94A3B8').fontSize(8).font('Helvetica')
   .text('CalculaCLT • Documento confidencial elaborado para fins estrategicos e comerciais • Setembro/2026', 45, 780, { align: 'center' });

doc.end();

writeStream.on('finish', () => {
  console.log('PDF gerado com sucesso em:', outputPath);
});
