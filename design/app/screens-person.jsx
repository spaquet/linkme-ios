// LinkMe — Person card & relationship timeline.

function QuickAction({ icon, label, onClick, primary }) {
  return (
    <button onClick={onClick} style={{
      flex:1, display:'flex', flexDirection:'column', alignItems:'center', gap:6, padding:'12px 4px',
      background: primary?LM.c.ink:LM.c.surface, color: primary?'#fff':LM.c.s700,
      border:`1px solid ${primary?LM.c.ink:LM.c.s200}`, borderRadius:16, cursor:'pointer',
      boxShadow:LM.shadow.sm, fontFamily:LM.font,
    }}>
      <Icon name={icon} size={20} stroke={1.9} />
      <span style={{ fontSize:11.5, fontWeight:600 }}>{label}</span>
    </button>
  );
}

function TimelineDot({ kind }) {
  const map = { capture:LM.c.t500, meet:LM.c.ink, note:LM.c.s400 };
  const icon = { capture:'mic', meet:'handshake', note:'thread' }[kind];
  return (
    <div style={{ width:30, height:30, borderRadius:10, background: kind==='capture'?LM.c.t50:LM.c.s100, border:`1px solid ${kind==='capture'?LM.c.t200:LM.c.s200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, zIndex:1 }}>
      <Icon name={icon} size={15} stroke={2} color={map[kind]} />
    </div>
  );
}

function PersonScreen({ id, go, back, openShare }) {
  const p = getPerson(id);
  if (!p) return <Screen header={<PushHeader onBack={back} />}><div style={{ padding:30 }}>Not found</div></Screen>;

  return (
    <Screen
      header={<PushHeader onBack={back} bg={LM.c.canvas} border={false}
        right={<div style={{ display:'flex', gap:8 }}>
          <IconBtn name="share" onClick={()=>openShare(p.id)} />
          <IconBtn name="dots" />
        </div>} />}
    >
      <div style={{ padding:'4px 16px '+(LM.homeH+24)+'px' }}>

        {/* identity */}
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', textAlign:'center', gap:10, padding:'6px 0 18px' }}>
          <Avatar name={p.name} tone={p.tone} size={84} ring />
          <div>
            <div style={{ fontSize:25, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.025em' }}>{p.name}</div>
            <div style={{ fontSize:15, color:LM.c.s500, marginTop:2 }}>{p.role} · {p.company}</div>
          </div>
          <div style={{ display:'flex', gap:6, flexWrap:'wrap', justifyContent:'center' }}>
            {p.tags.map(t=><Chip key={t} tone="slate">{t}</Chip>)}
          </div>
          <div style={{ display:'flex', gap:16, marginTop:4, color:LM.c.s500, fontSize:12.5 }}>
            <span style={{ display:'inline-flex', alignItems:'center', gap:5 }}><Icon name="handshake" size={14} color={LM.c.s400} />{p.met}</span>
            <span style={{ display:'inline-flex', alignItems:'center', gap:5 }}><Icon name="clock" size={14} color={LM.c.s400} />{p.lastTouch}</span>
          </div>
        </div>

        {/* quick actions */}
        <div style={{ display:'flex', gap:9, marginBottom:18 }}>
          <QuickAction icon="wand" label="Brief me" primary onClick={()=>go('briefing',{id:p.id})} />
          <QuickAction icon="send" label="Message" onClick={()=>go('followup',{id:p.id})} />
          <QuickAction icon="share" label="Share back" onClick={()=>openShare(p.id)} />
          <QuickAction icon="users" label="Intro" />
        </div>

        {/* live context */}
        <div style={{ marginBottom:18 }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:9 }}>
            <SectionLabel>Live context</SectionLabel>
            <OnDeviceChip />
          </div>
          <Card pad={16} style={{ background:LM.c.t50, border:`1px solid ${LM.c.t200}` }}>
            <div style={{ fontSize:15, color:LM.c.s700, lineHeight:1.55 }}>{p.context}</div>
          </Card>
        </div>

        {/* open threads */}
        <Section title="Open threads" count={p.openThreads.length}>
          <Card pad={0}>
            {p.openThreads.map((t,i)=>(
              <div key={i}>
                <div style={{ display:'flex', gap:11, alignItems:'flex-start', padding:'13px 16px' }}>
                  <div style={{ width:8, height:8, borderRadius:4, background:LM.c.amber500, marginTop:6, flexShrink:0 }} />
                  <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.45 }}>{t}</div>
                </div>
                {i<p.openThreads.length-1 && <Divider inset={35} />}
              </div>
            ))}
          </Card>
        </Section>

        {/* talking points */}
        <Section title="Talking points">
          <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
            {p.talkingPoints.map((t,i)=>(
              <Card key={i} pad={13} style={{ display:'flex', gap:11, alignItems:'center' }}>
                <div style={{ width:24, height:24, borderRadius:8, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:12, fontWeight:700, color:LM.c.t700 }}>{i+1}</div>
                <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.4 }}>{t}</div>
              </Card>
            ))}
          </div>
        </Section>

        {/* personal */}
        <Section title="Personal detail">
          <Card pad={16} style={{ display:'flex', gap:12, alignItems:'flex-start' }}>
            <div style={{ width:30, height:30, borderRadius:9, background:LM.c.s100, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}><Icon name="star" size={16} color={LM.c.s500} /></div>
            <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.55 }}>{p.personal}</div>
          </Card>
        </Section>

        {/* shared */}
        {p.shared?.length>0 && (
          <Section title="Shared connections" count={p.shared.length}>
            <Card pad={14}>
              <div style={{ display:'flex', flexDirection:'column', gap:0 }}>
                {p.shared.map((name,i)=>{
                  const sp = DATA.people.find(x=>x.name===name);
                  return (
                    <div key={name}>
                      <div onClick={()=> sp && go('person',{id:sp.id})} style={{ display:'flex', alignItems:'center', gap:11, padding:'9px 0', cursor: sp?'pointer':'default' }}>
                        <Avatar name={name} tone={sp?.tone} size={36} />
                        <div style={{ flex:1 }}>
                          <div style={{ fontSize:14.5, fontWeight:600, color:LM.c.ink }}>{name}</div>
                          {sp && <div style={{ fontSize:12, color:LM.c.s500 }}>{sp.role} · {sp.company}</div>}
                        </div>
                        {sp && <Icon name="chevR" size={16} color={LM.c.s300} />}
                      </div>
                      {i<p.shared.length-1 && <Divider inset={47} />}
                    </div>
                  );
                })}
              </div>
            </Card>
          </Section>
        )}

        {/* timeline */}
        <Section title="Relationship timeline">
          <div style={{ position:'relative', paddingLeft:2 }}>
            <div style={{ position:'absolute', left:16, top:14, bottom:14, width:2, background:LM.c.s200 }} />
            <div style={{ display:'flex', flexDirection:'column', gap:14 }}>
              {p.timeline.map((e,i)=>(
                <div key={i} style={{ display:'flex', gap:13 }}>
                  <TimelineDot kind={e.kind} />
                  <div style={{ flex:1, minWidth:0, paddingTop:1 }}>
                    <div style={{ display:'flex', justifyContent:'space-between', gap:8 }}>
                      <span style={{ fontSize:14.5, fontWeight:600, color:LM.c.ink }}>{e.label}</span>
                      <span style={{ fontSize:12, color:LM.c.s400, flexShrink:0 }}>{e.date}</span>
                    </div>
                    {e.detail && <div style={{ fontSize:13, color:LM.c.s500, lineHeight:1.45, marginTop:2 }}>{e.detail}</div>}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Section>

      </div>
    </Screen>
  );
}

function Section({ title, count, children }) {
  return (
    <div style={{ marginBottom:18 }}>
      <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:9 }}>
        <SectionLabel>{title}</SectionLabel>
        {count!=null && <span style={{ fontSize:11, fontWeight:700, color:LM.c.s400 }}>{count}</span>}
      </div>
      {children}
    </div>
  );
}

Object.assign(window, { PersonScreen });
