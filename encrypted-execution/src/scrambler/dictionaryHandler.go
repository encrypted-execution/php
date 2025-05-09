// Copyright (c) 2020 Polyverse Corporation

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"regexp"
	"time"
)

const scrambledDictFile = "scrambled.json"

var KeywordsRegex = regexp.MustCompile( //REGEX found as user @martindilling comment on PHP documentation.
	"[^a-zA-Z0-9]((a(bstract|nd|rray|s))|" +
		"(b(inary|reak|ool(ean)?))|" +
		"(c(a(llable|se|tch)|l(ass|one)|on(st|tinue)))|" +
		"(d(e(clare|fault|fine)|ie|o(uble)?))|" +
		"(e(cho|lse(if)?|mpty|nd(declare|for(each)?|if|switch|while)|val|x(it|tends)))|" +
		"(f(inal(ly)?|or(each)?|unction))|" +
		"(g(lobal|oto))|" +
		"(i(f|mplements|n(clude(_once)?|st(anceof|eadof)|terface)|sset))|" +
		"(n(amespace|ew))|" +
		"((x)?or)|" +
		"(p(r(i(nt|vate)|otected)|ublic))|" +
		"(re(quire(_once)?|turn))|" +
		"(s(tatic|witch))|" +
		"(t(hrow|r(ait|y)))|(u(nset|se))|" +
		"(break|list|(x)?or|var|while)|" +
		"(string|object|list|int(eger)?|real|float|[^_]AND|[^(R|_|F)(X)?)](X)?OR))[^a-zA-Z0-9]")

var EEWords = make(map[string]string)
var SpecialChar = make(map[string]string)
var PreMadeDict = false

func InitEEWords(filename string) {
	PreMadeDict = true
	file, _ := ioutil.ReadFile(filename)
	err := json.Unmarshal(file, &EEWords)
	if err != nil {
		panic(err)
	}
	fmt.Print(EEWords)
	InitChar()
}

func AddToEEWords(key string) bool {
	var ok bool
	if _, ok = EEWords[key]; ok {
		return false
	} else {
		EEWords[key] = randomStringGen() // (need checks here?)
		return true
	}
}

func GetScrambled(key string) (string, bool) {
	if _, ok := EEWords[key]; ok {
		return EEWords[key], true
	} else {
		return key, false
	}
}

var Buffer = bytes.Buffer{}

func Check(e error) {
	if e != nil {
		panic(e)
	}
}

func WriteFile(fileOut string) {
	err := ioutil.WriteFile(fileOut, Buffer.Bytes(), 0644)
	Check(err)
}

func WriteLineToBuff(s []byte) {
	Buffer.Write([]byte(s))
	Buffer.WriteString("\n")
}

func SerializeMap() {
	encodeFile, err := os.Create(scrambledDictFile)

	if err != nil {
		panic(err)
	}

	m, err := json.Marshal(EEWords)
	Check(err)

	_, err = encodeFile.Write(m)
	Check(err)

	err = encodeFile.Close()
	Check(err)

}

var CharMatches = []string{}

var CharStrRegex = regexp.MustCompile("(\")[^\\w\"]{2,}[ \"]")

var symbolChars = [...]string{"(", ")", "]", "-", "~", "^", "&", "@", "!", "|", "+", ":", "=", ",", "%"}
var specialChars = []string{"(", ")", "]"}

func shuffle() []string {
	r := rand.New(rand.NewSource(time.Now().Unix()))
	shuffled := make([]string, len(symbolChars))
	permutation := r.Perm(len(symbolChars))
	for i, randIndex := range permutation {
		shuffled[i] = symbolChars[randIndex]
	}
	return shuffled
}

func InitChar() {
	// create Char Matchers
	addCharMatches(specialChars, []string{"\"", "'"})
	addCharMatches([]string{"-", "~", "^", "&", "@", "!", "|", "+", ":", "=", ",", "%"}, []string{"'"})

	if !PreMadeDict {
		permutationGen()
	}

	for _, char := range specialChars {
		out := EEWords[char]
		if char == "]" {
			char = "\\]"
		}
		SpecialChar[char] = out
	}
}

func addCharMatches(matches []string, wrappers []string) {
	for _, match := range matches {
		for _, wrapper := range wrappers {
			CharMatches = append(CharMatches, wrapper+match+wrapper)
		}
	}
}

func permutationGen() {
	permutation := shuffle()

	for _, char := range symbolChars {
		EEWords[char], permutation = permutation[0], permutation[1:]
	}

	if EEWords["("] == "]" || EEWords[")"] == "]" {
		permutationGen()
	}
	return
}

//TODO:
//'[' ... creates an issue within strings. Any variable within a string that is followed by the scrambled
//			char, will throw an error. Both '[' and '-' have this issue, but because of how '[' is tokenized,
//			scrambling becomes an issue.
//'.' Creates issue with decimal numbers
// '>' '<' '?' create issues with open and close tags
// '$' creates issues with variables
// '/' and '*' crete issues with comments.
// dealing with coded formats requires changes to the lex,yacc files and extending php library. May be doable, but
// would take some time.