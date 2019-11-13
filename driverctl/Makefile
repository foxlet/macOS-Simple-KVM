PREFIX=/usr
UDEVDIR=$(shell pkg-config --variable=udevdir udev)
UNITDIR=$(shell pkg-config --variable=systemdsystemunitdir systemd)
SBINDIR=$(PREFIX)/sbin
CONFDIR=/etc/driverctl.d
MANDIR=$(PREFIX)/share/man/
BASHDIR=$(PREFIX)/share/bash-completion
NAME=driverctl
VERSION=0.$(shell git rev-list --count HEAD)
COMMIT=$(shell git rev-list --max-count 1 HEAD)
NVFMT=$(NAME)-$(VERSION)-$(COMMIT)

files: driverctl driverctl.8 driverctl-bash-completion.sh driverctl@.service 05-driverctl.rules \
	README COPYING TODO \
	89-vfio-uio.rules vfio_name \
	driverctl.spec.in Makefile

archive: files tag driverctl.spec
	git archive --prefix=$(NVFMT)/ HEAD > $(NVFMT).tar
	tar -r -f $(NVFMT).tar --transform "s:^:$(NVFMT)/:" driverctl.spec
	gzip -f -9 $(NVFMT).tar

driverctl.spec:	driverctl.spec.in files
	sed -e 's:#VERSION#:$(VERSION):g' \
            -e 's:#COMMIT#:$(COMMIT):g'  < driverctl.spec.in > driverctl.spec
	git log --format="* %cd %aN <%ae>%n%B" --date=local driverctl.spec.in | sed -r -e 's/%/%%/g' -e 's/[0-9]+:[0-9]+:[0-9]+ //' >> driverctl.spec

srpm:	driverctl.spec archive
	rpmbuild -bs --define "_sourcedir $(PWD)" --define "_specdir $(PWD)" --define "_builddir $(PWD)" --define "_srcrpmdir $(PWD)" --define "_rpmdir $(PWD)" driverctl.spec

rpm:	driverctl.spec archive
	rpmbuild -bb --define "_sourcedir $(PWD)" --define "_specdir $(PWD)" --define "_builddir $(PWD)" --define "_srcrpmdir $(PWD)" --define "_rpmdir $(PWD)" driverctl.spec

install:
	# driverctl 
	mkdir -p $(DESTDIR)$(CONFDIR)
	mkdir -p $(DESTDIR)$(UDEVDIR)/rules.d/
	install -m 644 05-driverctl.rules $(DESTDIR)$(UDEVDIR)/rules.d/
	mkdir -p $(DESTDIR)$(UNITDIR)
	install -m 644 driverctl@.service $(DESTDIR)$(UNITDIR)/
	mkdir -p $(DESTDIR)$(SBINDIR)
	install -m 755 driverctl $(DESTDIR)$(SBINDIR)/
	mkdir -p $(DESTDIR)$(BASHDIR)/completions/
	install -m 644 driverctl-bash-completion.sh $(DESTDIR)$(BASHDIR)/completions/driverctl
	mkdir -p $(DESTDIR)$(MANDIR)/man8
	install -m 644 driverctl.8 $(DESTDIR)$(MANDIR)/man8/
	# misc vfio/uio bits, dont really belong here...
	install -m 644 89-vfio-uio.rules $(DESTDIR)$(UDEVDIR)/rules.d/
	install -m 755 vfio_name $(DESTDIR)$(UDEVDIR)/

clean:
	rm -f driverctl.spec *.src.rpm noarch/*.rpm *.tar.gz

tag:
	git tag -l $(VERSION) | grep -q $(VERSION) || git tag $(VERSION)
