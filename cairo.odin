// Copyright 2012-2023 David Robillard <d@drobilla.net>
// SPDX-License-Identifier: ISC
package pugl

@(default_calling_convention="c", link_prefix="pugl")
foreign lib {
	/**
	Cairo graphics backend accessor.

	Pass the returned value to puglSetBackend() to draw to a view with Cairo.
	*/
	CairoBackend :: proc() -> ^Backend ---
}

