const menu = document.querySelector('.menu-toggle');
const navigation = document.querySelector('#navigation');
const themeButton = document.querySelector('.theme-toggle');
const systemTheme = window.matchMedia('(prefers-color-scheme: dark)');
let savedTheme;
try { savedTheme = localStorage.getItem('fdd-theme'); } catch { /* Use system preference. */ }
let hasThemePreference = savedTheme === 'light' || savedTheme === 'dark';
function applyTheme(theme) {
  const dark = theme === 'dark';
  document.documentElement.dataset.theme = theme;
  themeButton.setAttribute('aria-pressed', String(dark));
  const label = document.documentElement.lang === 'uk'
    ? (dark ? 'Увімкнути світлу тему' : 'Увімкнути темну тему')
    : (dark ? 'Switch to light theme' : 'Switch to dark theme');
  themeButton.setAttribute('aria-label', label);
  themeButton.title = label;
  document.querySelector('meta[name="theme-color"]').content = dark ? '#1c1e1b' : '#f5f3ed';
}
applyTheme(document.documentElement.dataset.theme);
themeButton.addEventListener('click', () => {
  const theme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
  hasThemePreference = true;
  applyTheme(theme);
  try { localStorage.setItem('fdd-theme', theme); } catch { /* The toggle still works without storage. */ }
});
systemTheme.addEventListener('change', event => {
  if (!hasThemePreference) applyTheme(event.matches ? 'dark' : 'light');
});
window.addEventListener('storage', event => {
  if (event.key !== 'fdd-theme') return;
  hasThemePreference = event.newValue === 'light' || event.newValue === 'dark';
  applyTheme(hasThemePreference ? event.newValue : (systemTheme.matches ? 'dark' : 'light'));
});
menu.addEventListener('click', () => {
  const open = menu.getAttribute('aria-expanded') !== 'true';
  menu.setAttribute('aria-expanded', String(open));
  navigation.classList.toggle('open', open);
});
navigation.addEventListener('click', event => {
  if (event.target.closest('a')) {
    menu.setAttribute('aria-expanded', 'false');
    navigation.classList.remove('open');
  }
});
const links = [...navigation.querySelectorAll('a')];
const sections = links.map(link => document.querySelector(link.getAttribute('href')));
function updateNavigation() {
  let current = sections[0];
  for (const section of sections) {
    if (section.getBoundingClientRect().top <= 160) current = section;
  }
  for (const link of links) {
    const active = link.hash === `#${current.id}`;
    link.classList.toggle('active', active);
    if (active) link.setAttribute('aria-current', 'location');
    else link.removeAttribute('aria-current');
  }
}
window.addEventListener('scroll', updateNavigation, { passive: true });
updateNavigation();
document.querySelectorAll('.copy-button').forEach(button => {
  const ukrainian = document.documentElement.lang === 'uk';
  const messages = ukrainian
    ? { copy: 'Копіювати', copied: 'Скопійовано', select: 'Виділіть текст', success: 'Текст скопійовано до буфера обміну.', fallback: 'Текст виділено. Скопіюйте його вручну.' }
    : { copy: 'Copy', copied: 'Copied', select: 'Select text', success: 'Text copied to the clipboard.', fallback: 'Text selected. Copy it manually.' };
  button.addEventListener('click', async () => {
    const code = button.closest('.code-block').querySelector('code').textContent;
    try {
      await navigator.clipboard.writeText(code);
      button.textContent = messages.copied;
      document.querySelector('#copy-status').textContent = messages.success;
    } catch {
      button.textContent = messages.select;
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(button.closest('.code-block').querySelector('code'));
      selection.removeAllRanges();
      selection.addRange(range);
      document.querySelector('#copy-status').textContent = messages.fallback;
    }
    setTimeout(() => { button.textContent = messages.copy; }, 2500);
  });
});
// Keep the reader in the same section when switching languages.
document.querySelectorAll('.language-switch a').forEach(link => {
  const path = link.getAttribute('href');
  function updateLanguageLink() { link.setAttribute('href', path + window.location.hash); }
  window.addEventListener('hashchange', updateLanguageLink);
  updateLanguageLink();
});
