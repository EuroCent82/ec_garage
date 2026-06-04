/**
 * EC Garage – UI Preview
 * 4 UI-Modi: Land, Luft, Wasser, Abschlepphof (Übersicht)
 */

const UI_MODES = {
  land: {
    title: 'Legion Square Garage',
    subtitle: 'Landfahrzeuge',
    accent: '#3b82f6',
    footerHint: '<kbd>E</kbd> Einparken &nbsp;·&nbsp; <kbd>ESC</kbd> Schließen',
    icon: VEHICLE_ICONS.land,
    emptyIcon: VEHICLE_ICONS.land,
  },
  air: {
    title: 'LSIA Hangar',
    subtitle: 'Luftfahrzeuge',
    accent: '#a78bfa',
    footerHint: '<kbd>E</kbd> Einparken &nbsp;·&nbsp; <kbd>ESC</kbd> Schließen',
    icon: VEHICLE_ICONS.air,
    emptyIcon: VEHICLE_ICONS.air,
  },
  water: {
    title: 'La Puerta Marina',
    subtitle: 'Wasserfahrzeuge',
    accent: '#06b6d4',
    footerHint: '<kbd>E</kbd> Einparken &nbsp;·&nbsp; <kbd>ESC</kbd> Schließen',
    icon: VEHICLE_ICONS.water,
    emptyIcon: VEHICLE_ICONS.water,
  },
  impound: {
    title: 'Abschlepphof Übersicht',
    subtitle: 'Beschlagnahmte Fahrzeuge',
    accent: '#f59e0b',
    footerHint: 'Freikauf nur am jeweiligen <strong>Standort</strong> möglich &nbsp;·&nbsp; <kbd>ESC</kbd> Schließen',
    icon: ICONS.warning(),
    emptyIcon: ICONS.warning(),
  },
};

const MOCK_VEHICLES = [
  // ── Land ──
  { id: 1, category: 'land', plate: 'LS 4821', model: 'Pfister Comet S2', modelKey: 'comet6', customName: 'Mein Daily', note: 'Vollgetankt, Reifen neu', status: 'parked', favorite: true, fuel: 87, body: 94, engine: 98, mileage: 12450 },
  { id: 2, category: 'land', plate: 'LS 9103', model: 'Benefactor Schafter V12', modelKey: 'schafter3', customName: 'Business Limo', note: '', status: 'parked', favorite: false, fuel: 42, body: 78, engine: 85, mileage: 45200 },
  { id: 3, category: 'land', plate: 'LS 7734', model: 'Vapid Dominator GTX', modelKey: 'dominator3', customName: 'Rennstrecke', note: 'Nur für Events', status: 'parked', favorite: true, fuel: 100, body: 100, engine: 100, mileage: 890 },
  { id: 4, category: 'land', plate: 'LS 2209', model: 'Obey 8F Drafter', modelKey: 'drafter', customName: null, note: '', status: 'out', favorite: false, fuel: 23, body: 65, engine: 72, mileage: 28900 },
  { id: 5, category: 'land', plate: 'LS 5512', model: 'Karin Sultan RS', modelKey: 'sultanrs', customName: 'Drift King', note: 'Steht am Mirror Park', status: 'out', favorite: true, fuel: 56, body: 88, engine: 91, mileage: 67300 },

  // ── Luft ──
  { id: 10, category: 'air', plate: 'AIR 001', model: 'Buckingham Volatus', modelKey: 'volatus', customName: 'VIP Heli', note: 'Hangar LSIA Nord', status: 'parked', favorite: true, fuel: 95, body: 100, engine: 97, mileage: 4200 },
  { id: 11, category: 'air', plate: 'AIR 772', model: 'Western Company Maverick', modelKey: 'maverick', customName: null, note: '', status: 'parked', favorite: false, fuel: 68, body: 82, engine: 88, mileage: 18700 },
  { id: 12, category: 'air', plate: 'AIR 330', model: 'Buckingham Luxor', modelKey: 'luxor', customName: 'Firmenjet', note: 'Letzter Flug: Sandy Shores', status: 'out', favorite: false, fuel: 31, body: 91, engine: 94, mileage: 89000 },

  // ── Wasser ──
  { id: 20, category: 'water', plate: 'SEA 007', model: 'Pegassi Speeder', modelKey: 'speeder', customName: 'Weekend Boot', note: '', status: 'parked', favorite: true, fuel: 78, body: 90, engine: 92, mileage: 1240 },
  { id: 21, category: 'water', plate: 'SEA 412', model: 'Nagasaki Dinghy', modelKey: 'dinghy', customName: null, note: 'Kleines Beiboot', status: 'parked', favorite: false, fuel: 100, body: 100, engine: 100, mileage: 85 },
  { id: 22, category: 'water', plate: 'SEA 889', model: 'Shitzu Jetmax', modelKey: 'jetmax', customName: 'Speed Demon', note: 'Vor Vespucci Beach', status: 'out', favorite: true, fuel: 44, body: 73, engine: 80, mileage: 5600 },

  // ── Impound (eigene UI – nur Standort-Übersicht) ──
  { id: 30, category: 'land', plate: 'LS 0088', model: 'Declasse Vigero ZX', modelKey: 'vigero2', customName: 'Muscle Baby', note: '', status: 'impound', favorite: false, fuel: 12, body: 45, engine: 38, mileage: 156000, impoundLot: 'lsia', impoundLotName: 'LSIA Abschlepphof', impoundFee: 2500 },
  { id: 31, category: 'land', plate: 'LS 3344', model: 'Bravado Banshee', modelKey: 'banshee', customName: null, note: 'Polizei-Beschlagnahme', status: 'impound', favorite: false, fuel: 0, body: 22, engine: 15, mileage: 89000, impoundLot: 'sandy', impoundLotName: 'Sandy Shores LSPD Impound', impoundFee: 5000 },
  { id: 32, category: 'air', plate: 'AIR 999', model: 'Western Company Cargobob', modelKey: 'cargobob', customName: 'Fracht-Heli', note: '', status: 'impound', favorite: false, fuel: 8, body: 55, engine: 40, mileage: 34000, impoundLot: 'fort_zancudo', impoundLotName: 'Fort Zancudo Militär-Impound', impoundFee: 12000 },
  { id: 33, category: 'water', plate: 'SEA 001', model: 'Dinka Marquis', modelKey: 'marquis', customName: 'Yacht Tender', note: '', status: 'impound', favorite: false, fuel: 20, body: 60, engine: 50, mileage: 320, impoundLot: 'paleto', impoundLotName: 'Paleto Bay Hafen-Impound', impoundFee: 1800 },
];

const IMPOUND_LOTS = [
  { id: 'lsia', name: 'LSIA Abschlepphof' },
  { id: 'sandy', name: 'Sandy Shores LSPD Impound' },
  { id: 'fort_zancudo', name: 'Fort Zancudo Militär-Impound' },
  { id: 'paleto', name: 'Paleto Bay Hafen-Impound' },
];

const isGameNui = window.EC_NUI?.isEmbed || typeof GetParentResourceName === 'function';

const state = {
  vehicles: isGameNui ? [] : [...MOCK_VEHICLES],
  uiMode: 'land',
  activeTab: 'parked',
  filter: 'all',
  search: '',
  lotFilter: 'all',
  renameTargetId: null,
};

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => document.querySelectorAll(sel);

const TAB_LABELS = {
  parked: { title: 'Keine Fahrzeuge in dieser Garage', text: 'Du hast hier nichts eingeparkt.' },
  out: { title: 'Keine ausgeparkten Fahrzeuge', text: 'Kein Fahrzeug dieser Garage ist gerade draußen.' },
};

const CATEGORY_LABELS = { land: 'Land', air: 'Luft', water: 'Wasser' };

function formatMileage(km) {
  return km.toLocaleString('de-DE') + ' km';
}

function formatMoney(amount) {
  return '$' + amount.toLocaleString('de-DE');
}

function getBarClass(value) {
  if (value <= 30) return 'low';
  if (value <= 60) return 'mid';
  return '';
}

function getDisplayName(v) {
  return v.customName || v.model;
}

function isImpoundMode() {
  return state.uiMode === 'impound';
}

function garageVehicles() {
  return state.vehicles.filter((v) => v.category === state.uiMode && v.status !== 'impound');
}

function impoundVehicles() {
  return state.vehicles.filter((v) => v.status === 'impound');
}

function filteredVehicles() {
  const pool = isImpoundMode() ? impoundVehicles() : garageVehicles().filter((v) => v.status === state.activeTab);

  return pool.filter((v) => {
    if (!isImpoundMode() && state.filter === 'favorites' && !v.favorite) return false;
    if (isImpoundMode() && state.lotFilter !== 'all' && v.impoundLot !== state.lotFilter) return false;

    if (state.search) {
      const q = state.search.toLowerCase();
      const haystack = [
        getDisplayName(v),
        v.model,
        v.plate,
        v.note,
        v.impoundLotName,
        CATEGORY_LABELS[v.category],
      ].filter(Boolean).join(' ').toLowerCase();
      if (!haystack.includes(q)) return false;
    }
    return true;
  });
}

function updateHeader() {
  const cfg = UI_MODES[state.uiMode];
  const app = $('#app');

  app.dataset.mode = state.uiMode;
  app.style.setProperty('--mode-accent', cfg.accent);
  $('#brand-icon').innerHTML = cfg.icon;
  $('#brand-title').textContent = cfg.title;
  $('#brand-subtitle').textContent = cfg.subtitle;
  $('#footer-hint').innerHTML = cfg.footerHint;

  $('#toolbar-garage').classList.toggle('hidden', isImpoundMode());
  $('#toolbar-impound').classList.toggle('hidden', !isImpoundMode());

  renderHeaderStats();
}

function renderHeaderStats() {
  const el = $('#header-stats');

  if (isImpoundMode()) {
    const impounded = impoundVehicles();
    const lots = new Set(impounded.map((v) => v.impoundLot)).size;
    const totalFees = impounded.reduce((s, v) => s + (v.impoundFee || 0), 0);

    el.innerHTML = `
      <div class="stat-pill stat-pill--warn">
        <span class="stat-value">${impounded.length}</span>
        <span class="stat-label">Beschlagnahmt</span>
      </div>
      <div class="stat-pill">
        <span class="stat-value">${lots}</span>
        <span class="stat-label">Standorte</span>
      </div>
      <div class="stat-pill">
        <span class="stat-value">${formatMoney(totalFees)}</span>
        <span class="stat-label">Gesamtgebühren</span>
      </div>`;
    return;
  }

  const pool = garageVehicles();
  el.innerHTML = `
    <div class="stat-pill">
      <span class="stat-value">${pool.filter((v) => v.status === 'parked').length}</span>
      <span class="stat-label">Eingeparkt</span>
    </div>
    <div class="stat-pill">
      <span class="stat-value">${pool.filter((v) => v.status === 'out').length}</span>
      <span class="stat-label">Ausgeparkt</span>
    </div>
    <div class="stat-pill stat-pill--warn">
      <span class="stat-value">${impoundVehicles().length}</span>
      <span class="stat-label">Impound</span>
    </div>`;
}

function statBar(label, value, barClass, index) {
  const cls = getBarClass(value);
  return `
    <div class="stat-row" style="--stat-index:${index}">
      ${STAT_ICONS[label]}
      <div class="stat-info">
        <div class="stat-label-row">
          <span class="stat-name">${label}</span>
          <span class="stat-percent">${value}%</span>
        </div>
        <div class="stat-bar">
          <div class="stat-bar-fill stat-bar-fill--${barClass} ${cls}" style="--bar-width:${value}%;--stat-index:${index}"></div>
        </div>
      </div>
    </div>`;
}

function renderCardImage(v, displayName, badgeHtml) {
  return `
    <div class="card-image-wrap">
      ${vehicleCardImageHtml(v)}
      <div class="card-image-shine"></div>
      ${badgeHtml}
      <button class="btn-favorite ${v.favorite ? 'active' : ''}" data-action="favorite" data-id="${v.id}" title="Favorit">
        ${ICONS.star(v.favorite)}
      </button>
    </div>`;
}

function renderGarageCard(v) {
  const displayName = getDisplayName(v);
  const badge = `<span class="card-badge card-badge--${v.status}">${v.status === 'parked' ? 'Eingeparkt' : 'Ausgeparkt'}</span>`;

  const renameBtn = `
    <button class="btn btn-ghost btn-icon-only" data-action="rename" data-id="${v.id}" title="Umbenennen">
      ${ICONS.pen()}
    </button>`;

  const actions = v.status === 'parked'
    ? `<button class="btn btn-primary" data-action="spawn" data-id="${v.id}">
         ${ICONS.arrowRight()} Ausparken
       </button>${renameBtn}`
    : `<button class="btn btn-success" data-action="locate" data-id="${v.id}">
         ${ICONS.mapPin()} Orten
       </button>${renameBtn}`;

  return `
    <article class="vehicle-card ${v.favorite ? 'is-favorite' : ''}" data-id="${v.id}">
      ${renderCardImage(v, displayName, badge)}
      <div class="card-body">
        <div class="card-info-block">
          <div class="card-title-row">
            <div class="card-names">
              <div class="card-name">${displayName}</div>
              <div class="card-model${v.customName ? '' : ' card-model--empty'}">${v.customName ? v.model : '\u00A0'}</div>
            </div>
            <span class="card-plate">${v.plate}</span>
          </div>
          <div class="card-note-slot${v.note ? ' has-content' : ''}">
            <div class="card-note">${v.note || '\u00A0'}</div>
          </div>
        </div>
        <div class="card-details-block">
          <div class="card-stats">
            ${statBar('Tank', v.fuel, 'fuel', 0)}
            ${statBar('Karosserie', v.body, 'body', 1)}
            ${statBar('Motor', v.engine, 'engine', 2)}
          </div>
          <div class="card-mileage">
            ${ICONS.mileage()}
            <span>Kilometerstand: <strong>${formatMileage(v.mileage)}</strong></span>
          </div>
        </div>
        <div class="card-actions">${actions}</div>
      </div>
    </article>`;
}

function renderImpoundCard(v) {
  const displayName = getDisplayName(v);
  const catLabel = CATEGORY_LABELS[v.category] || 'Fahrzeug';
  const badge = `<span class="card-badge card-badge--impound">Impound</span>`;

  return `
    <article class="vehicle-card vehicle-card--impound" data-id="${v.id}">
      ${renderCardImage(v, displayName, badge)}
      <div class="card-body">
        <div class="card-info-block">
          <div class="card-title-row">
            <div class="card-names">
              <div class="card-name">${displayName}</div>
              <div class="card-model">${v.model}</div>
            </div>
            <span class="card-plate">${v.plate}</span>
          </div>
          <div class="card-category-tag">${catLabel}-Fahrzeug</div>
          <div class="card-impound-location">
            ${ICONS.mapPin()}
            <div>
              <span class="impound-location-label">Standort</span>
              <span class="impound-location-name">${v.impoundLotName}</span>
            </div>
          </div>
          <div class="card-note-slot${v.note ? ' has-content' : ''}">
            <div class="card-note">${v.note || '\u00A0'}</div>
          </div>
          <div class="impound-fee">
            <span>Freikaufgebühr</span>
            <strong>${formatMoney(v.impoundFee)}</strong>
          </div>
        </div>
        <div class="card-details-block">
          <div class="card-stats">
            ${statBar('Tank', v.fuel, 'fuel', 0)}
            ${statBar('Karosserie', v.body, 'body', 1)}
            ${statBar('Motor', v.engine, 'engine', 2)}
          </div>
          <div class="card-mileage">
            ${ICONS.mileage()}
            <span>Kilometerstand: <strong>${formatMileage(v.mileage)}</strong></span>
          </div>
        </div>
        <div class="card-actions">
          <button class="btn btn-warning" data-action="mark-lot" data-id="${v.id}">
            ${ICONS.mapMarked()} Standort markieren
          </button>
        </div>
      </div>
    </article>`;
}

function render() {
  const list = filteredVehicles();
  const grid = $('#vehicle-grid');
  const empty = $('#empty-state');
  const cfg = UI_MODES[state.uiMode];

  updateHeader();
  $('#empty-icon').innerHTML = cfg.emptyIcon;

  if (list.length === 0) {
    grid.innerHTML = '';
    empty.classList.remove('hidden');

    if (isImpoundMode()) {
      $('#empty-title').textContent = 'Keine Fahrzeuge beschlagnahmt';
      $('#empty-text').textContent = 'Du hast derzeit keine Fahrzeuge auf Abschlepphöfen.';
    } else {
      const labels = TAB_LABELS[state.activeTab];
      $('#empty-title').textContent = labels.title;
      $('#empty-text').textContent = labels.text;
    }
  } else {
    empty.classList.add('hidden');
    grid.className = `vehicle-grid vehicle-grid--${state.uiMode}${isImpoundMode() ? ' vehicle-grid--impound' : ` vehicle-grid--${state.activeTab}`}`;
    grid.innerHTML = list.map((v) => isImpoundMode() ? renderImpoundCard(v) : renderGarageCard(v)).join('');
    initCardHoverEffects();
  }
}

function initCardHoverEffects() {
  $$('.vehicle-card').forEach((card) => {
    card.onmousemove = (e) => {
      const rect = card.getBoundingClientRect();
      card.style.setProperty('--mouse-x', `${((e.clientX - rect.left) / rect.width) * 100}%`);
      card.style.setProperty('--mouse-y', `${((e.clientY - rect.top) / rect.height) * 100}%`);
    };
  });
}

function populateLotFilter() {
  const select = $('#lot-filter');
  select.innerHTML = '<option value="all">Alle Standorte</option>' +
    IMPOUND_LOTS.map((l) => `<option value="${l.id}">${l.name}</option>`).join('');
}

function setUiMode(mode) {
  state.uiMode = mode;
  state.activeTab = 'parked';
  state.filter = 'all';
  state.lotFilter = 'all';
  state.search = '';
  $('#search-input').value = '';
  $('#search-input-impound').value = '';
  $('#lot-filter').value = 'all';

  $$('.preview-btn').forEach((b) => b.classList.toggle('active', b.dataset.mode === mode));
  $$('#toolbar-garage .tab').forEach((t) => t.classList.toggle('active', t.dataset.tab === 'parked'));
  $$('#toolbar-garage .filter-btn').forEach((b) => b.classList.toggle('active', b.dataset.filter === 'all'));

  render();
}

let toastTimer;
function showToast(message, type = 'info') {
  const toast = $('#toast');
  $('#toast-message').textContent = message;
  toast.className = `toast ${type}`;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.add('hidden'), 2800);
}

function openGarage(mode, garageName) {
  if (mode) setUiMode(mode);
  if (garageName && UI_MODES[state.uiMode]) {
    UI_MODES[state.uiMode].title = garageName;
    $('#brand-title').textContent = garageName;
  }
  $('#app').classList.remove('hidden');
  render();
}

function closeGarage() {
  $('#app').classList.add('hidden');
  closeRenameModal();
  if (window.EC_NUI?.isEmbed) {
    window.parent.postMessage({ action: 'nuiClose', screen: 'garage' }, '*');
  }
}

function openRenameModal(id) {
  const v = state.vehicles.find((x) => x.id === id);
  if (!v) return;
  state.renameTargetId = id;
  $('#rename-model').textContent = v.model + ' · ' + v.plate;
  $('#rename-input').value = v.customName || '';
  $('#note-input').value = v.note || '';
  $('#rename-modal').classList.remove('hidden');
  $('#rename-input').focus();
}

function closeRenameModal() {
  state.renameTargetId = null;
  $('#rename-modal').classList.add('hidden');
}

function saveRename() {
  const v = state.vehicles.find((x) => x.id === state.renameTargetId);
  if (!v) return;
  v.customName = $('#rename-input').value.trim() || null;
  v.note = $('#note-input').value.trim();
  closeRenameModal();
  render();
  showToast('Fahrzeug gespeichert', 'success');
}

function handleAction(action, id) {
  const v = state.vehicles.find((x) => x.id === id);
  if (!v) return;

  switch (action) {
    case 'favorite':
      v.favorite = !v.favorite;
      render();
      showToast(v.favorite ? 'Als Favorit markiert' : 'Favorit entfernt', 'info');
      break;
    case 'spawn':
      v.status = 'out';
      render();
      showToast(`${getDisplayName(v)} ausgeparkt`, 'success');
      break;
    case 'locate':
      showToast(`${getDisplayName(v)} auf der Karte markiert`, 'info');
      break;
    case 'mark-lot':
      showToast(`${v.impoundLotName} auf der Karte markiert`, 'warning');
      break;
    case 'rename':
      openRenameModal(id);
      break;
  }
}

function initStaticIcons() {
  $('#btn-close').innerHTML = ICONS.close();
  $$('#rename-modal .modal-close').forEach((el) => { el.innerHTML = ICONS.close(); });

  const parkedTab = $('#toolbar-garage .tab[data-tab="parked"]');
  const outTab = $('#toolbar-garage .tab[data-tab="out"]');
  if (parkedTab) parkedTab.innerHTML = `${ICONS.grid()} Eingeparkt`;
  if (outTab) outTab.innerHTML = `${ICONS.clock()} Ausgeparkt`;

  $$('#toolbar-garage .search-box, #toolbar-impound .search-box').forEach((box) => {
    if (!box.querySelector('.icon')) box.insertAdjacentHTML('afterbegin', ICONS.search());
  });

  const favBtn = $('#toolbar-garage .filter-btn[data-filter="favorites"]');
  if (favBtn) favBtn.innerHTML = `${ICONS.star()} Favoriten`;

  const banner = $('.impound-info-banner');
  if (banner && !banner.querySelector('.icon')) {
    banner.insertAdjacentHTML('afterbegin', ICONS.mapPin());
  }
}

function init() {
  initStaticIcons();

  populateLotFilter();

  $$('#toolbar-garage .tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      $$('#toolbar-garage .tab').forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');
      state.activeTab = tab.dataset.tab;
      render();
    });
  });

  $$('#toolbar-garage .filter-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      $$('#toolbar-garage .filter-btn').forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
      state.filter = btn.dataset.filter;
      render();
    });
  });

  $('#search-input').addEventListener('input', (e) => {
    state.search = e.target.value;
    render();
  });

  $('#search-input-impound').addEventListener('input', (e) => {
    state.search = e.target.value;
    render();
  });

  $('#lot-filter').addEventListener('change', (e) => {
    state.lotFilter = e.target.value;
    render();
  });

  $('#vehicle-grid').addEventListener('click', (e) => {
    const btn = e.target.closest('[data-action]');
    if (!btn) return;
    handleAction(btn.dataset.action, parseInt(btn.dataset.id, 10));
  });

  $('#btn-close').addEventListener('click', closeGarage);

  $$('#rename-modal .modal-close').forEach((btn) => btn.addEventListener('click', closeRenameModal));
  $('#rename-save').addEventListener('click', saveRename);
  $('#rename-input').addEventListener('keydown', (e) => { if (e.key === 'Enter') saveRename(); });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (!$('#rename-modal').classList.contains('hidden')) closeRenameModal();
      else if (!$('#app').classList.contains('hidden')) closeGarage();
    }
  });

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (data?.action === 'open' || data?.action === 'openGarage') {
      state.vehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
      openGarage(data.mode || 'land', data.garageName);
    }
    if (data?.action === 'close') closeGarage();
  });
}

init();
