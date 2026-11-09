// Orijinal ses efektleri (PCM -> WAV) ve orijinal MIDI müzikleri.
// MIDI dosyaları tarayıcıda küçük bir sentezleyiciyle çalınır.
'use strict';

const SFX = (() => {
  let ac = null, master = null, sfxGain = null, musGain = null;
  const bufs = new Map(), opt = { sfx: true, music: true };
  try { Object.assign(opt, JSON.parse(localStorage.getItem('anrufen_audio') || '{}')); } catch (e) { }
  function saveOpt() { try { localStorage.setItem('anrufen_audio', JSON.stringify(opt)); } catch (e) { } }

  function init() {
    if (ac) { if (ac.state === 'suspended') ac.resume(); return; }
    const AC = window.AudioContext || window.webkitAudioContext; if (!AC) return;
    ac = new AC(); master = ac.createGain(); master.connect(ac.destination);
    sfxGain = ac.createGain(); sfxGain.gain.value = 0.7; sfxGain.connect(master);
    musGain = ac.createGain(); musGain.gain.value = 0.32; musGain.connect(master);
    if (Music.pending) Music.play(Music.pending);
  }
  async function load(name) {
    if (bufs.has(name)) return bufs.get(name);
    const pr = fetch(`assets/snd/${name}.wav`).then(r => r.arrayBuffer()).then(a => new Promise((res, rej) => ac.decodeAudioData(a, res, rej))).catch(() => null);
    bufs.set(name, pr); return pr;
  }
  const lastAt = {};
  function play(name, vol = 1) {
    if (!ac || !opt.sfx || !name) return;
    const now = ac.currentTime; if (lastAt[name] && now - lastAt[name] < 0.06) return; lastAt[name] = now;
    load(name).then(b => { if (!b) return; const s = ac.createBufferSource(); s.buffer = b; const g = ac.createGain(); g.gain.value = vol; s.connect(g); g.connect(sfxGain); s.start(); });
  }

  // ---------------- MIDI ----------------
  function parseMidi(buf) {
    const d = new DataView(buf); let p = 14; const ntr = d.getUint16(10), div = d.getUint16(12), ev = [];
    for (let tr = 0; tr < ntr && p < d.byteLength; tr++) {
      const len = d.getUint32(p + 4); let i = p + 8; const end = i + len; p = end; let tick = 0, rs = 0;
      const vlq = () => { let v = 0, b; do { b = d.getUint8(i++); v = (v << 7) | (b & 127); } while (b & 128); return v; };
      while (i < end) {
        tick += vlq(); let st = d.getUint8(i); if (st & 128) { i++; if (st < 0xf0) rs = st; } else st = rs;
        if (st === 0xff) { const ty = d.getUint8(i++), l = vlq(); if (ty === 0x51) ev.push({ tick, tempo: (d.getUint8(i) << 16) | (d.getUint8(i + 1) << 8) | d.getUint8(i + 2) }); i += l; }
        else if (st === 0xf0 || st === 0xf7) { i += vlq(); }
        else {
          const hi = st >> 4, ch = st & 15, a = d.getUint8(i++), b = (hi === 12 || hi === 13) ? 0 : d.getUint8(i++);
          if (hi === 9 && b > 0) ev.push({ tick, on: 1, ch, n: a, v: b });
          else if (hi === 8 || hi === 9) ev.push({ tick, off: 1, ch, n: a });
          else if (hi === 12) ev.push({ tick, prog: a, ch });
        }
      }
    }
    ev.sort((x, y) => x.tick - y.tick);
    // tikleri saniyeye çevir, notaları sürelendir
    let tempo = 500000, lt = 0, sec = 0; const notes = [], open = {}, prog = {};
    for (const e of ev) {
      sec += (e.tick - lt) * tempo / 1e6 / div; lt = e.tick;
      if (e.tempo) tempo = e.tempo;
      else if (e.prog != null) prog[e.ch] = e.prog;
      else if (e.on) { const k = e.ch + '_' + e.n; if (open[k]) open[k].d = sec - open[k].t; open[k] = { t: sec, n: e.n, v: e.v, ch: e.ch, p: prog[e.ch] || 0, d: 0.4 }; notes.push(open[k]); }
      else if (e.off) { const k = e.ch + '_' + e.n; if (open[k]) { open[k].d = Math.max(0.05, sec - open[k].t); delete open[k]; } }
    }
    return { notes, len: sec };
  }
  let noiseBuf = null;
  function noise() { if (!noiseBuf) { noiseBuf = ac.createBuffer(1, ac.sampleRate * 0.5, ac.sampleRate); const a = noiseBuf.getChannelData(0); for (let i = 0; i < a.length; i++) a[i] = Math.random() * 2 - 1; } return noiseBuf; }
  function voice(n, at) {
    const f = 440 * Math.pow(2, (n.n - 69) / 12), v = (n.v / 127) * 0.22, g = ac.createGain(); g.connect(musGain);
    if (n.ch === 9) { // davul
      const kick = n.n <= 36, s = kick ? ac.createOscillator() : ac.createBufferSource();
      if (kick) { s.frequency.setValueAtTime(140, at); s.frequency.exponentialRampToValueAtTime(45, at + 0.12); } else { s.buffer = noise(); }
      const fl = ac.createBiquadFilter(); fl.type = kick ? 'lowpass' : (n.n >= 42 ? 'highpass' : 'bandpass'); fl.frequency.value = kick ? 300 : (n.n >= 42 ? 6000 : 1800);
      s.connect(fl); fl.connect(g); g.gain.setValueAtTime(v * (kick ? 2.2 : 1), at); g.gain.exponentialRampToValueAtTime(0.001, at + (kick ? 0.2 : n.n >= 49 ? 0.4 : 0.1)); s.start(at); s.stop(at + 0.45); return;
    }
    const o = ac.createOscillator(), fl = ac.createBiquadFilter(); fl.type = 'lowpass'; o.frequency.value = f; o.connect(fl); fl.connect(g);
    const p = n.p; let rel = 0.15;
    if (p >= 40 && p <= 55 && p !== 45 && p !== 46 && p !== 47 || (p >= 88 && p <= 95)) { // yaylılar, pad: yavaş giriş
      o.type = 'sawtooth'; fl.frequency.value = Math.min(4000, f * 3 + 500); const o2 = ac.createOscillator(); o2.type = 'sawtooth'; o2.frequency.value = f * 1.004; o2.connect(fl); o2.start(at); o2.stop(at + n.d + 0.4);
      g.gain.setValueAtTime(0.0001, at); g.gain.linearRampToValueAtTime(v * 0.5, at + 0.09); g.gain.setValueAtTime(v * 0.5, at + Math.max(0.1, n.d)); rel = 0.3;
    } else if (p === 47) { // timpani
      o.type = 'sine'; fl.frequency.value = 800; g.gain.setValueAtTime(v * 2.2, at); g.gain.exponentialRampToValueAtTime(0.001, at + 0.7); o.start(at); o.stop(at + 0.75); return;
    } else if (p === 46 || p === 45 || p < 32 || (p >= 104 && p <= 111)) { // arp, piyano, gitar: çekilen tel
      o.type = 'triangle'; fl.frequency.value = Math.min(6000, f * 5); g.gain.setValueAtTime(v * 1.3, at); g.gain.exponentialRampToValueAtTime(v * 0.25, at + 0.35); g.gain.exponentialRampToValueAtTime(0.001, at + Math.max(0.5, n.d + 0.6)); o.start(at); o.stop(at + Math.max(0.5, n.d + 0.6)); return;
    } else if (p >= 32 && p < 40) { o.type = 'triangle'; fl.frequency.value = 900; g.gain.setValueAtTime(v * 1.6, at); g.gain.setValueAtTime(v * 1.6, at + n.d); }
    else { // üflemeliler vb.
      o.type = (p >= 56 && p < 72) ? 'square' : 'triangle'; fl.frequency.value = Math.min(5000, f * 4); g.gain.setValueAtTime(0.0001, at); g.gain.linearRampToValueAtTime(v * (o.type === 'square' ? 0.45 : 1), at + 0.03); g.gain.setValueAtTime(v * (o.type === 'square' ? 0.45 : 1), at + n.d);
    }
    g.gain.exponentialRampToValueAtTime(0.001, at + n.d + rel); o.start(at); o.stop(at + n.d + rel + 0.05);
  }
  const songs = new Map();
  const Music = {
    cur: null, pending: null, song: null, t0: 0, idx: 0, timer: null,
    async play(name) {
      if (!name) return; this.pending = name;
      if (!ac || !opt.music) return;
      if (this.cur === name && this.timer) return;
      this.stop(true); this.cur = name;
      if (!songs.has(name)) songs.set(name, fetch('assets/music/' + name).then(r => r.arrayBuffer()).then(parseMidi).catch(() => null));
      const s = await songs.get(name); if (!s || this.cur !== name || this.timer) return;
      this.song = s; this.t0 = ac.currentTime + 0.15; this.idx = 0;
      musGain.gain.cancelScheduledValues(ac.currentTime); musGain.gain.setValueAtTime(0.32, ac.currentTime);
      this.timer = setInterval(() => this.tick(), 100); this.tick();
    },
    tick() {
      const s = this.song; if (!s || !ac) return; const horizon = ac.currentTime + 0.35;
      for (let guard = 0; guard < 400; guard++) {
        if (this.idx >= s.notes.length) { this.t0 += s.len + 0.6; this.idx = 0; if (this.t0 > horizon) break; }
        const n = s.notes[this.idx], at = this.t0 + n.t; if (at > horizon) break;
        if (at > ac.currentTime - 0.05) voice(n, Math.max(at, ac.currentTime)); this.idx++;
      }
    },
    stop(keep) { if (this.timer) { clearInterval(this.timer); this.timer = null; } if (ac && musGain) { musGain.gain.cancelScheduledValues(ac.currentTime); musGain.gain.setTargetAtTime(0.0001, ac.currentTime, 0.08); } if (!keep) this.cur = null; else this.cur = null; },
  };
  document.addEventListener('visibilitychange', () => { if (!ac) return; if (document.hidden) ac.suspend(); else ac.resume(); });
  addEventListener('pointerdown', init, { capture: true });
  addEventListener('keydown', init, { capture: true });
  // menü ve düğme sesleri
  addEventListener('click', e => { if (e.target.closest && e.target.closest('button')) play('menusel', 0.6); }, { capture: true });
  return {
    init, play, Music, opt,
    setSfx(on) { opt.sfx = on; saveOpt(); },
    setMusic(on) { opt.music = on; saveOpt(); if (!on) Music.stop(); else Music.play(Music.pending); },
  };
})();
window.SFX = SFX;
