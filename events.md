---
layout: default
title: Events
---


<ul>
{% raw %}
{% assign items = site.events | sort: "date" | reverse %}
{% for item in items %}
  <li>
    <a href="{{ item.url }}">{{ item.title }}</a>
    – {{ item.date | date: "%d.%m.%Y" }}
  </li>
{% endfor %}
{% endraw %}
</ul>
