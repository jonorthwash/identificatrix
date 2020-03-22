all: lgdetector.hfst 

languages: kaz.detector.hfst kir.detector.hfst rus.detector.hfst

%.identifier.hfst:
	$(eval LG := $(shell echo $@ | sed 's/\.identifier\.hfst//'))
	echo "0 : %<$(LG)%>" | hfst-regexp2fst > $@

%.acceptor.hfst: %.automorf.hfst
	hfst-fst2txt $< | awk -F"\t" 'BEGIN {OFS=FS}{ if ($$4!="") $$4="@0@"; print}' | hfst-txt2fst | hfst-minimise > $@

%.detector.hfst: %.acceptor.hfst %.identifier.hfst
	hfst-concatenate $^ | hfst-minimise > $@

lgdetector.hfst: languages
	hfst-union kaz.detector.hfst kir.detector.hfst | hfst-union rus.detector.hfst | hfst-fst2fst -w > $@

clean:
	rm *.acceptor.hfst *.detector.hfst *.identifier.hfst lgdetector.hfst rus*

rus.automorf.hfst: rus.automorf.bin
	lt-print $< | sed 's/     /\t/g' | sed 's/ε/@0@/g' | sed 's/ /@_SPACE_@/g' > rus.automorf.att
	awk '{print $0 > "rus.section" NR ".att"}' RS='--\n' rus.automorf.att
	hfst-txt2fst rus.section1.att | hfst-minimise > rus.automorf1.hfst
	hfst-txt2fst rus.section2.att | hfst-minimise > rus.automorf2.hfst
	hfst-txt2fst rus.section3.att | hfst-minimise > rus.automorf3.hfst
	hfst-txt2fst rus.section4.att | hfst-minimise > rus.automorf4.hfst
	hfst-union rus.automorf1.hfst rus.automorf2.hfst | hfst-union rus.automorf3.hfst | hfst-union rus.automorf4.hfst | hfst-minimise | hfst-fst2fst -w > $@
