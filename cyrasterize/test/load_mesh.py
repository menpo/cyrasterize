import sip
sip.setapi('QString', 2)
sip.setapi('QVariant', 2)

from menpo3d.rasterize import GLRasterizer
import menpo

# Build a rasterizer configured from the current view
r = GLRasterizer()
