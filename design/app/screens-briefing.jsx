// LinkMe — Just-in-time briefing surface. "Brief me on Marcus before my 3pm."

function SiriLine() {
  return (
    <div style={{ display:'flex', alignItems:'center', gap:3, height:16 }}>
      {Array.from({length:5}).map((_,i)=>(
        <div key={i} style={{ width:3, height:16, borderRadius:3, transformOrigin:'center',
          background:LM.c.t400, animation:`lmwave ${0.6+i*0.1}s ease-in-out ${i*0.08}s infinite`, opacity:0.9 }} />
      ))}
    </div>
  );
}

function BriefBlock({ icon, title, children, count }) {
  return (
    <div style={{ marginBottom:16 }}>
      <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:9 }}>
        <Icon name={icon} size={16} stroke={1.9} color={LM.c.s500} />
        <SectionLabel>{title}</SectionLabel>
        {count!=null && <span style={{ fontSize:11, fontWeight:700, color:LM.c.s400 }}>{count}</span>}
      </div>
      {children}
    </div>
  );
}

function BriefingScreen({ id, back, go, openShare }) {
  const p = getPerson(id);
  const meeting = DATA.meetings.find(m=>m.person===id);
  const recent = p.timeline.filter(e=>e.kind!=='capture' || true).slice(0,2);

  return (
    <Screen bg={LM.c.canvas}
      footer={
        <div style={{ padding:`12px 16px ${LM.homeH+12}px`, background:'rgba(255,255,255,0.94)', backdropFilter:'blur(14px)', WebkitBackdropFilter:'blur(14px)', borderTop:`1px solid ${LM.c.s200}`, display:'flex', gap:10 }}>
          <SecondaryButton icon="person" full onClick={()=>go('person',{id:p.id})}>Profile</SecondaryButton>
          <PrimaryButton icon="send" full onClick={()=>go('followup',{id:p.id})}>Draft follow-up</PrimaryButton>
        </div>
      }
    >
      {/* INK HERO */}
      <div style={{ height:LM.statusH, background:LM.c.canvas }} />
      <div style={{ background:`linear-gradient(168deg, ${LM.c.ink} 0%, #14303a 100%)`, color:'#fff' }}>
        <div style={{ height:46, display:'flex', alignItems:'center', justifyContent:'space-between', padding:'0 12px' }}>
          <button onClick={back} style={{ width:38, height:38, borderRadius:12, border:'none', background:'rgba(255,255,255,0.1)', color:'#fff', display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer' }}>
            <Icon name="chevL" size={20} stroke={2.2} />
          </button>
          <OnDeviceChip label="Generated on device" />
          <button style={{ width:38, height:38, borderRadius:12, border:'none', background:'rgba(255,255,255,0.1)', color:'#fff', display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer' }}>
            <Icon name="siri" size={20} />
          </button>
        </div>

        <div style={{ padding:'14px 20px 22px' }}>
          <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:14 }}>
            <SiriLine />
            <span style={{ fontSize:12, color:'rgba(255,255,255,0.6)', fontStyle:'italic' }}>“Brief me on {p.name.split(' ')[0]} before my {meeting?meeting.time:'next'} …”</span>
          </div>
          <div style={{ display:'flex', gap:14, alignItems:'center' }}>
            <Avatar name={p.name} tone={p.tone} size={60} ring />
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ fontSize:23, fontWeight:600, letterSpacing:'-0.025em' }}>{p.name}</div>
              <div style={{ fontSize:13.5, color:'rgba(255,255,255,0.65)', marginTop:2 }}>{p.role} · {p.company}</div>
            </div>
          </div>
          {meeting && (
            <div style={{ display:'flex', gap:8, marginTop:16 }}>
              <Chip tone="white" icon="calendar" style={{ background:'rgba(255,255,255,0.1)', color:'#fff', border:'1px solid rgba(255,255,255,0.16)' }}>{meeting.time} · {meeting.where}</Chip>
              <Chip tone="white" icon="clock" style={{ background:'rgba(255,255,255,0.1)', color:'#fff', border:'1px solid rgba(255,255,255,0.16)' }}>in 18 min</Chip>
            </div>
          )}
        </div>
      </div>

      {/* BODY */}
      <div style={{ padding:'18px 16px 18px' }}>

        {/* the one thing */}
        <div style={{ marginBottom:18 }}>
          <Card pad={0} style={{ overflow:'hidden', boxShadow:LM.shadow.md }}>
            <div style={{ display:'flex', alignItems:'center', gap:7, padding:'12px 16px', background:LM.c.t500, color:'#fff' }}>
              <Icon name="sparkle" size={16} stroke={2} />
              <span style={{ fontSize:12, fontWeight:600, letterSpacing:'0.03em', textTransform:'uppercase' }}>The one thing to remember</span>
            </div>
            <div style={{ padding:'15px 16px', fontSize:16, color:LM.c.s700, lineHeight:1.55 }}>
              Lead with the <b style={{ color:LM.c.ink }}>fund close</b> — announced Tuesday. He still owes you the data-infra memo, and you offered the Naomi intro. Don’t re-pitch your round; he asked for metrics, so offer to send them.
            </div>
          </Card>
        </div>

        {/* where you left off */}
        <BriefBlock icon="clock" title="Where you left off">
          <Card pad={0}>
            {recent.map((e,i)=>(
              <div key={i}>
                <div style={{ display:'flex', gap:12, padding:'13px 16px' }}>
                  <TimelineDot kind={e.kind} />
                  <div style={{ flex:1 }}>
                    <div style={{ display:'flex', justifyContent:'space-between', gap:8 }}>
                      <span style={{ fontSize:14.5, fontWeight:600, color:LM.c.ink }}>{e.label}</span>
                      <span style={{ fontSize:12, color:LM.c.s400 }}>{e.date}</span>
                    </div>
                    {e.detail && <div style={{ fontSize:13, color:LM.c.s500, marginTop:2, lineHeight:1.45 }}>{e.detail}</div>}
                  </div>
                </div>
                {i<recent.length-1 && <Divider inset={56} />}
              </div>
            ))}
          </Card>
        </BriefBlock>

        {/* open threads */}
        <BriefBlock icon="thread" title="Open threads" count={p.openThreads.length}>
          <Card pad={0}>
            {p.openThreads.map((t,i)=>(
              <div key={i}>
                <div style={{ display:'flex', gap:11, alignItems:'flex-start', padding:'12px 16px' }}>
                  <div style={{ width:7, height:7, borderRadius:4, background:LM.c.amber500, marginTop:6, flexShrink:0 }} />
                  <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.45 }}>{t}</div>
                </div>
                {i<p.openThreads.length-1 && <Divider inset={34} />}
              </div>
            ))}
          </Card>
        </BriefBlock>

        {/* talking points */}
        <BriefBlock icon="star" title="Talking points">
          <div style={{ display:'flex', flexDirection:'column', gap:8 }}>
            {p.talkingPoints.map((t,i)=>(
              <Card key={i} pad={13} style={{ display:'flex', gap:11, alignItems:'center' }}>
                <div style={{ width:24, height:24, borderRadius:8, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:12, fontWeight:700, color:LM.c.t700 }}>{i+1}</div>
                <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.4 }}>{t}</div>
              </Card>
            ))}
          </div>
        </BriefBlock>

        {/* shared */}
        {p.shared?.length>0 && (
          <BriefBlock icon="users" title="Shared connections" count={p.shared.length}>
            <Card pad={14} style={{ display:'flex', alignItems:'center', gap:10 }}>
              <div style={{ display:'flex' }}>
                {p.shared.map((name,i)=>(
                  <div key={name} style={{ marginLeft: i===0?0:-10 }}>
                    <Avatar name={name} tone={DATA.people.find(x=>x.name===name)?.tone} size={38} ring />
                  </div>
                ))}
              </div>
              <div style={{ fontSize:13.5, color:LM.c.s600, lineHeight:1.4 }}>{p.shared.slice(0,2).join(', ')}{p.shared.length>2?` +${p.shared.length-2}`:''} can vouch for you.</div>
            </Card>
          </BriefBlock>
        )}

      </div>
    </Screen>
  );
}

Object.assign(window, { BriefingScreen });
