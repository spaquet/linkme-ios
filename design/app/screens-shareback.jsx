// LinkMe — Reciprocal share-back + no-app recipient web card + profile claim.

function FauxQR({ size=104 }) {
  // deterministic pseudo-QR
  const n = 11; const cell = size/n;
  const cells = [];
  for (let y=0;y<n;y++) for (let x=0;x<n;x++){
    const corner = (x<3&&y<3)||(x>n-4&&y<3)||(x<3&&y>n-4);
    const on = corner ? !((x===0||x===n-1||y===0)&&false) : (((x*7+y*13+x*y)%3===0));
    if (on) cells.push(<rect key={x+'-'+y} x={x*cell} y={y*cell} width={cell} height={cell} rx={cell*0.2} fill={LM.c.ink} />);
  }
  const eye = (cx,cy)=>(<g key={cx+'e'+cy}><rect x={cx*cell} y={cy*cell} width={cell*3} height={cell*3} rx={4} fill="none" stroke={LM.c.ink} strokeWidth={cell*0.7}/><rect x={(cx+1)*cell} y={(cy+1)*cell} width={cell} height={cell} fill={LM.c.t500}/></g>);
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ display:'block' }}>
      {cells}{eye(0,0)}{eye(n-3,0)}{eye(0,n-3)}
    </svg>
  );
}

// the user's identity card (mini preview)
function CardPreview({ dark=false }) {
  const u = DATA.user;
  return (
    <div style={{ borderRadius:18, overflow:'hidden', border:`1px solid ${dark?'rgba(255,255,255,0.12)':LM.c.s200}`, boxShadow:LM.shadow.sm }}>
      <div style={{ background:`linear-gradient(150deg, ${LM.c.t500}, ${LM.c.t700})`, height:48 }} />
      <div style={{ background: dark?'#11242b':LM.c.surface, padding:'0 16px 16px', marginTop:-22 }}>
        <Avatar name={u.name} tone="teal" size={52} ring />
        <div style={{ fontSize:17, fontWeight:600, color: dark?'#fff':LM.c.ink, marginTop:8 }}>{u.name}</div>
        <div style={{ fontSize:13, color: dark?'rgba(255,255,255,0.6)':LM.c.s500 }}>{u.role} · {u.company}</div>
      </div>
    </div>
  );
}

const METHODS = [
  { id:'namedrop', icon:'nfc',  title:'NameDrop', sub:'Hold phones together' },
  { id:'tap',      icon:'nfc',  title:'Tap to share', sub:'NFC' },
  { id:'qr',       icon:'qr',   title:'QR code', sub:'They scan' },
  { id:'wallet',   icon:'share',title:'Add to Wallet', sub:'A living pass' },
  { id:'link',     icon:'link', title:'Send a link', sub:'Works with no app' },
];

function ShareOverlay({ targetId, onClose }) {
  const p = getPerson(targetId);
  const first = p ? p.name.split(' ')[0] : 'them';
  const [view, setView] = React.useState('share'); // share | recipient | claim | claimed
  const [method, setMethod] = React.useState('namedrop');
  const u = DATA.user;

  // faux Safari chrome for the no-app recipient web views
  const Safari = ({ children, url }) => (
    <div style={{ position:'absolute', inset:0, background:'#fff', display:'flex', flexDirection:'column' }}>
      <div style={{ paddingTop:LM.statusH, background:'#f6f6f7', borderBottom:`1px solid ${LM.c.s200}` }}>
        <div style={{ display:'flex', alignItems:'center', gap:8, padding:'6px 14px 12px' }}>
          <button onClick={onClose} style={{ border:'none', background:'none', cursor:'pointer', color:LM.c.s500, fontSize:13, fontWeight:500 }}>Close</button>
          <div style={{ flex:1, height:36, borderRadius:11, background:'#fff', border:`1px solid ${LM.c.s200}`, display:'flex', alignItems:'center', justifyContent:'center', gap:6, color:LM.c.s500, fontSize:13.5 }}>
            <Icon name="lock" size={13} stroke={2} color={LM.c.s400} />{url}
          </div>
          <Icon name="dots" size={20} color={LM.c.s400} />
        </div>
      </div>
      <div className="lm-scroll" style={{ flex:1, overflowY:'auto' }}>{children}</div>
    </div>
  );

  // ── RECIPIENT WEB CARD (no app needed) ──
  if (view==='recipient') {
    return (
      <div style={{ position:'absolute', inset:0, zIndex:90 }}>
        <Safari url="linkme.to/alexrivera">
          <div style={{ background:`linear-gradient(170deg, ${LM.c.ink} 0%, #15323c 60%, #16323b 100%)`, padding:`30px 22px 26px`, color:'#fff', textAlign:'center' }}>
            <div style={{ display:'flex', justifyContent:'center', marginBottom:14 }}><Avatar name={u.name} tone="teal" size={88} ring /></div>
            <div style={{ fontSize:25, fontWeight:600, letterSpacing:'-0.02em' }}>{u.name}</div>
            <div style={{ fontSize:14.5, color:'rgba(255,255,255,0.7)', marginTop:3 }}>{u.role} · {u.company}</div>
            <div style={{ fontSize:14, color:'rgba(255,255,255,0.85)', marginTop:12, lineHeight:1.5, maxWidth:280, marginLeft:'auto', marginRight:'auto' }}>{u.tagline}</div>
            <div style={{ display:'inline-flex', alignItems:'center', gap:6, marginTop:16, padding:'5px 11px', borderRadius:999, background:'rgba(255,255,255,0.1)', border:'1px solid rgba(255,255,255,0.16)', fontSize:12 }}>
              <Icon name="handshake" size={13} color={LM.c.t400} /> You met at the Founders Circuit dinner
            </div>
          </div>

          <div style={{ padding:'20px 18px 30px' }}>
            <SectionLabel style={{ marginBottom:9 }}>Currently</SectionLabel>
            <div style={{ padding:'14px 16px', background:LM.c.t50, border:`1px solid ${LM.c.t200}`, borderRadius:16, fontSize:14.5, color:LM.c.s700, lineHeight:1.55 }}>
              Closing a pilot with two West-Coast ports this quarter. Hiring a founding account exec. Happy to swap notes on go-to-market in regulated logistics.
            </div>
            <div style={{ display:'flex', alignItems:'center', gap:6, color:LM.c.s400, fontSize:12, marginTop:8, justifyContent:'center' }}>
              <Icon name="refresh" size={12} stroke={2} color={LM.c.t500} /> This card stays current automatically.
            </div>

            <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, marginTop:18 }}>
              <SecondaryButton icon="person" full>Save contact</SecondaryButton>
              <SecondaryButton icon="mail" full>Email</SecondaryButton>
            </div>

            {/* the conversion: reciprocal claim */}
            <div style={{ marginTop:22, padding:'18px 16px', borderRadius:20, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, boxShadow:LM.shadow.md }}>
              <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:8 }}>
                <Mark size={22} /><span style={{ fontSize:13, fontWeight:700, color:LM.c.ink }}>LinkMe</span>
              </div>
              <div style={{ fontSize:17, fontWeight:600, color:LM.c.ink, lineHeight:1.35, letterSpacing:'-0.01em' }}>Claim your own card, {first} — and remember Alex back.</div>
              <div style={{ fontSize:13.5, color:LM.c.s500, lineHeight:1.55, marginTop:7 }}>Free, always-current, and yours to control. Comes with a private place to remember everyone you meet. No app required to start.</div>
              <div style={{ marginTop:14 }}>
                <PrimaryButton tone="ink" icon="arrowUR" full onClick={()=>setView('claim')}>Claim my profile</PrimaryButton>
              </div>
            </div>
            <div style={{ textAlign:'center', color:LM.c.s400, fontSize:11.5, marginTop:16 }}>linkme.to · a gift, not a referral</div>
          </div>
        </Safari>
      </div>
    );
  }

  // ── CLAIM (web, value-first) ──
  if (view==='claim' || view==='claimed') {
    const claimed = view==='claimed';
    const handle = (p?.name||'you').toLowerCase().replace(/[^a-z]/g,'');
    return (
      <div style={{ position:'absolute', inset:0, zIndex:90 }}>
        <Safari url="linkme.to/claim">
          <div style={{ padding:'26px 20px 30px' }}>
            {!claimed ? (
              <>
                <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:18 }}><Mark size={24} /><span style={{ fontSize:15, fontWeight:700, color:LM.c.ink }}>LinkMe</span></div>
                <div style={{ fontSize:24, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.02em', lineHeight:1.2 }}>Claim your free profile</div>
                <div style={{ fontSize:14.5, color:LM.c.s500, marginTop:8, lineHeight:1.55 }}>Standalone value first — reciprocity is the bonus.</div>

                <div style={{ display:'flex', flexDirection:'column', gap:10, margin:'20px 0' }}>
                  {[['person','An always-current identity card','People see the latest you, automatically.'],
                    ['sparkle','Your own relationship brain','A private place to remember everyone you meet.'],
                    ['lock','On your device','Your graph stays yours. Never sold, never aggregated.']].map(([ic,t,d])=>(
                    <div key={t} style={{ display:'flex', gap:12, alignItems:'flex-start' }}>
                      <div style={{ width:34, height:34, borderRadius:11, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}><Icon name={ic} size={18} stroke={1.9} color={LM.c.t700} /></div>
                      <div><div style={{ fontSize:14.5, fontWeight:600, color:LM.c.ink }}>{t}</div><div style={{ fontSize:13, color:LM.c.s500, lineHeight:1.45 }}>{d}</div></div>
                    </div>
                  ))}
                </div>

                <div style={{ display:'flex', alignItems:'center', height:50, border:`1.5px solid ${LM.c.s200}`, borderRadius:14, overflow:'hidden', background:LM.c.surface, marginBottom:12 }}>
                  <span style={{ paddingLeft:14, color:LM.c.s400, fontSize:15 }}>linkme.to/</span>
                  <span style={{ fontSize:15, color:LM.c.ink, fontWeight:600 }}>{handle}</span>
                </div>
                <PrimaryButton tone="teal" full icon="check" onClick={()=>setView('claimed')}>Claim {p?p.name.split(' ')[0]:'profile'}{"’"}s profile</PrimaryButton>
                <div style={{ textAlign:'center', color:LM.c.s400, fontSize:11.5, marginTop:12 }}>Takes 20 seconds · no app to download</div>
              </>
            ) : (
              <div style={{ textAlign:'center', paddingTop:10 }}>
                <div style={{ width:74, height:74, borderRadius:37, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, display:'flex', alignItems:'center', justifyContent:'center', margin:'0 auto 18px' }}>
                  <Icon name="check" size={36} stroke={2.2} color={LM.c.t600} />
                </div>
                <div style={{ fontSize:22, fontWeight:600, color:LM.c.ink }}>Your card is live</div>
                <div style={{ fontSize:14, color:LM.c.s500, marginTop:6 }}>linkme.to/{handle}</div>
                <div style={{ marginTop:20 }}><CardPreview /></div>
                <div style={{ margintop:8, marginTop:22, padding:'16px', borderRadius:18, background:LM.c.t50, border:`1px solid ${LM.c.t200}`, textAlign:'left' }}>
                  <div style={{ fontSize:15, fontWeight:600, color:LM.c.ink }}>Now remember Alex back</div>
                  <div style={{ fontSize:13, color:LM.c.s600, lineHeight:1.5, marginTop:5 }}>Speak a 10-second note about your meeting — your relationship brain starts here. This is the loop’s second capture.</div>
                  <div style={{ marginTop:13 }}><PrimaryButton tone="ink" icon="mic" full onClick={onClose}>Capture your first note</PrimaryButton></div>
                </div>
              </div>
            )}
          </div>
        </Safari>
      </div>
    );
  }

  // ── SHARE (sender side, in-app) ──
  return (
    <div style={{ position:'absolute', inset:0, zIndex:90, background:LM.c.canvas, display:'flex', flexDirection:'column' }}>
      <div style={{ paddingTop:LM.statusH, display:'flex', alignItems:'center', justifyContent:'space-between', padding:`${LM.statusH+6}px 16px 8px` }}>
        <button onClick={onClose} style={{ width:38, height:38, borderRadius:12, border:`1px solid ${LM.c.s200}`, background:LM.c.surface, display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer', color:LM.c.s600 }}><Icon name="x" size={20} /></button>
        <span style={{ fontSize:16, fontWeight:600, color:LM.c.ink }}>Share back</span>
        <Chip tone="teal" icon="shield" style={{ height:28 }}>Reputation-safe</Chip>
      </div>

      <div className="lm-scroll" style={{ flex:1, overflowY:'auto', padding:'10px 18px 24px' }}>
        <div style={{ fontSize:15, color:LM.c.s600, lineHeight:1.5, marginBottom:18 }}>
          Send {first} a card they’ll value immediately — then invite them to remember you back. It should feel like a gift, never spam.
        </div>

        {/* QR + your card */}
        <Card pad={18} style={{ display:'flex', gap:16, alignItems:'center', marginBottom:18 }}>
          <div style={{ padding:10, background:'#fff', borderRadius:14, border:`1px solid ${LM.c.s200}` }}><FauxQR size={96} /></div>
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontSize:16, fontWeight:600, color:LM.c.ink }}>{u.name}</div>
            <div style={{ fontSize:13, color:LM.c.s500, marginBottom:8 }}>{u.role} · {u.company}</div>
            <OnDeviceChip label="Your card · always current" />
          </div>
        </Card>

        <SectionLabel style={{ marginBottom:10 }}>How to exchange</SectionLabel>
        <div style={{ display:'flex', flexDirection:'column', gap:9, marginBottom:20 }}>
          {METHODS.map(m=>(
            <button key={m.id} onClick={()=>setMethod(m.id)} style={{ display:'flex', alignItems:'center', gap:13, padding:'13px 15px', borderRadius:16, cursor:'pointer', textAlign:'left',
              background: method===m.id?LM.c.t50:LM.c.surface, border:`1.5px solid ${method===m.id?LM.c.t200:LM.c.s200}`, fontFamily:LM.font }}>
              <div style={{ width:38, height:38, borderRadius:12, background: method===m.id?'#fff':LM.c.s100, border:`1px solid ${method===m.id?LM.c.t200:LM.c.s200}`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
                <Icon name={m.icon} size={20} stroke={1.9} color={method===m.id?LM.c.t700:LM.c.s500} />
              </div>
              <div style={{ flex:1 }}>
                <div style={{ fontSize:15, fontWeight:600, color:LM.c.ink }}>{m.title}</div>
                <div style={{ fontSize:12.5, color:LM.c.s500 }}>{m.sub}</div>
              </div>
              <div style={{ width:20, height:20, borderRadius:999, border:`2px solid ${method===m.id?LM.c.t500:LM.c.s300}`, display:'flex', alignItems:'center', justifyContent:'center' }}>
                {method===m.id && <div style={{ width:10, height:10, borderRadius:999, background:LM.c.t500 }} />}
              </div>
            </button>
          ))}
        </div>

        <PrimaryButton tone="ink" icon="send" full onClick={()=>setView('recipient')}>Send card to {first}</PrimaryButton>
        <button onClick={()=>setView('recipient')} style={{ width:'100%', marginTop:12, background:'none', border:'none', color:LM.c.t700, fontSize:13.5, fontWeight:600, cursor:'pointer', fontFamily:LM.font }}>
          Preview what {first} receives →
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { ShareOverlay });
