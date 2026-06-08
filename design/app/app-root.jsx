// LinkMe — app root: router, tab bar, overlays, Tweaks.

const ACCENTS = {
  Teal:   { t50:'#f0fdfa', t100:'#ccfbf1', t200:'#99f6e4', t400:'#2dd4bf', t500:'#14b8a6', t600:'#0d9488', t700:'#0f766e' },
  Indigo: { t50:'#eef2ff', t100:'#e0e7ff', t200:'#c7d2fe', t400:'#818cf8', t500:'#6366f1', t600:'#4f46e5', t700:'#4338ca' },
  Violet: { t50:'#f5f3ff', t100:'#ede9fe', t200:'#ddd6fe', t400:'#a78bfa', t500:'#8b5cf6', t600:'#7c3aed', t700:'#6d28d9' },
};
function applyAccent(name){ Object.assign(LM.c, ACCENTS[name] || ACCENTS.Teal); }

const TWEAK_DEFAULTS = {
  "accent": "Teal",
  "avatars": "Rounded",
  "openTo": "Onboarding",
  "motion": "On"
};

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  const [stage, setStage] = React.useState(t.openTo==='Onboarding' ? 'onboarding' : 'app');
  const [tab, setTab]     = React.useState('today');
  const [stack, setStack] = React.useState(()=> t.openTo==='Briefing' ? [{screen:'briefing',params:{id:'marcus'}}] : []);
  const [capture, setCapture] = React.useState(t.openTo==='Capture');
  const [share, setShare] = React.useState(null);

  // apply themeable tweaks (also on reload from persisted values)
  applyAccent(t.accent);
  LM.avatarRadius = t.avatars==='Circle' ? 0.5 : 0.32;

  const TAB_IDS = ['today','people','threads','privacy'];
  const go = (screen, params) => {
    if (TAB_IDS.includes(screen)) { setStack([]); setTab(screen); }
    else if (screen==='capture') setCapture(true);
    else setStack(s=>[...s, { screen, params }]);
  };
  const back = () => setStack(s=>s.slice(0,-1));
  const onTab = (id) => { if (id==='capture') setCapture(true); else { setStack([]); setTab(id); } };

  const applyOpenTo = (v) => {
    setShare(null); setCapture(false); setStack([]);
    if (v==='Onboarding') { setStage('onboarding'); return; }
    setStage('app');
    if (v==='Today')    setTab('today');
    if (v==='Capture')  { setTab('today'); setCapture(true); }
    if (v==='Briefing') { setTab('today'); setStack([{screen:'briefing',params:{id:'marcus'}}]); }
  };

  // ── render current surface ──
  let surface;
  if (stage==='onboarding') {
    surface = <Onboarding onDone={()=>setStage('app')} />;
  } else {
    const top = stack[stack.length-1];
    let screenEl;
    if (top) {
      const pr = top.params || {};
      if (top.screen==='person')   screenEl = <PersonScreen {...pr} go={go} back={back} openShare={setShare} />;
      if (top.screen==='briefing') screenEl = <BriefingScreen {...pr} go={go} back={back} openShare={setShare} />;
      if (top.screen==='followup') screenEl = <FollowupScreen {...pr} go={go} back={back} />;
    } else {
      if (tab==='today')   screenEl = <TodayScreen go={go} openCapture={()=>setCapture(true)} />;
      if (tab==='people')  screenEl = <PeopleScreen go={go} />;
      if (tab==='threads') screenEl = <ThreadsScreen go={go} />;
      if (tab==='privacy') screenEl = <PrivacyScreen />;
    }
    const showTab = !top;
    surface = (
      <div style={{ height:'100%', display:'flex', flexDirection:'column' }}>
        <div style={{ flex:1, minHeight:0, display:'flex', flexDirection:'column' }}>{screenEl}</div>
        {showTab && <TabBar active={tab} onTab={onTab} />}
      </div>
    );
  }

  return (
    <>
      <IOSDevice dark={false}>
        <div className={t.motion==='Reduced' ? 'lm-reduce' : ''} style={{ height:'100%', position:'relative', overflow:'hidden', background:LM.c.canvas }}>
          {surface}
          {capture && <CaptureOverlay onClose={()=>setCapture(false)} onSaved={(id)=>{ setCapture(false); setStage('app'); setStack([{screen:'person',params:{id}}]); }} />}
          {share && <ShareOverlay targetId={share} onClose={()=>setShare(null)} />}
        </div>
      </IOSDevice>

      <TweaksPanel title="Tweaks">
        <TweakSection label="Identity" />
        <TweakColor label="Accent" value={t.accent==='Teal'?'#14b8a6':t.accent==='Indigo'?'#6366f1':'#8b5cf6'}
          options={['#14b8a6','#6366f1','#8b5cf6']}
          onChange={(hex)=>{ const name = hex==='#14b8a6'?'Teal':hex==='#6366f1'?'Indigo':'Violet'; applyAccent(name); setTweak('accent', name); }} />
        <TweakRadio label="Avatars" value={t.avatars} options={['Rounded','Circle']}
          onChange={(v)=>{ LM.avatarRadius = v==='Circle'?0.5:0.32; setTweak('avatars', v); }} />
        <TweakSection label="Prototype" />
        <TweakSelect label="Open to" value={t.openTo} options={['Onboarding','Today','Capture','Briefing']}
          onChange={(v)=>{ setTweak('openTo', v); applyOpenTo(v); }} />
        <TweakRadio label="Motion" value={t.motion} options={['On','Reduced']}
          onChange={(v)=>setTweak('motion', v)} />
      </TweaksPanel>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('stage')).render(<App />);
