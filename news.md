---
layout: default
title: "News"
---

<div class="news-list">
  {% assign items = site.news | sort: "date" | reverse %}
  {% for item in items %}
    <article class="news-card">
      <h3>{{ item.title }}</h3>
      <div class="news-excerpt">{{ item.excerpt }}</div>
      <p><a class="news-more" href="{{ item.url | relative_url }}">Mehr</a></p>
    </article>
  {% endfor %}
</div>

