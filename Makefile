test:
	vusted --shuffle
.PHONY: test

doc:
	rm -f ./doc/cmdbuf.nvim.txt ./README.md
	nvim --headless -i NONE -n +"lua dofile('./spec/lua/cmdbuf/doc.lua')" +"quitall!"
	cat ./doc/cmdbuf.nvim.txt ./README.md
.PHONY: doc
