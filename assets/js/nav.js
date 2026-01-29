const toggle = document.querySelector('.nav-toggle');
const nav = document.getElementById('site-nav');
const links = nav.querySelectorAll('a');

toggle.addEventListener('click', () => {
  const open = nav.classList.toggle('is-open');
  toggle.setAttribute('aria-expanded', open);
});

links.forEach(link => {
  link.addEventListener('click', () => {
    nav.classList.remove('is-open');
    toggle.setAttribute('aria-expanded', 'false');
  });
});
