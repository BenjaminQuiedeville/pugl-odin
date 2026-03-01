// Copyright 2019-2023 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC
package pugl

@(default_calling_convention="c", link_prefix="pugl")
foreign lib {
	/**
	Stub graphics backend accessor.

	This backend just creates a simple native window without setting up any
	portable graphics API.
	*/
	StubBackend :: proc() -> ^Backend ---
}

