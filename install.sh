#!/bin/sh
# Подключение списка wolframdomenelist к панели Re:HomeProxy на OpenWrt.
# Добавляет пункт в выпадающее меню источников на вкладке «Правила прокси».

JS="/www/luci-static/resources/view/homeproxy/client.js"
SRC="../../../../../wolfram0108/wolframdomenelist/releases/latest/download/domains"
# Только ASCII: кириллица при вставке через sed на busybox повреждается
TITLE="Wolfram domain list"
MARK="wolframdomenelist"

if [ ! -f "$JS" ]; then
	echo "Ошибка: не найден файл панели $JS"
	echo "Убедитесь, что установлен пакет luci-app-re-homeproxy."
	exit 1
fi

if grep -q "$MARK" "$JS"; then
	echo "Список уже подключён — ничего делать не нужно."
	echo "Откройте «Правила прокси» и выберите «$TITLE» в поле «Отправитель»."
	exit 0
fi

if ! grep -q "so.value('refilter'," "$JS"; then
	echo "Ошибка: не найдена точка вставки в $JS"
	echo "Вероятно, версия панели изменилась. Сообщите об этом в репозиторий списка."
	exit 1
fi

cp "$JS" "$JS.bak"

sed -i "s|so.value('refilter',|so.value('$SRC', _('$TITLE'));\n\t\t\tso.value('refilter',|" "$JS"

if grep -q "$MARK" "$JS"; then
	echo "Готово. Список подключён."
	echo
	echo "Дальше:"
	echo "  1. Обновите страницу панели с очисткой кэша — Ctrl+F5"
	echo "  2. Настройки клиента → Правила прокси → Добавить"
	echo "  3. Отправитель: $TITLE"
	echo "  4. Узел: Как основной узел"
	echo "  5. Применить, затем Диагностика → Перезапустить службу"
	echo
	echo "Резервная копия файла панели: $JS.bak"
else
	echo "Не удалось изменить файл, восстанавливаю из копии."
	mv "$JS.bak" "$JS"
	exit 1
fi
