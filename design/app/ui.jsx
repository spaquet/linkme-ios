// LinkMe — shared UI primitives. Depends on window.LM, Icon, Mark.

// ───────── Avatar (rounded-square, tonal duotone, ink initials) ─────────
const AV_TONES = {
  teal:   { bg: LM.c.t100,   fg: LM.c.t700 },
  slate:  { bg: LM.c.s200,   fg: LM.c.s700 },
  amber:  { bg: LM.c.amber100,fg: LM.c.amber600 },
  indigo: { bg: '#e0e7ff',   fg: '#4338ca' },
  rose:   { bg: '#ffe4e6',   fg: '#be123c' },
  sky:    { bg: '#e0f2fe',   fg: '#0369a1' },
};
const TONE_KEYS = Object.keys(AV_TONES);
function toneFor(name='') {
  let h = 0; for (let i=0;i<name.length;i++) h = (h*31 + name.charCodeAt(i)) >>> 0;
  return TONE_KEYS[h % TONE_KEYS.length];
}
function initials(name='') {
  const p = name.trim().split(/\s+/);
  return ((p[0]?.[0]||'') + (p[1]?.[0]||'')).toUpperCase();
}
function Avatar({ name='', tone, size=44, photo, ring=false }) {
  const t = AV_TONES[tone || toneFor(name)];
  const rad = (LM.avatarRadius ?? 0.32);
  return (
    <div style={{
      width:size, height:size, borderRadius:size*rad, flexShrink:0,
      background: photo ? `center/cover url(${photo})` : t.bg,
      color:t.fg, display:'flex', alignItems:'center', justifyContent:'center',
      fontWeight:600, fontSize:size*0.36, letterSpacing:'-0.02em',
      boxShadow: ring ? `0 0 0 3px ${LM.c.surface}, 0 0 0 4.5px ${LM.c.t200}` : 'none',
    }}>{!photo && initials(name)}</div>
  );
}

// ───────── small atoms ─────────
function SectionLabel({ children, style }) {
  return <div style={{
    fontSize:11.5, fontWeight:600, letterSpacing:'0.08em', textTransform:'uppercase',
    color:LM.c.s500, ...style,
  }}>{children}</div>;
}

function Chip({ children, tone='slate', icon, style }) {
  const map = {
    slate:{bg:LM.c.s100, fg:LM.c.s600, bd:LM.c.s200},
    teal:{bg:LM.c.t50, fg:LM.c.t700, bd:LM.c.t200},
    amber:{bg:LM.c.amber50, fg:LM.c.amber600, bd:LM.c.amber100},
    ink:{bg:LM.c.ink, fg:'#fff', bd:LM.c.ink},
    white:{bg:'#fff', fg:LM.c.s600, bd:LM.c.s200},
  }[tone];
  return (
    <span style={{
      display:'inline-flex', alignItems:'center', gap:5, height:26, padding:'0 10px',
      borderRadius:999, fontSize:12.5, fontWeight:500, lineHeight:1,
      background:map.bg, color:map.fg, border:`1px solid ${map.bd}`, ...style,
    }}>
      {icon && <Icon name={icon} size={13} stroke={2} />}{children}
    </span>
  );
}

// the recurring "visible privacy" signal
function OnDeviceChip({ label='On this device', style }) {
  return (
    <span style={{
      display:'inline-flex', alignItems:'center', gap:5, height:24, padding:'0 9px 0 8px',
      borderRadius:999, fontSize:11.5, fontWeight:600, letterSpacing:'0.01em',
      background:LM.c.t50, color:LM.c.t700, border:`1px solid ${LM.c.t200}`, ...style,
    }}>
      <Icon name="lock" size={12} stroke={2.2} />{label}
    </span>
  );
}

function AIBadge({ children='On-device AI', style }) {
  return (
    <span style={{
      display:'inline-flex', alignItems:'center', gap:5, height:22, padding:'0 8px',
      borderRadius:999, fontSize:11, fontWeight:600, letterSpacing:'0.02em',
      background:'#fff', color:LM.c.t700, border:`1px solid ${LM.c.t200}`, ...style,
    }}>
      <Icon name="sparkle" size={12} stroke={2} />{children}
    </span>
  );
}

function Divider({ inset=0, style }) {
  return <div style={{ height:1, background:LM.c.s200, marginLeft:inset, ...style }} />;
}

// ───────── buttons ─────────
function PrimaryButton({ children, onClick, icon, full=true, tone='ink', style }) {
  const bg = tone==='teal' ? LM.c.t500 : LM.c.ink;
  const sh = tone==='teal' ? LM.shadow.teal : LM.shadow.md;
  return (
    <button onClick={onClick} style={{
      display:'flex', alignItems:'center', justifyContent:'center', gap:8,
      width: full?'100%':'auto', height:54, padding:'0 22px', border:'none',
      borderRadius:16, background:bg, color:'#fff', cursor:'pointer',
      fontFamily:LM.font, fontSize:16.5, fontWeight:600, letterSpacing:'-0.01em',
      boxShadow:sh, transition:'transform .12s ease, filter .12s ease',
      ...style,
    }}
      onMouseDown={e=>e.currentTarget.style.transform='translateY(1px) scale(0.992)'}
      onMouseUp={e=>e.currentTarget.style.transform='none'}
      onMouseLeave={e=>e.currentTarget.style.transform='none'}>
      {icon && <Icon name={icon} size={19} stroke={2} />}{children}
    </button>
  );
}

function SecondaryButton({ children, onClick, icon, full=true, style }) {
  return (
    <button onClick={onClick} style={{
      display:'flex', alignItems:'center', justifyContent:'center', gap:8,
      width: full?'100%':'auto', height:52, padding:'0 20px',
      borderRadius:16, background:LM.c.surface, color:LM.c.s700,
      border:`1px solid ${LM.c.s200}`, cursor:'pointer',
      fontFamily:LM.font, fontSize:16, fontWeight:600, boxShadow:LM.shadow.sm,
      ...style,
    }}>
      {icon && <Icon name={icon} size={18} stroke={2} />}{children}
    </button>
  );
}

function IconBtn({ name, onClick, size=40, iconSize=20, bg=LM.c.surface, color=LM.c.s700, bd=LM.c.s200, style }) {
  return (
    <button onClick={onClick} style={{
      width:size, height:size, borderRadius:size*0.32, flexShrink:0,
      display:'flex', alignItems:'center', justifyContent:'center',
      background:bg, color, border:`1px solid ${bd}`, cursor:'pointer',
      boxShadow:LM.shadow.sm, ...style,
    }}>
      <Icon name={name} size={iconSize} stroke={1.9} />
    </button>
  );
}

// ───────── card ─────────
function Card({ children, pad=16, style, onClick }) {
  return (
    <div onClick={onClick} style={{
      background:LM.c.surface, borderRadius:20, border:`1px solid ${LM.c.s200}`,
      boxShadow:LM.shadow.sm, padding:pad, cursor:onClick?'pointer':'default', ...style,
    }}>{children}</div>
  );
}

// ───────── layout: screen, headers, tab bar ─────────
function Screen({ children, header, footer, bg }) {
  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column', background:bg||LM.c.canvas, position:'relative', overflow:'hidden' }}>
      {header}
      <div className="lm-scroll" style={{ flex:1, overflowY:'auto', overflowX:'hidden', WebkitOverflowScrolling:'touch' }}>{children}</div>
      {footer}
    </div>
  );
}

// large-title app header (top-level tabs)
function TopBar({ title, subtitle, right, left, bg=LM.c.canvas }) {
  return (
    <div style={{ paddingTop:LM.statusH, background:bg, borderBottom:`1px solid ${LM.c.s200}` }}>
      <div style={{ padding:'8px 20px 14px', display:'flex', alignItems:'flex-end', justifyContent:'space-between', gap:12 }}>
        <div style={{ minWidth:0 }}>
          {left}
          <div style={{ fontSize:30, fontWeight:600, letterSpacing:'-0.03em', color:LM.c.ink, lineHeight:1.05 }}>{title}</div>
          {subtitle && <div style={{ fontSize:13.5, color:LM.c.s500, marginTop:3 }}>{subtitle}</div>}
        </div>
        {right && <div style={{ display:'flex', gap:8, alignItems:'center', flexShrink:0 }}>{right}</div>}
      </div>
    </div>
  );
}

// push (back) header
function PushHeader({ title, onBack, right, bg=LM.c.surface, border=true }) {
  return (
    <div style={{ paddingTop:LM.statusH, background:bg, borderBottom: border?`1px solid ${LM.c.s200}`:'none' }}>
      <div style={{ height:50, padding:'0 12px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <button onClick={onBack} style={{ display:'flex', alignItems:'center', gap:3, background:'none', border:'none', cursor:'pointer', color:LM.c.t700, fontFamily:LM.font, fontSize:16, fontWeight:500, padding:'6px 8px 6px 4px', marginLeft:-2 }}>
          <Icon name="chevL" size={20} stroke={2.2} />
        </button>
        {title && <div style={{ fontSize:16, fontWeight:600, color:LM.c.ink, letterSpacing:'-0.01em' }}>{title}</div>}
        <div style={{ minWidth:40, display:'flex', justifyContent:'flex-end' }}>{right}</div>
      </div>
    </div>
  );
}

const TABS = [
  { id:'today',   label:'Today',   icon:'home' },
  { id:'people',  label:'People',  icon:'users' },
  { id:'capture', label:'',        icon:'mic', center:true },
  { id:'threads', label:'Threads', icon:'thread' },
  { id:'privacy', label:'Privacy', icon:'shield' },
];
function TabBar({ active, onTab }) {
  return (
    <div style={{ position:'relative', background:'rgba(255,255,255,0.92)', backdropFilter:'blur(16px)', WebkitBackdropFilter:'blur(16px)', borderTop:`1px solid ${LM.c.s200}`, paddingBottom:LM.homeH }}>
      <div style={{ display:'flex', alignItems:'flex-start', justifyContent:'space-around', height:LM.tabH-LM.homeH, padding:'8px 8px 0' }}>
        {TABS.map(tb => {
          if (tb.center) {
            return (
              <button key={tb.id} onClick={()=>onTab(tb.id)} style={{
                width:60, height:60, marginTop:-22, borderRadius:22, border:`4px solid ${LM.c.canvas}`,
                background:`linear-gradient(160deg, ${LM.c.t400}, ${LM.c.t600})`, color:'#fff',
                display:'flex', alignItems:'center', justifyContent:'center', cursor:'pointer',
                boxShadow:LM.shadow.teal,
              }}>
                <Icon name="mic" size={26} stroke={2} />
              </button>
            );
          }
          const on = active===tb.id;
          return (
            <button key={tb.id} onClick={()=>onTab(tb.id)} style={{
              flex:1, maxWidth:70, background:'none', border:'none', cursor:'pointer',
              display:'flex', flexDirection:'column', alignItems:'center', gap:3,
              color: on?LM.c.t700:LM.c.s400, padding:'2px 0',
            }}>
              <Icon name={tb.icon} size={23} stroke={on?2.1:1.8} />
              <span style={{ fontSize:10.5, fontWeight: on?600:500, letterSpacing:'0.01em' }}>{tb.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

Object.assign(window, {
  Avatar, toneFor, initials, SectionLabel, Chip, OnDeviceChip, AIBadge, Divider,
  PrimaryButton, SecondaryButton, IconBtn, Card, Screen, TopBar, PushHeader, TabBar,
});
