package ulid

import "core:time"
import "core:strings"
import "core:mem"
import "core:math/rand"
import "core:testing"

@(rodata)
ENC_TABLE_CROCKFORD := [32]byte {
	'0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
	'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q',
	'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z',
}

@(rodata)
DEC_TABLE_CROCKFORD := [256]u8 {
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  0,  0,  0,  0,  0,  0,
	 0, 10, 11, 12, 13, 14, 15, 16, 17,  0, 18, 19,  0, 20, 21,  0,
	22, 23, 24, 25, 26,  0, 27, 28, 29, 30, 31,  0,  0,  0,  0,  0,
	 0, 10, 11, 12, 13, 14, 15, 16, 17,  0, 18, 19,  0, 20, 21,  0,
	22, 23, 24, 25, 26,  0, 27, 28, 29, 30, 31,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
}

TS_CHAR_COUNT :: 10
RAND_CHAR_COUNT :: 16

ULID :: u128

gen :: proc() -> ULID {
	ts := u64(time.time_to_unix_nano(time.now()) / 1_000_000)

	ulid : u128 = (u128(ts) << 80) | (rand.uint128() & (max(u128) >> 48))
	return ulid
}

decode :: proc(ulid_str: string) -> ULID {
	ulid : u128
	j: u8 = u8(len(ulid_str))

	for c in ulid_str {
		j -= 1
		bits : u128 = u128(DEC_TABLE_CROCKFORD[c])

		ulid |= (bits << (j * 5))
	}

	return ulid
}

as_b32 :: proc(ulid: ^ULID) -> string {
	_ulid := mem.ptr_to_bytes(ulid)

	encoded := make([]byte, TS_CHAR_COUNT + RAND_CHAR_COUNT)

	encoded[25] = ENC_TABLE_CROCKFORD[(_ulid[0] & 0x1f)]
	encoded[24] = ENC_TABLE_CROCKFORD[(_ulid[0] >> 5) | (_ulid[1] & 0x03) << 3]
	encoded[23] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 2) & 0x1f]
	encoded[22] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 7) | (_ulid[2] & 0x0f) << 1]
	encoded[21] = ENC_TABLE_CROCKFORD[(_ulid[2] >> 4) | (_ulid[3] & 0x01) << 4]
	encoded[20] = ENC_TABLE_CROCKFORD[(_ulid[3] >> 1) & 0x1f]
	encoded[19]  = ENC_TABLE_CROCKFORD[(_ulid[3] >> 6) | (_ulid[4] & 0x07) << 2]
	encoded[18]  = ENC_TABLE_CROCKFORD[(_ulid[4] >> 3)]

	encoded[17]  = ENC_TABLE_CROCKFORD[(_ulid[5] & 0x1f)]
	encoded[16]  = ENC_TABLE_CROCKFORD[(_ulid[5] >> 5) | (_ulid[6] & 0x03) << 3]
	encoded[15]  = ENC_TABLE_CROCKFORD[(_ulid[6] >> 2) & 0x1f]
	encoded[14]  = ENC_TABLE_CROCKFORD[(_ulid[6] >> 7) | (_ulid[7] & 0x0f) << 1]
	encoded[13]  = ENC_TABLE_CROCKFORD[(_ulid[7] >> 4) | (_ulid[8] & 0x01) << 4]
	encoded[12]  = ENC_TABLE_CROCKFORD[(_ulid[8] >> 1) & 0x1f]
	encoded[11]  = ENC_TABLE_CROCKFORD[(_ulid[8] >> 6) | (_ulid[9] & 0x07) << 2]
	encoded[10]  = ENC_TABLE_CROCKFORD[(_ulid[9] >> 3)]

	encoded[9] = ENC_TABLE_CROCKFORD[(_ulid[10] & 0x1f)]
	encoded[8] = ENC_TABLE_CROCKFORD[(_ulid[10] >> 5) | (_ulid[11] & 0x03) << 3]
	encoded[7] = ENC_TABLE_CROCKFORD[(_ulid[11] >> 2) & 0x1f]
	encoded[6] = ENC_TABLE_CROCKFORD[(_ulid[11] >> 7) | (_ulid[12] & 0x0f) << 1]
	encoded[5] = ENC_TABLE_CROCKFORD[(_ulid[12] >> 4) | (_ulid[13] & 0x01) << 4]
	encoded[4] = ENC_TABLE_CROCKFORD[(_ulid[13] >> 1) & 0x1f]
	encoded[3] = ENC_TABLE_CROCKFORD[(_ulid[13] >> 6) | (_ulid[14] & 0x07) << 2]
	encoded[2] = ENC_TABLE_CROCKFORD[(_ulid[14] >> 3)]
	encoded[1] = ENC_TABLE_CROCKFORD[(_ulid[15] & 0x1f)]
	encoded[0] = '0'

	result := strings.string_from_ptr(&encoded[0], TS_CHAR_COUNT + RAND_CHAR_COUNT)
	return result
}

ts_as_b32 :: proc(ulid: ^ULID) -> string {
	_ulid := mem.ptr_to_bytes(ulid)[10:][:6]

	encoded := make([]byte, TS_CHAR_COUNT)

	encoded[9] = ENC_TABLE_CROCKFORD[(_ulid[0] & 0x1f)]
	encoded[8] = ENC_TABLE_CROCKFORD[(_ulid[0] >> 5) | (_ulid[1] & 0x03) << 3]
	encoded[7] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 2) & 0x1f]
	encoded[6] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 7) | (_ulid[2] & 0x0f) << 1]
	encoded[5] = ENC_TABLE_CROCKFORD[(_ulid[2] >> 4) | (_ulid[3] & 0x01) << 4]
	encoded[4] = ENC_TABLE_CROCKFORD[(_ulid[3] >> 1) & 0x1f]
	encoded[3] = ENC_TABLE_CROCKFORD[(_ulid[3] >> 6) | (_ulid[4] & 0x07) << 2]
	encoded[2] = ENC_TABLE_CROCKFORD[(_ulid[4] >> 3)]
	encoded[1] = ENC_TABLE_CROCKFORD[(_ulid[5] & 0x1f)]
	encoded[0] = '0'

	result := strings.string_from_ptr(&encoded[0], TS_CHAR_COUNT)
	return result
}

rand_as_b32 :: proc(ulid: ^ULID) -> string {
	_ulid := mem.ptr_to_bytes(ulid)[0:10]

	encoded := make([]byte, RAND_CHAR_COUNT)

	encoded[15] = ENC_TABLE_CROCKFORD[(_ulid[0] & 0x1f)]
	encoded[14] = ENC_TABLE_CROCKFORD[(_ulid[0] >> 5) | (_ulid[1] & 0x03) << 3]
	encoded[13] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 2) & 0x1f]
	encoded[12] = ENC_TABLE_CROCKFORD[(_ulid[1] >> 7) | (_ulid[2] & 0x0f) << 1]
	encoded[11] = ENC_TABLE_CROCKFORD[(_ulid[2] >> 4) | (_ulid[3] & 0x01) << 4]
	encoded[10] = ENC_TABLE_CROCKFORD[(_ulid[3] >> 1) & 0x1f]
	encoded[9]  = ENC_TABLE_CROCKFORD[(_ulid[3] >> 6) | (_ulid[4] & 0x07) << 2]
	encoded[8]  = ENC_TABLE_CROCKFORD[(_ulid[4] >> 3)]

	encoded[7]  = ENC_TABLE_CROCKFORD[(_ulid[5] & 0x1f)]
   encoded[6]  = ENC_TABLE_CROCKFORD[(_ulid[5] >> 5) | (_ulid[6] & 0x03) << 3]
	encoded[5]  = ENC_TABLE_CROCKFORD[(_ulid[6] >> 2) & 0x1f]
	encoded[4]  = ENC_TABLE_CROCKFORD[(_ulid[6] >> 7) | (_ulid[7] & 0x0f) << 1]
	encoded[3]  = ENC_TABLE_CROCKFORD[(_ulid[7] >> 4) | (_ulid[8] & 0x01) << 4]
	encoded[2]  = ENC_TABLE_CROCKFORD[(_ulid[8] >> 1) & 0x1f]
	encoded[1]  = ENC_TABLE_CROCKFORD[(_ulid[8] >> 6) | (_ulid[9] & 0x07) << 2]
	encoded[0]  = ENC_TABLE_CROCKFORD[(_ulid[9] >> 3)]

	result := strings.string_from_ptr(&encoded[0], RAND_CHAR_COUNT)
	return result
}


@(test)
test_encode :: proc(t: ^testing.T) {
	ulid_testing : u128 = 2118346750954551625749575057819732880
	ulid_encoded :: "01JZX8XXZE9N750PHVB4PNN2WG"

	ts := ts_as_b32(&ulid_testing)
	rand := rand_as_b32(&ulid_testing)
	testing.expect(t, strings.compare("01JZX8XXZE", ts) == 0)
	testing.expect(t, strings.compare("9N750PHVB4PNN2WG", rand) == 0)

	encoded := as_b32(&ulid_testing)
	testing.expectf(t,
	                encoded == ulid_encoded,
	                "is {}, should be {}", encoded, ulid_encoded)

	defer delete(ts)
	defer delete(rand)
	defer delete(encoded)
}

@(test)
test_decode :: proc(t: ^testing.T) {
	ulid_b32 :: "01JZX8XXZE9N750PHVB4PNN2WG"
	ulid_expected : u128 : 2118346750954551625749575057819732880

	ulid := decode(ulid_b32)

	testing.expectf(t, ulid == ulid_expected, "is {}, should be {}", ulid, ulid_expected)
}
