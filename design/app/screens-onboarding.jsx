// LinkMe — Onboarding: under 90s, magic moment, build-your-card, permissions deferred.

function OnbWave({ active }) {
  return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:4, height:56 }}>
      {Array.from({length:22}).map((_,i)=>(
        <div key={i} style={{ width:4, height:40, borderRadius:4, transformOrigin:'center',
          background:`linear-gradient(${LM.c.t400}, ${LM.c.t600})`,
          animation: active?`lmwave ${0.7+(i%4)*0.1}s ease-in-out ${i*0.05}s infinite`:'none', opacity: active?1:0.25 }} />
      ))}
    </div>
  );
}

function MagicMoment() {
  const [rec, setRec] = React.useState(false);
  const [words, setWords] = React.useState(0);
  const [done, setDone] = React.useState(false);
  const note = "Met Marcus Chen, GP at Meridian — closing fund three, wants to see my metrics.".split(' ');

  React.useEffect(()=>{
    if (!rec) return;
    const w = setInterval(()=> setWords(n=> n>=note.length ? n : n+1), 120);
    return ()=>clearInterval(w);
  }, [rec]);
  React.useEffect(()=>{ if (rec && words>=note.length){ const t=setTimeout(()=>setDone(true), 650); return ()=>clearTimeout(t);} }, [words,rec]);

  if (done) {
    return (
      <div className="lmfade" style={{ width:'100%' }}>
        <Card pad={0} style={{ overflow:'hidden', boxShadow:LM.shadow.md }}>
          <div style={{ display:'flex', gap:13, alignItems:'center', padding:'16px' }}>
            <Avatar name="Marcus Chen" tone="teal" size={50} />
            <div style={{ flex:1 }}>
              <div style={{ fontSize:18, fontWeight:600, color:LM.c.ink }}>Marcus Chen</div>
              <div style={{ fontSize:13, color:LM.c.s500 }}>General Partner · Meridian Ventures</div>
            </div>
            <AIBadge>On device</AIBadge>
          </div>
          <Divider />
          <div style={{ padding:'13px 16px' }}>
            <SectionLabel style={{ color:LM.c.s400, fontSize:10.5 }}>Live context</SectionLabel>
            <div style={{ fontSize:14, color:LM.c.s700, lineHeight:1.5, marginTop:4 }}>Closing fund three. Wants to see your metrics.</div>
          </div>
        </Card>
        <div style={{ textAlign:'center', fontSize:13.5, color:LM.c.t700, fontWeight:600, marginTop:14 }}>That’s the whole thing.</div>
      </div>
    );
  }

  return (
    <div style={{ width:'100%', display:'flex', flexDirection:'column', alignItems:'center', gap:20 }}>
      <div style={{ minHeight:70, display:'flex', alignItems:'center', justifyContent:'center' }}>
        {rec ? <OnbWave active /> :
          <div style={{ fontSize:15, color:LM.c.s400, textAlign:'center', maxWidth:240 }}>You just met someone. Tap and say one sentence about them.</div>}
      </div>
      <div style={{ minHeight:48, fontSize:16, lineHeight:1.5, color:LM.c.s600, textAlign:'center', padding:'0 10px' }}>
        {rec && note.slice(0,words).join(' ')}
      </div>
      <button onClick={()=>!rec && setRec(true)} style={{ width:76, height:76, borderRadius:38, border:`5px solid ${LM.c.surface}`, cursor: rec?'default':'pointer',
        background: rec? LM.c.ink : `linear-gradient(160deg, ${LM.c.t400}, ${LM.c.t600})`, boxShadow: rec?LM.shadow.lg:LM.shadow.teal,
        display:'flex', alignItems:'center', justifyContent:'center', position:'relative' }}>
        {!rec && <span style={{ position:'absolute', inset:-5, borderRadius:43, border:`2px solid ${LM.c.t400}`, animation:'lmpulse 1.8s ease-out infinite' }} />}
        {rec ? <div style={{ width:24, height:24, borderRadius:7, background:'#fff' }} /> : <Icon name="mic" size={30} stroke={2} color="#fff" />}
      </button>
    </div>
  );
}

// ── Build-your-card (define who you are; this is what you share) ──
function CardCreate() {
  const u = DATA.user;
  const [f, setF] = React.useState({ name:u.name, role:u.role, company:u.company, tagline:u.tagline, email:u.email });
  const [focus, setFocus] = React.useState(null);
  const set = (k,v)=>{ setF(s=>({ ...s, [k]:v })); u[k]=v; if (k==='name'){ u.first = v.trim().split(' ')[0]; } };

  const Field = ({ k, label, placeholder, full }) => (
    <div style={{ gridColumn: full?'1 / -1':'auto' }}>
      <div style={{ fontSize:10.5, fontWeight:600, letterSpacing:'0.06em', textTransform:'uppercase', color:LM.c.s400, marginBottom:5 }}>{label}</div>
      <input value={f[k]} placeholder={placeholder}
        onChange={e=>set(k, e.target.value)} onFocus={()=>setFocus(k)} onBlur={()=>setFocus(null)}
        style={{ width:'100%', boxSizing:'border-box', height:46, padding:'0 13px', borderRadius:12,
          border:`1.5px solid ${focus===k?LM.c.t500:LM.c.s200}`, background:LM.c.surface,
          fontFamily:LM.font, fontSize:15, color:LM.c.ink, outline:'none',
          boxShadow: focus===k?LM.shadow.sm:'none' }} />
    </div>
  );

  return (
    <div style={{ width:'100%', display:'flex', flexDirection:'column', gap:16 }}>
      {/* live preview */}
      <div style={{ borderRadius:18, overflow:'hidden', border:`1px solid ${LM.c.s200}`, boxShadow:LM.shadow.md }}>
        <div style={{ background:`linear-gradient(150deg, ${LM.c.t500}, ${LM.c.t700})`, height:52, position:'relative' }}>
          <span style={{ position:'absolute', top:10, right:12, display:'inline-flex', alignItems:'center', gap:5, fontSize:10.5, fontWeight:600, color:'rgba(255,255,255,0.9)' }}>
            <Icon name="refresh" size={12} stroke={2} color="#fff" /> Always current
          </span>
        </div>
        <div style={{ background:LM.c.surface, padding:'0 16px 16px', marginTop:-24, textAlign:'left' }}>
          <Avatar name={f.name||'You'} tone="teal" size={56} ring />
          <div style={{ fontSize:18, fontWeight:600, color:LM.c.ink, marginTop:8 }}>{f.name||'Your name'}</div>
          <div style={{ fontSize:13, color:LM.c.s500 }}>{f.role||'Role'} · {f.company||'Company'}</div>
          {f.tagline && <div style={{ fontSize:13, color:LM.c.s600, lineHeight:1.45, marginTop:7 }}>{f.tagline}</div>}
        </div>
      </div>

      {/* fields */}
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:11, textAlign:'left' }}>
        <Field k="name" label="Full name" placeholder="Your name" full />
        <Field k="role" label="Role" placeholder="Founder & CEO" />
        <Field k="company" label="Company" placeholder="Company" />
        <Field k="tagline" label="One line about you" placeholder="What you’re building" full />
        <Field k="email" label="Email" placeholder="you@company.com" full />
      </div>

      <div style={{ display:'flex', alignItems:'center', gap:9, padding:'11px 13px', background:LM.c.t50, border:`1px solid ${LM.c.t200}`, borderRadius:13 }}>
        <Icon name="shield" size={18} stroke={1.9} color={LM.c.t700} style={{ flexShrink:0 }} />
        <div style={{ fontSize:12.5, color:LM.c.s600, lineHeight:1.45, textAlign:'left' }}>This is the card people receive when you share back. You control it — and it stays current automatically.</div>
      </div>
    </div>
  );
}

const SLIDES = [
  {
    key:'welcome',
    render:()=>(
      <div style={{ textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', gap:18 }}>
        <div style={{ width:84, height:84, borderRadius:26, background:LM.c.surface, border:`1px solid ${LM.c.s200}`, boxShadow:LM.shadow.md, display:'flex', alignItems:'center', justifyContent:'center' }}><Mark size={48} /></div>
        <div>
          <div style={{ fontSize:30, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.03em', lineHeight:1.1 }}>LinkMe</div>
          <div style={{ fontSize:16.5, color:LM.c.s500, lineHeight:1.5, marginTop:12, maxWidth:300 }}>The private memory and instinct of a great connector — in your pocket.</div>
        </div>
      </div>
    ),
  },
  {
    key:'magic', title:'Capture in 10 seconds',
    sub:'Speak a note after a meeting. Your iPhone turns it into a person you’ll never forget.',
    render:()=> <MagicMoment />,
  },
  {
    key:'recall', title:'Recalled — and kept private',
    sub:'Right before you meet again, LinkMe briefs you. And it all stays on your iPhone.',
    render:()=>(
      <div style={{ width:'100%', display:'flex', flexDirection:'column', gap:14 }}>
        <Card pad={0} style={{ overflow:'hidden', boxShadow:LM.shadow.md }}>
          <div style={{ display:'flex', alignItems:'center', gap:7, padding:'11px 15px', background:LM.c.t500, color:'#fff' }}>
            <Icon name="wand" size={16} stroke={2} /><span style={{ fontSize:12, fontWeight:600, letterSpacing:'0.02em', textTransform:'uppercase' }}>Brief me before 3:00</span>
          </div>
          <div style={{ padding:'14px 16px', display:'flex', gap:12, alignItems:'center' }}>
            <Avatar name="Marcus Chen" tone="teal" size={44} />
            <div style={{ fontSize:14, color:LM.c.s700, lineHeight:1.5, textAlign:'left' }}>Lead with the <b style={{ color:LM.c.ink }}>fund close</b>. He owes you the memo; you offered an intro.</div>
          </div>
        </Card>
        <div style={{ display:'flex', alignItems:'center', gap:10, padding:'12px 14px', background:LM.c.surface, border:`1px solid ${LM.c.s200}`, borderRadius:14 }}>
          <div style={{ width:34, height:34, borderRadius:11, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
            <Icon name="shield" size={18} stroke={1.9} color={LM.c.t700} />
          </div>
          <div style={{ fontSize:13, color:LM.c.s600, lineHeight:1.45, textAlign:'left', flex:1 }}>Capture, briefings and your whole graph stay on this device.</div>
          <OnDeviceChip />
        </div>
      </div>
    ),
  },
  {
    key:'card', title:'Create your card', scroll:true,
    sub:'This is who you are when you meet someone — confirm your details.',
    render:()=> <CardCreate />,
  },
];

function Onboarding({ onDone }) {
  const [i, setI] = React.useState(0);
  const last = i===SLIDES.length-1;
  const s = SLIDES[i];

  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column', background:LM.c.canvas, position:'relative' }}>
      {/* top: progress + skip */}
      <div style={{ paddingTop:LM.statusH }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'10px 20px' }}>
          <div style={{ display:'flex', gap:6 }}>
            {SLIDES.map((_,k)=>(
              <div key={k} style={{ width: k===i?22:7, height:7, borderRadius:999, background: k===i?LM.c.t500:LM.c.s300, transition:'width .25s ease' }} />
            ))}
          </div>
          {!last && <button onClick={onDone} style={{ background:'none', border:'none', color:LM.c.s500, fontSize:14, fontWeight:600, cursor:'pointer', fontFamily:LM.font }}>Skip</button>}
        </div>
      </div>

      {/* body */}
      <div key={s.key} className="lmfade lm-scroll" style={{ flex:1, minHeight:0, overflowY:'auto', display:'flex', flexDirection:'column', justifyContent: s.scroll?'flex-start':'center', alignItems:'center', padding: s.scroll?'14px 22px 8px':'0 26px', textAlign:'center', gap:24 }}>
        {s.title && (
          <div>
            <div style={{ fontSize:26, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.025em', lineHeight:1.15 }}>{s.title}</div>
            {s.sub && <div style={{ fontSize:15.5, color:LM.c.s500, lineHeight:1.5, marginTop:10, maxWidth:330 }}>{s.sub}</div>}
          </div>
        )}
        <div style={{ width:'100%', display:'flex', justifyContent:'center' }}>{s.render()}</div>
      </div>

      {/* footer */}
      <div style={{ padding:`14px 22px ${LM.homeH+14}px`, background:LM.c.canvas, borderTop: s.scroll?`1px solid ${LM.c.s200}`:'none' }}>
        <PrimaryButton tone="ink" full onClick={()=> last ? onDone() : setI(i+1)}>
          {last ? 'Enter LinkMe' : i===0 ? 'Get started' : s.key==='recall' ? 'Set up my card' : 'Continue'}
        </PrimaryButton>
        {i===0 && <button onClick={onDone} style={{ width:'100%', marginTop:12, background:'none', border:'none', color:LM.c.t700, fontSize:14, fontWeight:600, cursor:'pointer', fontFamily:LM.font }}>I already have a profile</button>}
      </div>
    </div>
  );
}

Object.assign(window, { Onboarding });
