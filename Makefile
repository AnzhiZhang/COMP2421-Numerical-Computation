BUILDDIR=public

LECTURES=$(shell find lec -name "*.md" -exec basename {} \;)

TARGETS=$(LECTURES:%.md=$(BUILDDIR)/%/index.html)
ALL_TARGETS= \
	$(LECTURES:%.md=$(BUILDDIR)/%/index.html) \
	$(LECTURES:%.md=$(BUILDDIR)/%/embed.html)
# $(LECTURES:%.md=$(BUILDDIR)/%/presenter.html) \

all: $(TARGETS) ${BUILDDIR}/index.html
	cp -r css ${BUILDDIR}/css
	cp -r js ${BUILDDIR}/js
	cp -r img ${BUILDDIR}/img
	cp -r static/* ${BUILDDIR}

full: $(ALL_TARGETS) ${BUILDDIR}/index.html
	cp -r css ${BUILDDIR}/css
	cp -r js ${BUILDDIR}/js
	cp -r img ${BUILDDIR}/img
	cp -r static/* ${BUILDDIR}

${BUILDDIR}/index.html: ./pandoc/make-index.py
	python ./pandoc/make-index.py $@ $(LECTURES)

${BUILDDIR}/lec%/index.html: lec/lec%.md pandoc/revealjs-template.html
	mkdir -p $(shell dirname $@)
	pandoc  \
	--mathjax \
	--template=./pandoc/revealjs-template.html \
	-t revealjs \
	--no-highlight \
	--slide-level 2 \
	-V controls=true \
	-V controlsTutorial=true \
	-V slideNumber="'c'" \
	-V history=true \
	-s $< -o $@

${BUILDDIR}/lec%/embed.html: lec/lec%.md pandoc/revealjs-template.html
	mkdir -p $(shell dirname $@)
	pandoc \
	--mathjax \
	--template=./pandoc/revealjs-template.html \
	-t revealjs \
	--no-highlight \
	-V controls=true \
	-V controlsTutorial=true \
	-V slideNumber=false \
	--slide-level 2 \
	-V embedded="true" \
	-V print-pdf=false \
	-V history=true \
	-s $< -o $@

${BUILDDIR}/lec%/presenter.html: lec/lec%.md pandoc/revealjs-template.html
	pandoc \
	--self-contained \
	--mathjax \
	--template=./pandoc/revealjs-template.html \
	-t revealjs \
	--no-highlight \
	--slide-level 2 \
	-V controls=false \
	-V slideNumber="'c'" \
	-V history=true \
	-s $< -o $@

dist: $(ALL_TARGETS) ${BUILDDIR}/index.html
	tar -cvzf slides.tar.gz ${BUILDDIR}

clean:
	rm -rf ${BUILDDIR}
