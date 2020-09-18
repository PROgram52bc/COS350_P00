// Utility to draw geometric shapes on an image
import 'maths.dart';
import 'image.dart';
import 'dart:math';

class Draw {
	Image _image; // the image to operate on
	Draw(this._image);
	void ellipse(
			Point2 center, 
			double r1,
			double r2,
			{Color color,
			Vector2 orientation,
			Color borderColor,
			double borderWidth=0
			}
			) {
		(orientation ??= Vector2(1,0)).normalize();
		color ??= Color.white();
		borderColor ??= borderWidth == 0 ? color : Color.black();
		if (r2 > r1) {
			throw FormatException("invalid radius value, expected ${r1} [major radius] >= ${r2} [minor radius]");
		}
		// inner ellipse
		double innerFocalLength = sqrt(r1*r1 - r2*r2);
		Point2 innerFocus1 = center + (orientation * innerFocalLength);
		Point2 innerFocus2 = center + (-orientation * innerFocalLength);
		// outer ellipse
		double outerR1 = r1 + borderWidth;
		double outerR2 = r2 + borderWidth;
		double outerFocalLength = sqrt(outerR1*outerR1 - outerR2*outerR2);
		Point2 outerFocus1 = center + (orientation * outerFocalLength);
		Point2 outerFocus2 = center + (-orientation * outerFocalLength);
        for(var x = 0; x < _image.width; x++) {
            for(var y = 0; y < _image.height; y++) {
				var point = Point2(x.toDouble(),y.toDouble());
				double innerD = ((point - innerFocus1).length + (point - innerFocus2).length)/2;
				double outerD = ((point - outerFocus1).length + (point - outerFocus2).length)/2;
				if (innerD < r1) {
					// if point lies in the inner ellipse, fill color
					_image.setPixelSafe(x, y, color);
				} else if (innerD < r1+1 && outerD < outerR1) {
					// if point lies just on the border of inner and outer ellipse, mix the two
					_image.setPixelSafe(x, y, Color.lerp(borderColor, color, r1+1-innerD));
				} else if (outerD < outerR1) {
					// if point is within the outer ellipse, render borderColor
					_image.setPixelSafe(x, y, borderColor);
				} else if (outerD < outerR1+1) {
					// if point is on the border of outer ellipse and background, mix the two
					_image.setPixelSafe(x, y, Color.lerp(_image.getPixelSafe(x,y), borderColor, outerR1+1-outerD));
				}
			}
		}

	}
}
