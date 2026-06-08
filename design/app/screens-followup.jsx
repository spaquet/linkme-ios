// LinkMe — AI follow-up drafting (reached from a person or a proactive nudge).

function toneVariants(p) {
  const first = p.name.split(' ')[0];
  return {
    Warm: p.followup,
    Brief: `${first} — great connecting. ${p.openThreads[0] ? p.openThreads[0].replace(/^You /,'I’ll ').replace(/^Owes you/,'Looking forward to') + '.' : ''} Talk soon.`,
    Formal: `Hi ${first},\n\nThank you for the time today — I appreciated the conversation. I’ll follow up shortly on what we discussed. Please let me know if there’s anything useful I can send ahead.\n\nBest,\n${DATA.user.first}`,
  };
}

function FollowupScreen({ id, nudge, back, go }) {
  const p = getPerson(id);
  const variants = toneVariants(p);
  const [tone, setTone] = React.useState('Warm');
  const [text, setText] = React.useState(variants.Warm);
  const [channel, setChannel] = React.useState('Messages');
  const [sent, setSent] = React.useState(false);
  const [regen, setRegen] = React.useState(false);
  const nudgeObj = nudge ? DATA.nudges.find(n=>n.id===nudge) : null;

  const pickTone = (t)=>{ setTone(t); setRegen(true); setTimeout(()=>{ setText(variants[t]); setRegen(false); }, 450); };

  if (sent) {
    return (
      <Screen header={<PushHeader title="Follow-up" onBack={back} />}>
        <div style={{ padding:'40px 24px', display:'flex', flexDirection:'column', alignItems:'center', textAlign:'center', gap:18 }}>
          <div style={{ width:74, height:74, borderRadius:37, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon name="check" size={36} stroke={2.2} color={LM.c.t600} />
          </div>
          <div>
            <div style={{ fontSize:21, fontWeight:600, color:LM.c.ink }}>Sent to {p.name.split(' ')[0]}</div>
            <div style={{ fontSize:14, color:LM.c.s500, marginTop:6, lineHeight:1.5 }}>Logged to your timeline with {p.name.split(' ')[0]}.<br/>The relationship just compounded.</div>
          </div>
          <Card pad={14} style={{ width:'100%', display:'flex', gap:12, alignItems:'center', textAlign:'left' }}>
            <Avatar name={p.name} tone={p.tone} size={40} />
            <div style={{ flex:1 }}>
              <div style={{ fontSize:13.5, fontWeight:600, color:LM.c.ink }}>Send your card too?</div>
              <div style={{ fontSize:12.5, color:LM.c.s500 }}>Let {p.name.split(' ')[0]} remember you back.</div>
            </div>
            <Chip tone="ink">Share back</Chip>
          </Card>
          <PrimaryButton tone="ink" full onClick={back}>Done</PrimaryButton>
        </div>
      </Screen>
    );
  }

  return (
    <Screen header={<PushHeader title="Follow-up" onBack={back}
      right={<button onClick={()=>pickTone(tone)} style={{ width:38, height:38, borderRadius:12, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer', color:LM.c.s600 }}><Icon name="refresh" size={18} /></button>} />}
      footer={
        <div style={{ padding:`12px 16px ${LM.homeH+12}px`, background:LM.c.surface, borderTop:`1px solid ${LM.c.s200}`, display:'flex', gap:10, alignItems:'center' }}>
          <div style={{ fontSize:12.5, color:LM.c.s500, flex:1 }}>Sends from your {channel}. Nothing auto-sends.</div>
          <PrimaryButton tone="teal" icon="send" full={false} onClick={()=>setSent(true)} style={{ width:160 }}>Send</PrimaryButton>
        </div>
      }
    >
      <div style={{ padding:'16px 16px 18px' }}>

        {/* recipient + channel */}
        <Card pad={14} style={{ display:'flex', alignItems:'center', gap:12, marginBottom:14 }}>
          <Avatar name={p.name} tone={p.tone} size={44} />
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontSize:15.5, fontWeight:600, color:LM.c.ink }}>{p.name}</div>
            <div style={{ fontSize:12.5, color:LM.c.s500 }}>{p.role} · {p.company}</div>
          </div>
          <div style={{ display:'flex', gap:6 }}>
            {['Messages','Email'].map(c=>(
              <button key={c} onClick={()=>setChannel(c)} style={{ height:30, padding:'0 11px', borderRadius:999, fontFamily:LM.font, fontSize:12.5, fontWeight:600, cursor:'pointer',
                background: channel===c?LM.c.ink:LM.c.surface, color: channel===c?'#fff':LM.c.s600, border:`1px solid ${channel===c?LM.c.ink:LM.c.s200}` }}>{c}</button>
            ))}
          </div>
        </Card>

        {/* nudge context */}
        {nudgeObj && (
          <div style={{ display:'flex', gap:9, alignItems:'flex-start', padding:'11px 13px', background:LM.c.amber50, border:`1px solid ${LM.c.amber100}`, borderRadius:13, marginBottom:14 }}>
            <Icon name="bell" size={16} stroke={2} color={LM.c.amber600} style={{ marginTop:1, flexShrink:0 }} />
            <div style={{ fontSize:13, color:LM.c.s700, lineHeight:1.45 }}>{nudgeObj.detail}</div>
          </div>
        )}

        {/* tone */}
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:10 }}>
          <SectionLabel>Tone</SectionLabel>
          <AIBadge>Drafted on device</AIBadge>
        </div>
        <div style={{ display:'flex', gap:8, marginBottom:14 }}>
          {Object.keys(variants).map(t=>(
            <button key={t} onClick={()=>pickTone(t)} style={{ flex:1, height:38, borderRadius:12, fontFamily:LM.font, fontSize:13.5, fontWeight:600, cursor:'pointer',
              background: tone===t?LM.c.t50:LM.c.surface, color: tone===t?LM.c.t700:LM.c.s600, border:`1.5px solid ${tone===t?LM.c.t200:LM.c.s200}` }}>{t}</button>
          ))}
        </div>

        {/* draft */}
        <div style={{ position:'relative' }}>
          <div style={{ position:'absolute', top:-1, left:14, transform:'translateY(-50%)', background:LM.c.canvas, padding:'0 7px', fontSize:11, fontWeight:600, color:LM.c.s400, letterSpacing:'0.04em', textTransform:'uppercase' }}>Draft</div>
          <textarea value={regen? '' : text} onChange={e=>setText(e.target.value)} rows={9} style={{
            width:'100%', boxSizing:'border-box', resize:'none', padding:'18px 16px 16px',
            border:`1.5px solid ${LM.c.s200}`, borderRadius:18, background:LM.c.surface,
            fontFamily:LM.font, fontSize:15.5, color:LM.c.s700, lineHeight:1.6, outline:'none',
            boxShadow:LM.shadow.sm,
          }} />
          {regen && (
            <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', gap:10, color:LM.c.t700 }}>
              <div style={{ width:18, height:18, borderRadius:999, border:`2.5px solid ${LM.c.t100}`, borderTopColor:LM.c.t500, animation:'lmspin .8s linear infinite' }} />
              <span style={{ fontSize:13.5, fontWeight:600 }}>Rewriting, {tone.toLowerCase()}…</span>
            </div>
          )}
        </div>

        <div style={{ display:'flex', gap:8, marginTop:12 }}>
          <button style={{ flex:1, height:40, borderRadius:12, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, color:LM.c.s600, cursor:'pointer', fontFamily:LM.font, fontSize:13.5, fontWeight:600, display:'flex', alignItems:'center', justifyContent:'center', gap:7 }}>
            <Icon name="plus" size={16} stroke={2} />Insert a detail
          </button>
          <button onClick={()=>pickTone(tone)} style={{ flex:1, height:40, borderRadius:12, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, color:LM.c.s600, cursor:'pointer', fontFamily:LM.font, fontSize:13.5, fontWeight:600, display:'flex', alignItems:'center', justifyContent:'center', gap:7 }}>
            <Icon name="refresh" size={16} stroke={2} />Regenerate
          </button>
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { FollowupScreen });
