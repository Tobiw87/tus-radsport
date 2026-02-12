---
layout: default
title: "News"
---

<div class="news-list">
  {% assign items = site.news | sort: "date" | reverse %}
  {% for item in items %}
    <article class="news-card">
      <h3><a href="{{ item.url | relative_url }}">{{ item.title }}</a></h3>
      <p><small>{{ item.date | date: "%d.%m.%Y" }}</small></p>
      <div class="news-excerpt">{{ item.excerpt }}</div>
      <p><a class="cta-btn" href="{{ item.url | relative_url }}">Mehr</a></p>
    </article>
  {% endfor %}
</div>

