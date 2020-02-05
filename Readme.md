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


Chcia�bym podzieli� si� moim pomys�em na uproszczenie aktualizacji certyfikat�w Letsencypt w �rodowisku kontenerowym.
Moj� ulubion� platform� do hostingu aplikacji web jest docker.
Dlatego, do wdra�ania aplikacji web korzystam z kontener�w docker dzia�aj�cych na linuksowym VPS. W takim �rodowisku mam jeden kontener z serwerem proxy nginx, do kt�rego pod��czone s� inne kontenery z aplikacjami web.
Natomiast, do wdro�enia protoko�u HTTPS do kounikacji na zewn�trz u�ywam darmowych certyfikat�w letsencypt, kt�rymi zarz�dzam za pomoc� narz�dzia certbot. 
Cho� opisane �rodowisko jest niew�tpliwie popularnym i �wietnym rozwi�zaniem, to stwarza pewne problemy. 
Mianowicie, bez dodatkowych narz�dzi, musz� pami�ta� o tym aby po odnowieniu certyfikatu skopiowa� go do folderu serwera proxy a nast�pnie r�cznie prze�adowa� serwis, kt�ry z tego certyfikatu korzysta.
Mo�e nie jest to trudne zadanie ale wymaga ci�g�ej uwagi, kt�r� mo�na przecie� skierowa� na ciekawsze zaj�cia.
M�j pomys� na rozwi�zanie tego ma�ego problemu jest ca�kiem prosty i jednocze�nie do�� elastyczny. Pozwala mi r�wnie� unikn�� restartu serwera proxy.

Pomys� polega na wykorzystaniu timera certbota, kt�ry odpowiada za automatyczne, cykliczne odnawianie certyfikat�w. 
Certbot instaluje w systemie serwis timera o nazwie "certbot.service", kt�ry automatycznie uruchamia co jaki� czas proces odnawiania zainstalowanych certfikat�w.
W celu implementacji napisa�em kilku prostych skrypt�w, kt�re mo�na dowolnie konfigurowa�. Skrypty te instaluj� w systemie dwa dodatkowe serwisy, kt�re wsp�pracuj� z timerem certbota.
Pierwszy z serwis�w, kt�ry nazwa�em "certbot-renewed-copy.service" odpowiada za automatyczne kopiowanie odnowionych certyfikat�w do foldera proxy.
Drugi serwis, nazwany "certbot-post-renewal-reload.service" zajmuje si� prze�adowaniem kontener�w aplikacji web w przypadku odnowienia certyfikat�w.
Kontener serwera proxy nie jest prze�adowywany, dotyczy to tylko kontener�w aplikacji.
Tam, gdzie to mo�liwe, spos�b instalowania certyfikat�w przez certbota polega na metodzie webroot, poniewa� nie wymaga ona wy��czenia serwera proxy u�ywaj�cego portu 80.
Za�o�y�em, �e kontenery aplikacji web zarz�dzane s� za pomoc� narz�dzia docker-compose. W pliku konfiguracji tego narz�dzia, dla danego kontenera (docker-compose.yml), powinny by� okre�lone w parametrze "environment:VIRTUAL_HOST" nazwy domen odpowiadaj�ce zainstalowanym certyfikatom.
Ponadto zak�adam, �e certbot instaluje certyfikaty w standardowym folderze /etc/letsencrypt/live.
Uruchomione serwisy zapisuj� swoje logi do standardowego journala. Mo�na je zatem przejrze� w statusie danego serwisu lub za pomoc� narz�dzia journalctl.
Opisywane rozwi�zanie przetestowa�em na dystrybucjach linuxa debian 9 i ubuntu 16.

Zanim rozpoczniesz instalowanie, skopiuj wszystkie pobrane pliki do wybranego folderu.
Procedura instalacji polega na wcze�niejszym dostosowaniu tre�ci plik�w konfiguracyjnych a nast�pnie uruchomieniu skryptu instaluj�cego serwisy.
W pliku "config.copy.cf" trzeba wpisa� list� domen certyfikat�w, kt�re b�d� kopiowane (pole "certificates") oraz miejsce docelowe, gdzie zostan� one skopiowane dla serwera proxy (pole "destination").
Przyk�ad:
certificates = domain.com,sample.domain.com
destination = /path/to/proxy/certs
W pliku "config.reload.cf", w polu "certs_path" wpisz t� sam� �cie�k� do folderu serwera proxy, gdzie b�d� kopiowane certyfikaty:
certs_path = /path/to/proxy/certs
Plik "config.location.cf" zawiera list� wszystkich lokalizacji, w kt�rych znajduj� si� pliki docker-compose.yml przeznaczone do uruchamiania kontener�w dla aplikacji, kt�re zamierzamy automatycznie prze�adowa� po odnowieniu certyfikat�w.
Przyk�ad:
/path/to/docked/web/app1
/path/to/docked/api2
Do zainstalowania skrypt�w w systemie i uruchomienia opisywanych wy�ej serwis�w przygotowa�em prosty skrypt o nazwie "install.sh". 
Uruchom go w ten spos�b:
$ sudo bash install.sh
Status i logi zainstalowanych serwis�w mo�na sprawdzi� za pomoc� polecenia:
$ sudo systemctl status certbot-renewed-copy.service
$ sudo systemctl status certbot-post-renewal-reload.service

