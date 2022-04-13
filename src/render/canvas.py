# Cairo canvas to draw on
# Based on cairo-demo/X11/cairo-demo.c

import cairo

FONT = 'UbuntuCondensent'
SLANT = cairo.FONT_SLANT_NORMAL
BOLD = cairo.FONT_WEIGHT_NORMAL

def draw (da, ctx):
  ctx.set_source_rgb(1, 1, 1)

  ctx.select_font_face(FONT, SLANT, BOLD)
  ctx.set_font_size(32)

  ctx.move_to(100, 100)
  ctx.text_path('TODO: draw FPS ui components')
  ctx.fill()