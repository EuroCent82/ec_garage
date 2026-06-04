/**
 * EC Garage – Creator (Neuaufbau, ec_chat Theme)
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

function newGarageId() {
  return `garage_${Date.now()}`;
}

function emptyGarage(overrides = {}) {
  return {
    id: newGarageId(),
    name: 'Neue Garage',
    type: 'land',
    interact: null,
    spawnSlots: [],
    parkMode: 'zone',
    parkRadius: 25,
    parkSlots: [],
    blipEnabled: true,
    blipLabel: '',
    blipSprite: 357,
    blipColor: 3,
    job: '',
    minGrade: 0,
    propEnabled: false,
    propModel: 'prop_park_ticket_01',
    prop: null,
    ...overrides,
  };
}

function normalizeGarage(raw) {
  const prop = raw.prop;
  const propEnabled = prop?.enabled ?? raw.propEnabled ?? false;
  const propModel = prop?.model || raw.propModel || 'prop_park_ticket_01';
  return emptyGarage({
    ...raw,
    propEnabled,
    propModel,
    prop: propEnabled && prop
      ? { x: prop.x, y: prop.y, z: prop.z, h: prop.h ?? 0, model: propModel, enabled: true }
      : null,
  });
}

function nuiResource() {
  return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'ec_garage';
}

async function fetchCoords() {
  if (typeof GetParentResourceName !== 'function') {
    return { ...state.placementPos };
  }
  const res = await fetch(`https://${nuiResource()}/getCoords`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{}',
  });
  return res.json();
}

function setPlacementActive(active) {
  if (typeof GetParentResourceName !== 'function') return;
  fetch(`https://${nuiResource()}/setPlacementActive`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ active }),
  }).catch(() => {});
}

const state = {
  garages: [],
  activeGarageId: null,
  step: 0,
  placement: null,
  placementPos: { x: 884.88, y: -43.56, z: 78.76, h: 58.0 },
};

const $ = (s, root = document) => root.querySelector(s);

function garage() {
  return state.garages.find((g) => String(g.id) === String(state.activeGarageId));
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
  $('#toast-message', t).textContent = msg;
  t.classList.remove('hidden');
  clearTimeout(showToast._t);
  showToast._t = setTimeout(() => t.classList.add('hidden'), 2600);
}

function updateStepProgress() {
  const pct = ((state.step + 1) / STEPS.length) * 100;
  const fill = $('#step-progress-fill');
  const label = $('#step-progress-label');
  if (fill) fill.style.width = `${pct}%`;
  if (label) label.textContent = `Schritt ${state.step + 1} / ${STEPS.length}`;
}

function renderStepNav() {
  $('#step-nav').innerHTML = STEPS.map((s, i) => `
    <button type="button" class="step-btn${i === state.step ? ' active' : ''}${i < state.step ? ' done' : ''}" data-step="${i}">
      <span class="step-num">${i < state.step ? '✓' : i + 1}</span>
      <span class="step-label">${s.title}</span>
    </button>`).join('');
  updateStepProgress();
}

function renderGarageList() {
  $('#garage-list').innerHTML = state.garages.map((g) => `
    <div class="garage-item${String(g.id) === String(state.activeGarageId) ? ' active' : ''}" data-id="${g.id}">
      <div class="garage-item-icon garage-item-icon--${g.type}">${TYPE_ICONS[g.type]}</div>
      <div class="garage-item-info">
        <div class="garage-item-name">${escapeHtml(g.name)}</div>
        <div class="garage-item-meta">${g.spawnSlots.length} Spawn · ${g.parkMode === 'zone' ? 'Zone' : g.parkSlots.length + ' Park'}</div>
      </div>
    </div>`).join('');
}

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function stepNavButtons() {
  const prev = state.step > 0
    ? `<button type="button" class="btn btn-ghost" data-nav="prev">${ICONS.arrowLeft()} Zurück</button>`
    : '<span></span>';
  const next = state.step < STEPS.length - 1
    ? `<button type="button" class="btn btn-success" data-nav="next">Weiter ${ICONS.arrowRight()}</button>`
    : `<button type="button" class="btn btn-success" data-action="save-inline">${ICONS.save()} Garage speichern</button>`;
  return `<div class="step-nav-btns">${prev}${next}</div>`;
}

function renderBasics(g) {
  return `
    <div class="form-grid">
      <div class="field full">
        <label for="f-name">Garagen-Name</label>
        <input class="input" id="f-name" value="${escapeHtml(g.name)}" placeholder="z.B. Legion Square Garage" />
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
        <button type="button" class="btn btn-success" data-action="take-pos" data-target="interact">
          ${ICONS.mapPin()} Aktuelle Position
        </button>
      </div>
      <p class="field-hint" style="margin-bottom:14px">Hier öffnen Spieler das Garagen-UI mit <kbd>E</kbd></p>
      ${set ? `
        <div class="pos-coords">
          <div class="pos-coord set"><span>X</span><strong>${fmt(g.interact.x)}</strong></div>
          <div class="pos-coord set"><span>Y</span><strong>${fmt(g.interact.y)}</strong></div>
          <div class="pos-coord set"><span>Z</span><strong>${fmt(g.interact.z)}</strong></div>
          <div class="pos-coord set"><span>H</span><strong>${fmt(g.interact.h, 1)}°</strong></div>
        </div>
        <button type="button" class="btn btn-ghost" data-action="place-slot" data-target="interact">Im Hologramm-Modus bearbeiten</button>
      ` : `
        <div class="pos-empty">
          ${TYPE_ICONS.land}
          <p>Noch keine Position gesetzt.<br/>Gehe ingame zur Stelle und klicke „Aktuelle Position".</p>
        </div>`}
    </div>
    <div class="pos-card" style="margin-top:16px">
      <div class="pos-card-head">
        <h3>Welt-Objekt (optional)</h3>
        <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13px">
          <input type="checkbox" id="f-prop-enabled" ${g.propEnabled ? 'checked' : ''} />
          Prop spawnen
        </label>
      </div>
      <p class="field-hint" style="margin-bottom:12px">z.&nbsp;B. Ticketautomat <code>prop_park_ticket_01</code></p>
      <div class="field" style="margin-bottom:12px">
        <label for="f-prop-model">Prop-Modell</label>
        <input class="input" id="f-prop-model" value="${escapeHtml(g.propModel || 'prop_park_ticket_01')}" ${g.propEnabled ? '' : 'disabled'} />
      </div>
      ${g.propEnabled && g.prop ? `
        <div class="pos-coords">
          <div class="pos-coord set"><span>X</span><strong>${fmt(g.prop.x)}</strong></div>
          <div class="pos-coord set"><span>Y</span><strong>${fmt(g.prop.y)}</strong></div>
          <div class="pos-coord set"><span>Z</span><strong>${fmt(g.prop.z)}</strong></div>
          <div class="pos-coord set"><span>H</span><strong>${fmt(g.prop.h, 1)}°</strong></div>
        </div>
        <button type="button" class="btn btn-ghost" data-action="place-slot" data-target="prop">Position im Hologramm-Modus bearbeiten</button>
      ` : ''}
      <button type="button" class="btn btn-success" data-action="take-pos-prop" ${g.propEnabled ? '' : 'disabled'}>
        ${ICONS.mapPin()} Aktuelle Position (Prop)
      </button>
    </div>${stepNavButtons()}`;
}

function renderSlotList(slots, type, label) {
  if (!slots.length) {
    return `<div class="slots-empty">Noch keine ${label}. Klicke „Slot hinzufügen".</div>`;
  }
  return `<div class="slot-list">${slots.map((s, i) => `
    <div class="slot-item${type === 'park' ? ' slot-item--park' : ''}">
      <div class="slot-index">${i + 1}</div>
      <div class="slot-info">
        <strong>${label} #${i + 1}</strong>
        <span>${fmtCoord(s)}</span>
      </div>
      <div class="slot-actions">
        <button type="button" class="btn-icon" data-action="edit-slot" data-type="${type}" data-index="${i}" title="Bearbeiten">${ICONS.pen()}</button>
        <button type="button" class="btn-icon danger" data-action="delete-slot" data-type="${type}" data-index="${i}" title="Löschen">${ICONS.trash()}</button>
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
        <button type="button" class="btn btn-success" data-action="place-slot" data-target="spawn-new">
          ${ICONS.plus()} Slot hinzufügen
        </button>
      </div>
      ${renderSlotList(g.spawnSlots, 'spawn', 'Auspark-Slot')}
    </div>${stepNavButtons()}`;
}

function renderPark(g) {
  return `
    <div class="mode-toggle">
      <button type="button" class="mode-btn${g.parkMode === 'zone' ? ' active' : ''}" data-park-mode="zone">Einpark-Zone</button>
      <button type="button" class="mode-btn${g.parkMode === 'slot' ? ' active' : ''}" data-park-mode="slot">Feste Slots</button>
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
            <p>Feste Positionen (${g.parkSlots.length} definiert)</p>
          </div>
          <button type="button" class="btn btn-success" data-action="place-slot" data-target="park-new">
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
        <label for="f-blip-label">Blip-Label</label>
        <input class="input" id="f-blip-label" value="${escapeHtml(g.blipLabel || g.name)}" />
      </div>
      <div class="field">
        <label for="f-job">Job-Beschränkung <span class="field-hint">(leer = öffentlich)</span></label>
        <input class="input" id="f-job" value="${escapeHtml(g.job)}" placeholder="z.B. police" />
      </div>
      <div class="field">
        <label for="f-grade">Mindest-Rang</label>
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
        <p>${escapeHtml(g.name)}</p>
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
        <p>${g.blipEnabled ? escapeHtml(g.blipLabel || g.name) : 'Deaktiviert'}</p>
      </div>
      <div class="review-card">
        <h4>Zugriff</h4>
        <p>${g.job ? escapeHtml(g.job) + ' (Rang ' + g.minGrade + '+)' : 'Öffentlich'}</p>
      </div>
      <div class="review-card full">
        <h4>Welt-Objekt</h4>
        <p>${g.propEnabled && g.prop ? escapeHtml(g.propModel) : 'Keins'}</p>
        <p class="sub">${g.prop ? fmtCoord(g.prop) : ''}</p>
      </div>
    </div>${stepNavButtons()}`;
}

const STEP_RENDERERS = {
  basics: renderBasics,
  interact: renderInteract,
  spawn: renderSpawn,
  park: renderPark,
  blip: renderBlip,
  review: renderReview,
};

function renderStep() {
  const g = garage();
  if (!g) {
    $('#creator-body').innerHTML = '<p class="field-hint">Keine Garage ausgewählt.</p>';
    return;
  }

  const step = STEPS[state.step];
  $('#step-title').textContent = step.title;
  $('#step-desc').textContent = step.desc;
  $('#creator-body').innerHTML = STEP_RENDERERS[step.id](g);
  renderStepNav();
  renderGarageList();
}

function onCreatorBodyInput(e) {
  const g = garage();
  if (!g) return;
  const t = e.target;

  if (t.id === 'f-name') {
    g.name = t.value;
    renderGarageList();
    return;
  }
  if (t.id === 'f-blip-label') { g.blipLabel = t.value; return; }
  if (t.id === 'f-job') { g.job = t.value; return; }
  if (t.id === 'f-prop-model') { g.propModel = t.value.trim(); return; }
  if (t.id === 'f-grade') { g.minGrade = parseInt(t.value, 10) || 0; return; }
  if (t.id === 'park-radius') {
    g.parkRadius = parseInt(t.value, 10);
    const rv = document.querySelector('.range-value');
    if (rv) rv.textContent = `${g.parkRadius}m`;
  }
}

function onCreatorBodyChange(e) {
  const g = garage();
  if (!g) return;
  const t = e.target;

  if (t.id === 'f-blip') { g.blipEnabled = t.checked; return; }
  if (t.id === 'f-prop-enabled') {
    g.propEnabled = t.checked;
    if (!g.propEnabled) g.prop = null;
    renderStep();
  }
}

function onCreatorBodyClick(e) {
  const g = garage();
  if (!g) return;

  const typeBtn = e.target.closest('.type-option');
  if (typeBtn?.dataset.type) {
    g.type = typeBtn.dataset.type;
    renderStep();
    return;
  }

  const modeBtn = e.target.closest('[data-park-mode]');
  if (modeBtn) {
    g.parkMode = modeBtn.dataset.parkMode;
    renderStep();
    return;
  }

  const navBtn = e.target.closest('[data-nav]');
  if (navBtn) {
    state.step += navBtn.dataset.nav === 'next' ? 1 : -1;
    renderStep();
    return;
  }

  const actionBtn = e.target.closest('[data-action]');
  if (!actionBtn) return;

  const { action } = actionBtn.dataset;
  if (action === 'save-inline') {
    saveGarage();
    return;
  }
  handleAction(action, actionBtn.dataset);
}

function handleAction(action, data) {
  const g = garage();
  if (!g) return;

  switch (action) {
    case 'take-pos':
      fetchCoords().then((coords) => {
        g.interact = { ...coords };
        state.placementPos = { ...coords };
        showToast('Interaktionspunkt übernommen');
        renderStep();
      });
      break;
    case 'take-pos-prop':
      if (!g.propEnabled) return;
      fetchCoords().then((coords) => {
        g.prop = { ...coords, model: g.propModel, enabled: true };
        showToast('Prop-Position übernommen');
        renderStep();
      });
      break;
    case 'place-slot':
      startPlacement(data.target);
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

function startPlacement(target, index = null) {
  const g = garage();
  if (!g) return;

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
  } else if (target === 'prop') {
    label = 'Welt-Objekt';
    if (g.prop) pos = { x: g.prop.x, y: g.prop.y, z: g.prop.z, h: g.prop.h ?? 0 };
  }

  state.placement = { target, index, label };
  state.placementPos = pos;
  setPlacementActive(true);

  const iconEl = $('#hologram-icon');
  if (iconEl) iconEl.innerHTML = VEHICLE_ICONS[g.type] || VEHICLE_ICONS.land;

  const confirmBtn = $('#placement-confirm');
  if (confirmBtn) {
    confirmBtn.innerHTML = target.includes('spawn') || target.includes('park')
      ? `${ICONS.check()} Position speichern`
      : `${ICONS.check()} Übernehmen`;
  }

  updatePlacementUI();
  $('#placement-hud').classList.remove('hidden');
}

function confirmPlacement() {
  const g = garage();
  if (!g || !state.placement) return;

  const { target, index } = state.placement;
  const pos = { ...state.placementPos };

  if (target === 'interact') g.interact = pos;
  else if (target === 'spawn-new') g.spawnSlots.push(pos);
  else if (target === 'spawn-edit') g.spawnSlots[index] = pos;
  else if (target === 'park-new') g.parkSlots.push(pos);
  else if (target === 'park-edit') g.parkSlots[index] = pos;
  else if (target === 'prop') {
    g.prop = { ...pos, model: g.propModel, enabled: true };
    g.propEnabled = true;
  }

  closePlacement();
  renderStep();
  showToast('Position gespeichert');
}

function closePlacement() {
  state.placement = null;
  setPlacementActive(false);
  $('#placement-hud').classList.add('hidden');
}

function updatePlacementUI() {
  const p = state.placementPos;
  $('#placement-badge').textContent = state.placement?.label || 'Position';
  $('#coord-x').textContent = fmt(p.x);
  $('#coord-y').textContent = fmt(p.y);
  $('#coord-z').textContent = fmt(p.z);
  $('#coord-h').textContent = `${fmt(p.h, 1)}°`;
  $('#hologram-heading').textContent = `${fmt(p.h, 0)}°`;

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
  if (dh) p.h = ((p.h + dh) % 360 + 360) % 360;
  updatePlacementUI();
}

function garagePayload(g) {
  return {
    id: String(g.id),
    name: g.name,
    type: g.type,
    interact: g.interact,
    spawnSlots: g.spawnSlots,
    parkMode: g.parkMode,
    parkRadius: g.parkRadius,
    parkSlots: g.parkSlots,
    blipEnabled: g.blipEnabled,
    blipLabel: g.blipLabel || g.name,
    blipSprite: g.blipSprite,
    blipColor: g.blipColor,
    job: g.job,
    minGrade: g.minGrade,
    prop: g.propEnabled && g.prop
      ? { enabled: true, model: g.propModel, x: g.prop.x, y: g.prop.y, z: g.prop.z, h: g.prop.h ?? 0 }
      : null,
  };
}

function saveGarage() {
  const g = garage();
  if (!g) return showToast('Keine Garage aktiv');
  if (!g.name.trim()) return showToast('Name fehlt');
  if (!g.interact) return showToast('Interaktionspunkt fehlt');
  if (!g.spawnSlots.length) return showToast('Mindestens ein Auspark-Slot nötig');

  const payload = garagePayload(g);
  if (typeof GetParentResourceName === 'function') {
    fetch(`https://${nuiResource()}/saveGarage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
      .then((r) => r.json())
      .then((res) => {
        if (res.ok) showToast(`Garage „${g.name}" gespeichert — live aktiv`);
        else showToast(res.message || 'Speichern fehlgeschlagen');
      })
      .catch(() => showToast('Speichern fehlgeschlagen'));
    return;
  }
  showToast(`Garage „${g.name}" gespeichert (Preview)`);
}

function exportJson() {
  const data = JSON.stringify(state.garages.map(garagePayload), null, 2);
  navigator.clipboard?.writeText(data).then(
    () => showToast('JSON in Zwischenablage kopiert'),
    () => showToast('Kopieren fehlgeschlagen'),
  );
}

function loadGaragesFromGame(list) {
  if (!Array.isArray(list) || !list.length) return;
  state.garages = list.map(normalizeGarage);
  state.activeGarageId = state.garages[0].id;
  const first = state.garages[0];
  if (first?.interact) state.placementPos = { ...first.interact };
}

function seedPreviewGarages() {
  if (state.garages.length) return;
  state.garages = [
    normalizeGarage({
      id: 1,
      name: 'Legion Square',
      type: 'land',
      interact: { x: 215.12, y: -809.5, z: 30.73, h: 70.0 },
      spawnSlots: [{ x: 220.1, y: -806.2, z: 30.5, h: 68.0 }],
    }),
    normalizeGarage({ id: 2, name: 'LSIA Hangar', type: 'air' }),
  ];
  state.activeGarageId = 1;
}

const CREATOR_CLOSE_MS = 300;

function openCreator(data) {
  if (data?.garages?.length) loadGaragesFromGame(data.garages);
  if (!state.garages.length) {
    const g = emptyGarage({ name: 'Neue Garage' });
    state.garages.push(g);
    state.activeGarageId = g.id;
  }
  if (data?.editGarageId != null) {
    state.activeGarageId = data.editGarageId;
    state.step = 0;
  } else if (state.activeGarageId == null && state.garages.length) {
    state.activeGarageId = state.garages[0].id;
  }

  const root = $('#creator');
  const shell = document.querySelector('.creator-shell');
  root.classList.remove('hidden');
  shell?.classList.remove('is-closing');
  state.step = 0;
  renderStep();
}

function closeCreator() {
  const root = $('#creator');
  const shell = document.querySelector('.creator-shell');
  if (root.classList.contains('hidden')) return;
  closePlacement();
  shell?.classList.add('is-closing');
  setTimeout(() => {
    root.classList.add('hidden');
    shell?.classList.remove('is-closing');
    if (window.EC_NUI?.isEmbed) {
      window.parent.postMessage({ action: 'nuiClose', screen: 'creator' }, '*');
    }
  }, CREATOR_CLOSE_MS);
}

function initStaticIcons() {
  $('#btn-close').innerHTML = ICONS.close();
  $('#btn-new-garage').innerHTML = ICONS.plus();
  $('#btn-export').innerHTML = `${ICONS.export()} Export JSON`;
  $('#btn-save').innerHTML = `${ICONS.save()} Speichern`;
  $('#placement-confirm').innerHTML = `${ICONS.check()} Übernehmen`;
  const holo = $('#hologram-icon');
  if (holo) holo.innerHTML = VEHICLE_ICONS.land;
}

function init() {
  initStaticIcons();

  const body = $('#creator-body');
  body.addEventListener('input', onCreatorBodyInput);
  body.addEventListener('change', onCreatorBodyChange);
  body.addEventListener('click', onCreatorBodyClick);

  $('#step-nav').addEventListener('click', (e) => {
    const btn = e.target.closest('.step-btn');
    if (btn) {
      state.step = parseInt(btn.dataset.step, 10);
      renderStep();
    }
  });

  $('#garage-list').addEventListener('click', (e) => {
    const item = e.target.closest('.garage-item');
    if (!item) return;
    state.activeGarageId = item.dataset.id;
    renderStep();
  });

  $('#btn-new-garage').addEventListener('click', () => {
    const g = emptyGarage({ name: `Neue Garage ${state.garages.length + 1}` });
    state.garages.push(g);
    state.activeGarageId = g.id;
    state.step = 0;
    renderStep();
    showToast('Neue Garage erstellt');
  });

  $('#btn-close').addEventListener('click', closeCreator);
  $('#btn-save').addEventListener('click', saveGarage);
  $('#btn-export').addEventListener('click', exportJson);
  $('#placement-cancel').addEventListener('click', closePlacement);
  $('#placement-confirm').addEventListener('click', confirmPlacement);

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
    const data = event.data;
    if (data?.action === 'openCreator') openCreator(data);
    if (data?.action === 'closeCreator') closeCreator();
    if (data?.action === 'garagesSynced' && Array.isArray(data.garages)) {
      loadGaragesFromGame(data.garages);
      renderStep();
    }
    if (data?.action === 'placementSync' && data.position && state.placement) {
      state.placementPos = { ...data.position };
      updatePlacementUI();
    }
  });
}

init();

const isFiveM = typeof GetParentResourceName === 'function';
if (!isFiveM) {
  seedPreviewGarages();
  openCreator();
}
