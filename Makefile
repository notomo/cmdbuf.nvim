test:
	vusted --shuffle
.PHONY: test

doc:
	nvim --headless -i NONE -n +"lua dofile('./spec/doc.lua')" +"quitall!"
	cat ./doc/cmdbuf.nvim.txt
	cat ./README.md
.PHONY: doc
