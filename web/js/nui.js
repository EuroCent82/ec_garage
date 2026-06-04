/**
 * NUI-Router: leer bis Garage oder Creator geöffnet wird.
 */
const garageFrame = document.getElementById('garage-frame');
const creatorFrame = document.getElementById('creator-frame');
let active = null;

function resourceName() {
  return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'ec_garage';
}

function postClose() {
  fetch(`https://${resourceName()}/close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: '{}',
  }).catch(() => {});
}

function hideAll() {
  garageFrame.classList.add('hidden');
  creatorFrame.classList.add('hidden');
  active = null;
}

function loadFrame(frame, src, payload, messageAction) {
  const send = () => {
    const data = { ...(payload || {}) };
    delete data.action;
    data.action = messageAction;
    frame.contentWindow.postMessage(data, '*');
  };

  if (frame.dataset.ready === '1') {
    send();
    return;
  }

  frame.src = src;
  frame.onload = () => {
    frame.dataset.ready = '1';
    frame.onload = null;
    requestAnimationFrame(() => {
      requestAnimationFrame(send);
    });
  };
}

function showGarage(payload) {
  hideAll();
  garageFrame.classList.remove('hidden');
  active = 'garage';
  loadFrame(garageFrame, 'index.html', payload, 'open');
}

function showCreator(payload) {
  hideAll();
  creatorFrame.classList.remove('hidden');
  active = 'creator';
  loadFrame(creatorFrame, 'creator.html', payload, 'openCreator');
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data?.action) return;

  switch (data.action) {
    case 'open':
    case 'openGarage':
      showGarage(data);
      break;
    case 'openCreator':
      showCreator(data);
      break;
    case 'close':
      if (active === 'garage' && garageFrame.dataset.ready === '1') {
        garageFrame.contentWindow.postMessage({ action: 'close' }, '*');
      }
      hideAll();
      break;
    case 'closeCreator':
      if (active === 'creator' && creatorFrame.dataset.ready === '1') {
        creatorFrame.contentWindow.postMessage({ action: 'closeCreator' }, '*');
      }
      hideAll();
      break;
    default:
      break;
  }
});

window.addEventListener('message', (event) => {
  if (event.source === window) return;
  if (event.data?.action !== 'nuiClose') return;
  hideAll();
  postClose();
});
