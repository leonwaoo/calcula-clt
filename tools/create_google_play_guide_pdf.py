from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    KeepTogether,
    ListFlowable,
    ListItem,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'output' / 'pdf' / 'guia-google-play-calcula-clt.pdf'


def footer(canvas, document):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor('#D7DED9'))
    canvas.line(2 * cm, 1.45 * cm, A4[0] - 2 * cm, 1.45 * cm)
    canvas.setFont('Helvetica', 8)
    canvas.setFillColor(colors.HexColor('#5B665F'))
    canvas.drawString(2 * cm, 1.0 * cm, 'Calcula CLT - guia de publicação e monetização')
    canvas.drawRightString(A4[0] - 2 * cm, 1.0 * cm, f'Página {document.page}')
    canvas.restoreState()


def bullet(items, style):
    return ListFlowable(
        [ListItem(Paragraph(item, style), leftIndent=12) for item in items],
        bulletType='bullet',
        start='circle',
        leftIndent=16,
        bulletFontSize=7,
        spaceAfter=8,
    )


def section(title, items, styles):
    return KeepTogether([
        Spacer(1, 9),
        Paragraph(title, styles['Heading2']),
        bullet(items, styles['BodyText']),
    ])


def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(
        name='CoverTitle', parent=styles['Title'], fontName='Helvetica-Bold',
        fontSize=28, leading=33, alignment=TA_CENTER, textColor=colors.HexColor('#075E54'), spaceAfter=12,
    ))
    styles.add(ParagraphStyle(
        name='CoverSubtitle', parent=styles['BodyText'], fontSize=12, leading=18,
        alignment=TA_CENTER, textColor=colors.HexColor('#4C5B53'),
    ))
    styles['Heading2'].fontName = 'Helvetica-Bold'
    styles['Heading2'].fontSize = 15
    styles['Heading2'].leading = 20
    styles['Heading2'].textColor = colors.HexColor('#075E54')
    styles['BodyText'].fontName = 'Helvetica'
    styles['BodyText'].fontSize = 10
    styles['BodyText'].leading = 14
    styles['BodyText'].spaceAfter = 5
    styles.add(ParagraphStyle(
        name='Small', parent=styles['BodyText'], fontSize=8.5, leading=12, textColor=colors.HexColor('#4C5B53'),
    ))
    styles.add(ParagraphStyle(
        name='Callout', parent=styles['BodyText'], fontSize=10.5, leading=15,
        borderColor=colors.HexColor('#B8D8D2'), borderWidth=0.8, borderPadding=12,
        backColor=colors.HexColor('#EFF8F5'), spaceBefore=12, spaceAfter=12,
    ))

    doc = SimpleDocTemplate(
        str(OUTPUT), pagesize=A4, rightMargin=2 * cm, leftMargin=2 * cm,
        topMargin=1.8 * cm, bottomMargin=2.1 * cm, title='Guia Google Play - Calcula CLT', author='Calcula CLT',
    )
    story = [
        Spacer(1, 2.3 * cm),
        Paragraph('Calcula CLT', styles['CoverTitle']),
        Paragraph('Publicação na Google Play e recebimento de pagamentos', styles['CoverTitle']),
        Spacer(1, 0.4 * cm),
        Paragraph('Roteiro prático para transformar o acesso Pro do aplicativo em uma venda segura pela Google Play.', styles['CoverSubtitle']),
        Spacer(1, 1.2 * cm),
        Paragraph('<b>Modelo recomendado:</b> aplicativo gratuito para instalar + produto único não consumível para liberar análise detalhada e relatório PDF.', styles['Callout']),
        Paragraph('Identificador atual do aplicativo: <b>com.calculaclt.calcula_clt</b>. Não altere esse identificador depois do primeiro envio à Play Console.', styles['BodyText']),
        Spacer(1, 0.6 * cm),
        Paragraph('Checklist rápido', styles['Heading2']),
        bullet([
            'Conta de desenvolvedor e identidade verificadas.',
            'Perfil de pagamentos e conta bancária confirmados.',
            'AAB assinado, ficha da loja e política de privacidade preparados.',
            'Produto Pro criado, compra validada no servidor e testes concluídos.',
        ], styles['BodyText']),
        PageBreak(),
        Paragraph('1. Conta e recebimento', styles['Heading2']),
        bullet([
            'Acesse a Play Console com a conta que será proprietária do aplicativo e conclua o cadastro de desenvolvedor.',
            'Em Configurações > Perfil de pagamentos, crie o perfil com nome legal, endereço físico, site e e-mail de suporte.',
            'Em Como você recebe pagamentos, adicione a conta bancária. O titular e o país devem corresponder ao perfil. A Google pode solicitar verificação por depósito de teste ou documentos.',
            'Defina a conta verificada como forma principal de recebimento.',
        ], styles['BodyText']),
        Paragraph('2. Gerar o arquivo para a loja', styles['Heading2']),
        bullet([
            'Crie e guarde uma chave de upload. Ela não deve ser enviada ao GitHub.',
            'No projeto, execute: <b>flutter pub get</b>, <b>flutter test</b> e <b>flutter build appbundle --release</b>.',
            'Envie o arquivo build/app/outputs/bundle/release/app-release.aab. Na primeira publicação, aceite o Play App Signing.',
        ], styles['BodyText']),
        Paragraph('3. Criar o app e o produto Pro', styles['Heading2']),
        bullet([
            'Na Play Console, crie um App gratuito. A receita virá da compra interna, não do download.',
            'Preencha nome, descrições, ícone, imagens, suporte, política de privacidade, classificação indicativa e declarações de segurança dos dados.',
            'Declare que o app contém compras no aplicativo.',
            'Em Monetizar com a Play > Produtos > Produtos únicos, crie o produto <b>calculaclt_pro_lifetime</b>, nomeie como Calcula CLT Pro e configure-o como não consumível.',
            'Defina preço e países de venda. Um produto não consumível é comprado uma vez e fica associado à conta Google do cliente.',
        ], styles['BodyText']),
        PageBreak(),
        Paragraph('4. Validação: condição para liberar o Pro', styles['Heading2']),
        Paragraph('Não libere PDF ou análise apenas porque o aplicativo recebeu uma confirmação local. O aplicativo já foi estruturado para permanecer bloqueado até que seu servidor confirme a compra.', styles['Callout']),
        bullet([
            'O usuário inicia a compra pela tela da Google Play.',
            'O app recebe o token da transação e envia o token ao seu servidor.',
            'O servidor consulta a Google Play Developer API e confirma que o estado é PURCHASED.',
            'O servidor responde valid: true. Somente nesse momento o acesso Pro é liberado.',
            'O servidor deve reconhecer a compra não consumível e receber notificações em tempo real para tratar cancelamentos e reembolsos.',
            'Configure a URL do servidor no build: --dart-define=PURCHASE_VALIDATION_URL=https://seu-dominio.com/google-play/verify.',
        ], styles['BodyText']),
        Paragraph('5. Testar e publicar', styles['Heading2']),
        bullet([
            'Envie primeiro para Teste interno e adicione e-mails em Configurações > Testadores de licença.',
            'Teste compra aprovada, recusada, pendente, restauração e reembolso. Em todos os cenários, o acesso só pode mudar após a resposta do servidor.',
            'Para contas pessoais novas, faça teste fechado com pelo menos 12 testadores inscritos continuamente por 14 dias antes de solicitar o acesso à produção.',
            'Depois da revisão, publique em Produção nos países escolhidos e acompanhe avaliações, falhas, pedidos e reembolsos.',
        ], styles['BodyText']),
        Paragraph('Como você recebe por cada venda', styles['Heading2']),
    ]

    table = Table([
        [Paragraph('<b>Etapa</b>', styles['BodyText']), Paragraph('<b>O que acontece</b>', styles['BodyText'])],
        [Paragraph('1. Compra', styles['BodyText']), Paragraph('O cliente paga na Google Play usando os meios aceitos para a região.', styles['BodyText'])],
        [Paragraph('2. Processamento', styles['BodyText']), Paragraph('A Google processa a transação, aplica a taxa de serviço aplicável e cuida dos tributos que lhe couberem.', styles['BodyText'])],
        [Paragraph('3. Relatórios', styles['BodyText']), Paragraph('A venda e o saldo líquido podem ser acompanhados em relatórios financeiros da Play Console.', styles['BodyText'])],
        [Paragraph('4. Repasse', styles['BodyText']), Paragraph('As operações de um mês costumam ser pagas por volta do dia 15 do mês seguinte, se a conta estiver verificada e o saldo mínimo for atingido. O banco pode demorar alguns dias para creditar.', styles['BodyText'])],
    ], colWidths=[3.2 * cm, 12.8 * cm], repeatRows=1)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#075E54')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('GRID', (0, 0), (-1, -1), 0.35, colors.HexColor('#CCD8D3')),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F4F8F6')]),
        ('LEFTPADDING', (0, 0), (-1, -1), 8), ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8), ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
    ]))
    story += [table, Spacer(1, 12), Paragraph('Importante: não é necessário criar PIX, checkout externo ou Stripe para vender o recurso digital dentro deste app Android. A venda e o recebimento são administrados pela Google Play.', styles['Callout'])]
    story += [Paragraph('Fontes oficiais', styles['Heading2'])]
    for source in [
        'Perfil de pagamentos: https://support.google.com/googleplay/android-developer/answer/7161426',
        'Conta bancária e verificação: https://support.google.com/googleplay/android-developer/answer/13628312',
        'Pedidos e repasses: https://support.google.com/googleplay/android-developer/answer/137997',
        'Produtos únicos: https://developer.android.com/google/play/billing/one-time-products',
        'Validação de compras: https://developer.android.com/google/play/billing/lifecycle/one-time',
        'Testes de faturamento: https://developer.android.com/google/play/billing/test',
        'Teste exigido para contas pessoais novas: https://support.google.com/googleplay/android-developer/answer/14151465',
    ]:
        story.append(Paragraph(source, styles['Small']))
        story.append(Spacer(1, 3))
    doc.build(story, onFirstPage=footer, onLaterPages=footer)


if __name__ == '__main__':
    main()
