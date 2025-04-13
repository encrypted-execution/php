// Copyright (c) 2020 Polyverse Corporation

package main

import (
	"crypto/rand"
	"log"
	"math/big"
)

const MAX = 15
const MIN = 6

// https://stackoverflow.com/a/6878625/6998816
const MAX_UNIT64 = ^uint64(0)
const MAX_INT64 = int64(MAX_UNIT64 >> 1)
const usableChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

const (
	letterIdxBits = 6                    // 6 bits to represent a letter index
	letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
	letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
)

func randomStringGen() string {
	n := cryptoRandInRangeInt64(MIN, MAX)

	b := make([]byte, n)
	for i, cache, remain := n-1, cryptoRantInt64(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = cryptoRantInt64(), letterIdxMax
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

func cryptoRantInt64() int64 {
	return cryptoRandInRangeInt64(0, MAX_INT64)
}

func cryptoRandInRangeInt64(min int64, max int64) int64 {
	bigMin := big.NewInt(min)
	bigMax := big.NewInt(max)
	var randRange big.Int
	randRange.Sub(bigMax, bigMin)
	randNumInRange, err := rand.Int(rand.Reader, &randRange)
	if err != nil {
		log.Fatalf("Unable to generate a cryptographically secure random number: %v", err)
	}

	var randNum big.Int
	randNum.Add(randNumInRange, bigMin)

	// down-cast into 64-bit unsigned int
	return randNum.Int64()
}
