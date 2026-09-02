package br.com.ordempro.autonomo

import android.app.*
import android.content.*
import android.graphics.*
import android.graphics.pdf.PdfDocument
import android.net.Uri
import android.os.Bundle
import android.text.InputType
import android.view.*
import android.widget.*
import androidx.core.content.FileProvider
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.*

data class ServiceOrder(
    val id: Long = System.currentTimeMillis(), val number: String, val client: String,
    val phone: String, val service: String, val details: String, val value: Double,
    val status: String, val date: String = SimpleDateFormat("dd/MM/yyyy", Locale("pt", "BR")).format(Date())
)

class MainActivity : Activity() {
    private val orders = mutableListOf<ServiceOrder>()
    private val money = NumberFormat.getCurrencyInstance(Locale("pt", "BR"))
    private lateinit var list: LinearLayout
    private lateinit var empty: TextView
    private val prefs by lazy { getSharedPreferences("os_facil", MODE_PRIVATE) }
    private val teal = Color.rgb(21, 94, 117)

    override fun onCreate(savedInstanceState: Bundle?) { super.onCreate(savedInstanceState); load(); showHome() }

    private fun showHome() {
        val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setBackgroundColor(Color.rgb(248,250,252)) }
        root.addView(header())
        val scroll = ScrollView(this); val body = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(dp(20),dp(18),dp(20),dp(30)) }
        val title = TextView(this).apply { text = "Ordens de serviço"; textSize = 25f; setTextColor(Color.rgb(15,23,42)); setTypeface(null, Typeface.BOLD) }
        body.addView(title)
        body.addView(TextView(this).apply { text = "Crie, salve e compartilhe seus atendimentos."; textSize=15f; setTextColor(Color.DKGRAY); setPadding(0,dp(4),0,dp(16)) })
        body.addView(button("＋  Nova ordem de serviço", teal) { editOrder(null) }, LinearLayout.LayoutParams(-1,dp(52)))
        body.addView(TextView(this).apply { text="HISTÓRICO"; textSize=12f; setTypeface(null,Typeface.BOLD); setTextColor(teal); setPadding(0,dp(26),0,dp(8)) })
        empty = TextView(this).apply { text="Nenhuma ordem criada ainda.\nToque em “Nova ordem de serviço” para começar."; gravity=Gravity.CENTER; setTextColor(Color.GRAY); textSize=16f; setPadding(0,dp(36),0,dp(36)) }
        list = LinearLayout(this).apply { orientation=LinearLayout.VERTICAL }
        body.addView(empty); body.addView(list)
        scroll.addView(body); root.addView(scroll, LinearLayout.LayoutParams(-1,0,1f)); setContentView(root); render()
    }

    private fun header(): View = LinearLayout(this).apply {
        gravity=Gravity.CENTER_VERTICAL; setPadding(dp(20),dp(14),dp(10),dp(14)); setBackgroundColor(teal)
        addView(ImageView(this@MainActivity).apply { setImageResource(R.drawable.os_facil_logo); scaleType=ImageView.ScaleType.CENTER_INSIDE }, LinearLayout.LayoutParams(dp(42),dp(42)).apply { rightMargin=dp(10) })
        addView(TextView(this@MainActivity).apply { text="OrdemPro"; textSize=22f; setTextColor(Color.WHITE); setTypeface(null,Typeface.BOLD) }, LinearLayout.LayoutParams(0,-2,1f))
        addView(Button(this@MainActivity).apply { text="Perfil"; textSize=14f; setTextColor(Color.WHITE); setBackgroundColor(Color.TRANSPARENT); setOnClickListener { profile() } }, LinearLayout.LayoutParams(-2,dp(42)))
    }

    private fun render() {
        list.removeAllViews(); empty.visibility=if(orders.isEmpty()) View.VISIBLE else View.GONE
        orders.sortedByDescending { it.id }.forEach { order ->
            val card = LinearLayout(this).apply { orientation=LinearLayout.VERTICAL; setPadding(dp(16),dp(14),dp(16),dp(12)); setBackgroundColor(Color.WHITE)
                setOnClickListener { editOrder(order) } }
            card.addView(TextView(this).apply { text="OS ${order.number}  •  ${order.status}"; textSize=13f; setTextColor(teal); setTypeface(null,Typeface.BOLD) })
            card.addView(TextView(this).apply { text=order.client; textSize=19f; setTextColor(Color.rgb(15,23,42)); setPadding(0,dp(5),0,0) })
            card.addView(TextView(this).apply { text="${order.service}  •  ${money.format(order.value)}"; textSize=14f; setTextColor(Color.DKGRAY); setPadding(0,dp(3),0,0) })
            val actions=LinearLayout(this).apply { gravity=Gravity.END; setPadding(0,dp(8),0,0) }
            actions.addView(button("PDF", Color.rgb(230,245,243)) { createPdf(order) }, LinearLayout.LayoutParams(dp(76),dp(40)))
            actions.addView(button("Editar", Color.TRANSPARENT) { editOrder(order) }, LinearLayout.LayoutParams(dp(80),dp(40)))
            card.addView(actions); list.addView(card, LinearLayout.LayoutParams(-1,-2).apply { bottomMargin=dp(10) })
        }
    }

    private fun editOrder(existing: ServiceOrder?) {
        val wrap=LinearLayout(this).apply { orientation=LinearLayout.VERTICAL; setPadding(dp(22),0,dp(22),0) }
        val n=field(wrap,"Número da OS", existing?.number ?: nextNumber())
        val client=field(wrap,"Nome do cliente",existing?.client ?: "")
        val phone=field(wrap,"Telefone / WhatsApp",existing?.phone ?: "")
        val service=field(wrap,"Serviço executado",existing?.service ?: "")
        val details=field(wrap,"Descrição, materiais e observações",existing?.details ?: "",true)
        val value=field(wrap,"Valor total (ex.: 150,00)",existing?.value?.toString()?.replace('.',',') ?: "",false,true)
        val status=Spinner(this).apply { adapter=ArrayAdapter(this@MainActivity,android.R.layout.simple_spinner_dropdown_item,listOf("Aberta","Em andamento","Concluída","Cancelada")); setSelection(listOf("Aberta","Em andamento","Concluída","Cancelada").indexOf(existing?.status ?: "Aberta")) }
        wrap.addView(label("Status")); wrap.addView(status)
        val scroll=ScrollView(this).apply { addView(wrap) }
        AlertDialog.Builder(this).setTitle(if(existing==null) "Nova ordem" else "Editar ordem").setView(scroll)
            .setNegativeButton("Cancelar",null).setPositiveButton("Salvar",null).setNeutralButton(if(existing==null) "" else "Excluir",null).create().also { dialog ->
                dialog.setOnShowListener {
                    dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                        val amount=parse(value.text.toString()); if(client.text.isBlank() || service.text.isBlank()) { toast("Informe o cliente e o serviço."); return@setOnClickListener }
                        val o=ServiceOrder(existing?.id ?: System.currentTimeMillis(),n.text.toString().ifBlank { nextNumber() },client.text.toString(),phone.text.toString(),service.text.toString(),details.text.toString(),amount,(status.selectedItem as String),existing?.date ?: SimpleDateFormat("dd/MM/yyyy",Locale("pt","BR")).format(Date()))
                        if(existing!=null) orders.removeAll { it.id==existing.id }; orders.add(o); save(); render(); dialog.dismiss()
                    }
                    if(existing!=null) dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setOnClickListener { orders.removeAll { it.id==existing.id }; save(); render(); dialog.dismiss() }
                }; dialog.show()
            }
    }

    private fun profile() {
        val wrap=LinearLayout(this).apply { orientation=LinearLayout.VERTICAL; setPadding(dp(22),0,dp(22),0) }
        val name=field(wrap,"Seu nome ou empresa",prefs.getString("pro_name","") ?: "")
        val doc=field(wrap,"CPF ou CNPJ",prefs.getString("pro_doc","") ?: "")
        val contact=field(wrap,"Telefone / e-mail",prefs.getString("pro_contact","") ?: "")
        AlertDialog.Builder(this).setTitle("Dados do profissional").setView(wrap).setNegativeButton("Cancelar",null).setNeutralButton("Privacidade") { _,_ -> privacy() }.setPositiveButton("Salvar") { _,_ -> prefs.edit().putString("pro_name",name.text.toString()).putString("pro_doc",doc.text.toString()).putString("pro_contact",contact.text.toString()).apply(); toast("Dados salvos") }.show()
    }

    private fun privacy() {
        AlertDialog.Builder(this).setTitle("Privacidade").setMessage("O OrdemPro armazena as ordens de serviço somente neste aparelho. Não possui conta, anúncios, rastreadores ou servidor próprio. Os dados só são compartilhados quando você escolhe enviar um PDF pelo Android.").setPositiveButton("Entendi", null).show()
    }

    private fun createPdf(o: ServiceOrder) {
        try {
            val pdf=PdfDocument(); val page=pdf.startPage(PdfDocument.PageInfo.Builder(595,842,1).create()); val c=page.canvas; val p=Paint(Paint.ANTI_ALIAS_FLAG); var y=66
            fun line(text:String,size:Float=12f,bold:Boolean=false,color:Int=Color.DKGRAY) { p.textSize=size; p.typeface=if(bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT; p.color=color; c.drawText(text,45f,y.toFloat(),p); y += (size+12).toInt() }
            c.drawColor(Color.WHITE); line("ORDEM DE SERVIÇO",22f,true,teal); line("OS Nº ${o.number}",13f,true); y+=12
            line("PRESTADOR",11f,true,teal); line(prefs.getString("pro_name","").orEmpty().ifBlank { "Profissional autônomo" },15f,true); line(prefs.getString("pro_doc","").orEmpty()); line(prefs.getString("pro_contact","").orEmpty()); y+=16
            line("CLIENTE",11f,true,teal); line(o.client,15f,true); line(o.phone); y+=16
            line("SERVIÇO",11f,true,teal); line(o.service,15f,true); o.details.split("\n").forEach { line(it) }; y+=16
            line("Data: ${o.date}"); line("Status: ${o.status}"); y+=12; line("VALOR TOTAL: ${money.format(o.value)}",18f,true,teal); y+=60
            line("Assinatura do cliente: _________________________________"); pdf.finishPage(page)
            val dir=File(cacheDir,"pdfs").apply { mkdirs() }; val file=File(dir,"OS-${o.number.replace(Regex("[^A-Za-z0-9]"),"-")}.pdf"); FileOutputStream(file).use { pdf.writeTo(it) }; pdf.close()
            val uri:Uri=FileProvider.getUriForFile(this,"$packageName.files",file); startActivity(Intent(Intent.ACTION_SEND).apply { type="application/pdf"; putExtra(Intent.EXTRA_STREAM,uri); addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION) }.let { Intent.createChooser(it,"Compartilhar ordem de serviço") })
        } catch(e:Exception) { toast("Não foi possível gerar o PDF: ${e.message}") }
    }

    private fun field(parent:LinearLayout,hint:String,value:String,multi:Boolean=false,decimal:Boolean=false):EditText { parent.addView(label(hint)); return EditText(this).apply { setText(value); this.hint=hint; textSize=16f; if(multi) { minLines=3; gravity=Gravity.TOP; inputType=InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE } else if(decimal) inputType=InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL; parent.addView(this,LinearLayout.LayoutParams(-1,-2).apply { bottomMargin=dp(10) }) } }
    private fun label(text:String)=TextView(this).apply { this.text=text; textSize=12f; setTextColor(teal); setTypeface(null,Typeface.BOLD); setPadding(0,dp(8),0,0) }
    private fun button(text:String,color:Int,click:()->Unit)=Button(this).apply { this.text=text; textSize=14f; setTextColor(if(color==teal) Color.WHITE else teal); setBackgroundColor(color); setOnClickListener { click() } }
    private fun parse(raw:String)=raw.replace(".","").replace(",",".").toDoubleOrNull() ?: 0.0
    private fun nextNumber()="${SimpleDateFormat("yyyy",Locale.US).format(Date())}-${(orders.maxOfOrNull { it.id }?.rem(10000)?.plus(1) ?: 1).toString().padStart(4,'0')}"
    private fun save() { val a=JSONArray(); orders.forEach { o -> a.put(JSONObject().put("id",o.id).put("number",o.number).put("client",o.client).put("phone",o.phone).put("service",o.service).put("details",o.details).put("value",o.value).put("status",o.status).put("date",o.date)) }; prefs.edit().putString("orders",a.toString()).apply() }
    private fun load() { val a=JSONArray(prefs.getString("orders","[]")); for(i in 0 until a.length()) { val x=a.getJSONObject(i); orders.add(ServiceOrder(x.getLong("id"),x.getString("number"),x.getString("client"),x.optString("phone"),x.getString("service"),x.optString("details"),x.optDouble("value"),x.optString("status","Aberta"),x.optString("date"))) } }
    private fun dp(v:Int)=(v*resources.displayMetrics.density).toInt(); private fun toast(s:String)=Toast.makeText(this,s,Toast.LENGTH_SHORT).show()
}
