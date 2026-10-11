const menu = document.querySelector('.menu-toggle');
const navigation = document.querySelector('#navigation');
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
  button.addEventListener('click', async () => {
    const code = button.closest('.code-block').querySelector('code').textContent;
    try {
      await navigator.clipboard.writeText(code);
      button.textContent = 'Скопировано';
      document.querySelector('#copy-status').textContent = 'Текст скопирован в буфер обмена.';
    } catch {
      button.textContent = 'Выделите текст';
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(button.closest('.code-block').querySelector('code'));
      selection.removeAllRanges();
      selection.addRange(range);
      document.querySelector('#copy-status').textContent = 'Текст выделен. Скопируйте его вручную.';
    }
    setTimeout(() => { button.textContent = 'Копировать'; }, 2500);
  });
});
