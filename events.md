---
layout: default
title: Galerie
permalink: /events/
---

<ul>
{% assign items = site.events | sort: "event_date" | reverse %}
{% for item in items %}
  <li>
    <a href="{{ item.url | relative_url }}">{{ item.title }}</a>
  </li>
{% endfor %}
</ul>
