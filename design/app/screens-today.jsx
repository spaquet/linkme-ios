// LinkMe — tab roots: Today, People, Threads, Privacy.

const PAD_BOTTOM = LM.tabH + 18;

// ════════════════════════ TODAY (briefing-forward home) ════════════════════════
function TodayScreen({ go, openCapture }) {
  const next = DATA.meetings.find(m=>m.soon);
  const nextPerson = getPerson(next.person);
  const later = DATA.meetings.filter(m=>!m.soon);
  const topNudges = DATA.nudges.slice(0,2);
  const recent = DATA.people.slice(0,6);

  return (
    <Screen
      header={
        <TopBar
          title="Today"
          left={<div style={{ fontSize:13.5, color:LM.c.s500, fontWeight:500, marginBottom:2 }}>Good afternoon, {DATA.user.first}</div>}
          right={<>
            <IconBtn name="search" onClick={()=>go('people')} />
            <div style={{ position:'relative' }}>
              <IconBtn name="bell" onClick={()=>go('threads')} />
              <span style={{ position:'absolute', top:-3, right:-3, width:17, height:17, borderRadius:9, background:LM.c.t500, color:'#fff', fontSize:10.5, fontWeight:700, display:'flex', alignItems:'center', justifyContent:'center', border:'2px solid '+LM.c.canvas }}>3</span>
            </div>
          </>}
        />
      }
    >
      <div style={{ padding:'18px 16px '+PAD_BOTTOM+'px', display:'flex', flexDirection:'column', gap:22 }}>

        {/* UP NEXT — the just-in-time briefing hero */}
        <div>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:10 }}>
            <SectionLabel>Up next · {next.time}</SectionLabel>
            <OnDeviceChip />
          </div>
          <Card pad={0} style={{ overflow:'hidden', boxShadow:LM.shadow.md }}>
            <div style={{ padding:'18px 18px 16px' }}>
              <div style={{ display:'flex', gap:14, alignItems:'center' }}>
                <Avatar name={nextPerson.name} tone={nextPerson.tone} size={56} ring />
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontSize:19, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.02em' }}>{nextPerson.name}</div>
                  <div style={{ fontSize:13.5, color:LM.c.s500, marginTop:1 }}>{nextPerson.role} · {nextPerson.company}</div>
                </div>
                <Chip tone="slate" icon="calendar">{next.where}</Chip>
              </div>
              <div style={{ marginTop:14, padding:'13px 14px', background:LM.c.t50, border:`1px solid ${LM.c.t200}`, borderRadius:14 }}>
                <div style={{ display:'flex', alignItems:'center', gap:6, marginBottom:6 }}>
                  <Icon name="sparkle" size={14} stroke={2} color={LM.c.t700} />
                  <span style={{ fontSize:11.5, fontWeight:600, color:LM.c.t700, letterSpacing:'0.02em', textTransform:'uppercase' }}>The one thing to remember</span>
                </div>
                <div style={{ fontSize:14.5, color:LM.c.s700, lineHeight:1.5 }}>He owes you the data-infra memo, and you offered the Naomi intro. Lead with the fund close — announced Tuesday.</div>
              </div>
            </div>
            <button onClick={()=>go('briefing',{ id:nextPerson.id })} style={{
              width:'100%', height:52, border:'none', borderTop:`1px solid ${LM.c.s200}`,
              background:LM.c.ink, color:'#fff', cursor:'pointer',
              display:'flex', alignItems:'center', justifyContent:'center', gap:8,
              fontFamily:LM.font, fontSize:16, fontWeight:600,
            }}>
              <Icon name="wand" size={18} stroke={2} /> Brief me before 3:00
            </button>
          </Card>
        </div>

        {/* LATER TODAY */}
        <div>
          <SectionLabel style={{ marginBottom:10 }}>Later today</SectionLabel>
          <Card pad={0}>
            {later.map((m,i)=>{
              const per = m.person ? getPerson(m.person) : null;
              return (
                <div key={m.id}>
                  <div onClick={()=> per ? go('person',{id:per.id}) : null} style={{ display:'flex', alignItems:'center', gap:13, padding:'13px 16px', cursor: per?'pointer':'default' }}>
                    <div style={{ width:52, textAlign:'right', fontSize:13, fontWeight:600, color:LM.c.s600, flexShrink:0 }}>{m.time}</div>
                    <div style={{ width:1, height:30, background:LM.c.s200, flexShrink:0 }} />
                    {per ? <Avatar name={per.name} tone={per.tone} size={34} />
                         : <div style={{ width:34, height:34, borderRadius:11, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}><Icon name="users" size={18} stroke={1.9} color={LM.c.t600} /></div>}
                    <div style={{ flex:1, minWidth:0 }}>
                      <div style={{ fontSize:15, fontWeight:600, color:LM.c.ink, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>{m.title}</div>
                      <div style={{ fontSize:12.5, color:LM.c.s500 }}>{m.scene? 'Scene · seed the room' : m.where}</div>
                    </div>
                    {m.scene ? <Chip tone="teal">Scene</Chip> : <Icon name="chevR" size={18} color={LM.c.s300} />}
                  </div>
                  {i<later.length-1 && <Divider inset={68} />}
                </div>
              );
            })}
          </Card>
        </div>

        {/* NEEDS YOU (nudges preview) */}
        <div>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:10 }}>
            <SectionLabel>Needs you</SectionLabel>
            <button onClick={()=>go('threads')} style={{ background:'none', border:'none', color:LM.c.t700, fontSize:13, fontWeight:600, cursor:'pointer', fontFamily:LM.font }}>All threads</button>
          </div>
          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {topNudges.map(n=>{
              const per = getPerson(n.person);
              return (
                <Card key={n.id} onClick={()=>go('followup',{ id:per.id, nudge:n.id })} pad={14} style={{ display:'flex', gap:12, alignItems:'center' }}>
                  <Avatar name={per.name} tone={per.tone} size={40} />
                  <div style={{ flex:1, minWidth:0 }}>
                    <div style={{ fontSize:14.5, fontWeight:600, color:LM.c.ink }}>{n.title}</div>
                    <div style={{ fontSize:12.5, color:LM.c.s500, lineHeight:1.4, marginTop:1, display:'-webkit-box', WebkitLineClamp:2, WebkitBoxOrient:'vertical', overflow:'hidden' }}>{n.detail}</div>
                  </div>
                  <Chip tone="ink">{n.cta}</Chip>
                </Card>
              );
            })}
          </div>
        </div>

        {/* RECENT CAPTURES */}
        <div>
          <SectionLabel style={{ marginBottom:10 }}>Recent captures</SectionLabel>
          <div className="lm-scroll" style={{ display:'flex', gap:10, overflowX:'auto', margin:'0 -16px', padding:'0 16px' }}>
            {recent.map(p=>(
              <div key={p.id} onClick={()=>go('person',{id:p.id})} style={{ width:108, flexShrink:0, cursor:'pointer' }}>
                <Card pad={12} style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:8, textAlign:'center' }}>
                  <Avatar name={p.name} tone={p.tone} size={48} />
                  <div>
                    <div style={{ fontSize:13, fontWeight:600, color:LM.c.ink, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis', maxWidth:84 }}>{p.name.split(' ')[0]}</div>
                    <div style={{ fontSize:11, color:LM.c.s500, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis', maxWidth:84 }}>{p.company}</div>
                  </div>
                </Card>
              </div>
            ))}
            <div onClick={openCapture} style={{ width:108, flexShrink:0, cursor:'pointer' }}>
              <div style={{ height:'100%', minHeight:128, border:`1.5px dashed ${LM.c.t200}`, borderRadius:20, background:LM.c.t50, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:8, color:LM.c.t700 }}>
                <Icon name="mic" size={24} stroke={2} /><span style={{ fontSize:12, fontWeight:600 }}>Capture</span>
              </div>
            </div>
          </div>
        </div>

      </div>
    </Screen>
  );
}

// ════════════════════════ PEOPLE ════════════════════════
function PeopleScreen({ go }) {
  const [filter, setFilter] = React.useState('All');
  const filters = ['All','Investors','Founders','Execs'];
  const match = (p) => filter==='All' ? true
    : filter==='Investors' ? /Investor|Angel/.test(p.tags.join())
    : filter==='Founders' ? p.tags.includes('Founder')
    : p.tags.includes('Exec') || p.tags.includes('Buyer');
  const list = DATA.people.filter(match);

  return (
    <Screen
      header={<TopBar title="People" subtitle={`${DATA.people.length} relationships · all on this device`} />}
    >
      <div style={{ padding:'14px 16px '+PAD_BOTTOM+'px' }}>
        {/* search */}
        <div style={{ display:'flex', alignItems:'center', gap:9, height:44, padding:'0 14px', background:LM.c.surface, border:`1px solid ${LM.c.s200}`, borderRadius:14, boxShadow:LM.shadow.sm, marginBottom:12 }}>
          <Icon name="search" size={18} color={LM.c.s400} />
          <span style={{ fontSize:15, color:LM.c.s400 }}>Search people, companies, context…</span>
        </div>
        {/* filter chips */}
        <div style={{ display:'flex', gap:8, marginBottom:14 }}>
          {filters.map(f=>(
            <button key={f} onClick={()=>setFilter(f)} style={{
              height:32, padding:'0 14px', borderRadius:999, cursor:'pointer', fontFamily:LM.font,
              fontSize:13.5, fontWeight:600,
              background: filter===f?LM.c.ink:LM.c.surface, color: filter===f?'#fff':LM.c.s600,
              border:`1px solid ${filter===f?LM.c.ink:LM.c.s200}`,
            }}>{f}</button>
          ))}
        </div>
        {/* list */}
        <Card pad={0}>
          {list.map((p,i)=>(
            <div key={p.id}>
              <div onClick={()=>go('person',{id:p.id})} style={{ display:'flex', alignItems:'center', gap:13, padding:'13px 16px', cursor:'pointer' }}>
                <Avatar name={p.name} tone={p.tone} size={46} />
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontSize:15.5, fontWeight:600, color:LM.c.ink }}>{p.name}</div>
                  <div style={{ fontSize:13, color:LM.c.s500, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>{p.role} · {p.company}</div>
                </div>
                <div style={{ textAlign:'right', flexShrink:0 }}>
                  <div style={{ fontSize:11.5, color:LM.c.s400 }}>{p.lastTouch}</div>
                  <Icon name="chevR" size={16} color={LM.c.s300} style={{ marginTop:2 }} />
                </div>
              </div>
              {i<list.length-1 && <Divider inset={75} />}
            </div>
          ))}
        </Card>
      </div>
    </Screen>
  );
}

// ════════════════════════ THREADS (follow-ups & nudges) ════════════════════════
function ThreadsScreen({ go }) {
  return (
    <Screen header={<TopBar title="Threads" subtitle="Proactive nudges & open follow-ups" />}>
      <div style={{ padding:'18px 16px '+PAD_BOTTOM+'px', display:'flex', flexDirection:'column', gap:22 }}>
        <div>
          <div style={{ display:'flex', alignItems:'center', gap:7, marginBottom:10 }}>
            <SectionLabel>Proactive nudges</SectionLabel>
            <AIBadge>On-device AI</AIBadge>
          </div>
          <div style={{ display:'flex', flexDirection:'column', gap:11 }}>
            {DATA.nudges.map(n=>{
              const per = getPerson(n.person);
              const tone = n.kind==='signal' ? 'teal' : n.kind==='promise' ? 'amber' : 'slate';
              const label = n.kind==='signal' ? 'Live signal' : n.kind==='promise' ? 'You promised' : 'Reciprocity';
              return (
                <Card key={n.id} pad={16}>
                  <div style={{ display:'flex', gap:13 }}>
                    <Avatar name={per.name} tone={per.tone} size={44} />
                    <div style={{ flex:1, minWidth:0 }}>
                      <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:3 }}>
                        <span style={{ fontSize:15.5, fontWeight:600, color:LM.c.ink }}>{per.name}</span>
                        <Chip tone={tone} style={{ height:21, fontSize:11 }}>{label}</Chip>
                      </div>
                      <div style={{ fontSize:13.5, color:LM.c.s600, lineHeight:1.5 }}>{n.detail}</div>
                    </div>
                  </div>
                  <div style={{ display:'flex', gap:9, marginTop:13 }}>
                    <button onClick={()=>go('followup',{ id:per.id, nudge:n.id })} style={{ flex:1, height:42, borderRadius:13, border:'none', background:LM.c.ink, color:'#fff', fontFamily:LM.font, fontSize:14.5, fontWeight:600, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:7 }}>
                      <Icon name="wand" size={16} stroke={2} />{n.cta}
                    </button>
                    <button onClick={()=>go('person',{id:per.id})} style={{ width:42, height:42, borderRadius:13, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, color:LM.c.s600, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center' }}>
                      <Icon name="person" size={18} />
                    </button>
                  </div>
                </Card>
              );
            })}
          </div>
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:8, justifyContent:'center', color:LM.c.s400, fontSize:12.5 }}>
          <Icon name="lock" size={13} stroke={2} color={LM.c.t600} />
          Nudges are generated on your device. Nothing was sent anywhere.
        </div>
      </div>
    </Screen>
  );
}

// ════════════════════════ PRIVACY (visible, first-class consent) ════════════════════════
function Switch({ on, onToggle, locked=false }) {
  return (
    <button onClick={locked?undefined:onToggle} style={{
      width:50, height:30, borderRadius:999, border:'none', position:'relative', flexShrink:0,
      cursor: locked?'default':'pointer', transition:'background .2s ease',
      background: on ? LM.c.t500 : LM.c.s300, opacity: locked?0.85:1,
    }}>
      <span style={{ position:'absolute', top:3, left: on?23:3, width:24, height:24, borderRadius:999, background:'#fff', boxShadow:'0 1px 3px rgba(0,0,0,.25)', transition:'left .2s ease' }} />
    </button>
  );
}

function PrivacyScreen() {
  const [s, setS] = React.useState({ cloud:false, signals:true, calendar:true, contacts:true, siri:true });
  const t = (k)=> setS(v=>({ ...v, [k]:!v[k] }));
  const Row = ({ icon, title, detail, k, locked, value }) => (
    <div style={{ display:'flex', gap:13, alignItems:'flex-start', padding:'14px 16px' }}>
      <div style={{ width:34, height:34, borderRadius:11, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
        <Icon name={icon} size={18} stroke={1.9} color={LM.c.t700} />
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:'flex', alignItems:'center', gap:7 }}>
          <span style={{ fontSize:15, fontWeight:600, color:LM.c.ink }}>{title}</span>
          {locked && <span style={{ fontSize:10.5, fontWeight:600, color:LM.c.t700, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, borderRadius:999, padding:'1px 7px' }}>Always</span>}
        </div>
        <div style={{ fontSize:12.5, color:LM.c.s500, lineHeight:1.45, marginTop:2 }}>{detail}</div>
      </div>
      <Switch on={value} onToggle={()=>t(k)} locked={locked} />
    </div>
  );

  return (
    <Screen header={<TopBar title="Privacy" subtitle="You can see exactly what stays on device" />}>
      <div style={{ padding:'18px 16px '+PAD_BOTTOM+'px', display:'flex', flexDirection:'column', gap:20 }}>
        {/* hero */}
        <div style={{ background:`linear-gradient(165deg, ${LM.c.ink}, #14303a)`, borderRadius:22, padding:'22px 20px', color:'#fff', boxShadow:LM.shadow.lg }}>
          <div style={{ width:46, height:46, borderRadius:14, background:'rgba(255,255,255,0.1)', border:'1px solid rgba(255,255,255,0.18)', display:'flex', alignItems:'center', justifyContent:'center', marginBottom:14 }}>
            <Icon name="shield" size={24} stroke={1.9} color={LM.c.t400} />
          </div>
          <div style={{ fontSize:21, fontWeight:600, letterSpacing:'-0.02em', lineHeight:1.25 }}>Your relationship brain lives on this device.</div>
          <div style={{ fontSize:13.5, color:'rgba(255,255,255,0.66)', lineHeight:1.55, marginTop:8 }}>Capture, transcription, briefings and nudges all run on-device with Apple’s on-device models. Nothing leaves unless you turn on a specific switch below.</div>
          <div style={{ display:'flex', gap:18, marginTop:18 }}>
            {[['18','people'],['46','captures'],['0','left this device']].map(([n,l])=>(
              <div key={l}>
                <div style={{ fontSize:22, fontWeight:600, color: l==='0 left'?LM.c.t400:'#fff' }}>{n}</div>
                <div style={{ fontSize:11.5, color:'rgba(255,255,255,0.6)' }}>{l}</div>
              </div>
            ))}
          </div>
        </div>

        <div>
          <SectionLabel style={{ marginBottom:10 }}>What runs on device</SectionLabel>
          <Card pad={0}>
            <Row icon="mic"     title="Voice capture & transcription" detail="Speech-to-text and extraction never leave your iPhone." locked value={true} />
            <Divider inset={63} />
            <Row icon="sparkle" title="Briefings & nudges"           detail="Summaries and talking points are generated locally." locked value={true} />
          </Card>
        </div>

        <div>
          <SectionLabel style={{ marginBottom:10 }}>What needs your permission</SectionLabel>
          <Card pad={0}>
            <Row icon="link"     title="Cloud enrichment"   detail="Look up public company & news context. Sends only a name + company." k="cloud" value={s.cloud} />
            <Divider inset={63} />
            <Row icon="star"     title="Life & deal signals" detail="Watch public sources for fundraises, role changes and press." k="signals" value={s.signals} />
            <Divider inset={63} />
            <Row icon="calendar" title="Calendar"            detail="Read upcoming events to time your briefings." k="calendar" value={s.calendar} />
            <Divider inset={63} />
            <Row icon="users"    title="Contacts"            detail="Match captures to people you already know." k="contacts" value={s.contacts} />
            <Divider inset={63} />
            <Row icon="siri"     title="Siri & App Intents"  detail="“Hey Siri, brief me on Marcus.” Requests are handled on device." k="siri" value={s.siri} />
          </Card>
        </div>

        <div style={{ textAlign:'center', color:LM.c.s400, fontSize:12.5, lineHeight:1.5 }}>
          We never build aggregate data products from your network.<br/>Your graph is yours.
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { TodayScreen, PeopleScreen, ThreadsScreen, PrivacyScreen });
