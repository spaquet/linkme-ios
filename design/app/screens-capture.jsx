// LinkMe — Voice-to-card capture (the hero moment). Overlay over the app.

const CAPTURE_TRANSCRIPT = "Just met Elena Vasquez — she’s the founder of Halcyon, building AI for clinical-trial data. Raising about a three million dollar seed. She used to lead data science at Verily. Wants an intro to a regulatory advisor — I said I’d connect her with Mara. Her daughter just started at Berkeley. Follow up next week.";

const CAPTURED_PERSON = {
  id:'elena', name:'Elena Vasquez', tone:'sky', role:'Founder', company:'Halcyon',
  met:'Founders Circuit dinner', when:'', lastTouch:'Just now', captures:1,
  tags:['Founder','Healthtech','Seed'],
  context:'Raising ~$3M seed · AI for clinical-trial data · ex-Verily data-science lead.',
  personal:'Daughter just started at UC Berkeley.',
  openThreads:['Wants an intro to a regulatory advisor (Mara)'],
  talkingPoints:['Her seed raise','The Verily years','Berkeley move-in'],
  shared:['Marcus Chen'],
  followup:'Elena — great meeting you tonight. I’ll connect you with Mara on the regulatory side this week as promised. Would love to hear more about the trials data approach.',
  timeline:[{ kind:'capture', date:'Just now', label:'Voice note after meeting', detail:'Founder of Halcyon, raising a seed.' }],
};

function Waveform({ active }) {
  const bars = 34;
  return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:4, height:96 }}>
      {Array.from({length:bars}).map((_,i)=>{
        const mid = Math.abs(i - bars/2) / (bars/2);          // 0 center → 1 edges
        const base = 0.9 - mid*0.65;
        return (
          <div key={i} style={{
            width:4, height: 64*base+10, borderRadius:4, transformOrigin:'center',
            background:`linear-gradient(${LM.c.t400}, ${LM.c.t600})`,
            animation: active ? `lmwave ${0.7+ (i%5)*0.12}s ease-in-out ${i*0.045}s infinite` : 'none',
            opacity: active ? 1 : 0.3,
          }} />
        );
      })}
    </div>
  );
}

function ExtractField({ icon, label, children, delay=0 }) {
  return (
    <div className="lmfade" style={{ animationDelay:delay+'s', display:'flex', gap:12, padding:'13px 0' }}>
      <div style={{ width:30, height:30, borderRadius:9, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, marginTop:1 }}>
        <Icon name={icon} size={16} stroke={1.9} color={LM.c.t700} />
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
          <SectionLabel style={{ color:LM.c.s400, fontSize:10.5 }}>{label}</SectionLabel>
          <Icon name="pencil" size={14} color={LM.c.s300} />
        </div>
        <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.5, marginTop:3 }}>{children}</div>
      </div>
    </div>
  );
}

function CaptureOverlay({ onClose, onSaved }) {
  const [phase, setPhase] = React.useState('listening'); // listening | processing | result
  const [secs, setSecs] = React.useState(0);
  const [words, setWords] = React.useState(0);
  const tokenList = CAPTURE_TRANSCRIPT.split(' ');

  // tick timer + reveal transcript while listening
  React.useEffect(()=>{
    if (phase!=='listening') return;
    const t = setInterval(()=> setSecs(s=>s+1), 1000);
    const w = setInterval(()=> setWords(n=>{
      if (n>=tokenList.length){ return n; }
      return n+1;
    }), 165);
    return ()=>{ clearInterval(t); clearInterval(w); };
  }, [phase]);

  // auto-finish shortly after transcript completes
  React.useEffect(()=>{
    if (phase==='listening' && words>=tokenList.length){
      const id = setTimeout(()=> finish(), 900);
      return ()=>clearTimeout(id);
    }
  }, [words, phase]);

  const finish = ()=>{
    setPhase('processing');
    setTimeout(()=> setPhase('result'), 1600);
  };
  const save = ()=>{
    if (!DATA.people.find(p=>p.id===CAPTURED_PERSON.id)) DATA.people.unshift(CAPTURED_PERSON);
    onSaved(CAPTURED_PERSON.id);
  };
  const mmss = `0:${String(secs).padStart(2,'0')}`;
  const shown = tokenList.slice(0, words).join(' ');

  return (
    <div style={{ position:'absolute', inset:0, zIndex:80, background:LM.c.canvas, display:'flex', flexDirection:'column' }}>
      {/* top bar */}
      <div style={{ paddingTop:LM.statusH, display:'flex', alignItems:'center', justifyContent:'space-between', padding:`${LM.statusH+6}px 16px 8px` }}>
        <button onClick={onClose} style={{ width:38, height:38, borderRadius:12, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer', color:LM.c.s600 }}>
          <Icon name="x" size={20} />
        </button>
        <OnDeviceChip label={phase==='result' ? 'Stayed on this device' : 'Recording on device'} />
        <div style={{ width:38 }} />
      </div>

      {/* ── LISTENING ── */}
      {phase==='listening' && (
        <div style={{ flex:1, display:'flex', flexDirection:'column', padding:'0 22px 28px' }}>
          <div style={{ flex:1, display:'flex', flexDirection:'column', justifyContent:'center', gap:26 }}>
            <div style={{ textAlign:'center' }}>
              <div style={{ fontFamily:LM.mono, fontSize:15, color:LM.c.t700, letterSpacing:'0.04em' }}>{mmss}</div>
              <div style={{ fontSize:23, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.02em', marginTop:6 }}>Listening…</div>
            </div>
            <Waveform active />
            <div style={{ minHeight:120, fontSize:17, lineHeight:1.55, color:LM.c.s600, textAlign:'center' }}>
              {shown}<span style={{ display:'inline-block', width:2, height:18, marginLeft:2, background:LM.c.t500, verticalAlign:'-2px', animation:'lmblink 1s step-end infinite' }} />
            </div>
          </div>
          <button onClick={finish} style={{ alignSelf:'center', width:72, height:72, borderRadius:36, border:`5px solid ${LM.c.surface}`, background:LM.c.ink, boxShadow:LM.shadow.lg, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ width:24, height:24, borderRadius:7, background:'#fff' }} />
          </button>
          <div style={{ textAlign:'center', fontSize:12.5, color:LM.c.s400, marginTop:14 }}>Tap to stop · a 10-second note is all it takes</div>
        </div>
      )}

      {/* ── PROCESSING ── */}
      {phase==='processing' && (
        <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:22, padding:'0 30px 60px' }}>
          <div style={{ position:'relative', width:78, height:78, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <div style={{ position:'absolute', inset:0, borderRadius:999, border:`3px solid ${LM.c.t100}`, borderTopColor:LM.c.t500, animation:'lmspin 0.9s linear infinite' }} />
            <Icon name="sparkle" size={30} stroke={1.8} color={LM.c.t600} />
          </div>
          <div style={{ textAlign:'center' }}>
            <div style={{ fontSize:19, fontWeight:600, color:LM.c.ink }}>Structuring the person…</div>
            <div style={{ fontSize:13.5, color:LM.c.s500, marginTop:6, lineHeight:1.5 }}>Apple’s on-device model is turning your note<br/>into a record. This never leaves your iPhone.</div>
          </div>
        </div>
      )}

      {/* ── RESULT ── */}
      {phase==='result' && (
        <div className="lm-scroll" style={{ flex:1, overflowY:'auto', padding:'4px 18px 24px' }}>
          <div className="lmfade" style={{ display:'flex', alignItems:'center', gap:8, marginBottom:14 }}>
            <AIBadge>Drafted on device · review &amp; save</AIBadge>
          </div>
          <Card pad={0} style={{ boxShadow:LM.shadow.md, overflow:'hidden' }}>
            {/* identity */}
            <div className="lmfade" style={{ display:'flex', gap:14, alignItems:'center', padding:'18px 18px 16px' }}>
              <Avatar name={CAPTURED_PERSON.name} tone={CAPTURED_PERSON.tone} size={56} />
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontSize:20, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.02em' }}>{CAPTURED_PERSON.name}</div>
                <div style={{ fontSize:13.5, color:LM.c.s500, marginTop:1 }}>{CAPTURED_PERSON.role} · {CAPTURED_PERSON.company}</div>
                <div style={{ display:'flex', gap:6, marginTop:8, flexWrap:'wrap' }}>
                  {CAPTURED_PERSON.tags.map(t=><Chip key={t} tone="teal" style={{ height:22, fontSize:11.5 }}>{t}</Chip>)}
                </div>
              </div>
            </div>
            <Divider />
            <div style={{ padding:'4px 18px 8px' }}>
              <ExtractField icon="building" label="Live context" delay={0.05}>{CAPTURED_PERSON.context}</ExtractField>
              <Divider />
              <ExtractField icon="thread" label="Follow-up" delay={0.13}>Intro to a regulatory advisor (Mara) · next week</ExtractField>
              <Divider />
              <ExtractField icon="star" label="Personal detail" delay={0.21}>{CAPTURED_PERSON.personal}</ExtractField>
            </div>
          </Card>

          {/* original note */}
          <div className="lmfade" style={{ animationDelay:'0.28s', marginTop:14 }}>
            <div style={{ display:'flex', alignItems:'center', gap:7, marginBottom:8 }}>
              <Icon name="mic" size={14} stroke={2} color={LM.c.s400} />
              <SectionLabel style={{ color:LM.c.s400 }}>From your 14-second note</SectionLabel>
            </div>
            <div style={{ fontSize:13.5, color:LM.c.s500, lineHeight:1.55, fontStyle:'italic', padding:'12px 14px', background:LM.c.s50, border:`1px solid ${LM.c.s200}`, borderRadius:14 }}>
              “{CAPTURE_TRANSCRIPT}”
            </div>
          </div>

          <div className="lmfade" style={{ animationDelay:'0.34s', display:'flex', gap:10, marginTop:18 }}>
            <SecondaryButton icon="pencil" full onClick={save} style={{ flex:'0 0 auto', width:52, padding:0 }}>{''}</SecondaryButton>
            <PrimaryButton tone="teal" icon="check" onClick={save} style={{ flex:1 }}>Save to graph</PrimaryButton>
          </div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { CaptureOverlay, CAPTURED_PERSON });
