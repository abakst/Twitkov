# Simple Make script to build the 
# twitkov executable and place it in cgi-bin

all: twitkov
	cp twitkov cgi-bin/twitkov

twitkov: Main.hs Markov.hs Search.hs
	ghc --make Main -o twitkov

clean:
	-rm twitkov
	-rm *.o
	-rm *.hi
