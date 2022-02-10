// Copyright (c) 2020 Polyverse Corporation

package main

import (
	"crypto/rand"
	"math/big"
)

const MAX = 15
const MIN = 6

const usableChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

const (
	letterIdxBits = 6                    // 6 bits to represent a letter index
	letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
	letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
)

func randomStringGen() string {
	bigMin := big.NewInt(MIN)
	bigMax := big.NewInt(MAX)
	randRage := bigMax.Sub(bigMin)
	n := rand.Int(rand.Reader, randRage) + bigMin
	b := make([]byte, n)
	for i, cache, remain := n-1, randSrc.Int63(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = randSrc.Int63(), letterIdxMax
		}
		if idx := int(cache & letterIdxMask); idx < len(usableChars) {
			b[i] = usableChars[idx]
			i--
		}
		cache >>= letterIdxBits
		remain--
	}

	return string(b)
}
