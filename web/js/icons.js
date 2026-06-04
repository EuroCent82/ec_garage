/**
 * EC Garage – Font Awesome 6 Icons (lokal: vendor/fontawesome)
 */

function fa(name, style = 'solid', extraClass = '') {
  const styleClass = style === 'regular' ? 'fa-regular'
    : style === 'brands' ? 'fa-brands'
    : 'fa-solid';
  const extra = extraClass ? ` ${extraClass}` : '';
  return `<i class="${styleClass} fa-${name} icon${extra}" aria-hidden="true"></i>`;
}

const ICONS = {
  close: () => fa('xmark'),
  search: () => fa('magnifying-glass'),
  star: (filled = true) => (filled ? fa('star') : fa('star', 'regular')),
  grid: () => fa('table-cells'),
  clock: () => fa('clock'),
  warning: () => fa('triangle-exclamation'),
  mapPin: () => fa('location-dot'),
  mapMarked: () => fa('map-location-dot'),
  pen: () => fa('pen'),
  arrowRight: () => fa('arrow-right'),
  arrowLeft: () => fa('arrow-left'),
  trash: () => fa('trash'),
  plus: () => fa('plus'),
  check: () => fa('check'),
  gear: () => fa('gear'),
  gasPump: () => fa('gas-pump'),
  shield: () => fa('shield-halved'),
  engine: () => fa('oil-can'),
  mileage: () => fa('gauge-high'),
  export: () => fa('file-export'),
  save: () => fa('floppy-disk'),
  garage: () => fa('warehouse'),
  carSide: () => fa('car-side'),
  helicopter: () => fa('helicopter'),
  ship: () => fa('ship'),
  parking: () => fa('square-parking'),
  circleDot: () => fa('circle-dot'),
  crosshairs: () => fa('crosshairs'),
  layerGroup: () => fa('layer-group'),
  tag: () => fa('tag'),
  users: () => fa('users'),
  blip: () => fa('map'),
};

const VEHICLE_ICONS = {
  land: fa('car-side', 'solid', 'icon--vehicle'),
  air: fa('helicopter', 'solid', 'icon--vehicle'),
  water: fa('ship', 'solid', 'icon--vehicle'),
};

const STAT_ICONS = {
  Tank: fa('gas-pump', 'solid', 'stat-icon stat-icon--fuel'),
  Karosserie: fa('shield-halved', 'solid', 'stat-icon stat-icon--body'),
  Motor: fa('oil-can', 'solid', 'stat-icon stat-icon--engine'),
};

function vehicleCardImageHtml(v) {
  const brand = (v.model || '').split(' ')[0].toUpperCase();
  const cat = v.category || 'land';
  return `
    <div class="card-image-fa card-image-fa--${cat}">
      <span class="card-image-fa__brand">${brand}</span>
      ${VEHICLE_ICONS[cat] || VEHICLE_ICONS.land}
      <span class="card-image-fa__model">${(v.modelKey || '').toUpperCase()}</span>
    </div>`;
}

/** @deprecated – Silhouetten durch FA ersetzt */
const VEHICLE_SILHOUETTES = {};
