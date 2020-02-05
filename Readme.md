Introduction
What the article/code snippet does, why it's useful, the problem it solves etc.

Background
(Optional) Is there any background to this article that may be useful such as an introduction to the basic ideas presented?

Using the code
A brief description of how to use the article or code. The class names, the methods and properties, any tricks or tips.

Blocks of code should be set as style "Formatted" like this:

//
// Any source code blocks look like this
//


Remember to set the Language of your code snippet using the Language dropdown.

Use the "var" button to to wrap Variable or class names in <code> tags like this.

Points of Interest
Did you learn anything interesting/fun/annoying while writing the code? Did you do anything particularly clever or wild or zany?


Chcia³bym podzieliæ siê moim pomys³em na uproszczenie aktualizacji certyfikatów Letsencypt w œrodowisku kontenerowym.
Moj¹ ulubion¹ platform¹ do hostingu aplikacji web jest docker.
Dlatego, do wdra¿ania aplikacji web korzystam z kontenerów docker dzia³aj¹cych na linuksowym VPS. W takim œrodowisku mam jeden kontener z serwerem proxy nginx, do którego pod³¹czone s¹ inne kontenery z aplikacjami web.
Natomiast, do wdro¿enia protoko³u HTTPS do kounikacji na zewn¹trz u¿ywam darmowych certyfikatów letsencypt, którymi zarz¹dzam za pomoc¹ narzêdzia certbot. 
Choæ opisane œrodowisko jest niew¹tpliwie popularnym i œwietnym rozwi¹zaniem, to stwarza pewne problemy. 
Mianowicie, bez dodatkowych narzêdzi, muszê pamiêtaæ o tym aby po odnowieniu certyfikatu skopiowaæ go do folderu serwera proxy a nastêpnie rêcznie prze³adowaæ serwis, który z tego certyfikatu korzysta.
Mo¿e nie jest to trudne zadanie ale wymaga ci¹g³ej uwagi, któr¹ mo¿na przecie¿ skierowaæ na ciekawsze zajêcia.
Mój pomys³ na rozwi¹zanie tego ma³ego problemu jest ca³kiem prosty i jednoczeœnie doœæ elastyczny. Pozwala mi równie¿ unikn¹æ restartu serwera proxy.

Pomys³ polega na wykorzystaniu timera certbota, który odpowiada za automatyczne, cykliczne odnawianie certyfikatów. 
Certbot instaluje w systemie serwis timera o nazwie "certbot.service", który automatycznie uruchamia co jakiœ czas proces odnawiania zainstalowanych certfikatów.
W celu implementacji napisa³em kilku prostych skryptów, które mo¿na dowolnie konfigurowaæ. Skrypty te instaluj¹ w systemie dwa dodatkowe serwisy, które wspó³pracuj¹ z timerem certbota.
Pierwszy z serwisów, który nazwa³em "certbot-renewed-copy.service" odpowiada za automatyczne kopiowanie odnowionych certyfikatów do foldera proxy.
Drugi serwis, nazwany "certbot-post-renewal-reload.service" zajmuje siê prze³adowaniem kontenerów aplikacji web w przypadku odnowienia certyfikatów.
Kontener serwera proxy nie jest prze³adowywany, dotyczy to tylko kontenerów aplikacji.
Tam, gdzie to mo¿liwe, sposób instalowania certyfikatów przez certbota polega na metodzie webroot, poniewa¿ nie wymaga ona wy³¹czenia serwera proxy u¿ywaj¹cego portu 80.
Za³o¿y³em, ¿e kontenery aplikacji web zarz¹dzane s¹ za pomoc¹ narzêdzia docker-compose. W pliku konfiguracji tego narzêdzia, dla danego kontenera (docker-compose.yml), powinny byæ okreœlone w parametrze "environment:VIRTUAL_HOST" nazwy domen odpowiadaj¹ce zainstalowanym certyfikatom.
Ponadto zak³adam, ¿e certbot instaluje certyfikaty w standardowym folderze /etc/letsencrypt/live.
Uruchomione serwisy zapisuj¹ swoje logi do standardowego journala. Mo¿na je zatem przejrzeæ w statusie danego serwisu lub za pomoc¹ narzêdzia journalctl.
Opisywane rozwi¹zanie przetestowa³em na dystrybucjach linuxa debian 9 i ubuntu 16.

Zanim rozpoczniesz instalowanie, skopiuj wszystkie pobrane pliki do wybranego folderu.
Procedura instalacji polega na wczeœniejszym dostosowaniu treœci plików konfiguracyjnych a nastêpnie uruchomieniu skryptu instaluj¹cego serwisy.
W pliku "config.copy.cf" trzeba wpisaæ listê domen certyfikatów, które bêd¹ kopiowane (pole "certificates") oraz miejsce docelowe, gdzie zostan¹ one skopiowane dla serwera proxy (pole "destination").
Przyk³ad:
certificates = domain.com,sample.domain.com
destination = /path/to/proxy/certs
W pliku "config.reload.cf", w polu "certs_path" wpisz t¹ sam¹ œcie¿kê do folderu serwera proxy, gdzie bêd¹ kopiowane certyfikaty:
certs_path = /path/to/proxy/certs
Plik "config.location.cf" zawiera listê wszystkich lokalizacji, w których znajduj¹ siê pliki docker-compose.yml przeznaczone do uruchamiania kontenerów dla aplikacji, które zamierzamy automatycznie prze³adowaæ po odnowieniu certyfikatów.
Przyk³ad:
/path/to/docked/web/app1
/path/to/docked/api2
Do zainstalowania skryptów w systemie i uruchomienia opisywanych wy¿ej serwisów przygotowa³em prosty skrypt o nazwie "install.sh". 
Uruchom go w ten sposób:
$ sudo bash install.sh
Status i logi zainstalowanych serwisów mo¿na sprawdziæ za pomoc¹ polecenia:
$ sudo systemctl status certbot-renewed-copy.service
$ sudo systemctl status certbot-post-renewal-reload.service

