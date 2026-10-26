## splitTypeR logo: a camel whose two humps are the two normal distributions
## of the mixture model, split by the classification threshold.
##
## Usage (from the repository folder):
##     python3 make_name_outline.py /path/to/Arimo-Bold.ttf
##     Rscript make_logo_camel.R
## The first command is only needed when the name (text, color, size or
## position) changes. The second writes logo.svg and logo.png.
##
## Copyright 2026 Astrid Deschênes. Licensed under CC BY 4.0 (see LICENSE.md).

args <- commandArgs(TRUE)
outFile <- if (length(args)) args[1] else "logo.svg"

## Options
shiftX <- -7; shiftY <- -32      # position of the camel
groundMargin <- 30               # distance between ground line and border
showLine <- TRUE                 # dashed classification threshold
showSun <- TRUE                  # desert sun above the camel
useOutlines <- TRUE              # name as outlines (name_outline.svgfrag)

W <- 518; H <- 600
cx <- W / 2; cy <- H / 2; R <- 290
ang <- seq(-90, 210, by=60) * pi / 180
hexPts <- function(r) paste(sprintf("%.1f,%.1f", cx + r * cos(ang),
    cy + r * sin(ang)), collapse=" ")

## Colors
navy <- "#1B3A57"; cream <- "#F7F4EC"; camel <- "#D9A86C"
camelDark <- "#9C6B35"; grey <- "#9AA5B1"; red <- "#D9534F"

## Back of the camel: mixture of two normal distributions
x <- seq(-2.6, 2.9, length.out=200)
mu1 <- -1.2; s1 <- 0.55; mu2 <- 1.0; s2 <- 0.55
d <- 0.605 * dnorm(x, mu1, s1) + 0.45 * dnorm(x, mu2, s2)
xmin <- 115; xmax <- 365; yBack <- 300; yscale <- 275
px <- xmin + (x - min(x)) / diff(range(x)) * (xmax - xmin)
py <- yBack - d * yscale
toX <- function(v) xmin + (v - min(x)) / diff(range(x)) * (xmax - xmin)

## Body: back curve, front of chest, belly and rump
## The rump is extended to the left by 'ext' pixels (without changing the
## humps) so that the tail and the head are at the same distance of the border
ext <- 30
xRump <- xmin - ext
yBelly <- 345
body <- paste0("M", sprintf("%.1f,%.1f", xRump, py[1]),
    paste0(" L", sprintf("%.1f,%.1f", px, py), collapse=""),
    sprintf(" C%.1f,%.1f %.1f,%.1f %.1f,%.1f", xmax + 25, yBack, xmax + 25,
        yBelly, xmax - 15, yBelly),
    sprintf(" L%.1f,%.1f", xRump + 15, yBelly),
    sprintf(" C%.1f,%.1f %.1f,%.1f %.1f,%.1f Z", xRump - 20, yBelly, xRump - 20,
        py[1], xRump, py[1]))

## Humps: part of the body above the shoulder line, split at the threshold
thr <- qnorm(0.95, mu1, s1)
tx <- toX(thr)
yHump <- 278

## Neck and head (facing right)
## The top of the neck starts on the back, before the end of the second hump,
## and follows the slope of the back for a smooth transition
nx0 <- xmax - 40
ny0 <- approx(px, py, xout=nx0)$y
slope <- diff(approx(px, py, xout=c(nx0 - 1, nx0 + 1))$y) / 2
neck <- sprintf(paste0("M%.1f,%.1f C%.1f,%.1f %.1f,%.1f %.1f,%.1f ",
    "L%.1f,%.1f C%.1f,%.1f %.1f,%.1f %.1f,%.1f ",
    "L%.1f,%.1f Z"),
    nx0, ny0, nx0 + 30, ny0 + 30 * slope, xmax + 28, 262, xmax + 40, 235,
    xmax + 65, 240, xmax + 58, 270, xmax + 50, 300, xmax + 20, yBelly - 10,
    nx0, yBelly - 10)
head <- sprintf(paste0('<ellipse cx="%.1f" cy="%.1f" rx="38" ry="22" ',
    'fill="%s" stroke="%s" stroke-width="5" transform="rotate(12 %.1f %.1f)"/>'),
    xmax + 82, 196, camel, camelDark, xmax + 82, 196)
ear <- sprintf('<ellipse cx="%.1f" cy="%.1f" rx="7" ry="12" fill="%s" stroke="%s" stroke-width="4"/>',
    xmax + 60, 175, camel, camelDark)
eye <- sprintf('<circle cx="%.1f" cy="%.1f" r="5" fill="%s"/>', xmax + 82, 188, navy)
smile <- sprintf('<path d="M%.1f,%.1f q10,8 20,0" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round"/>',
    xmax + 92, 208, navy)
nostril <- sprintf('<circle cx="%.1f" cy="%.1f" r="2.5" fill="%s"/>', xmax + 112, 198, navy)

## Legs and tail
yGround <- 418
## Back legs are shifted by half the rump extension to keep the balance
legX <- c(150 - ext / 2, 180 - ext / 2, 320, 348)
legDx <- c(-4, 6, -4, 6)
legs <- vapply(seq_along(legX), function(k) sprintf(
    '<path d="M%.1f,%d L%.1f,%d" stroke="%s" stroke-width="16" stroke-linecap="round"/>',
    legX[k], yBelly - 8, legX[k] + legDx[k], yGround, camelDark),
    character(1))
tail <- sprintf('<path d="M%.1f,%.1f q-22,20 -14,48" fill="none" stroke="%s" stroke-width="7" stroke-linecap="round"/>',
    xRump - 5, py[1] + 15, camelDark)

## Sun: a disc surrounded by short rounded rays
## The rays are scaled with the radius (designed for r = 26)
sunSVG <- function(x, y, r, color="#F2B134", rayColor="#E8962E") {
    k <- r / 26
    a <- seq(0, 2 * pi, length.out=13)[-13]
    rays <- sprintf(paste0('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" ',
        'stroke="%s" stroke-width="%.1f" stroke-linecap="round"/>'),
        x + (r + 8 * k) * cos(a), y + (r + 8 * k) * sin(a),
        x + (r + 20 * k) * cos(a), y + (r + 20 * k) * sin(a), rayColor, 6 * k)
    paste(c(rays, sprintf('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>',
        x, y, r, color)), collapse="\n")
}

svg <- c(
'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 518 600" width="518" height="600">',
'<defs>',
sprintf('<clipPath id="hex"><polygon points="%s"/></clipPath>', hexPts(R - 16)),
sprintf('<clipPath id="body"><path d="%s"/></clipPath>', body),
'</defs>',
sprintf('<polygon points="%s" fill="%s"/>', hexPts(R), navy),
sprintf('<polygon points="%s" fill="%s"/>', hexPts(R - 16), cream),
'<g clip-path="url(#hex)">',
## Ground line: centred on the hexagon, ending 'groundMargin' pixels before
## the inner edge of the border (drawn outside the shifted camel group)
sprintf('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="%s" stroke-width="5" stroke-linecap="round"/>',
    cx - (R - 16) * cos(pi / 6) + groundMargin, yGround + 8 + shiftY,
    cx + (R - 16) * cos(pi / 6) - groundMargin, yGround + 8 + shiftY, camelDark),
## Desert sun above the camel (optional)
if (showSun) sunSVG(x=338, y=148, r=26 * 0.9) else NULL,
sprintf('<g transform="translate(%d,%d)">', shiftX, shiftY),
tail, legs,
## Outlines first (twice as thick), then fills on top: the fills hide the
## inner half of the outlines, including the line between neck and body
sprintf('<path d="%s" fill="%s" stroke="%s" stroke-width="10" stroke-linejoin="round"/>', neck, camel, camelDark),
sprintf('<path d="%s" fill="%s" stroke="%s" stroke-width="10" stroke-linejoin="round"/>', body, camel, camelDark),
sprintf('<path d="%s" fill="%s"/>', neck, camel),
sprintf('<path d="%s" fill="%s"/>', body, camel),
'<g clip-path="url(#body)">',
sprintf('<rect x="0" y="0" width="%.1f" height="%d" fill="%s"/>', tx, yHump, grey),
sprintf('<rect x="%.1f" y="0" width="%.1f" height="%d" fill="%s"/>', tx, W - tx, yHump, red),
'</g>',
if (showLine) sprintf('<line x1="%.1f" y1="%d" x2="%.1f" y2="%d" stroke="%s" stroke-width="5" stroke-dasharray="14,9"/>', tx, round(min(py)) - 20, tx, yGround, navy) else NULL,
'<g transform="translate(-15,35)">',
ear, head, eye, smile, nostril,
'</g>',
'</g>',
'</g>',
## Package name: vector outlines (from make_name_outline.py) when available,
## so the SVG does not depend on the installed fonts; text otherwise
if (useOutlines && file.exists("name_outline.svgfrag")) {
    paste(readLines("name_outline.svgfrag"), collapse="\n")
} else {
    sprintf(paste0('<text x="259" y="468" text-anchor="middle" font-family="Helvetica, Arial, sans-serif" ',
        'font-size="60" font-weight="bold" fill="%s">split<tspan fill="#B03A36">Type</tspan>R</text>'), navy)
},
'</svg>')
writeLines(paste(svg, collapse="\n"), outFile)

## PNG version (transparent background), exported from the SVG file
if (requireNamespace("magick", quietly=TRUE)) {
    pngFile <- sub("\\.svg$", ".png", outFile)
    img <- magick::image_read(outFile, density=96)
    magick::image_write(magick::image_convert(img, "png"), pngFile,
        format="png")
    message("Written: ", outFile, " and ", pngFile)
} else {
    message("Written: ", outFile, " (install the magick package for the PNG)")
}
