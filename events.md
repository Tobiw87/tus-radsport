---
layout: default
title: Events
permalink: /event/
---

<ul>
{% assign items = site.events | sort: "event_date" | reverse %}
{% for item in items %}
  <li>
    <a href="{{ item.url | relative_url }}">{{ item.title }}</a>
  </li>
{% endfor %}
</ul>
