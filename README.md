# wolframdomenelist

Список доменов для выборочного проксирования на роутере — заблокированные и ограниченные в России ресурсы.

Публикуется в двух видах:

| Файл | Что это |
|---|---|
| [`domains.lst`](domains.lst) | исходный список, по домену в строке — его и редактируем |
| `domains.srs` | скомпилированный набор правил sing-box, лежит в [релизах](../../releases/latest) |

Файл `domains.srs` пересобирается автоматически при каждом изменении `domains.lst` и публикуется в релизе `latest`.

## Подключение в Re:HomeProxy (OpenWrt)

Панель формирует адрес загрузки списка подстановкой значения источника, поэтому свой список подключается добавлением одного пункта в выпадающее меню.

Выполнить на роутере одной командой:

```sh
grep -q wolframdomenelist /www/luci-static/resources/view/homeproxy/client.js || sed -i "s|so.value('refilter',|so.value('../../../../../wolfram0108/wolframdomenelist/releases/latest/download/domains', _('Список Wolfram'));\n\t\t\tso.value('refilter',|" /www/luci-static/resources/view/homeproxy/client.js
```

Затем обновить страницу панели с очисткой кэша (`Ctrl+F5`) и добавить правило:

**Настройки клиента → Правила прокси → Добавить**

| Поле | Значение |
|---|---|
| Включить | ✔ |
| Отправитель | `Список Wolfram` |
| Узел | `Как основной узел` |

Нажать **Применить**. Список скачается автоматически и дальше будет обновляться раз в сутки.

> **Внимание.** Файл `client.js` принадлежит пакету панели, поэтому после обновления `luci-app-re-homeproxy` пункт меню пропадёт — команду нужно выполнить снова. Признак: пункт «Список Wolfram» исчез из выпадающего меню, правило перестало обновляться.

## Подключение в других клиентах

Прямая ссылка на набор правил:

```
https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.srs
```

Подходит для любого клиента на sing-box, где можно указать `rule_set` типа `remote`:

```json
{
  "type": "remote",
  "tag": "wolfram-domains",
  "format": "binary",
  "url": "https://github.com/wolfram0108/wolframdomenelist/releases/latest/download/domains.srs",
  "update_interval": "1d"
}
```

## Как дополнять список

1. Открыть [`domains.lst`](domains.lst), добавить домены — по одному в строке, без `http://` и `www.`
2. Сохранить изменения
3. Сборка запустится сама, через минуту обновлённый `domains.srs` появится в релизе

Правила совпадения — по суффиксу домена: запись `example.com` покрывает и `sub.example.com`.

Строки, начинающиеся с `#`, игнорируются — ими можно комментировать разделы.

## Сборка вручную

```sh
sing-box rule-set compile --output domains.srs domains.json
```

Посмотреть содержимое готового набора:

```sh
sing-box rule-set decompile domains.srs -o domains.json
```
