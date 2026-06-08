// LinkMe — design kit (tokens, icons, primitives) on the OmniReach base.
// Premium iOS identity: Geist, teal as the "live / on-device / AI" signal,
// slate ink, hairline borders, soft elevation, generous radii.

const LM = {
  c: {
    // neutrals (OmniReach slate)
    ink:      '#0f1720',  // headline ink (slightly cooler slate-900)
    s900:'#111827', s800:'#1f2937', s700:'#374151', s600:'#4b5563',
    s500:'#6b7280', s400:'#9ca3af', s300:'#d1d5db', s200:'#e5e7eb',
    s100:'#f3f4f6', s50:'#f9fafb',
    // teal accent (the live / on-device / AI signal)
    t50:'#f0fdfa', t100:'#ccfbf1', t200:'#99f6e4', t400:'#2dd4bf',
    t500:'#14b8a6', t600:'#0d9488', t700:'#0f766e',
    amber50:'#fffbeb', amber100:'#fef3c7', amber500:'#f59e0b', amber600:'#d97706',
    rose50:'#fff5f7', rose400:'#f43f5e', rose500:'#e11d48',
    white:'#ffffff',
    canvas:'#f6f8f9',           // app canvas — a hair cooler than slate-50
    surface:'#ffffff',
  },
  font: '"Geist", system-ui, -apple-system, sans-serif',
  mono: '"Geist Mono", ui-monospace, SFMono-Regular, Menlo, monospace',
  // layout
  statusH: 56,
  tabH: 78,
  homeH: 30,
  shadow: {
    sm:'0 1px 2px rgba(15,23,32,.05)',
    md:'0 6px 16px -6px rgba(15,23,32,.14), 0 2px 5px -2px rgba(15,23,32,.08)',
    lg:'0 18px 40px -12px rgba(15,23,32,.22), 0 6px 14px -8px rgba(15,23,32,.12)',
    teal:'0 10px 30px -8px rgba(20,184,166,.45)',
  },
};

// ───────────────────────── Icons (24px, 1.75 stroke, round) ─────────────────────────
function Icon({ name, size = 24, stroke = 1.75, color = 'currentColor', fill = 'none', style }) {
  const p = { fill, stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    mic: <g {...p}><rect x="9" y="2.5" width="6" height="11.5" rx="3"/><path d="M5.5 11a6.5 6.5 0 0 0 13 0M12 17.5V21M8.5 21h7"/></g>,
    sparkle: <g {...p}><path d="M12 3l1.6 4.6L18 9l-4.4 1.4L12 15l-1.6-4.6L6 9l4.4-1.4z"/><path d="M18.5 14.5l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7z"/></g>,
    wand: <g {...p}><path d="M15 4l1 2.5L18.5 8 16 9l-1 2.5L14 9l-2.5-1L14 7z"/><path d="M12.5 9.5L4 18l2 2 8.5-8.5"/></g>,
    calendar: <g {...p}><rect x="3.5" y="5" width="17" height="15.5" rx="3"/><path d="M3.5 9.5h17M8 3v4M16 3v4"/></g>,
    clock: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></g>,
    users: <g {...p}><circle cx="9" cy="8.5" r="3.3"/><path d="M3.5 19.5a5.5 5.5 0 0 1 11 0M16 6.2a3.2 3.2 0 0 1 0 6.1M17.5 19.5a5.5 5.5 0 0 0-2.7-4.6"/></g>,
    person: <g {...p}><circle cx="12" cy="8" r="3.6"/><path d="M5 20a7 7 0 0 1 14 0"/></g>,
    share: <g {...p}><path d="M12 15V3M8.5 6.5L12 3l3.5 3.5"/><path d="M6 11.5H5a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-2-2h-1"/></g>,
    send: <g {...p}><path d="M21 3L10.5 13.5M21 3l-6.5 18-4-8-8-4z"/></g>,
    qr: <g {...p}><rect x="3.5" y="3.5" width="6" height="6" rx="1.2"/><rect x="14.5" y="3.5" width="6" height="6" rx="1.2"/><rect x="3.5" y="14.5" width="6" height="6" rx="1.2"/><path d="M14.5 14.5h3v3M20.5 17.5v3M17.5 20.5h-3"/></g>,
    nfc: <g {...p}><path d="M5 8.5c5-3 9-3 14 0M7.5 11.5c3.5-2 5.5-2 9 0M10 14.5c1.5-1 2.5-1 4 0"/></g>,
    shield: <g {...p}><path d="M12 3l7 2.5v5.5c0 4.4-3 8-7 10-4-2-7-5.6-7-10V5.5z"/><path d="M9 12l2 2 4-4"/></g>,
    lock: <g {...p}><rect x="5" y="10.5" width="14" height="9.5" rx="2.4"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5"/></g>,
    check: <g {...p}><path d="M5 12.5l4.5 4.5L19 7"/></g>,
    chevR: <g {...p}><path d="M9 5l7 7-7 7"/></g>,
    chevL: <g {...p}><path d="M15 5l-7 7 7 7"/></g>,
    plus: <g {...p}><path d="M12 5v14M5 12h14"/></g>,
    bell: <g {...p}><path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6M10 20a2 2 0 0 0 4 0"/></g>,
    x: <g {...p}><path d="M6 6l12 12M18 6L6 18"/></g>,
    arrowUR: <g {...p}><path d="M7 17L17 7M8 7h9v9"/></g>,
    link: <g {...p}><path d="M10 13.5a3.5 3.5 0 0 0 5 0l2.5-2.5a3.5 3.5 0 0 0-5-5L11 7.5M14 10.5a3.5 3.5 0 0 0-5 0L6.5 13a3.5 3.5 0 0 0 5 5L13 16.5"/></g>,
    phone: <g {...p}><path d="M6 3.5h3l1.5 4-2 1.5a11 11 0 0 0 5 5l1.5-2 4 1.5v3a2 2 0 0 1-2.2 2A16 16 0 0 1 4 5.7 2 2 0 0 1 6 3.5z"/></g>,
    mail: <g {...p}><rect x="3.5" y="5.5" width="17" height="13" rx="2.5"/><path d="M4 7l8 5.5L20 7"/></g>,
    building: <g {...p}><rect x="5" y="3.5" width="14" height="17" rx="2"/><path d="M9 8h2M9 12h2M13 8h2M13 12h2M9.5 20.5v-4h5v4"/></g>,
    star: <g {...p}><path d="M12 3.5l2.4 5 5.4.6-4 3.7 1.1 5.4L12 15.6 7.1 18.2l1.1-5.4-4-3.7 5.4-.6z"/></g>,
    pencil: <g {...p}><path d="M14.5 5.5l4 4M4 20l1-4L16 5a2 2 0 0 1 3 3L8 19z"/></g>,
    siri: <g {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 7v10M9 9.2v5.6M15 9.2v5.6M6.3 11v2M17.7 11v2"/></g>,
    gift: <g {...p}><rect x="4" y="9" width="16" height="11.5" rx="2"/><path d="M3.5 9h17M12 9v11.5M12 9c-1.2-3.5-5.5-3.5-5 0M12 9c1.2-3.5 5.5-3.5 5 0"/></g>,
    search: <g {...p}><circle cx="11" cy="11" r="6.5"/><path d="M16 16l4 4"/></g>,
    home: <g {...p}><path d="M4 11l8-6.5 8 6.5M6 9.5V20h12V9.5"/></g>,
    thread: <g {...p}><path d="M4.5 6.5h15M4.5 12h10M4.5 17.5h13"/></g>,
    dots: <g {...p}><circle cx="5" cy="12" r="1.3" fill={color} stroke="none"/><circle cx="12" cy="12" r="1.3" fill={color} stroke="none"/><circle cx="19" cy="12" r="1.3" fill={color} stroke="none"/></g>,
    edit: <g {...p}><path d="M4 20l1-4L16 5a2 2 0 0 1 3 3L8 19z"/></g>,
    handshake: <g {...p}><path d="M3 8.5l3-2 4 3 2-1 2 1 4-3 3 2M3 8.5v6l4 4 2-2M21 8.5v6l-4 4-3-3M9 16.5l2 2"/></g>,
    refresh: <g {...p}><path d="M4 12a8 8 0 0 1 13.5-5.8L20 8M20 4v4h-4M20 12a8 8 0 0 1-13.5 5.8L4 16M4 20v-4h4"/></g>,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={style} aria-hidden="true">
      {paths[name] || null}
    </svg>
  );
}

// hub-and-spokes brand mark
function Mark({ size = 26, color = LM.c.t500 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <line x1="12" y1="8.5" x2="12" y2="3"/><line x1="14.84" y1="9.95" x2="19.24" y2="6.76"/>
      <line x1="15.41" y1="12.8" x2="20.49" y2="14"/><line x1="13.88" y1="14.95" x2="17.24" y2="20.24"/>
      <line x1="10.72" y1="15.26" x2="8.76" y2="20.24"/><line x1="8.59" y1="12.8" x2="3.51" y2="14"/>
      <line x1="9.17" y1="9.95" x2="4.76" y2="6.76"/>
      <circle cx="12" cy="3" r="1.5" fill={color}/><circle cx="19.24" cy="6.76" r="1.2"/>
      <circle cx="20.49" cy="14" r="1.5" fill={color}/><circle cx="17.24" cy="20.24" r="1.2"/>
      <circle cx="8.76" cy="20.24" r="1.5" fill={color}/><circle cx="3.51" cy="14" r="1.2"/>
      <circle cx="4.76" cy="6.76" r="1.5" fill={color}/><circle cx="12" cy="12" r="3.5" strokeWidth="1"/>
    </svg>
  );
}

Object.assign(window, { LM, Icon, Mark });
