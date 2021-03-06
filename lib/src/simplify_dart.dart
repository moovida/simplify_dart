/// Code ported from  (c) 2017, Vladimir Agafonkin
/// Simplify.js, a high-performance JS polyline simplification library
/// mourner.github.io/simplify-js

// square distance between 2 points
double getSqDist(p1, p2) {
  var dx = p1.x - p2.x, dy = p1.y - p2.y;

  return dx * dx + dy * dy;
}

// square distance from a point to a segment
double getSqSegDist(p, p1, p2) {
  var x = p1.x, y = p1.y, dx = p2.x - x, dy = p2.y - y;

  if (dx != 0 || dy != 0) {
    var t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = p2.x;
      y = p2.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;

  return dx * dx + dy * dy;
}
// rest of the code doesn't care about point format

// basic distance-based simplification
List<dynamic> simplifyRadialDist(points, sqTolerance) {
  var prevPoint = points[0], newPoints = [prevPoint], point;

  for (var i = 1, len = points.length; i < len; i++) {
    point = points[i];

    if (getSqDist(point, prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }

  if (prevPoint != point) newPoints.add(point);

  return newPoints;
}

void simplifyDPStep(points, first, last, sqTolerance, simplified) {
  var maxSqDist = sqTolerance, index;

  for (var i = first + 1; i < last; i++) {
    var sqDist = getSqSegDist(points[i], points[first], points[last]);

    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - first > 1) {
      simplifyDPStep(points, first, index, sqTolerance, simplified);
    }
    simplified.add(points[index]);
    if (last - index > 1) {
      simplifyDPStep(points, index, last, sqTolerance, simplified);
    }
  }
}

// simplification using Ramer-Douglas-Peucker algorithm
List<dynamic> simplifyDouglasPeucker(points, sqTolerance) {
  var last = points.length - 1;

  var simplified = [points[0]];
  simplifyDPStep(points, 0, last, sqTolerance, simplified);
  simplified.add(points[last]);

  return simplified;
}

// both algorithms combined for awesome performance
List<dynamic> simplify(points, {tolerance = 1, highestQuality = false}) {
  if (points.length <= 2) return points;

  var sqTolerance = tolerance != null ? tolerance * tolerance : 1;

  points = highestQuality ? points : simplifyRadialDist(points, sqTolerance);
  points = simplifyDouglasPeucker(points, sqTolerance);

  return points;
}
