# Content

AUTHOR_NAME = "Author"
AUTHOR_EMAIL = "author@example.org"
SITE_TITLE = "Site Title"
SITE_TAGLINE = "Site Tagline"

POSTS_PER_PAGE = 10
POSTS_PER_PAGE_ATOM = 10

POSTS = \
	post2 \
	post1 \
	$(NULL)

PAGES = \
	about \
	$(NULL)

ASSETS = \
	assets/custom.css \
	$(NULL)


# Arguments

BLOGC ?= $(shell which blogc)
INSTALL ?= $(shell which install)
OUTPUT_DIR ?= _build
BASE_DOMAIN ?= http://example.org
BASE_URL ?=

DATE_FORMAT = "%Y/%m/%d %H:%M:%S GMT"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = $(BLOGC) \
	-D AUTHOR_NAME=$(AUTHOR_NAME) \
	-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
	-D SITE_TITLE=$(SITE_TITLE) \
	-D SITE_TAGLINE=$(SITE_TAGLINE) \
	-D BASE_DOMAIN=$(BASE_DOMAIN) \
	-D BASE_URL=$(BASE_URL) \
	$(NULL)


# Rules

LAST_PAGE = $(shell $(BLOGC_COMMAND) \
	-D FILTER_PAGE=1 \
	-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
	-p LAST_PAGE \
	-l \
	$(addprefix content/post/, $(addsuffix .txt, $(POSTS))))

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/atom.xml \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/post/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(PAGES))) \
	$(addprefix $(OUTPUT_DIR)/page/, $(addsuffix /index.html, \
		$(shell for i in {1..$(LAST_PAGE)}; do echo $$i; done)))

$(OUTPUT_DIR)/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/page/%/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/page/,,' -e 's,/index\.html$$,,')\
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom.xml: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(INSTALL) -m 0644 $< $@

clean:
	rm -rf "$(OUTPUT_DIR)"
