# NFQWS-MENU

Интерактивное меню установки и управления пакетами **nfqws-keenetic**, **nfqws2-keenetic** и **nfqws-keenetic-web** для роутеров **Keenetic / Netcraze** с **Entware**.

Репозиторий также служит хранилищем готовых **стратегий** обхода DPI, **blobs** и **lists**.

- Скрипт: [`nfqws-menu.sh`](nfqws-menu.sh) (текущая версия **0.6.40**)
- Стратегии: [`strategies/`](strategies/)
- Hosts: [`hosts`](hosts)
- Контрольные суммы: [`SHA256SUMS`](SHA256SUMS), [`strategies/blobs/SHA256SUMS`](strategies/blobs/SHA256SUMS)

### Официальные проекты

| Пакет | Репозиторий |
| --- | --- |
| nfqws-keenetic (v1) | https://github.com/nfqws/nfqws-keenetic |
| nfqws2-keenetic (v2) | https://github.com/nfqws/nfqws2-keenetic |
| Веб-интерфейс | https://github.com/nfqws/nfqws-keenetic-web |

### Источник стратегий

Стратегии в этом репозитории сделаны на базе проекта\
[**Flowseal/zapret-discord-youtube**](https://github.com/Flowseal/zapret-discord-youtube)\
и адаптированы под формат конфигов `nfqws-keenetic` / `nfqws2-keenetic`.

Подготовлены пользователем [**@Nare51**](https://github.com/Nare51) с использованием искусственного интеллекта.

---

## Быстрый старт

Подключитесь к Entware (SSH, порт 222 или 22, логин `root`):

```bash
opkg update && opkg install curl libnghttp2 && curl -sSL https://raw.githubusercontent.com/rndnaame/nfqws-menu/main/nfqws-menu.sh -o /opt/nfqws-menu.sh && sh /opt/nfqws-menu.sh
```

или с wget:

```bash
wget -O /opt/nfqws-menu.sh https://raw.githubusercontent.com/rndnaame/nfqws-menu/main/nfqws-menu.sh && chmod +x /opt/nfqws-menu.sh && sh /opt/nfqws-menu.sh
```

После первого запуска создаётся symlink для быстрого старта:

```bash
menu
```

(`/opt/bin/menu` → `/opt/nfqws-menu.sh`)

---

## Что делает меню

При запуске скрипт:

1. Определяет архитектуру процессора (`aarch64` / `mipsel` / `mips` …) — с кэшированием.
2. Показывает **только установленные** компоненты (версии и статус):
   - пакеты NFQWS / web, usque-keenetic, tg-ws-proxy, magitrickle;
   - dpi-detector, awg-manager (`[+SB]` при наличии sing-box), KeenKit;
   - другие сервисы из `/opt/etc/init.d/`;
   - **⚡** — сервис запущен.
3. Предлагает меню:

```
[::]  КОМПОНЕНТЫ
      1.  Установить NFQWS/NFQWS2
      2.  Установить веб-интерфейс

[::]  СТРАТЕГИИ/СПИСКИ
      3.  Выбор стратегии
      4.  Обновить IPSet List
      5.  Загрузить rkn.list (125k+ доменов)
      6.  Обход блокировки DoT/DoH
      7.  Смена активных fake:blob
      8.  Обновление hosts
      9.  Управление DoT/DoH

[::]  УТИЛИТЫ
      10. dpi-detector
      11. awg-manager
      12. KeenKit
      13. TG WS Proxy Go
      14. usque-keenetic
      15. MagiTrickle

[::]  СЕРВИС
      77. Change language
      88. Удаление пакетов

      99. Обновить скрипт
      00. Выход
```

Пример блока статуса:

```
Установленные компоненты:
  nfqws2-keenetic        1.2.6 ⚡
  nfqws-keenetic-web     3.0.23 ⚡
  dpi-detector           5.0.0-alpha.6
  awg-manager [+SB]      2.18.0
  KeenKit                2.8.7
  magitrickle            ...
```

### 1. Установка NFQWS / NFQWS2

- Выбор версии: **nfqws-keenetic** (v1) или **nfqws2-keenetic** (v2).
- Установка зависимостей (`ca-certificates`, `wget-ssl`, удаление `wget-nossl`).
- Добавление официального opkg-репозитория под архитектуру.
- Установка пакета.
- Предложение установить веб-интерфейс.

> При установке v2, если уже стоит v1, скрипт предложит удалить старый пакет (рекомендуется).

### 2. Установка веб-интерфейса

Устанавливает `nfqws-keenetic-web` (lighttpd + PHP на порту **90**).

- Адрес: `http://<IP-роутера>:90`
- Логин/пароль — учётные данные Entware (по умолчанию `root` / `keenetic`).

### 3. Установка стратегии

- Если ни одна версия NFQWS не установлена — предлагает установить.
- Показывает список `.conf` из:
  - `strategies/nfqws1/` — для v1
  - `strategies/nfqws2/` — для v2
- Список стратегий: сначала из корневого **`SHA256SUMS`** (без GitHub API), при недоступности — GitHub Contents API.
- Скачивает выбранный файл, делает **бэкап** текущего конфига и применяет стратегию.
- Перед записью **нормализует CRLF → LF** (Windows-переводы строк в `.conf` иначе ломают `source` и iptables: `: not found`, `invalid port/service`).
- После применения выполняет пост-настройку:

#### ISP_INTERFACE / IPV6_ENABLED

- Определяет интерфейс провайдера из default route (`ip route` / `route`), сравнивает с `ISP_INTERFACE` в конфиге и при необходимости предлагает установить правильное значение. При чтении значения снимаются `\r`, кавычки и пробелы (защита от CRLF в выводе меню).
- Проверяет наличие **глобального IPv6** (`2a00*`) на интерфейсе провайдера и выставляет `IPV6_ENABLED=0|1` в конфиге.

#### Восстановление rkn.list

Если до смены стратегии в `MODE_LIST` уже был `--hostlist=…/rkn.list`, привязка **восстанавливается** после применения новой стратегии (полный `.conf` иначе затёр бы её).

#### Проверка blobs (наличие + SHA256)

Парсит установленный конфиг и находит используемые `.bin` (`--blob=…`, `--dpi-desync-fake-tls=…`, `--dpi-desync-fake-quic=…` и абсолютные пути).

- Сверяет локальные файлы с эталоном [`strategies/blobs/SHA256SUMS`](strategies/blobs/SHA256SUMS) (`sha256sum` или `openssl dgst -sha256`; кэш SUMS ~1 ч).
- Отсутствующие или **устаревшие/повреждённые** (хеш не совпал) предлагает скачать заново; после загрузки — повторная проверка SHA256 (при несовпадении файл удаляется).

#### Обновление lists

По запросу обновляет из `strategies/lists/`: `user.list`, `exclude.list`, `ipset.list`, `ipset_exclude.list`.  
`auto.list` **не трогается** — его заполняет демон.

После всех шагов соответствующий сервис перезапускается.

### 4. Обновление IPSet List

Скачивает актуальный IP/CIDR-список из\
[Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube)\
и записывает в `ipset.list`:

| Версия | Путь |
| --- | --- |
| nfqws-keenetic (v1) | `/opt/etc/nfqws/ipset.list` |
| nfqws2-keenetic (v2) | `/opt/etc/nfqws2/lists/ipset.list` |

Бэкап, очистка пустых строк/комментариев, перезапуск сервиса. При двух установленных версиях — можно обновить обе.

### 5. Загрузить rkn.list (125k+ доменов)

Доступно при установленном **nfqws-keenetic** (v1) и/или **nfqws2-keenetic** (v2). При обеих версиях — выбор: 1 / 2 / обе.

- Если `rkn.list` уже есть — показывает размер в **КБ** (без медленного подсчёта 125k строк) и спрашивает, обновлять ли список (**по умолчанию: Нет**). При отказе скачивание пропускается.
- Скачивает большой список доменов РКН из [IndeecFOX/zapret4rocket](https://github.com/IndeecFOX/zapret4rocket)\
  (`extra_strats/TCP/RKN/List.txt`). При недоступности GitHub — зеркало `mizulina.shit.vc` (как в zapret4rocket/z4r).
- Записывает:
  - **v1** → `/opt/etc/nfqws/rkn.list`
  - **v2** → `/opt/etc/nfqws2/lists/rkn.list`
- Добавляет `--hostlist=…/rkn.list` в `MODE_LIST` соответствующего конфига (с бэкапом), если его ещё нет. Вставка через **awk** (устойчиво к CRLF, пробелам, пустым кавычкам).
- **Перезапуск** сервиса (`S51nfqws` / `S51nfqws2`) только при реальных изменениях (обновлён список и/или изменён `MODE_LIST`). Если hostlist уже был в конфиге и список не обновляли — перезапуск не выполняется.

### 6. Обход блокировки DoT/DoH

Только при установленном **nfqws2-keenetic**.

Добавляет в `NFQWS_ARGS_CUSTOM` стратегию обхода блокировок публичных DoT/DoH DNS (Cloudflare, Google, AdGuard, NextDNS, Quad9 и др.), при необходимости добавляет порт `853` в `TCP_PORTS` / `UDP_PORTS`, перезапускает `S51nfqws2`.

### 7. Смена активных fake:blob

Позволяет заменить используемые в конфиге `fake:blob=NAME` на другой `.bin`-файл (переназначает путь в `--blob=NAME:…`).

- Быстрый разбор конфига (v1/v2) одним проходом **awk**: секции `NFQWS_*ARGS*`, map `--blob=name:path`, уникальные `fake:blob=` (hex пропускаются).
- Показывает список найденных имён по секциям.
- Кандидаты `.bin`: локальные → имена из **`strategies/blobs/SHA256SUMS`** → GitHub API → встроенный fallback.
- При выборе файла из репозитория — скачивает его, обновляет `--blob=…`, бэкап конфига.
- Перезапуск сервиса — по подтверждению (по умолчанию Да).

### 8. Обновление hosts

Запись статических DNS-привязок на стороне **Keenetic** через `ndmc` (`ip host DOMAIN IP` / `no ip host DOMAIN` + сохранение конфигурации).

- Скачивает файл `hosts` из репозитория.
- Секции задаются комментариями `# Имя секции`; внутри — строки `IP DOMAIN`.
- Можно выбрать одну или несколько секций, **все**, либо **88** — удалить домены из hosts-файла.
- Только **IPv4**; битые домены (`..`, ведущая `.`) пропускаются; **один IP на домен**.
- Предупреждение, если уникальных записей **&gt; 64** (лимит Keenetic `ip host`).
- Нужен `ndmc` (только Keenetic / Netcraze OS).

### 9. Управление DoT/DoH

Управление DNS-over-TLS / DNS-over-HTTPS на стороне **Keenetic** через `ndmc`.

Подменю:

```
1) Добавить DoT сервер(ы)
2) Добавить DoH сервер(ы)
3) Привязать домен к DNS (Пресеты)
4) Удалить сервер(ы)
0) Назад
```

Возможности:

- Просмотр текущих DoT/DoH и персональных привязок к доменам
- Счётчик слотов **N/8** — только секция **System** (Policy0/1 и `*-filters` не учитываются)
- Пресеты DoT/DoH: Яндекс, Cloudflare, Google, Quad9, CleanBrowsing, OpenDNS, DNS.SB, dns0.eu, OpenNameServer, AdGuard (Default/Family), ControlD Free, DNS4EU (Protective/Unfiltered), Alibaba DNS, DNSPod, Proxy-DNS, Cloudflare Gateway и др. (Tiar Japan убраны) или ручной ввод
- Быстрая привязка доменов (пресеты):

| № | Описание |
| --- | --- |
| 1 | CleanBrowsing DoT → instagram.com |
| 2 | CleanBrowsing DoH → instagram.com |
| 3 | sw.ext.io DoT → rutor.is & rutor.info |
| 4 | Malw Link DoH → ntc.party |
| 5 | Xbox-DNS DoT → gql.twitch.tv & usher.ttvnw.net |
| 6 | Xbox-DNS DoH → gql.twitch.tv & usher.ttvnw.net |
| 7 | Ввести свой домен и выбрать сервер |

- Удаление upstream-ов с сохранением конфигурации

> Нужен `ndmc` (CLI Keenetic/Netcraze).\
> При активном **Интернет-фильтре** часть DoT может помечаться как *disregarded*.

### 10. dpi-detector

Инструмент для анализа цензуры трафика в России: обнаруживает и классифицирует блокировки сайтов, хостингов и CDN (TCP16–20 блокировки), а также подмену DNS-запросов провайдером.

Актуальная версия [dpi-detector](https://github.com/Runnin4ik/dpi-detector) (ветка `rust`):

```bash
curl -fsSL https://raw.githubusercontent.com/Runnin4ik/dpi-detector/rust/install.sh | sh
```

Если бинарник уже есть (`/opt/bin/dpi-detector`) — очищает дубликаты (`/tmp`, `/opt/root`) и сразу запускает его. После установки — та же очистка дубликатов.

### 11. awg-manager

Веб-интерфейс для управления AmneziaWG VPN-туннелями на роутерах Keenetic. В тестовом режиме добавлена поддержка Sing-box (vless tcp, hysteria, trojan и др.).

Установщик [awg-compressed](https://github.com/rndnaame/awg-compressed):

```bash
curl -sL https://raw.githubusercontent.com/rndnaame/awg-compressed/main/install-compressed.sh | sh
```

В статусе: `awg-manager` или `awg-manager [+SB]` при наличии sing-box.

### 12. KeenKit

Многофункциональный скрипт, упрощающий взаимодействие с роутером на базе KeeneticOS.

- Есть `/opt/keenkit.sh` — **сразу запускает**.
- Иначе — установщик [KeenKit](https://github.com/spatiumstas/KeenKit).

### 13. TG WS Proxy Go

Локальный MTProto-прокси для Telegram Desktop, который ускоряет работу Telegram, перенаправляя трафик через WebSocket-соединения. Данные передаются в том же зашифрованном виде, а для работы не нужны сторонние серверы.

Установка / обновление [tg-ws-proxy](https://github.com/spatiumstas/tg-ws-proxy-go):

- Уже установлен → `opkg update && opkg upgrade tg-ws-proxy`
- Не установлен → репозиторий feedly + `opkg install tg-ws-proxy`

```bash
curl -fsSL https://raw.githubusercontent.com/spatiumstas/feedly/main/add-repo.sh | sh
opkg install tg-ws-proxy
```

Конфиги: `/opt/etc/tg-ws-proxy/config.conf`, `secret.conf`\
Init: `/opt/etc/init.d/S99tg-ws-proxy` (start / stop / status / restart)

### 14. usque-keenetic

Адаптация неофициального клиента Cloudflare WARP с режимом MASQUE для роутеров Keenetic / Netcraze.

Установка / обновление [usque-keenetic](https://side-effect-tm.github.io/usque-keenetic/):

- **Не установлен** — репозиторий под архитектуру + установка:

```bash
mkdir -p /opt/etc/opkg
echo "src/gz usque-keenetic https://side-effect-tm.github.io/usque-keenetic/$ARCH" > /opt/etc/opkg/usque-keenetic.conf
opkg update
opkg install usque-keenetic
```

- **Установлен** → `opkg update && opkg upgrade usque-keenetic`
- Init: `/opt/etc/init.d/S51usque` (start | stop | restart)
- Конфиг: `/opt/etc/usque/usque.conf`

```
# Интерфейс. Определяется автоматически при установке.
# Должен быть вида opkgtun*
IFACE="opkgtun0"
```

### 15. MagiTrickle

Утилита для точечной маршрутизации сетевого трафика по заданным доменным именам.

Установка / обновление [MagiTrickle](http://bin.magitrickle.dev/):

- **Не установлен** — добавление репозитория (`add_repo.sh`) + `opkg install magitrickle` + `S99magitrickle start`
- **Установлен** → `opkg update && opkg install magitrickle` + restart сервиса
- Init: `/opt/etc/init.d/S99magitrickle` (start | stop | restart | status)
- Удаление — в п. 88 (с опциональным удалением `/opt/etc/opkg/magitrickle.conf`)

### 77. Change language

Мгновенное переключение интерфейса **ru ↔ en** (файл `/opt/etc/nfqws-menu.lang`).

### 88. Удаление пакетов

Показывает установленные компоненты и позволяет удалить выборочно:

```
Удаление:
  [N] nfqws2-keenetic / nfqws-keenetic-web / dpi-detector /
      awg-manager / tg-ws-proxy / usque-keenetic /
      magitrickle / opera-proxy / KeenKit
  [a] Удалить все пакеты NFQWS
  [b] Удалить резервные копии (.bak.* / *-opkg)
  [0] Назад
```

- Пакеты NFQWS — `opkg remove --autoremove`
- **dpi-detector** — бинарник (`/opt/bin/dpi-detector` и др.)
- **awg-manager** — `opkg remove` + `rm -rf /opt/etc/awg-manager`
- **tg-ws-proxy** — `opkg remove` + запрос на удаление `/opt/etc/opkg/feedly.conf`
- **usque-keenetic** — `opkg remove --autoremove` + `/opt/etc/opkg/usque-keenetic.conf`
- **magitrickle** — `opkg remove` + запрос на удаление `/opt/etc/opkg/magitrickle.conf`
- **KeenKit** — удаление `/opt/keenkit.sh`
- **a)** — все пакеты NFQWS + dpi-detector
- **b)** — `*.bak.*`, `*.conf-opkg`, `*.list-opkg` в `/opt/etc/nfqws/`, `/opt/etc/nfqws2/`, `/opt/etc/nfqws2/lists/`

### 99. Обновить скрипт

Скачивает свежую версию из репозитория, перезаписывает `/opt/nfqws-menu.sh`, обновляет symlink `/opt/bin/menu`, сразу перезапускает меню (`exec`).

---

## Changelog

### 0.6.40

- **Таймауты загрузок** — увеличены для сильного DPI: connect 10 с, max 30 с, wget 25 с (раньше 5 / 15 / 12)
- **п. 5 rkn.list** — при недоступности GitHub raw пробуется зеркало `http://mizulina.shit.vc:666/...` (как в zapret4rocket); URL основного источника упрощён (`…/master/…` без `refs/heads`)

### 0.6.36 – 0.6.39

- **LBL_*** — подписи пунктов совпадают с номерами меню (`LBL_5`…`LBL_9`; удалён `LBL_7F`)
- **DoT/DoH пресеты** — Google, AdGuard Default/Family, ControlD Free, DNS4EU, Alibaba DNS, DNSPod; убраны нерабочие Tiar Japan
- **proc_running** — `grep -qF --` (fix при именах сервисов с ведущим `-`)

### 0.6.26 – 0.6.35

- **SHA256 blobs** — проверка локальных `.bin` по `strategies/blobs/SHA256SUMS`; перекачка при несовпадении хеша
- **Список стратегий** — из корневого `SHA256SUMS` (без GitHub API), API как fallback
- **Список blobs** (п. 7) — приоритет SUMS → API → fallback
- **Загрузки** — при блокировке основного канала `curl --interface` через туннели (`awg0`, `t2s0`, `nwg0`, `opkgtun0`, …); короткие таймауты
- **CI** — workflow `.github/workflows/sha256sums.yml` обновляет `SHA256SUMS` и `strategies/blobs/SHA256SUMS` (push / daily / manual)
- **п. 3** — авто `IPV6_ENABLED` по наличию глобального IPv6 на ISP-интерфейсе; сохранение привязки **rkn.list** в `MODE_LIST` при смене стратегии
- **DNS (п. 9)** — парсер только секция System (`proxy-tls` / `proxy-https`); Policy* и `*-filters` игнорируются

### 0.6.23 – 0.6.25

- **п. 5** — поддержка **v1 и v2** (выбор 1 / 2 / обе); размер существующего `rkn.list` в КБ вместо подсчёта строк
- **п. 5** — вставка в `MODE_LIST` через **awk** (CRLF, пустые кавычки, пробелы)
- **п. 10** — очистка дубликатов `dpi-detector` (`/tmp`, `/opt/root`) перед запуском / после установки

### 0.6.22

- **п. 8** — только IPv4; пропуск битых доменов (`..`, ведущая `.`); один IP на домен; предупреждение при &gt;64 записей (лимит Keenetic)
- **hosts** — исправлены `objects.githubusercontent.com`, `my.telegram.org`; убраны IPv6 и дубли discord

### 0.6.19 – 0.6.21

- **п. 3** — при применении стратегии: нормализация **CRLF → LF** в скачанном `.conf` (иначе `S51nfqws2` падает с `: not found` / битыми портами iptables)
- **ISP_INTERFACE** — при разборе значения из конфига удаляются `\r` и кавычки (исправлен «съехавший» вывод `[+]` → `"+]`)
- **п. 8** — **Обновление hosts**: секции из `hosts` в репозитории → `ndmc ip host` / удаление (`no ip host`) + save

### 0.6.18

- **п. 7** — ускорен разбор конфига: один проход `awk` вместо shell+grep на каждую строку

### 0.6.16 – 0.6.17

- **п. 5** — если `rkn.list` уже есть, спрашивает об обновлении (по умолчанию **Нет**)
- **п. 5** — перезапуск `S51nfqws2` только при изменениях (список и/или `MODE_LIST`)

### 0.6.15

- Базовая линейка 0.6.x (см. ниже)

### 0.6.x (основные изменения относительно 0.5.x)

- **п. 5** — загрузка **rkn.list** (125k+ доменов, zapret4rocket) + автодобавление в `MODE_LIST`
- **п. 7** — смена активных **fake:blob** (локальные + из репозитория)
- **п. 8** — **Обновление hosts** через `ndmc`
- **п. 15** — **MagiTrickle** (установка/обновление/удаление)
- **п. 9** (бывш. 6) — Управление DoT/DoH: пресеты Xbox-DNS DoT/DoH для Twitch (`gql.twitch.tv`, `usher.ttvnw.net`)
- **SHA256** blobs + список стратегий из SUMS; fallback загрузок через VPN/туннель-интерфейсы
- Нумерация: 5 = rkn.list, 6 = DoT/DoH bypass, 7 = fake:blob, 8 = hosts, 9 = Manage DoT/DoH
- Статус: отображение magitrickle; удаление opera-proxy / KeenKit / MagiTrickle в п. 88
- Без принудительного `export LD_LIBRARY_PATH` (совместимость ndmc / Entware wget)

### 0.5.17

- **usque-keenetic** (п. 14) — установка/обновление; удаление в п. 88

### 0.5.16

- **DNS-счётчик** — только секция System; Policy0/1 и `proxy-*-filters` не учитываются

### 0.5.14 – 0.5.15

- Счётчик DoT/DoH по слотам (записи `server-tls` / `server-https`), а не по уникальным targets
- Ужесточён парсер `show dns-proxy`

### 0.5.13

- **LD_LIBRARY_PATH / ndmc_cli** — OPKG-путь по умолчанию; `ndmc` через системные библиотеки (как у spatiumstas)

### 0.5.11 – 0.5.12

- **TG WS Proxy Go** (п. 13) — установка/обновление через feedly
- Удаление `tg-ws-proxy` в п. 88 (+ опционально `feedly.conf`)

### 0.4.0 → 0.5.x

- **Управление DoT/DoH** через `ndmc`
- Утилиты: awg-manager, KeenKit; удаление — п. 88
- Быстрый запуск `menu`, статус только установленного, ⚡, кэш opkg/процессов
- Переключение языка (п. 77)

---

## Структура репозитория

```
nfqws-menu/
├── nfqws-menu.sh          # Главный скрипт меню
├── hosts                  # Секции IP DOMAIN для п. 8 (ndmc ip host)
├── SHA256SUMS             # Хеши файлов репозитория (список стратегий без API)
├── README.md
├── .github/workflows/
│   └── sha256sums.yml     # Автообновление SHA256SUMS
└── strategies/
    ├── blobs/
    │   ├── *.bin          # Бинарные шаблоны
    │   └── SHA256SUMS     # Эталоны для проверки blobs на роутере
    ├── lists/             # Готовые списки доменов / IP
    │   ├── user.list
    │   ├── exclude.list
    │   ├── ipset.list
    │   └── ipset_exclude.list
    ├── nfqws1/            # Стратегии для nfqws-keenetic (v1)
    └── nfqws2/            # Стратегии для nfqws2-keenetic (v2)
```

### Как добавить свою стратегию

1. Файл `имя.conf` в `strategies/nfqws1/` или `strategies/nfqws2/`.
2. Полный конфиг (`ISP_INTERFACE=`, `NFQWS_ARGS=` / `NFQWS_BASE_ARGS=` и т.д.).
3. При необходимости — `.bin` в `strategies/blobs/`, списки в `strategies/lists/`.
4. После push workflow обновит `SHA256SUMS` / `strategies/blobs/SHA256SUMS`; скрипт подхватит стратегию из SUMS (или через GitHub API).

---

## Требования (Keenetic / Netcraze)

1. Установлен **Entware** (внутренняя память или USB).
2. В веб-интерфейсе — **модули ядра Netfilter** (`OPKG → Kernel modules for Netfilter`).\
   На старых прошивках компонент появляется после включения IPv6.
3. Рекомендуется отключить DNS провайдера и настроить DoT/DoH.
4. Команды выполняются **в среде Entware**, не в CLI Keenetic.

---

## Полезные команды вручную

```bash
# Статус сервисов
/opt/etc/init.d/S51nfqws status          # v1
/opt/etc/init.d/S51nfqws2 status         # v2
/opt/etc/init.d/S99tg-ws-proxy status    # TG WS Proxy
/opt/etc/init.d/S51usque status          # usque
/opt/etc/init.d/S99magitrickle status    # MagiTrickle

# Порт веб-интерфейса
netstat -lnt | grep ':90'

# Перезапуск
/opt/etc/init.d/S51nfqws restart
/opt/etc/init.d/S51nfqws2 restart
/opt/etc/init.d/S99tg-ws-proxy restart
/opt/etc/init.d/S51usque restart
/opt/etc/init.d/S99magitrickle restart

# Информация о пакете
opkg info nfqws-keenetic
opkg info nfqws2-keenetic
opkg info nfqws-keenetic-web
opkg info tg-ws-proxy
opkg info usque-keenetic
opkg info magitrickle

# Конфиги
vi /opt/etc/nfqws/nfqws.conf
vi /opt/etc/nfqws2/nfqws2.conf
vi /opt/etc/tg-ws-proxy/config.conf
vi /opt/etc/tg-ws-proxy/secret.conf
vi /opt/etc/usque/usque.conf

# Интерфейс провайдера
ip route | grep ^default
# или
route | grep ^default

# DNS-proxy (DoT/DoH)
ndmc -c show dns-proxy

# Быстрый запуск меню
menu
```

---

## Лицензия / отказ от ответственности

Материалы подготовлены в ознакомительных и научно-технических целях.\
Использование на свой страх и риск. Автор не несёт ответственности за последствия.

Стратегии адаптированы на основе [Flowseal/zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube),\
подготовлены [@Nare51](https://github.com/Nare51) с использованием искусственного интеллекта.\
Официальные пакеты NFQWS: [nfqws](https://github.com/nfqws).