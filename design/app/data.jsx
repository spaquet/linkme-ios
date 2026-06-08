// LinkMe — shared content. The launch graph: founders + investors + execs who meet each other.

const DATA = {
  user: { name:'Alex Rivera', first:'Alex', role:'Founder & CEO', company:'Pier 9', handle:'alexrivera', email:'alex@pier9.com', tagline:'Building the logistics layer for coastal freight.' },

  people: [
    {
      id:'marcus', name:'Marcus Chen', tone:'teal',
      role:'General Partner', company:'Meridian Ventures',
      met:'Founders Circuit · Battery SF', when:'Today, 3:00 PM',
      lastTouch:'9 days ago', captures:4,
      tags:['Investor','Seed–Series A','AI infra'],
      context:'Closing Meridian’s third fund (~$400M); actively writing seed checks in AI infrastructure this quarter.',
      personal:'Training for the Marin Century ride in October. Two kids at Marin Country Day — coaches their soccer on weekends.',
      openThreads:[
        'Owes you the data-infra thesis memo he mentioned',
        'You offered an intro to Naomi at Cedar Health',
        'Series A timing — he asked to see updated metrics',
      ],
      talkingPoints:[
        'Congratulate on the fund close — announced Tuesday',
        'His portfolio co Hagen is hiring a VP Eng (you know two)',
        'The Tahoe founder offsite he’s hosting in November',
      ],
      shared:['Priya Nair','Daniel Okafor','Sofia Marchetti'],
      followup:'Hey Marcus — great catching up over coffee. Sending the updated metrics deck now; the Q2 retention curve is the part I’d flag. Also happy to make that intro to Naomi at Cedar whenever useful.',
      timeline:[
        { kind:'capture', date:'Today, 3:42 PM', label:'Voice note after coffee', detail:'Closing fund 3, ~$400M. Wants updated metrics. Intro to Naomi.' },
        { kind:'meet', date:'Mar 2', label:'Coffee — Battery SF', detail:'First in-person since the dinner. Talked Series A timing.' },
        { kind:'note', date:'Feb 11', label:'He intro’d you to Sofia (Northwind)', detail:'Warm intro over email.' },
        { kind:'meet', date:'Jan 24', label:'Met at Founders Circuit dinner', detail:'Seed-stage SF founder/investor scene.' },
      ],
    },
    {
      id:'priya', name:'Priya Nair', tone:'indigo',
      role:'Founder & CEO', company:'Loophole AI',
      met:'Founders Circuit dinner', when:'', lastTouch:'3 weeks ago', captures:2,
      tags:['Founder','Series A'],
      context:'Just closed a $14M Series A led by Northwind. Hiring a founding designer.',
      personal:'Runs the Friday founders’ run club in the Presidio.',
      openThreads:['Intro’d you to her Northwind partner','Asked for your design-hire shortlist'],
      talkingPoints:['Congratulate on the Series A','Her run club Friday'],
      shared:['Marcus Chen','Daniel Okafor'],
      followup:'Priya — huge congrats on the round. Sending two designer names today.',
      timeline:[
        { kind:'note', date:'2 weeks ago', label:'News: closed $14M Series A', detail:'Led by Northwind.' },
        { kind:'meet', date:'Jan 24', label:'Founders Circuit dinner', detail:'Seated next to each other.' },
      ],
    },
    {
      id:'daniel', name:'Daniel Okafor', tone:'slate',
      role:'Angel Investor', company:'ex-Stripe',
      met:'Intro from Priya Nair', when:'', lastTouch:'6 days ago', captures:1,
      tags:['Angel','Fintech'],
      context:'Writing $50–100K angel checks; deep payments network from Stripe years.',
      personal:'Collects vinyl; just back from Lagos.',
      openThreads:['No follow-up yet since you met'],
      talkingPoints:['His payments thesis','Ask about the Lagos trip'],
      shared:['Priya Nair','Marcus Chen'],
      followup:'Daniel — great to finally meet. Would love to keep the payments conversation going.',
      timeline:[
        { kind:'meet', date:'6 days ago', label:'Coffee — Sightglass', detail:'Intro from Priya.' },
      ],
    },
    {
      id:'sofia', name:'Sofia Marchetti', tone:'rose',
      role:'Partner', company:'Northwind',
      met:'Intro from Marcus Chen', when:'Today, 4:30 PM', lastTouch:'1 week ago', captures:2,
      tags:['Investor','Series A–B'],
      context:'Leads enterprise infra at Northwind; led Priya’s round.',
      personal:'Sails out of Sausalito most weekends.',
      openThreads:['Partner sync today at 4:30','Diligence questions on your pipeline'],
      talkingPoints:['Her Priya investment','Sailing season'],
      shared:['Marcus Chen','Priya Nair'],
      followup:'Sofia — looking forward to the sync at 4:30. I’ll bring the pipeline breakdown.',
      timeline:[
        { kind:'note', date:'1 week ago', label:'Email — scheduled partner sync', detail:'' },
        { kind:'note', date:'Feb 11', label:'Marcus intro’d you', detail:'' },
      ],
    },
    {
      id:'james', name:'James Whitfield', tone:'sky',
      role:'CFO', company:'Aperture',
      met:'SaaStr afterparty', when:'', lastTouch:'1 month ago', captures:1,
      tags:['Exec','Buyer'],
      context:'Evaluating tools for a 40-person revenue org; budget cycle in Q3.',
      personal:'Marathoner — Chicago in the fall.',
      openThreads:['Wants a pilot proposal'],
      talkingPoints:['His Q3 budget cycle','Chicago marathon'],
      shared:['Sofia Marchetti'],
      followup:'James — putting together that pilot proposal. Sending this week.',
      timeline:[
        { kind:'meet', date:'1 month ago', label:'SaaStr afterparty', detail:'' },
      ],
    },
    {
      id:'naomi', name:'Naomi Brooks', tone:'amber',
      role:'Founder', company:'Cedar Health',
      met:'You intro’d via Marcus', when:'', lastTouch:'2 days ago', captures:1,
      tags:['Founder','Healthtech'],
      context:'Raising a seed for clinician-facing AI; warm to Meridian.',
      personal:'Former ER physician.',
      openThreads:['Wants the intro to Marcus you offered'],
      talkingPoints:['Her seed raise','Meridian fit'],
      shared:['Marcus Chen'],
      followup:'Naomi — connecting you with Marcus at Meridian now. You’ll like each other.',
      timeline:[
        { kind:'note', date:'2 days ago', label:'You offered the Marcus intro', detail:'' },
      ],
    },
  ],

  meetings: [
    { id:'m1', time:'3:00 PM', title:'Coffee with Marcus Chen', where:'Battery SF', person:'marcus', soon:true },
    { id:'m2', time:'4:30 PM', title:'Northwind partner sync', where:'Sansome St', person:'sofia' },
    { id:'m3', time:'6:30 PM', title:'Founders Circuit dinner', where:'Private — Jackson Sq', person:null, scene:true },
  ],

  nudges: [
    { id:'n1', kind:'followup', person:'daniel', title:'Follow up with Daniel Okafor', detail:'You met 6 days ago and haven’t followed up. Reciprocity window is closing.', cta:'Draft follow-up' },
    { id:'n2', kind:'signal', person:'priya', title:'Priya Nair closed a Series A', detail:'Public signal picked up 2 weeks ago. A congrats note compounds the relationship.', cta:'Congratulate' },
    { id:'n3', kind:'promise', person:'naomi', title:'You promised Naomi an intro', detail:'You offered to connect Naomi to Marcus 2 days ago. Marcus is warm to it.', cta:'Make the intro' },
  ],
};

function getPerson(id){ return DATA.people.find(p=>p.id===id); }

Object.assign(window, { DATA, getPerson });
