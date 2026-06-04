/**
 * FiveM / iframe: kein Preview-Hintergrund, nur Panel wenn geöffnet.
 */
(function () {
  const isGame = typeof GetParentResourceName === 'function';
  const isEmbed = window.parent !== window;
  const isBrowserPreview = isEmbed && !isGame;
  window.EC_NUI = { isGame, isEmbed, isBrowserPreview };

  if (isGame || isEmbed) {
    document.documentElement.classList.add('nui-embed');
    const apply = () => document.body?.classList.add('nui-embed');
    if (document.body) apply();
    else document.addEventListener('DOMContentLoaded', apply);
  }
})();
