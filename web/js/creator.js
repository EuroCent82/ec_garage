/**
 * EC Garage – Creator UI Preview
 */

const STEPS = [
  { id: 'basics', title: 'Grunddaten', desc: 'Name und Fahrzeugtyp der Garage festlegen' },
  { id: 'interact', title: 'Interaktion', desc: 'Position wo Spieler E drücken zum Öffnen' },
  { id: 'spawn', title: 'Auspark-Slots', desc: 'Spawn-Positionen für ausgeparkte Fahrzeuge' },
  { id: 'park', title: 'Einparken', desc: 'Zone oder feste Einpark-Slots definieren' },
  { id: 'blip', title: 'Blip & Zugriff', desc: 'Karten-Marker und Berechtigungen' },
  { id: 'review', title: 'Übersicht', desc: 'Alles prüfen und speichern' },
];

const TYPE_ICONS = VEHICLE_ICONS;

function emptyGarage(overrides = {}) {
  return {
    id: Date.now(),
    name: 'Neue Garage',
    type: 'land',
    interact: null,
    spawnSlots: [],
    parkMode: 'zone',
    parkRadius: 25,
    parkSlots: [],
    blipEnabled: true,
    blipLabel: '',
    job: '',
    minGrade: 0,
    ...overrides,
  };
}

const state = {
  garages: [
    emptyGarage({
      id: 1,
      name: 'Legion Square Garage',
      type: 'land',
      interact: { x: 215.12, y: -810.45, z: 30.73, h: 0 },
      spawnSlots: [
        { x: 222.4, y: -804.2, z: 30.65, h: 160.0 },
        { x: 218.1, y: -804.5, z: 30.65, h: 160.0 },
      ],
      parkMode: 'zone',
      parkRadius: 30,
      blipLabel: 'Legion Garage',
    }),
    emptyGarage({
      id: 2,
      name: 'LSIA Hangar',
      type: 'air',
      interact: { x: -1267.0, y: -3012.5, z: 13.94, h: 0 },
      spawnSlots: [{ x: -1275.2, y: -3005.8, z: 13.94, h: 330.0 }],
      parkMode: 'slot',
      parkSlots: [{ x: -1275.2, y: -3005.8, z: 13.94, h: 330.0 }],
      blipLabel: 'LSIA Hangar',
    }),
    emptyGarage({
      id: 'wuerfelpark',
      name: 'Würfelpark Garage',
      type: 'land',
      interact: { x: 884.88, y: -43.56, z: 78.76, h: 58.0 },
      spawnSlots: [
        { x: 895.20, y: -35.80, z: 78.76, h: 328.0 },
        { x: 899.50, y: -30.20, z: 78.76, h: 328.0 },
        { x: 903.80, y: -24.50, z: 78.76, h: 328.0 },
        { x: 908.10, y: -18.90, z: 78.76, h: 328.0 },
      ],
      parkMode: 'zone',
      parkRadius: 42,
      blipLabel: 'Würfelpark',
    }),
  ],
  activeGarageId: 'wuerfelpark',
  step: 0,
  placement: null,
  placementPos: { x: 215.0, y: -810.0, z: 30.7, h: 0 },
};

const $ = (s) => document.querySelector(s);
const $$ = (s) => document.querySelectorAll(s);

function garage() {
  return state.garages.find((g) => g.id === state.activeGarageId);
}

function fmt(n, d = 2) {
  return Number(n).toFixed(d);
}

function fmtCoord(c) {
  if (!c) return '—';
  return `X: ${fmt(c.x)}  Y: ${fmt(c.y)}  Z: ${fmt(c.z)}  H: ${fmt(c.h, 1)}°`;
}

function showToast(msg) {
  const t = $('#toast');
  $('#toast-message').textContent = msg;
  t.classList.remove('hidden');
  clearTimeout(showToast._t);
  showToast._t = setTimeout(() => t.classList.add('hidden'), 2600);
}

function renderStepNav() {
  $('#step-nav').innerHTML = STEPS.map((s, i) => `
    <button class="step-btn${i === state.step ? ' active' : ''}${i < state.step ? ' done' : ''}" data-step="${i}">
      <span class="step-num">${i + 1}</span>
      ${s.title}
    </button>`).join('');
}

function renderGarageList() {
  $('#garage-list').innerHTML = state.garages.map((g) => `
    <div class="garage-item${g.id === state.activeGarageId ? ' active' : ''}" data-id="${g.id}">
      <div class="garage-item-icon garage-item-icon--${g.type}">${TYPE_ICONS[g.type]}</div>
      <div class="garage-item-info">
        <div class="garage-item-name">${g.name}</div>
        <div class="garage-item-meta">${g.spawnSlots.length} Spawn · ${g.parkMode === 'zone' ? 'Zone' : g.parkSlots.length + ' Park'}</div>
      </div>
    </div>`).join('');
}

function stepNavButtons() {
  const prev = state.step > 0 ? `<button class="btn btn-ghost" data-nav="prev">${ICONS.arrowLeft()} Zurück</button>` : '<span></span>';
  const next = state.step < STEPS.length - 1
    ? `<button class="btn btn-success" data-nav="next">Weiter ${ICONS.arrowRight()}</button>`
    : `<button class="btn btn-success" id="btn-save-inline">${ICONS.save()} Garage speichern</button>`;
  return `<div class="step-nav-btns">${prev}${next}</div>`;
}

function renderBasics(g) {
  return `
    <div class="form-grid">
      <div class="field full">
        <label>Garagen-Name</label>
        <input class="input" id="f-name" value="${g.name}" placeholder="z.B. Legion Square Garage" />
      </div>
      <div class="field full">
        <label>Fahrzeugtyp</label>
        <div class="type-picker">
          ${['land', 'air', 'water'].map((t) => `
            <button type="button" class="type-option${g.type === t ? ' active' : ''}" data-type="${t}">
              ${TYPE_ICONS[t]}
              <span>${t === 'land' ? 'PKW' : t === 'air' ? 'Helikopter' : 'Boot'}</span>
            </button>`).join('')}
        </div>
      </div>
    </div>${stepNavButtons()}`;
}

function renderInteract(g) {
  const set = !!g.interact;
  return `
    <div class="pos-card">
      <div class="pos-card-head">
        <h3>Interaktionspunkt</h3>
        <button class="btn btn-success" data-action="take-pos" data-target="interact">
          ${ICONS.mapPin()} Aktuelle Position
        </button>
      </div>
      <p class="field-hint" style="margin-bottom:14px">Hier öffnen Spieler das Garagen-UI mit <kbd style="padding:2px 6px;background:var(--bg-elevated);border-radius:4px;font-size:11px">E</kbd></p>
      ${set ? `
        <div class="pos-coords">
          <div class="pos-coord set"><span>X</span><strong>${fmt(g.interact.x)}</strong></div>
          <div class="pos-coord set"><span>Y</span><strong>${fmt(g.interact.y)}</strong></div>
          <div class="pos-coord set"><span>Z</span><strong>${fmt(g.interact.z)}</strong></div>
          <div class="pos-coord set"><span>H</span><strong>${fmt(g.interact.h, 1)}°</strong></div>
        </div>
        <button class="btn btn-ghost" data-action="place-slot" data-target="interact">Im Hologramm-Modus bearbeiten</button>
      ` : `
        <div class="pos-empty">
          ${TYPE_ICONS.land}
          <p>Noch keine Position gesetzt.<br/>Gehe ingame zur Stelle und klicke „Aktuelle Position".</p>
        </div>`}
    </div>${stepNavButtons()}`;
}

function renderSlotList(slots, type, label) {
  if (!slots.length) {
    return `<div class="slots-empty">Noch keine ${label}. Klicke „Slot hinzufügen" um das Hologramm zu platzieren.</div>`;
  }
  return `<div class="slot-list">${slots.map((s, i) => `
    <div class="slot-item${type === 'park' ? ' slot-item--park' : ''}">
      <div class="slot-index">${i + 1}</div>
      <div class="slot-info">
        <strong>${label} #${i + 1}</strong>
        <span>${fmtCoord(s)}</span>
      </div>
      <div class="slot-actions">
        <button class="btn-icon" data-action="edit-slot" data-type="${type}" data-index="${i}" title="Bearbeiten">
          ${ICONS.pen()}
        </button>
        <button class="btn-icon danger" data-action="delete-slot" data-type="${type}" data-index="${i}" title="Löschen">
          ${ICONS.trash()}
        </button>
      </div>
    </div>`).join('')}</div>`;
}

function renderSpawn(g) {
  return `
    <div class="slots-section">
      <div class="slots-header">
        <div>
          <h3>Auspark-Slots</h3>
          <p>Fahrzeuge spawnen an diesen Positionen (${g.spawnSlots.length} definiert)</p>
        </div>
        <button class="btn btn-success" data-action="place-slot" data-target="spawn-new">
          ${ICONS.plus()} Slot hinzufügen
        </button>
      </div>
      ${renderSlotList(g.spawnSlots, 'spawn', 'Auspark-Slot')}
    </div>${stepNavButtons()}`;
}

function renderPark(g) {
  return `
    <div class="mode-toggle">
      <button class="mode-btn${g.parkMode === 'zone' ? ' active' : ''}" data-park-mode="zone">Einpark-Zone</button>
      <button class="mode-btn${g.parkMode === 'slot' ? ' active' : ''}" data-park-mode="slot">Feste Slots</button>
    </div>
    ${g.parkMode === 'zone' ? `
      <div class="zone-settings">
        <h3 style="font-size:14px;font-weight:600;margin-bottom:6px">Einpark-Zone (Radius)</h3>
        <p class="field-hint">Spieler können Fahrzeuge in diesem Radius um den Interaktionspunkt einparken.</p>
        <div class="range-row">
          <input type="range" id="park-radius" min="5" max="80" value="${g.parkRadius}" />
          <span class="range-value">${g.parkRadius}m</span>
        </div>
      </div>` : `
      <div class="slots-section">
        <div class="slots-header">
          <div>
            <h3>Einpark-Slots</h3>
            <p>Feste Positionen zum Einparken (${g.parkSlots.length} definiert)</p>
          </div>
          <button class="btn btn-success" data-action="place-slot" data-target="park-new">
            ${ICONS.plus()} Slot hinzufügen
          </button>
        </div>
        ${renderSlotList(g.parkSlots, 'park', 'Einpark-Slot')}
      </div>`}
    ${stepNavButtons()}`;
}

function renderBlip(g) {
  return `
    <div class="form-grid form-grid--single">
      <div class="field">
        <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
          <input type="checkbox" id="f-blip" ${g.blipEnabled ? 'checked' : ''} />
          Blip auf der Karte anzeigen
        </label>
      </div>
      <div class="field">
        <label>Blip-Label</label>
        <input class="input" id="f-blip-label" value="${g.blipLabel || g.name}" placeholder="Kartenname" />
      </div>
      <div class="field">
        <label>Job-Beschränkung <span class="field-hint">(leer = öffentlich)</span></label>
        <input class="input" id="f-job" value="${g.job}" placeholder="z.B. police, ambulance" />
      </div>
      <div class="field">
        <label>Mindest-Rang</label>
        <input class="input" type="number" id="f-grade" min="0" value="${g.minGrade}" />
      </div>
    </div>${stepNavButtons()}`;
}

function renderReview(g) {
  const typeLabel = { land: 'Landfahrzeuge', air: 'Luftfahrzeuge', water: 'Wasserfahrzeuge' };
  return `
    <div class="review-grid">
      <div class="review-card">
        <h4>Name</h4>
        <p>${g.name}</p>
        <span class="review-tag review-tag--${g.type}">${typeLabel[g.type]}</span>
      </div>
      <div class="review-card">
        <h4>Interaktion</h4>
        <p>${g.interact ? 'Gesetzt' : '—'}</p>
        <p class="sub">${g.interact ? fmtCoord(g.interact) : 'Noch nicht definiert'}</p>
      </div>
      <div class="review-card">
        <h4>Auspark-Slots</h4>
        <p>${g.spawnSlots.length} Slot${g.spawnSlots.length !== 1 ? 's' : ''}</p>
      </div>
      <div class="review-card">
        <h4>Einparken</h4>
        <p>${g.parkMode === 'zone' ? `Zone (${g.parkRadius}m)` : `${g.parkSlots.length} Slot(s)`}</p>
      </div>
      <div class="review-card">
        <h4>Blip</h4>
        <p>${g.blipEnabled ? g.blipLabel || g.name : 'Deaktiviert'}</p>
      </div>
      <div class="review-card">
        <h4>Zugriff</h4>
        <p>${g.job ? g.job + ' (Rang ' + g.minGrade + '+)' : 'Öffentlich'}</p>
      </div>
    </div>${stepNavButtons()}`;
}

function renderStep() {
  const g = garage();
  if (!g) return;

  const step = STEPS[state.step];
  $('#step-title').textContent = step.title;
  $('#step-desc').textContent = step.desc;

  const renderers = {
    basics: renderBasics,
    interact: renderInteract,
    spawn: renderSpawn,
    park: renderPark,
    blip: renderBlip,
    review: renderReview,
  };

  $('#creator-body').innerHTML = renderers[step.id](g);
  renderStepNav();
  renderGarageList();
  bindStepEvents();
}

function bindStepEvents() {
  const g = garage();
  if (!g) return;

  const nameEl = $('#f-name');
  if (nameEl) nameEl.oninput = (e) => { g.name = e.target.value; renderGarageList(); };

  $$('.type-option').forEach((btn) => {
    btn.onclick = () => { g.type = btn.dataset.type; renderStep(); };
  });

  const blipEl = $('#f-blip');
  if (blipEl) blipEl.onchange = (e) => { g.blipEnabled = e.target.checked; };

  const blipLabel = $('#f-blip-label');
  if (blipLabel) blipLabel.oninput = (e) => { g.blipLabel = e.target.value; };

  const jobEl = $('#f-job');
  if (jobEl) jobEl.oninput = (e) => { g.job = e.target.value; };

  const gradeEl = $('#f-grade');
  if (gradeEl) gradeEl.oninput = (e) => { g.minGrade = parseInt(e.target.value, 10) || 0; };

  const radiusEl = $('#park-radius');
  if (radiusEl) {
    radiusEl.oninput = (e) => {
      g.parkRadius = parseInt(e.target.value, 10);
      $('.range-value').textContent = g.parkRadius + 'm';
    };
  }

  $$('[data-park-mode]').forEach((btn) => {
    btn.onclick = () => { g.parkMode = btn.dataset.parkMode; renderStep(); };
  });

  $$('[data-nav]').forEach((btn) => {
    btn.onclick = () => {
      state.step += btn.dataset.nav === 'next' ? 1 : -1;
      renderStep();
    };
  });

  $('#btn-save-inline')?.addEventListener('click', saveGarage);

  $$('[data-action]').forEach((btn) => {
    btn.onclick = () => handleAction(btn.dataset.action, btn.dataset);
  });
}

function handleAction(action, data) {
  const g = garage();
  if (!g) return;

  switch (action) {
    case 'take-pos':
      g.interact = { ...state.placementPos };
      showToast('Interaktionspunkt übernommen');
      renderStep();
      break;
    case 'place-slot':
      startPlacement(data.target, data.type ? parseInt(data.index, 10) : null);
      break;
    case 'edit-slot':
      startPlacement(`${data.type}-edit`, parseInt(data.index, 10));
      break;
    case 'delete-slot': {
      const arr = data.type === 'spawn' ? g.spawnSlots : g.parkSlots;
      arr.splice(parseInt(data.index, 10), 1);
      renderStep();
      showToast('Slot gelöscht');
      break;
    }
  }
}

function startPlacement(target, index) {
  const g = garage();
  let label = 'Position';
  let pos = { ...state.placementPos };

  if (target === 'interact') {
    label = 'Interaktionspunkt';
    if (g.interact) pos = { ...g.interact };
  } else if (target === 'spawn-new') {
    label = `Auspark-Slot #${g.spawnSlots.length + 1}`;
  } else if (target === 'spawn-edit') {
    label = `Auspark-Slot #${index + 1}`;
    pos = { ...g.spawnSlots[index] };
  } else if (target === 'park-new') {
    label = `Einpark-Slot #${g.parkSlots.length + 1}`;
  } else if (target === 'park-edit') {
    label = `Einpark-Slot #${index + 1}`;
    pos = { ...g.parkSlots[index] };
  }

  state.placement = { target, index, label };
  state.placementPos = pos;

  const iconEl = $('#hologram')?.querySelector('.hologram-icon');
  if (iconEl && g) {
    iconEl.innerHTML = VEHICLE_ICONS[g.type] || VEHICLE_ICONS.land;
  }

  updatePlacementUI();
  $('#placement-hud').classList.remove('hidden');
}

function confirmPlacement() {
  const g = garage();
  const { target, index } = state.placement;
  const pos = { ...state.placementPos };

  if (target === 'interact') g.interact = pos;
  else if (target === 'spawn-new') g.spawnSlots.push(pos);
  else if (target === 'spawn-edit') g.spawnSlots[index] = pos;
  else if (target === 'park-new') g.parkSlots.push(pos);
  else if (target === 'park-edit') g.parkSlots[index] = pos;

  closePlacement();
  renderStep();
  showToast('Position gespeichert');
}

function closePlacement() {
  state.placement = null;
  $('#placement-hud').classList.add('hidden');
}

function updatePlacementUI() {
  const p = state.placementPos;
  $('#placement-badge').textContent = state.placement?.label || 'Position';
  $('#coord-x').textContent = fmt(p.x);
  $('#coord-y').textContent = fmt(p.y);
  $('#coord-z').textContent = fmt(p.z);
  $('#coord-h').textContent = fmt(p.h, 1) + '°';
  $('#hologram-heading').textContent = fmt(p.h, 0) + '°';

  const holo = $('#hologram');
  if (holo) {
    const ox = ((p.x % 10) - 5) * 8;
    const oy = ((p.y % 10) - 5) * 6;
    holo.style.transform = `translate(calc(-50% + ${ox}px), calc(-50% + ${oy}px)) rotate(${p.h}deg)`;
  }
}

function movePlacement(dx, dy, dh) {
  if (!state.placement) return;
  const p = state.placementPos;
  p.x = Math.round((p.x + dx) * 100) / 100;
  p.y = Math.round((p.y + dy) * 100) / 100;
  if (dh) {
    p.h = ((p.h + dh) % 360 + 360) % 360;
  }
  updatePlacementUI();
}

function saveGarage() {
  const g = garage();
  if (!g.name.trim()) return showToast('Name fehlt');
  if (!g.interact) return showToast('Interaktionspunkt fehlt');
  if (!g.spawnSlots.length) return showToast('Mindestens ein Auspark-Slot nötig');
  showToast(`Garage „${g.name}" gespeichert`);
}

function exportJson() {
  const data = JSON.stringify(state.garages, null, 2);
  navigator.clipboard?.writeText(data);
  showToast('JSON in Zwischenablage kopiert');
}

function openCreator() {
  $('#creator').classList.remove('hidden');
  renderStep();
}

function closeCreator() {
  closePlacement();
  $('#creator').classList.add('hidden');
  if (window.EC_NUI?.isEmbed) {
    window.parent.postMessage({ action: 'nuiClose', screen: 'creator' }, '*');
  }
}

function initStaticIcons() {
  $('.sidebar-logo').innerHTML = ICONS.gear();
  $('#btn-close').innerHTML = ICONS.close();
  $('#btn-new-garage').innerHTML = ICONS.plus();
  $('#btn-export').innerHTML = `${ICONS.export()} Export JSON`;
  $('#btn-save').innerHTML = `${ICONS.save()} Speichern`;
  $('#placement-confirm').innerHTML = `${ICONS.check()} Slot speichern`;

  const holoDefault = $('#hologram-icon-default');
  if (holoDefault) holoDefault.innerHTML = VEHICLE_ICONS.land;
}

function init() {
  initStaticIcons();

  renderStepNav();
  renderGarageList();

  $('#step-nav').addEventListener('click', (e) => {
    const btn = e.target.closest('.step-btn');
    if (btn) { state.step = parseInt(btn.dataset.step, 10); renderStep(); }
  });

  $('#garage-list').addEventListener('click', (e) => {
    const item = e.target.closest('.garage-item');
    if (item) {
      const id = item.dataset.id;
      state.activeGarageId = /^\d+$/.test(id) ? parseInt(id, 10) : id;
      renderStep();
    }
  });

  $('#btn-new-garage').onclick = () => {
    const g = emptyGarage({ name: 'Neue Garage ' + (state.garages.length + 1) });
    state.garages.push(g);
    state.activeGarageId = g.id;
    state.step = 0;
    renderStep();
    showToast('Neue Garage erstellt');
  };

  $('#btn-close').onclick = closeCreator;
  $('#btn-save').onclick = saveGarage;
  $('#btn-export').onclick = exportJson;
  $('#placement-cancel').onclick = closePlacement;
  $('#placement-confirm').onclick = confirmPlacement;

  document.addEventListener('keydown', (e) => {
    if (!state.placement) {
      if (e.key === 'Escape' && !$('#creator').classList.contains('hidden')) closeCreator();
      return;
    }

    const step = e.shiftKey ? 0.5 : 0.15;
    switch (e.key) {
      case 'ArrowUp': e.preventDefault(); movePlacement(0, step, 0); break;
      case 'ArrowDown': e.preventDefault(); movePlacement(0, -step, 0); break;
      case 'ArrowLeft': e.preventDefault(); movePlacement(-step, 0, 0); break;
      case 'ArrowRight': e.preventDefault(); movePlacement(step, 0, 0); break;
      case 'q': case 'Q': e.preventDefault(); movePlacement(0, 0, -5); break;
      case 'e': case 'E': e.preventDefault(); movePlacement(0, 0, 5); break;
      case 'Enter': e.preventDefault(); confirmPlacement(); break;
      case 'Escape': e.preventDefault(); closePlacement(); break;
    }
  });

  window.addEventListener('message', (event) => {
    if (event.data?.action === 'openCreator') openCreator();
    if (event.data?.action === 'closeCreator') closeCreator();
    if (event.data?.position) state.placementPos = { ...event.data.position };
  });
}

init();
