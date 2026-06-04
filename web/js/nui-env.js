/**
 * FiveM / iframe: kein Preview-Hintergrund, nur Panel wenn geöffnet.
 */
(function () {
  const isGame = typeof GetParentResourceName === 'function';
  const isEmbed = window.parent !== window;
  window.EC_NUI = { isGame, isEmbed };

  if (isGame || isEmbed) {
    document.documentElement.classList.add('nui-embed');
    const apply = () => document.body?.classList.add('nui-embed');
    if (document.body) apply();
    else document.addEventListener('DOMContentLoaded', apply);
  }
})();
