import { useState, useEffect, useRef, useCallback } from "react";

const T = {
  navy:"#0B1D35",navyMid:"#132848",brand:"#2563EB",brandL:"#EFF6FF",brandD:"#1D4ED8",
  green:"#059669",greenL:"#ECFDF5",amber:"#D97706",amberL:"#FFFBEB",
  red:"#DC2626",redL:"#FEF2F2",purple:"#7C3AED",purpleL:"#F5F3FF",
  teal:"#0891B2",tealL:"#ECFEFF",text:"#0F172A",textSec:"#475569",
  textTer:"#94A3B8",border:"#E2E8F0",surface:"#F8FAFC",white:"#FFFFFF",
};

const DEFAULT_CATS = [
  {id:"housing",label:"Habitação",icon:"🏠",color:"#7C3AED",bg:"#F5F3FF",type:"expense"},
  {id:"food",label:"Alimentação",icon:"🛒",color:"#F59E0B",bg:"#FFFBEB",type:"expense"},
  {id:"transport",label:"Transporte",icon:"🚗",color:"#3B82F6",bg:"#EFF6FF",type:"expense"},
  {id:"health",label:"Saúde",icon:"💊",color:"#10B981",bg:"#ECFDF5",type:"expense"},
  {id:"subs",label:"Subscrições",icon:"📱",color:"#EC4899",bg:"#FDF2F8",type:"expense"},
  {id:"restaurant",label:"Restaurantes",icon:"🍽️",color:"#EF4444",bg:"#FEF2F2",type:"expense"},
  {id:"shopping",label:"Compras",icon:"🛍️",color:"#F97316",bg:"#FFF7ED",type:"expense"},
  {id:"leisure",label:"Lazer",icon:"🎭",color:"#8B5CF6",bg:"#F5F3FF",type:"expense"},
  {id:"education",label:"Educação",icon:"📚",color:"#0891B2",bg:"#ECFEFF",type:"expense"},
  {id:"investment",label:"Investimento",icon:"📈",color:"#059669",bg:"#ECFDF5",type:"expense"},
  {id:"salary",label:"Salário",icon:"💼",color:"#059669",bg:"#ECFDF5",type:"income"},
  {id:"freelance",label:"Freelance",icon:"💻",color:"#2563EB",bg:"#EFF6FF",type:"income"},
  {id:"other_in",label:"Outra receita",icon:"💰",color:"#D97706",bg:"#FFFBEB",type:"income"},
  {id:"other",label:"Outros",icon:"📦",color:"#64748B",bg:"#F8FAFC",type:"expense"},
];

const KW = {
  café:"food",cafe:"food",coffee:"food",starbucks:"food",migros:"food",lidl:"food",
  uber:"transport",bolt:"transport",taxi:"transport",comboio:"transport",metro:"transport",sbb:"transport",
  netflix:"subs",spotify:"subs",amazon:"subs",apple:"subs",disney:"subs",
  renda:"housing",aluguer:"housing",hipoteca:"housing",
  farmácia:"health",médico:"health",ginásio:"health",
  restaurante:"restaurant",almoço:"restaurant",jantar:"restaurant",
  zara:"shopping",ikea:"shopping",fnac:"shopping",
  salário:"salary",salario:"salary",vencimento:"salary",
  freelance:"freelance",projeto:"freelance",
};

const MONTHS_FULL=["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"];
const MONTHS_SHORT=["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
const now=new Date(), CY=now.getFullYear(), CM=now.getMonth();

function mkExp(d,a,c,off=0){const dt=new Date(CY,CM,now.getDate()-off);return{id:Math.random().toString(36).slice(2),desc:d,amount:a,catId:c,type:"expense",date:dt.toISOString().slice(0,10)};}
function mkInc(d,a,c,off=0){const dt=new Date(CY,CM,now.getDate()-off);return{id:Math.random().toString(36).slice(2),desc:d,amount:a,catId:c,type:"income",date:dt.toISOString().slice(0,10)};}

const INIT_TX=[
  mkInc("Salário",5500,"salary",5),mkInc("Freelance projeto",800,"freelance",3),
  mkExp("Renda",1450,"housing",4),mkExp("Migros semana",87.3,"food",3),
  mkExp("Netflix",15.9,"subs",3),mkExp("Spotify",9.9,"subs",3),
  mkExp("Starbucks",5.5,"food",0),mkExp("Uber",14.2,"transport",0),
  mkExp("Restaurante",48,"restaurant",2),mkExp("SBB passe",175,"transport",4),
  mkExp("Farmácia",32.6,"health",1),mkExp("Zara",89,"shopping",2),
  mkExp("Ginásio",40,"health",4),mkExp("ETF S&P500",400,"investment",4),
];
const INIT_BUDGET={housing:1450,food:350,transport:250,health:150,subs:80,restaurant:200,shopping:150,leisure:100,education:50,investment:400,other:100};

function buildHistory(){
  return Array.from({length:6},(_,i)=>{
    const d=new Date(CY,CM-5+i,1);
    const base=1700+Math.random()*500;
    const income=5500+(i===2?800:0)+(i===4?600:0);
    return{month:d.getMonth(),year:d.getFullYear(),label:MONTHS_SHORT[d.getMonth()],
      totalExpense:i===5?0:base,totalIncome:i===5?0:income,
      byCategory:{housing:1450,food:70+Math.random()*80,transport:160+Math.random()*100,
        health:30+Math.random()*100,subs:25+Math.random()*15,
        restaurant:20+Math.random()*120,shopping:10+Math.random()*180,investment:400,other:Math.random()*80}};
  });
}

const fCHF=(n,d=2)=>"CHF "+Number(n||0).toLocaleString("pt-PT",{minimumFractionDigits:d,maximumFractionDigits:d});
const fK=n=>n>=1e6?"CHF "+(n/1e6).toFixed(1)+"M":n>=1000?"CHF "+(n/1000).toFixed(0)+"K":fCHF(n,0);
const pct=(a,b)=>b>0?Math.min(100,Math.round(a/b*100)):0;
const catById=(cats,id)=>cats.find(c=>c.id===id)||cats[cats.length-1];
const todayStr=()=>new Date().toISOString().slice(0,10);
const daysInMonth=(y,m)=>new Date(y,m+1,0).getDate();

function projectWealth(initial,monthly,rate,years){
  let b=initial;const mr=rate/12/100;
  for(let y=0;y<years;y++)for(let m=0;m<12;m++)b=(b+monthly)*(1+mr);
  return b;
}

const GS=`
@import url('https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=Inter:wght@300;400;500;600&display=swap');
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
html,body,#root{height:100%;background:#B8C5D6;font-family:'Inter',sans-serif}
::-webkit-scrollbar{width:3px}::-webkit-scrollbar-thumb{background:#CBD5E1;border-radius:2px}
input,select{font-family:'Inter',sans-serif}
input[type=range]{-webkit-appearance:none;width:100%;height:4px;background:#E2E8F0;border-radius:2px;outline:none;cursor:pointer}
input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:18px;height:18px;border-radius:50%;background:#2563EB;border:2px solid #fff;box-shadow:0 1px 4px rgba(37,99,235,.35)}
@keyframes slideUp{from{transform:translateY(16px);opacity:0}to{transform:translateY(0);opacity:1}}
@keyframes popUp{from{transform:translateY(100%)}to{transform:translateY(0)}}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
`;

function PhoneShell({children,statusDark}){
  const [t,setT]=useState(()=>{const n=new Date();return n.getHours()+":"+(n.getMinutes()<10?"0":"")+n.getMinutes();});
  useEffect(()=>{const i=setInterval(()=>{const n=new Date();setT(n.getHours()+":"+(n.getMinutes()<10?"0":"")+n.getMinutes());},15000);return()=>clearInterval(i);},[]);
  return(
    <div style={{display:"flex",justifyContent:"center",alignItems:"flex-start",minHeight:"100vh",padding:"16px 0 32px",background:"#B8C5D6"}}>
      <div style={{width:390,height:844,borderRadius:44,background:T.white,boxShadow:"0 32px 80px rgba(0,0,0,.3),0 0 0 1px rgba(0,0,0,.06)",display:"flex",flexDirection:"column",overflow:"hidden",position:"relative"}}>
        <div style={{background:statusDark?T.navy:T.white,padding:"14px 24px 6px",display:"flex",justifyContent:"space-between",alignItems:"center",flexShrink:0,transition:"background .3s"}}>
          <span style={{fontSize:14,fontWeight:600,color:statusDark?"rgba(255,255,255,.8)":T.text}}>{t}</span>
          <div style={{width:90,height:6,background:statusDark?"rgba(255,255,255,.12)":T.border,borderRadius:3}}/>
          <span style={{fontSize:12,color:statusDark?"rgba(255,255,255,.5)":T.textTer}}>●●●</span>
        </div>
        {children}
      </div>
    </div>
  );
}

function BottomNav({active,onChange}){
  const items=[
    {id:"summary",icon:"⊟",label:"Resumo"},
    {id:"analysis",icon:"◎",label:"Análise"},
    {id:"add",icon:null},
    {id:"budget",icon:"◈",label:"Orçamento"},
    {id:"projections",icon:"◬",label:"Projeções"},
  ];
  return(
    <div style={{display:"flex",background:T.white,borderTop:`1px solid ${T.border}`,padding:"8px 0 20px",flexShrink:0}}>
      {items.map(item=>item.id==="add"?(
        <div key="add" style={{flex:1,display:"flex",justifyContent:"center"}}>
          <button onClick={()=>onChange("add")} style={{width:56,height:56,borderRadius:"50%",background:T.brand,border:`3px solid ${T.white}`,boxShadow:"0 4px 20px rgba(37,99,235,.45)",marginTop:-24,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",color:T.white,fontSize:30,fontWeight:300,lineHeight:1,transition:"transform .15s"}}
            onMouseDown={e=>e.currentTarget.style.transform="scale(.9)"}
            onMouseUp={e=>e.currentTarget.style.transform="scale(1)"}
          >+</button>
        </div>
      ):(
        <button key={item.id} onClick={()=>onChange(item.id)} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:3,background:"none",border:"none",cursor:"pointer",padding:"4px 0"}}>
          <span style={{fontSize:18,lineHeight:1,filter:active===item.id?"none":"grayscale(1) opacity(.45)",transition:"filter .2s"}}>{item.icon}</span>
          <span style={{fontSize:10,fontWeight:500,color:active===item.id?T.brand:T.textTer,transition:"color .2s"}}>{item.label}</span>
          {active===item.id&&<div style={{width:4,height:4,borderRadius:"50%",background:T.brand}}/>}
        </button>
      ))}
    </div>
  );
}

function Card({children,style={}}){return <div style={{background:T.white,border:`1px solid ${T.border}`,borderRadius:16,padding:16,...style}}>{children}</div>;}
function PBar({value,color=T.brand,height=6,style={}}){return(<div style={{background:T.surface,borderRadius:height,height,overflow:"hidden",...style}}><div style={{width:`${Math.min(100,Math.max(0,value))}%`,height:"100%",background:color,borderRadius:height,transition:"width .5s ease"}}/></div>);}
function Tag({children,color=T.brand,bg}){return <span style={{display:"inline-block",padding:"2px 8px",borderRadius:20,fontSize:11,fontWeight:500,background:bg||color+"18",color}}>{children}</span>;}
function Btn({children,onClick,variant="primary",style={},disabled,small}){
  const base={padding:small?"8px 14px":"13px 20px",borderRadius:10,fontSize:small?13:15,fontWeight:500,fontFamily:"'Inter',sans-serif",cursor:disabled?"default":"pointer",border:"none",transition:"all .15s",width:style.width||"100%",textAlign:"center",lineHeight:1.3};
  const v={primary:{background:T.brand,color:T.white,opacity:disabled?.4:1},ghost:{background:"transparent",color:T.brand,border:`1.5px solid ${T.border}`}};
  return <button onClick={disabled?undefined:onClick} style={{...base,...v[variant],...style}}>{children}</button>;
}

// ─── CANVAS: LINE CHART ───────────────────────────────────────────────────────
function LineChart({series,labels,colors,height=150}){
  const ref=useRef(null);
  useEffect(()=>{
    if(!ref.current)return;
    const cv=ref.current,ctx=cv.getContext("2d");
    const W=cv.width,H=cv.height,P={t:10,r:12,b:28,l:58};
    ctx.clearRect(0,0,W,H);
    if(!series.length||!series[0].length)return;
    const all=series.flat();
    const maxV=Math.max(...all)||1,minV=0,range=maxV-minV||1;
    const xS=(W-P.l-P.r)/(labels.length-1||1);
    [0,.25,.5,.75,1].forEach(f=>{
      const y=H-P.b-(f*(H-P.t-P.b));
      ctx.beginPath();ctx.strokeStyle="rgba(0,0,0,.05)";ctx.lineWidth=1;
      ctx.moveTo(P.l,y);ctx.lineTo(W-P.r,y);ctx.stroke();
      ctx.fillStyle=T.textTer;ctx.font="10px Inter";ctx.textAlign="right";
      ctx.fillText(fK(minV+f*range),P.l-4,y+4);
    });
    labels.forEach((l,i)=>{
      ctx.fillStyle=T.textTer;ctx.font="10px Inter";ctx.textAlign="center";
      ctx.fillText(l,P.l+i*xS,H-6);
    });
    series.forEach((pts,si)=>{
      const c=colors[si];
      ctx.beginPath();
      pts.forEach((v,i)=>{const x=P.l+i*xS,y=H-P.b-((v-minV)/range*(H-P.t-P.b));i===0?ctx.moveTo(x,y):ctx.lineTo(x,y);});
      ctx.strokeStyle=c;ctx.lineWidth=2.5;ctx.lineJoin="round";ctx.stroke();
      const lastI=pts.length-1;
      ctx.lineTo(P.l+lastI*xS,H-P.b);ctx.lineTo(P.l,H-P.b);ctx.closePath();
      ctx.fillStyle=c+"18";ctx.fill();
      pts.forEach((v,i)=>{
        const x=P.l+i*xS,y=H-P.b-((v-minV)/range*(H-P.t-P.b));
        ctx.beginPath();ctx.arc(x,y,3.5,0,Math.PI*2);ctx.fillStyle=c;ctx.fill();
        ctx.beginPath();ctx.arc(x,y,2,0,Math.PI*2);ctx.fillStyle=T.white;ctx.fill();
      });
    });
  },[series,labels,colors,height]);
  return <canvas ref={ref} width={340} height={height} style={{width:"100%",height}}/>;
}

// ─── CANVAS: DONUT ────────────────────────────────────────────────────────────
function DonutChart({data,size=160}){
  const ref=useRef(null);
  useEffect(()=>{
    if(!ref.current||!data.length)return;
    const cv=ref.current,ctx=cv.getContext("2d");
    const W=cv.width,H=cv.height,cx=W/2,cy=H/2,r=W*.38,inn=r*.6;
    ctx.clearRect(0,0,W,H);
    const total=data.reduce((s,d)=>s+d.value,0)||1;
    let ang=-Math.PI/2;
    data.forEach(d=>{
      const sw=(d.value/total)*2*Math.PI;
      ctx.beginPath();
      ctx.moveTo(cx+inn*Math.cos(ang),cy+inn*Math.sin(ang));
      ctx.arc(cx,cy,inn,ang,ang+sw);
      ctx.lineTo(cx+r*Math.cos(ang+sw),cy+r*Math.sin(ang+sw));
      ctx.arc(cx,cy,r,ang+sw,ang,true);
      ctx.closePath();ctx.fillStyle=d.color;ctx.fill();
      ang+=sw;
    });
    ctx.beginPath();ctx.arc(cx,cy,inn-1,0,Math.PI*2);ctx.fillStyle=T.white;ctx.fill();
    const top=data.reduce((a,b)=>a.value>b.value?a:b,data[0]);
    ctx.font=`bold 11px Syne,sans-serif`;ctx.fillStyle=T.textSec;ctx.textAlign="center";
    ctx.fillText(top.label,cx,cy-2);
    ctx.font=`500 10px Inter`;ctx.fillStyle=T.textTer;
    ctx.fillText(Math.round(top.value/total*100)+"%",cx,cy+13);
  },[data,size]);
  return <canvas ref={ref} width={size} height={size} style={{width:size,height:size}}/>;
}

// ─── SUMMARY ─────────────────────────────────────────────────────────────────
function SummaryScreen({transactions,budget,categories}){
  const cur=transactions.filter(t=>{const d=new Date(t.date);return d.getMonth()===CM&&d.getFullYear()===CY;});
  const totalInc=cur.filter(t=>t.type==="income").reduce((s,t)=>s+t.amount,0);
  const totalExp=cur.filter(t=>t.type==="expense").reduce((s,t)=>s+t.amount,0);
  const totalBud=Object.values(budget).reduce((s,v)=>s+v,0);
  const rem=totalInc-totalExp;
  const dLeft=daysInMonth(CY,CM)-now.getDate();
  const daily=dLeft>0?Math.max(0,rem)/dLeft:0;
  const spentPct=pct(totalExp,totalBud);
  const saveRate=totalInc>0?Math.max(0,Math.round((rem/totalInc)*100)):0;
  const expCats=categories.filter(c=>c.type==="expense").map(c=>({...c,spent:cur.filter(t=>t.type==="expense"&&t.catId===c.id).reduce((s,t)=>s+t.amount,0),planned:budget[c.id]||0})).filter(c=>c.spent>0||c.planned>0).sort((a,b)=>b.spent-a.spent);

  return(
    <div style={{display:"flex",flexDirection:"column",flex:1,overflow:"hidden"}}>
      <div style={{background:T.navy,padding:"18px 18px 24px",flexShrink:0,position:"relative",overflow:"hidden"}}>
        <div style={{position:"absolute",right:-40,top:-40,width:140,height:140,borderRadius:"50%",border:"35px solid rgba(255,255,255,.04)",pointerEvents:"none"}}/>
        <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start",marginBottom:18}}>
          <div>
            <div style={{fontSize:12,color:"rgba(255,255,255,.4)",marginBottom:2}}>Bom dia 👋</div>
            <div style={{fontSize:15,fontWeight:500,color:"rgba(255,255,255,.8)"}}>{MONTHS_FULL[CM]} {CY}</div>
          </div>
          <div style={{textAlign:"center"}}>
            <div style={{width:50,height:50,borderRadius:"50%",border:`3px solid ${saveRate>=20?T.green:"#FBBF24"}`,background:saveRate>=20?"rgba(5,150,105,.12)":"rgba(217,119,6,.12)",display:"flex",alignItems:"center",justifyContent:"center"}}>
              <span style={{fontSize:15,fontWeight:700,fontFamily:"Syne",color:saveRate>=20?T.green:"#FBBF24"}}>{saveRate}%</span>
            </div>
            <div style={{fontSize:9,color:saveRate>=20?T.green:"#FBBF24",fontWeight:600,textTransform:"uppercase",letterSpacing:".05em",marginTop:3}}>poupança</div>
          </div>
        </div>
        <div style={{fontSize:12,color:"rgba(255,255,255,.4)",marginBottom:4}}>Saldo disponível</div>
        <div style={{fontSize:36,fontWeight:800,fontFamily:"Syne",color:T.white,marginBottom:14,lineHeight:1}}>{fCHF(rem)}</div>
        <PBar value={spentPct} color={spentPct>90?"#EF4444":spentPct>70?"#FBBF24":"#34D399"} height={6} style={{marginBottom:8}}/>
        <div style={{display:"flex",justifyContent:"space-between",fontSize:11,color:"rgba(255,255,255,.4)"}}>
          <span>Gasto: {fCHF(totalExp,0)}</span>
          <span>Orçamento: {fCHF(totalBud,0)}</span>
        </div>
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"14px 16px 16px"}}>
        {spentPct>75&&dLeft>3&&(<div style={{background:T.amberL,borderLeft:`3px solid ${T.amber}`,padding:"10px 12px",marginBottom:14,fontSize:13,color:"#92400E",lineHeight:1.5}}><strong>Atenção:</strong> {spentPct}% do orçamento com {dLeft} dias restantes.</div>)}
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8,marginBottom:14}}>
          {[{l:"Receitas",v:fCHF(totalInc,0),c:T.green},{l:"Despesas",v:fCHF(totalExp,0),c:T.red},{l:"Limite/dia",v:fCHF(daily,0),c:T.brand}].map(k=>(
            <Card key={k.l} style={{padding:11,textAlign:"center"}}><div style={{fontSize:10,color:T.textTer,textTransform:"uppercase",letterSpacing:".05em",marginBottom:3}}>{k.l}</div><div style={{fontSize:15,fontWeight:700,fontFamily:"Syne",color:k.c}}>{k.v}</div></Card>
          ))}
        </div>
        <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:10}}>Últimas transações</div>
        {cur.slice(0,5).map(t=>{const cat=catById(categories,t.catId);return(
          <div key={t.id} style={{display:"flex",alignItems:"center",gap:11,padding:"10px 0",borderBottom:`1px solid ${T.border}`}}>
            <div style={{width:38,height:38,borderRadius:11,background:cat.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:18,flexShrink:0}}>{cat.icon}</div>
            <div style={{flex:1}}><div style={{fontSize:13,fontWeight:500,color:T.text}}>{t.desc}</div><div style={{fontSize:11,color:T.textTer}}>{cat.label} · {t.date.slice(8)}/{t.date.slice(5,7)}</div></div>
            <div style={{fontSize:13,fontWeight:600,color:t.type==="income"?T.green:T.red}}>{t.type==="income"?"+":"-"}{fCHF(t.amount)}</div>
          </div>
        );})}
        <div style={{fontSize:13,fontWeight:600,color:T.text,margin:"18px 0 10px"}}>Gastos vs orçamento</div>
        {expCats.slice(0,6).map(c=>{const p=pct(c.spent,c.planned),over=c.spent>c.planned&&c.planned>0;return(
          <div key={c.id} style={{marginBottom:13}}>
            <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:5}}>
              <span style={{fontSize:16}}>{c.icon}</span>
              <span style={{fontSize:13,color:T.textSec,flex:1}}>{c.label}</span>
              <span style={{fontSize:11,fontWeight:600,color:over?T.red:T.textSec}}>{fCHF(c.spent,0)}</span>
              <span style={{fontSize:11,color:T.textTer}}>/{fCHF(c.planned,0)}</span>
              <Tag color={over?T.red:p>80?T.amber:T.green}>{p}%</Tag>
            </div>
            <PBar value={p} color={over?"#EF4444":p>80?"#F59E0B":c.color} height={5}/>
          </div>
        );})}
      </div>
    </div>
  );
}

// ─── ANALYSIS ────────────────────────────────────────────────────────────────
function AnalysisScreen({transactions,history,categories}){
  const [tab,setTab]=useState("line");
  const [drillM,setDrillM]=useState(null);
  const [drillC,setDrillC]=useState(null);

  const curExp=transactions.filter(t=>t.type==="expense"&&new Date(t.date).getMonth()===CM).reduce((s,t)=>s+t.amount,0);
  const curInc=transactions.filter(t=>t.type==="income"&&new Date(t.date).getMonth()===CM).reduce((s,t)=>s+t.amount,0);
  const allM=[...history.slice(0,5),{...history[5],totalExpense:curExp,totalIncome:curInc}];
  const labels=allM.map(m=>m.label);

  const curCats=categories.filter(c=>c.type==="expense").map(c=>({...c,value:transactions.filter(t=>t.type==="expense"&&t.catId===c.id&&new Date(t.date).getMonth()===CM).reduce((s,t)=>s+t.amount,0)})).filter(c=>c.value>0).sort((a,b)=>b.value-a.value);
  const totalCurExp=curCats.reduce((s,c)=>s+c.value,0)||1;
  const avgExp=allM.slice(0,5).reduce((s,m)=>s+m.totalExpense,0)/5;
  const tabs=[{id:"line",label:"Evolução"},{id:"donut",label:"Categorias"},{id:"insights",label:"Insights"}];

  return(
    <div style={{display:"flex",flexDirection:"column",flex:1,overflow:"hidden"}}>
      <div style={{padding:"18px 16px 0",flexShrink:0}}>
        <div style={{fontSize:22,fontWeight:800,fontFamily:"Syne",color:T.text,marginBottom:2}}>Análise</div>
        <div style={{fontSize:13,color:T.textSec,marginBottom:14}}>Últimos 6 meses · {MONTHS_FULL[CM]} {CY}</div>
        <div style={{display:"flex",gap:6,marginBottom:14}}>
          {tabs.map(t=><button key={t.id} onClick={()=>setTab(t.id)} style={{padding:"6px 14px",borderRadius:8,border:`1px solid ${tab===t.id?T.brand:T.border}`,background:tab===t.id?T.brandL:T.white,color:tab===t.id?T.brand:T.textSec,fontSize:13,fontWeight:500,cursor:"pointer",fontFamily:"'Inter',sans-serif",transition:"all .15s"}}>{t.label}</button>)}
        </div>
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"0 16px 16px"}}>

        {tab==="line"&&(<>
          <Card style={{marginBottom:12,padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:4}}>Despesas vs Receitas</div>
            <div style={{fontSize:12,color:T.textTer,marginBottom:14}}>Últimos 6 meses</div>
            <LineChart series={[allM.map(m=>m.totalExpense),allM.map(m=>m.totalIncome)]} labels={labels} colors={[T.red,T.green]} height={150}/>
            <div style={{display:"flex",gap:16,justifyContent:"center",marginTop:12}}>
              {[["Despesas",T.red],["Receitas",T.green]].map(([l,c])=><div key={l} style={{display:"flex",alignItems:"center",gap:5}}><div style={{width:12,height:3,background:c,borderRadius:2}}/><span style={{fontSize:11,color:T.textSec}}>{l}</span></div>)}
            </div>
          </Card>
          <Card style={{marginBottom:12,padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:4}}>Drilldown por mês</div>
            <div style={{fontSize:12,color:T.textTer,marginBottom:12}}>Selecione um mês para ver detalhe</div>
            <div style={{display:"flex",gap:6,overflowX:"auto",paddingBottom:8,marginBottom:12}}>
              {allM.map((m,i)=><button key={i} onClick={()=>{setDrillM(drillM===i?null:i);setDrillC(null);}} style={{padding:"5px 12px",borderRadius:8,border:`1px solid ${drillM===i?T.brand:T.border}`,background:drillM===i?T.brandL:T.white,color:drillM===i?T.brand:T.textSec,fontSize:12,fontWeight:500,cursor:"pointer",whiteSpace:"nowrap",flexShrink:0,fontFamily:"'Inter',sans-serif"}}>{m.label}</button>)}
            </div>
            {drillM!=null&&(
              <div style={{animation:"slideUp .25s ease both"}}>
                <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:12}}>
                  <div><div style={{fontSize:12,color:T.textTer}}>{allM[drillM].label} {allM[drillM].year}</div><div style={{fontSize:16,fontWeight:700,fontFamily:"Syne",color:T.text}}>{fCHF(allM[drillM].totalExpense,0)}</div></div>
                  {drillM>0&&<Tag color={allM[drillM].totalExpense>allM[drillM-1].totalExpense?T.red:T.green}>{allM[drillM].totalExpense>allM[drillM-1].totalExpense?"↑":"↓"}{Math.abs(Math.round((allM[drillM].totalExpense/allM[drillM-1].totalExpense-1)*100))}% vs mês ant.</Tag>}
                </div>
                {Object.entries(allM[drillM].byCategory||{}).filter(([,v])=>v>0).sort(([,a],[,b])=>b-a).map(([k,v])=>{
                  const cat=catById(categories,k);const isOpen=drillC===k;
                  return(<div key={k}>
                    <div onClick={()=>setDrillC(isOpen?null:k)} style={{display:"flex",alignItems:"center",gap:8,padding:"8px 0",borderBottom:`1px solid ${T.border}`,cursor:"pointer"}}>
                      <span style={{fontSize:16,width:22}}>{cat.icon}</span>
                      <span style={{fontSize:13,color:T.text,flex:1}}>{cat.label}</span>
                      <div style={{width:70,height:4,background:T.surface,borderRadius:2,overflow:"hidden",marginRight:8}}>
                        <div style={{height:4,background:cat.color,width:pct(v,allM[drillM].totalExpense)+"%",borderRadius:2}}/>
                      </div>
                      <span style={{fontSize:12,fontWeight:600,color:T.text,minWidth:64,textAlign:"right"}}>{fCHF(v,0)}</span>
                      <span style={{fontSize:11,color:T.textTer,marginLeft:4}}>{isOpen?"▲":"▶"}</span>
                    </div>
                    {isOpen&&drillM===5&&(
                      <div style={{background:T.surface,borderRadius:8,padding:"6px 0",margin:"4px 0 6px",animation:"slideUp .2s ease both"}}>
                        {transactions.filter(t=>t.catId===k&&t.type==="expense"&&new Date(t.date).getMonth()===CM).map(t=>(
                          <div key={t.id} style={{display:"flex",justifyContent:"space-between",padding:"6px 12px",fontSize:12}}>
                            <span style={{color:T.text}}>{t.desc}</span>
                            <div style={{display:"flex",gap:10}}><span style={{color:T.textTer}}>{t.date.slice(8)}/{t.date.slice(5,7)}</span><span style={{color:T.red,fontWeight:500}}>{fCHF(t.amount)}</span></div>
                          </div>
                        ))}
                        {transactions.filter(t=>t.catId===k&&t.type==="expense"&&new Date(t.date).getMonth()===CM).length===0&&<div style={{padding:"8px 12px",fontSize:12,color:T.textTer}}>Sem transações este mês para os dados históricos.</div>}
                      </div>
                    )}
                    {isOpen&&drillM<5&&<div style={{background:T.surface,borderRadius:8,padding:"8px 12px",margin:"4px 0 6px",fontSize:12,color:T.textTer}}>Dados históricos resumidos — adicione transações no mês corrente para ver detalhe.</div>}
                  </div>);
                })}
              </div>
            )}
          </Card>
        </>)}

        {tab==="donut"&&(<>
          <Card style={{marginBottom:12,padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:14}}>{MONTHS_FULL[CM]} — Distribuição de despesas</div>
            <div style={{display:"flex",gap:16,alignItems:"center"}}>
              <DonutChart data={curCats} size={140}/>
              <div style={{flex:1}}>
                {curCats.slice(0,5).map(c=><div key={c.id} style={{display:"flex",alignItems:"center",gap:7,marginBottom:9}}>
                  <div style={{width:8,height:8,borderRadius:"50%",background:c.color,flexShrink:0}}/>
                  <span style={{fontSize:12,color:T.textSec,flex:1}}>{c.icon} {c.label}</span>
                  <span style={{fontSize:11,fontWeight:600,color:T.text}}>{Math.round(c.value/totalCurExp*100)}%</span>
                </div>)}
              </div>
            </div>
          </Card>
          <Card style={{padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:12}}>Detalhe por categoria</div>
            {curCats.map(c=><div key={c.id} style={{marginBottom:14}}>
              <div style={{display:"flex",alignItems:"center",gap:8,marginBottom:5}}>
                <span style={{fontSize:15}}>{c.icon}</span>
                <span style={{fontSize:13,color:T.text,flex:1,fontWeight:500}}>{c.label}</span>
                <span style={{fontSize:13,fontWeight:700,color:c.color}}>{fCHF(c.value)}</span>
                <Tag color={c.color}>{Math.round(c.value/totalCurExp*100)}%</Tag>
              </div>
              <PBar value={c.value/totalCurExp*100} color={c.color} height={5}/>
            </div>)}
          </Card>
        </>)}

        {tab==="insights"&&(<>
          <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10,marginBottom:12}}>
            {[
              {l:"Média mensal",v:fCHF(avgExp,0),icon:"📊",c:T.brand},
              {l:"Este mês vs média",v:(curExp>avgExp?"↑":"↓")+Math.abs(Math.round((curExp/avgExp-1)*100))+"%",icon:"📈",c:curExp>avgExp?T.red:T.green},
              {l:"Maior categoria",v:curCats[0]?.label||"—",icon:"🏆",c:T.amber},
              {l:"Categorias ativas",v:curCats.length,icon:"📂",c:T.purple},
            ].map(k=><Card key={k.l} style={{padding:14}}><div style={{fontSize:20,marginBottom:6}}>{k.icon}</div><div style={{fontSize:11,color:T.textTer,marginBottom:3}}>{k.l}</div><div style={{fontSize:14,fontWeight:700,fontFamily:"Syne",color:k.c}}>{k.v}</div></Card>)}
          </div>
          <Card style={{marginBottom:12,padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:12}}>Tendência de poupança</div>
            <LineChart series={[allM.map(m=>Math.max(0,m.totalIncome-m.totalExpense))]} labels={labels} colors={[T.green]} height={110}/>
          </Card>
          <Card style={{padding:16}}>
            <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:12}}>Insights automáticos</div>
            {[
              curCats[0]&&`A maior despesa este mês é ${curCats[0].label} com ${fCHF(curCats[0].value)} (${Math.round(curCats[0].value/totalCurExp*100)}% do total).`,
              `A média de despesas nos últimos 6 meses é ${fCHF(avgExp,0)}/mês.`,
              curCats.find(c=>c.id==="investment")&&`Está a investir ${fCHF(curCats.find(c=>c.id==="investment").value)} este mês. Excelente hábito!`,
              curExp>avgExp&&`Este mês está ${Math.round((curExp/avgExp-1)*100)}% acima da sua média histórica. Atenção aos gastos.`,
            ].filter(Boolean).map((ins,i)=><div key={i} style={{display:"flex",gap:10,padding:"10px 0",borderBottom:`1px solid ${T.border}`}}><span style={{fontSize:16}}>💡</span><p style={{fontSize:13,color:T.textSec,lineHeight:1.6,margin:0}}>{ins}</p></div>)}
          </Card>
        </>)}
      </div>
    </div>
  );
}

// ─── BUDGET ──────────────────────────────────────────────────────────────────
function BudgetScreen({transactions,budget,setBudget,categories}){
  const [editing,setEditing]=useState(null);
  const [editVal,setEditVal]=useState("");
  const cur=transactions.filter(t=>{const d=new Date(t.date);return d.getMonth()===CM&&d.getFullYear()===CY;});
  const totalPlan=Object.values(budget).reduce((s,v)=>s+v,0);
  const totalSpent=cur.filter(t=>t.type==="expense").reduce((s,t)=>s+t.amount,0);
  const cats=categories.filter(c=>c.type==="expense").map(c=>({...c,spent:cur.filter(t=>t.type==="expense"&&t.catId===c.id).reduce((s,t)=>s+t.amount,0),planned:budget[c.id]||0})).sort((a,b)=>b.spent-a.spent);
  const saveEdit=k=>{setBudget(p=>({...p,[k]:parseFloat(editVal)||0}));setEditing(null);};

  return(
    <div style={{display:"flex",flexDirection:"column",flex:1,overflow:"hidden"}}>
      <div style={{padding:"18px 16px 0",flexShrink:0}}>
        <div style={{fontSize:22,fontWeight:800,fontFamily:"Syne",color:T.text,marginBottom:2}}>Orçamento</div>
        <div style={{fontSize:13,color:T.textSec,marginBottom:12}}>{MONTHS_FULL[CM]} {CY} · Toque ✏️ para editar</div>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8,marginBottom:14}}>
          {[{l:"Previsto",v:fCHF(totalPlan,0),c:T.text},{l:"Gasto",v:fCHF(totalSpent,0),c:T.red},{l:"Restante",v:fCHF(Math.max(0,totalPlan-totalSpent),0),c:totalPlan>totalSpent?T.green:T.red}].map(k=>(
            <Card key={k.l} style={{padding:11,textAlign:"center"}}><div style={{fontSize:10,color:T.textTer,textTransform:"uppercase",letterSpacing:".05em",marginBottom:3}}>{k.l}</div><div style={{fontSize:14,fontWeight:700,fontFamily:"Syne",color:k.c}}>{k.v}</div></Card>
          ))}
        </div>
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"0 16px 16px"}}>
        {cats.map(c=>{const p=pct(c.spent,c.planned),over=c.spent>c.planned&&c.planned>0,isEd=editing===c.id;return(
          <div key={c.id} style={{border:`1px solid ${isEd?T.brand:T.border}`,borderRadius:14,padding:14,marginBottom:10,background:isEd?"#FAFCFF":T.white,transition:"all .2s"}}>
            <div style={{display:"flex",alignItems:"center",gap:10,marginBottom:10}}>
              <div style={{width:36,height:36,borderRadius:10,background:c.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:18,flexShrink:0}}>{c.icon}</div>
              <span style={{fontSize:14,fontWeight:600,color:T.text,flex:1}}>{c.label}</span>
              <Tag color={over?T.red:p>80?T.amber:T.green} bg={over?T.redL:p>80?T.amberL:T.greenL}>{p}%</Tag>
              <button onClick={()=>{setEditing(isEd?null:c.id);setEditVal(c.planned.toString());}} style={{background:"none",border:"none",cursor:"pointer",fontSize:14,padding:"2px 4px",color:T.textTer}}>✏️</button>
            </div>
            <div style={{display:"flex",justifyContent:"space-between",fontSize:12,marginBottom:6}}>
              <span style={{color:T.red,fontWeight:500}}>Gasto: {fCHF(c.spent)}</span>
              <span style={{color:T.textTer}}>Previsto: {fCHF(c.planned)}</span>
              <span style={{color:over?T.red:T.green,fontWeight:500}}>{over?"Excedido":"Resta"}: {fCHF(Math.abs(c.planned-c.spent))}</span>
            </div>
            <PBar value={p} color={over?"#EF4444":p>80?"#F59E0B":c.color} height={7}/>
            {isEd&&(
              <div style={{display:"flex",gap:8,alignItems:"center",marginTop:12,paddingTop:10,borderTop:`1px solid ${T.border}`,animation:"slideUp .2s ease both"}}>
                <span style={{fontSize:13,color:T.textSec,whiteSpace:"nowrap"}}>Previsto CHF</span>
                <input type="number" value={editVal} onChange={e=>setEditVal(e.target.value)} onKeyDown={e=>e.key==="Enter"&&saveEdit(c.id)} autoFocus style={{flex:1,border:`1.5px solid ${T.brand}`,borderRadius:8,padding:"7px 10px",fontSize:14,fontWeight:500,color:T.text,outline:"none",background:T.white}}/>
                <Btn onClick={()=>saveEdit(c.id)} small style={{width:"auto"}}>Guardar</Btn>
                <button onClick={()=>setEditing(null)} style={{background:"none",border:"none",cursor:"pointer",fontSize:13,color:T.textTer,fontFamily:"'Inter',sans-serif"}}>✕</button>
              </div>
            )}
          </div>
        );})}
      </div>
    </div>
  );
}

// ─── ADD TRANSACTION ─────────────────────────────────────────────────────────
function AddScreen({categories,setCategories,onSave,onCancel}){
  const [type,setType]=useState("expense");
  const [desc,setDesc]=useState("");
  const [amount,setAmount]=useState("");
  const [catId,setCatId]=useState("food");
  const [date,setDate]=useState(todayStr());
  const [showNewCat,setShowNewCat]=useState(false);
  const [newName,setNewName]=useState("");
  const [newIcon,setNewIcon]=useState("⭐");
  const ICONS=["⭐","🎯","🏋️","🎮","🎵","🌍","🐾","🍕","🎓","💡","🔧","🎨","🚀","🏖️","💎","🎪","🦋","🍀"];
  const filtCats=categories.filter(c=>c.type===type);

  useEffect(()=>{
    if(desc){const s=KW[(desc.split(" ")[0]||"").toLowerCase()];const cat=categories.find(c=>c.id===s);if(cat&&cat.type===type)setCatId(s);}
  },[desc,type]);

  const save=()=>{
    const a=parseFloat(amount);if(!desc.trim()||!a||a<=0)return;
    onSave({id:Math.random().toString(36).slice(2),desc:desc.trim(),amount:a,catId,type,date});
  };
  const addCat=()=>{
    if(!newName.trim())return;
    const nc={id:"c"+Date.now(),label:newName.trim(),icon:newIcon,color:"#64748B",bg:"#F8FAFC",type};
    setCategories(p=>[...p,nc]);setCatId(nc.id);setShowNewCat(false);setNewName("");
  };

  return(
    <div style={{position:"absolute",inset:0,background:"rgba(11,29,53,.5)",display:"flex",flexDirection:"column",justifyContent:"flex-end",zIndex:50}} onClick={onCancel}>
      <div style={{background:T.white,borderRadius:"22px 22px 0 0",padding:"18px 20px 36px",maxHeight:"92%",overflowY:"auto",animation:"popUp .32s cubic-bezier(.22,1,.36,1) both"}} onClick={e=>e.stopPropagation()}>
        <div style={{width:36,height:4,background:T.border,borderRadius:2,margin:"0 auto 18px"}}/>
        <div style={{fontSize:18,fontWeight:700,color:T.text,marginBottom:18}}>Adicionar lançamento</div>
        {/* type */}
        <div style={{display:"flex",gap:8,marginBottom:18,background:T.surface,padding:4,borderRadius:12}}>
          {[["expense","🔴 Despesa"],["income","🟢 Receita"]].map(([v,l])=>(
            <button key={v} onClick={()=>{setType(v);setCatId(v==="expense"?"food":"salary");}} style={{flex:1,padding:"9px 0",borderRadius:9,border:"none",background:type===v?T.white:T.surface,color:type===v?T.text:T.textSec,fontSize:14,fontWeight:type===v?600:400,cursor:"pointer",boxShadow:type===v?"0 1px 4px rgba(0,0,0,.08)":"none",fontFamily:"'Inter',sans-serif",transition:"all .2s"}}>{l}</button>
          ))}
        </div>
        {/* desc */}
        <div style={{marginBottom:14}}>
          <div style={{fontSize:12,color:T.textTer,marginBottom:6,fontWeight:500,textTransform:"uppercase",letterSpacing:".06em"}}>Descrição</div>
          <input value={desc} onChange={e=>setDesc(e.target.value)} placeholder={type==="expense"?"Ex: Café, Uber, Netflix...":"Ex: Salário, Projeto X..."} style={{width:"100%",border:`1.5px solid ${T.border}`,borderRadius:10,padding:"11px 14px",fontSize:15,color:T.text,outline:"none",fontFamily:"'Inter',sans-serif",background:T.white}} onFocus={e=>e.target.style.borderColor=T.brand} onBlur={e=>e.target.style.borderColor=T.border}/>
        </div>
        {/* amount */}
        <div style={{marginBottom:18}}>
          <div style={{fontSize:12,color:T.textTer,marginBottom:6,fontWeight:500,textTransform:"uppercase",letterSpacing:".06em"}}>Valor</div>
          <div style={{position:"relative"}}>
            <span style={{position:"absolute",left:14,top:"50%",transform:"translateY(-50%)",fontSize:15,color:T.textTer,fontWeight:500}}>CHF</span>
            <input type="number" value={amount} onChange={e=>setAmount(e.target.value)} placeholder="0.00" style={{width:"100%",border:`1.5px solid ${T.border}`,borderRadius:10,padding:"11px 14px 11px 52px",fontSize:18,fontWeight:600,color:T.text,outline:"none",fontFamily:"'Inter',sans-serif",background:T.white}} onFocus={e=>e.target.style.borderColor=T.brand} onBlur={e=>e.target.style.borderColor=T.border}/>
          </div>
        </div>
        {/* category */}
        <div style={{marginBottom:14}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:8}}>
            <span style={{fontSize:12,color:T.textTer,fontWeight:500,textTransform:"uppercase",letterSpacing:".06em"}}>Categoria</span>
            <button onClick={()=>setShowNewCat(!showNewCat)} style={{fontSize:12,color:T.brand,background:"none",border:"none",cursor:"pointer",fontFamily:"'Inter',sans-serif",fontWeight:500}}>+ Nova categoria</button>
          </div>
          {showNewCat&&(
            <div style={{background:T.brandL,borderRadius:10,padding:12,marginBottom:10,animation:"slideUp .2s ease both"}}>
              <div style={{fontSize:12,fontWeight:600,color:T.brand,marginBottom:8}}>Nova categoria ({type==="expense"?"despesa":"receita"})</div>
              <div style={{display:"flex",gap:8,marginBottom:8}}>
                <input value={newName} onChange={e=>setNewName(e.target.value)} placeholder="Nome" style={{flex:1,border:`1px solid ${T.border}`,borderRadius:8,padding:"8px 10px",fontSize:13,color:T.text,outline:"none",fontFamily:"'Inter',sans-serif"}}/>
                <select value={newIcon} onChange={e=>setNewIcon(e.target.value)} style={{border:`1px solid ${T.border}`,borderRadius:8,padding:"8px",fontSize:16,cursor:"pointer"}}>{ICONS.map(i=><option key={i} value={i}>{i}</option>)}</select>
              </div>
              <div style={{display:"flex",gap:8}}><Btn onClick={addCat} small>Criar</Btn><Btn onClick={()=>setShowNewCat(false)} variant="ghost" small>Cancelar</Btn></div>
            </div>
          )}
          <div style={{display:"flex",gap:6,flexWrap:"wrap"}}>
            {filtCats.map(c=><button key={c.id} onClick={()=>setCatId(c.id)} style={{padding:"6px 12px",borderRadius:8,border:`1.5px solid ${catId===c.id?c.color:T.border}`,background:catId===c.id?c.bg:T.white,color:catId===c.id?c.color:T.textSec,fontSize:12,fontWeight:catId===c.id?600:400,cursor:"pointer",fontFamily:"'Inter',sans-serif",transition:"all .15s"}}>{c.icon} {c.label}</button>)}
          </div>
        </div>
        {/* date */}
        <div style={{marginBottom:22}}>
          <div style={{fontSize:12,color:T.textTer,marginBottom:6,fontWeight:500,textTransform:"uppercase",letterSpacing:".06em"}}>Data</div>
          <div style={{display:"flex",gap:8}}>
            {[["Hoje",todayStr()],["Ontem",new Date(Date.now()-86400000).toISOString().slice(0,10)]].map(([l,v])=>(
              <button key={l} onClick={()=>setDate(v)} style={{padding:"7px 14px",borderRadius:8,border:`1px solid ${date===v?T.brand:T.border}`,background:date===v?T.brandL:T.white,color:date===v?T.brand:T.textSec,fontSize:13,fontWeight:500,cursor:"pointer",fontFamily:"'Inter',sans-serif",transition:"all .15s"}}>{l}</button>
            ))}
            <input type="date" value={date} onChange={e=>setDate(e.target.value)} style={{flex:1,border:`1px solid ${T.border}`,borderRadius:8,padding:"7px 10px",fontSize:12,color:T.text,fontFamily:"'Inter',sans-serif",cursor:"pointer"}}/>
          </div>
        </div>
        <Btn onClick={save} disabled={!desc.trim()||!amount||parseFloat(amount)<=0}>{type==="expense"?"💳 Registar despesa":"💰 Registar receita"}</Btn>
        <div style={{textAlign:"center",marginTop:14}}><button onClick={onCancel} style={{fontSize:14,color:T.textSec,background:"none",border:"none",cursor:"pointer",fontFamily:"'Inter',sans-serif"}}>Cancelar</button></div>
      </div>
    </div>
  );
}

// ─── PROJECTIONS ─────────────────────────────────────────────────────────────
function ProjectionsScreen({transactions}){
  const curInc=transactions.filter(t=>t.type==="income"&&new Date(t.date).getMonth()===CM).reduce((s,t)=>s+t.amount,0);
  const [income,setIncome]=useState(Math.round(curInc)||5500);
  const [exps,setExps]=useState(3200);
  const [invest,setInvest]=useState(400);
  const [rate,setRate]=useState(7);
  const [years,setYears]=useState(20);
  const [wealth,setWealth]=useState(12000);

  const monthly=Math.max(0,income-exps-invest)+invest;
  const cons=projectWealth(wealth,monthly,4,years);
  const mod=projectWealth(wealth,monthly,rate,years);
  const opt=projectWealth(wealth,monthly,rate+3,years);
  const pts=8,chartY=Math.min(years,20);
  const mkS=r=>Array.from({length:pts},(_,i)=>projectWealth(wealth,monthly,r,Math.round((i+1)*(chartY/pts))));
  const chartLbls=Array.from({length:pts},(_,i)=>Math.round((i+1)*(chartY/pts))+"a");

  return(
    <div style={{display:"flex",flexDirection:"column",flex:1,overflow:"hidden"}}>
      <div style={{padding:"18px 16px 0",flexShrink:0}}>
        <div style={{fontSize:22,fontWeight:800,fontFamily:"Syne",color:T.text,marginBottom:2}}>Projeções</div>
        <div style={{fontSize:13,color:T.textSec,marginBottom:0}}>Simulação de crescimento patrimonial</div>
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"14px 16px 16px"}}>
        <Card style={{marginBottom:12,padding:16}}>
          <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:14}}>Parâmetros</div>
          {[
            {l:"Rendimento mensal",v:income,s:setIncome,min:500,max:20000,step:100,c:T.green,fmt:v=>fCHF(v,0)},
            {l:"Despesas mensais",v:exps,s:setExps,min:500,max:15000,step:100,c:T.red,fmt:v=>fCHF(v,0)},
            {l:"Investimento mensal",v:invest,s:setInvest,min:0,max:5000,step:50,c:T.purple,fmt:v=>fCHF(v,0)},
            {l:"Retorno anual (%)",v:rate,s:setRate,min:1,max:20,step:.5,c:T.brand,fmt:v=>v+"%"},
            {l:"Horizonte (anos)",v:years,s:setYears,min:1,max:40,step:1,c:T.amber,fmt:v=>v+" anos"},
            {l:"Património atual",v:wealth,s:setWealth,min:0,max:500000,step:1000,c:T.teal,fmt:v=>fCHF(v,0)},
          ].map(({l,v,s,min,max,step,c,fmt})=>(
            <div key={l} style={{marginBottom:15}}>
              <div style={{display:"flex",justifyContent:"space-between",marginBottom:5,fontSize:13}}>
                <span style={{color:T.textSec}}>{l}</span>
                <span style={{fontWeight:600,color:c,fontFamily:"Syne"}}>{fmt(v)}</span>
              </div>
              <input type="range" min={min} max={max} step={step} value={v} onChange={e=>s(Number(e.target.value))} style={{accentColor:c}}/>
            </div>
          ))}
          <div style={{background:T.surface,borderRadius:8,padding:"9px 12px",marginTop:4,display:"flex",justifyContent:"space-between",fontSize:13}}>
            <span style={{color:T.textSec}}>Poupança mensal total</span>
            <span style={{fontWeight:700,color:income-exps>=0?T.green:T.red}}>{fCHF(Math.max(0,income-exps),0)}/mês</span>
          </div>
        </Card>
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10,marginBottom:10}}>
          <div style={{background:T.brandL,borderRadius:14,padding:14,textAlign:"center"}}><div style={{fontSize:10,color:T.brand,fontWeight:600,textTransform:"uppercase",letterSpacing:".07em",marginBottom:4}}>Conservador (4%)</div><div style={{fontSize:20,fontWeight:800,fontFamily:"Syne",color:T.brandD}}>{fK(cons)}</div></div>
          <div style={{background:T.greenL,borderRadius:14,padding:14,textAlign:"center"}}><div style={{fontSize:10,color:T.green,fontWeight:600,textTransform:"uppercase",letterSpacing:".07em",marginBottom:4}}>Moderado ({rate}%)</div><div style={{fontSize:20,fontWeight:800,fontFamily:"Syne",color:"#065f46"}}>{fK(mod)}</div></div>
        </div>
        <div style={{background:T.amberL,borderRadius:14,padding:14,textAlign:"center",marginBottom:14}}>
          <div style={{fontSize:10,color:T.amber,fontWeight:600,textTransform:"uppercase",letterSpacing:".07em",marginBottom:4}}>Otimista ({rate+3}%)</div>
          <div style={{fontSize:24,fontWeight:800,fontFamily:"Syne",color:"#92400E"}}>{fK(opt)}</div>
        </div>
        <Card style={{marginBottom:14}}>
          <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:12}}>Evolução projetada</div>
          <LineChart series={[mkS(4),mkS(rate),mkS(rate+3)]} labels={chartLbls} colors={[T.brand,T.green,T.amber]} height={130}/>
          <div style={{display:"flex",gap:14,justifyContent:"center",marginTop:10}}>
            {[["Conservador",T.brand],["Moderado",T.green],["Otimista",T.amber]].map(([l,c])=><div key={l} style={{display:"flex",alignItems:"center",gap:5}}><div style={{width:12,height:3,background:c,borderRadius:2}}/><span style={{fontSize:11,color:T.textSec}}>{l}</span></div>)}
          </div>
        </Card>
        <Card style={{marginBottom:14}}>
          <div style={{fontSize:13,fontWeight:600,color:T.text,marginBottom:12}}>Marcos patrimoniais (cenário moderado)</div>
          {[100000,250000,500000,1000000].map(target=>{
            const yn=Array.from({length:40},(_,i)=>i+1).find(y=>projectWealth(wealth,monthly,rate,y)>=target);
            return yn?(<div key={target} style={{display:"flex",justifyContent:"space-between",padding:"8px 0",borderBottom:`1px solid ${T.border}`}}>
              <span style={{fontSize:13,color:T.text}}>{fK(target)}</span>
              <span style={{fontSize:12,fontWeight:600,color:yn<=10?T.green:yn<=20?T.brand:T.amber}}>{yn} anos ({CY+yn})</span>
            </div>):null;
          })}
        </Card>
        <div style={{fontSize:11,color:T.textTer,textAlign:"center",lineHeight:1.6,padding:"0 8px"}}>Projeções para fins educativos. Não constituem aconselhamento financeiro ou de investimento.</div>
      </div>
    </div>
  );
}

// ─── APP ─────────────────────────────────────────────────────────────────────
export default function ValuraApp(){
  const [tab,setTab]=useState("summary");
  const [showAdd,setShowAdd]=useState(false);
  const [transactions,setTransactions]=useState(INIT_TX);
  const [budget,setBudget]=useState(INIT_BUDGET);
  const [categories,setCategories]=useState(DEFAULT_CATS);
  const [history]=useState(buildHistory);

  const handleNav=id=>{if(id==="add"){setShowAdd(true);return;}setTab(id);};
  const handleSave=tx=>{setTransactions(p=>[tx,...p]);setShowAdd(false);};

  return(
    <>
      <style>{GS}</style>
      <PhoneShell statusDark={tab==="summary"&&!showAdd}>
        <div style={{flex:1,display:"flex",flexDirection:"column",overflow:"hidden",position:"relative"}}>
          {tab==="summary"&&<SummaryScreen transactions={transactions} budget={budget} categories={categories}/>}
          {tab==="analysis"&&<AnalysisScreen transactions={transactions} history={history} categories={categories}/>}
          {tab==="budget"&&<BudgetScreen transactions={transactions} budget={budget} setBudget={setBudget} categories={categories}/>}
          {tab==="projections"&&<ProjectionsScreen transactions={transactions}/>}
          {showAdd&&<AddScreen categories={categories} setCategories={setCategories} onSave={handleSave} onCancel={()=>setShowAdd(false)}/>}
        </div>
        <BottomNav active={tab} onChange={handleNav}/>
      </PhoneShell>
    </>
  );
}
