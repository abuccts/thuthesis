# Makefile for RucThesis

# Compiling method: latexmk/xelatex/pdflatex
METHOD = latexmk
# Set opts for latexmk if you use it
LATEXMKOPTS = -xelatex
# Basename of thesis
THESISMAIN = main

PACKAGE=ructhesis
SOURCES=$(PACKAGE).ins $(PACKAGE).dtx
THESISCONTENTS=$(THESISMAIN).tex data/*.tex $(FIGURES)
# NOTE: update this to reflect your local file types.
FIGURES=$(wildcard figures/*.eps figures/*.pdf)
BIBFILE=ref/*.bib
CLSFILES=dtx-style.sty $(PACKAGE).cls $(PACKAGE).cfg

# make deletion work on Windows
ifdef SystemRoot
	RM = del /Q
	OPEN = start
else
	RM = rm -f
	OPEN = open
endif


.PHONY: all clean count distclean dist thesis viewthesis doc viewdoc cls check FORCE_MAKE

all: doc thesis

cls: $(CLSFILES)

$(CLSFILES): $(SOURCES)
	latex $(PACKAGE).ins

viewdoc: doc
	$(OPEN) $(PACKAGE).pdf

doc: $(PACKAGE).pdf

viewthesis: thesis
	$(OPEN) $(THESISMAIN).pdf

thesis: $(THESISMAIN).pdf

ifeq ($(METHOD),latexmk)

$(PACKAGE).pdf: $(CLSFILES) FORCE_MAKE
	$(METHOD) $(LATEXMKOPTS) $(PACKAGE).dtx

$(THESISMAIN).pdf: $(CLSFILES) FORCE_MAKE
	$(METHOD) $(LATEXMKOPTS) $(THESISMAIN)

else ifneq (,$(filter $(METHOD),xelatex pdflatex))

$(PACKAGE).pdf: $(CLSFILES)
	$(METHOD) $(PACKAGE).dtx
	makeindex -s gind.ist -o $(PACKAGE).ind $(PACKAGE).idx
	makeindex -s gglo.ist -o $(PACKAGE).gls $(PACKAGE).glo
	$(METHOD) $(PACKAGE).dtx
	$(METHOD) $(PACKAGE).dtx

$(THESISMAIN).pdf: $(CLSFILES) $(THESISCONTENTS) $(THESISMAIN).bbl
	$(METHOD) $(THESISMAIN)
	$(METHOD) $(THESISMAIN)

$(THESISMAIN).bbl: $(BIBFILE)
	$(METHOD) $(THESISMAIN)
	-bibtex $(THESISMAIN)
	$(RM) $(THESISMAIN).pdf

else
$(error Unknown METHOD: $(METHOD))

endif

count:
	perl texcount.pl $(THESISMAIN).tex -inc -total

clean:
	latexmk -c $(PACKAGE).dtx $(THESISMAIN)
	-@$(RM) *~

cleanall: clean
	-@$(RM) $(PACKAGE).pdf $(THESISMAIN).pdf

distclean: cleanall
	-@$(RM) $(CLSFILES)
	-@$(RM) -r dist

check: FORCE_MAKE
	ag 'Renmin University of China Thesis Template|\\def\\version|"version":' $(PACKAGE).dtx package.json

dist: all
	@if [ -z "$(version)" ]; then \
		echo "Usage: make dist version=[x.y.z | ctan]"; \
	else \
		npm run build -- --version=$(version); \
	fi
