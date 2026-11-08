// gk_compat: the copy button on code blocks, for a Redmine series whose core has none (GkCompat.can?(:code_copy_button)).
// The same markup the newer core draws: div.pre-wrapper around the pre, with a.copy-pre-content-link first in it, so that
// a plugin finds the button the same way on every series. Removed with the version file of the last series that needs it.
(function () {
  function copy(text, done) {
    function old() {
      var a = document.createElement('textarea');
      a.value = text; a.style.position = 'fixed'; a.style.insetInlineStart = '-9999px';
      document.body.appendChild(a); a.select();
      try { if (document.execCommand('copy')) done(); } catch (e) { /* nothing copied, nothing said */ }
      a.remove();
    }
    // navigator.clipboard, not the page's address, says whether it can be asked: as the newer core does it
    if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, old); else old();
  }

  function setup() {
    var cfg = window.GkCompatCodeCopy;
    if (!cfg) return;
    document.querySelectorAll('.wiki pre:not(.pre-wrapper pre)').forEach(function (pre) {
      var wrapper = document.createElement('div');
      wrapper.className = 'pre-wrapper';
      var button = document.createElement('a');
      button.className = 'copy-pre-content-link icon-only';
      button.title = cfg.title;
      button.innerHTML = cfg.icon;
      pre.parentNode.insertBefore(wrapper, pre);
      wrapper.appendChild(button);
      wrapper.appendChild(pre);
      button.addEventListener('click', function (e) {
        e.preventDefault();
        // what is copied, as the newer core does it: without the last line break, and without the space highlighted code ends in
        var text = (pre.querySelector('code') || pre).textContent;
        if (text.endsWith('\n')) text = text.slice(0, -1);
        if (pre.querySelector('code.syntaxhl') && text.endsWith(' ')) text = text.slice(0, -1);
        copy(text, function () {
          button.innerHTML = cfg.checked;
          setTimeout(function () { button.innerHTML = cfg.icon; }, 2000);
        });
      });
    });
  }

  // a text drawn later (a preview, a note that was edited, a part fetched by a script) gets its button too
  var waiting = false;
  function later() {
    if (waiting) return;
    waiting = true;
    window.requestAnimationFrame(function () { waiting = false; setup(); });
  }
  function start() {
    setup();
    new MutationObserver(later).observe(document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
