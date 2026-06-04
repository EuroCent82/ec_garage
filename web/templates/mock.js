/** Gemeinsame Demo-Daten für UI-Vorlagen (nur Browser-Preview) */
window.EC_TEMPLATE_MOCK = [
  { id: 1, category: 'land', plate: 'LS 4821', model: 'Pfister Comet S2', modelKey: 'comet6', customName: 'Mein Daily', note: 'Vollgetankt', status: 'parked', favorite: true, fuel: 87, body: 94, engine: 98, mileage: 12450 },
  { id: 2, category: 'land', plate: 'LS 9103', model: 'Benefactor Schafter V12', modelKey: 'schafter3', customName: 'Business Limo', note: '', status: 'parked', favorite: false, fuel: 42, body: 78, engine: 85, mileage: 45200 },
  { id: 3, category: 'land', plate: 'LS 7734', model: 'Vapid Dominator GTX', modelKey: 'dominator3', customName: 'Rennstrecke', note: 'Nur Events', status: 'parked', favorite: true, fuel: 100, body: 100, engine: 100, mileage: 890 },
  { id: 4, category: 'land', plate: 'LS 2209', model: 'Obey 8F Drafter', modelKey: 'drafter', customName: null, note: '', status: 'out', favorite: false, fuel: 23, body: 65, engine: 72, mileage: 28900 },
  { id: 5, category: 'land', plate: 'LS 5512', model: 'Karin Sultan RS', modelKey: 'sultanrs', customName: 'Drift King', note: 'Mirror Park', status: 'out', favorite: true, fuel: 56, body: 88, engine: 91, mileage: 67300 },
  { id: 10, category: 'air', plate: 'AIR 001', model: 'Buckingham Volatus', modelKey: 'volatus', customName: 'VIP Heli', note: '', status: 'parked', favorite: true, fuel: 95, body: 100, engine: 97, mileage: 4200 },
  { id: 11, category: 'air', plate: 'AIR 772', model: 'Western Maverick', modelKey: 'maverick', customName: null, note: '', status: 'parked', favorite: false, fuel: 68, body: 82, engine: 88, mileage: 18700 },
  { id: 20, category: 'water', plate: 'SEA 007', model: 'Pegassi Speeder', modelKey: 'speeder', customName: 'Weekend Boot', note: '', status: 'parked', favorite: true, fuel: 78, body: 90, engine: 92, mileage: 1240 },
  { id: 21, category: 'water', plate: 'SEA 412', model: 'Nagasaki Dinghy', modelKey: 'dinghy', customName: null, note: 'Beiboot', status: 'out', favorite: false, fuel: 100, body: 100, engine: 100, mileage: 85 },
];

window.EC_TEMPLATE = {
  displayName(v) {
    return v.customName || v.model;
  },
  formatKm(n) {
    return (n ?? 0).toLocaleString('de-DE') + ' km';
  },
  statusLabel(v) {
    if (v.status === 'parked') return 'Eingeparkt';
    if (v.status === 'out') return 'Ausgeparkt';
    return v.status;
  },
  catIcon(cat) {
    const m = { land: 'fa-car-side', air: 'fa-helicopter', water: 'fa-ship' };
    return `<i class="fa-solid ${m[cat] || m.land}"></i>`;
  },
  statBars(v) {
    const rows = [
      ['Tank', v.fuel, 'fuel'],
      ['Karosserie', v.body, 'body'],
      ['Motor', v.engine, 'engine'],
    ];
    return rows.map(([label, val, cls]) => `
      <div class="t-stat" data-label="${label}">
        <span class="t-stat__label">${label}</span>
        <div class="t-stat__track"><div class="t-stat__fill t-stat__fill--${cls}" style="width:${val}%"></div></div>
        <span class="t-stat__pct">${val}%</span>
      </div>`).join('');
  },
  filter(list, { tab, q, favoritesOnly }) {
    let out = list.filter((v) => v.category === tab);
    if (favoritesOnly) out = out.filter((v) => v.favorite);
    const s = (q || '').trim().toLowerCase();
    if (s) {
      out = out.filter((v) =>
        [v.plate, v.model, v.customName, v.modelKey, v.note].some((x) =>
          String(x || '').toLowerCase().includes(s)
        )
      );
    }
    return out;
  },
};
