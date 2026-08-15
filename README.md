# wolframdomenelist

Список доменов для выборочного проксирования на роутере — заблокированные и ограниченные в России ресурсы.

## Форматы

Один и тот же список публикуется в четырёх видах — берите тот, который понимает ваш инструмент.

| Файл | Формат | Кому нужен |
|---|---|---|
| [`domains.lst`](domains.lst) | простой текст, **исходник** — его и редактируем | человеку |
| [`domains.txt`](domains.txt) | простой текст, нормализованный: без дублей, пустых строк и комментариев, отсортирован | zapret, keen-pbr, AdGuard Home, dnsmasq, скрипты |
| [`domains.json`](domains.json) | sing-box rule-set, `format: source` | podkop и клиенты sing-box, которым нужен исходник |
| `domains.srs` | sing-box rule-set, `format: binary` — только в [релизах](../../releases/latest) | клиенты sing-box; втрое меньше и не требует парсинга на роутере |

`domains.txt`, `domains.json` и `domains.srs` пересобираются автоматически при каждом изменении
`domains.lst`. Первые два коммитятся обратно в `main` (чтобы не устаревали `raw`-ссылки), все —
выкладываются в релиз `latest`.

### Ссылки

Из ветки `main` (обновляются сразу после сборки):

```
https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/domains.txt
https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/domains.json
```

Из релиза `latest`:

```
https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.srs
https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.json
https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.txt
```

## Подключение в Podkop (OpenWrt)

**Настройки → секция `main` → «Remote domain lists»** («Удалённые списки доменов») — вписать:

```
https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/domains.json
```

Или командой на роутере:

```sh
uci add_list podkop.main.remote_domain_lists='https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/domains.json'
uci commit podkop && /etc/init.d/podkop restart
```

Podkop определяет формат **по расширению файла**: `.json` → `source`, `.srs` → `binary`, всё
остальное отвергает с ошибкой `Unsupported file extension`. Поэтому `domains.txt` и `domains.lst`
сюда подставлять нельзя — только `.json` или `.srs`.

Проверка, что список подхватился:

```sh
nslookup 4pda.to 127.0.0.1     # домен из списка → адрес из fake-IP диапазона 198.18.0.0/15
nslookup ya.ru   127.0.0.1     # домена нет в списке → настоящий адрес
```

## Подключение в других клиентах sing-box

```json
{
  "type": "remote",
  "tag": "wolfram-domains",
  "format": "binary",
  "url": "https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.srs",
  "update_interval": "1d"
}
```

## Подключение там, где нужен простой текст

`domains.txt` — по домену в строке, без комментариев и пустых строк. Годится для zapret
(`zapret-hosts-user.txt`), keen-pbr, AdGuard Home, dnsmasq-скриптов:

```sh
wget -qO /opt/zapret2/ipset/zapret-hosts-user.txt \
  https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/domains.txt
```

## Как дополнять список

1. Открыть [`domains.lst`](domains.lst), добавить домены — по одному в строке, без `http://` и `www.`
2. Сохранить изменения
3. Сборка запустится сама: через минуту обновятся `domains.txt`, `domains.json` и релиз с `domains.srs`

Правила совпадения — по суффиксу домена: запись `example.com` покрывает и `sub.example.com`.

Строки, начинающиеся с `#`, игнорируются — ими можно комментировать разделы. В `domains.txt` и
`domains.json` они не попадают.

## Сборка вручную

```sh
# простой текст
grep -vE '^\s*(#|$)' domains.lst | sort -u > domains.txt

# sing-box
sing-box rule-set compile --output domains.srs domains.json
```

Посмотреть содержимое готового набора:

```sh
sing-box rule-set decompile domains.srs -o domains.json
```

---

<details>
<summary>Устаревшее: подключение в Re:HomeProxy</summary>

Панель Re:HomeProxy больше не используется (снята с роутера 15.08.2026 в пользу podkop). Раздел
оставлен на случай возврата.

Панель формирует адрес загрузки списка подстановкой значения источника, поэтому свой список
подключался добавлением одного пункта в выпадающее меню:

```sh
wget -qO- https://raw.githubusercontent.com/wolfram0108/wolframdomenelist/main/install.sh | sh
```

Затем обновить страницу панели с очисткой кэша (`Ctrl+F5`) и добавить правило:
**Настройки клиента → Правила прокси → Добавить**, отправитель `Wolfram domain list`, узел
«Как основной узел».

Файл `client.js` принадлежит пакету панели, поэтому после обновления `luci-app-re-homeproxy` пункт
меню пропадал и команду нужно было выполнять снова. Отключение — восстановлением файла из копии:

```sh
mv /www/luci-static/resources/view/homeproxy/client.js.bak /www/luci-static/resources/view/homeproxy/client.js
```

</details>
