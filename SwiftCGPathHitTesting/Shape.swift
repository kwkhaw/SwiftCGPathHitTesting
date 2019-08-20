import UIKit

enum ShapeType: UInt32, CaseIterable {
  case Rect
  case Ellipse
  case House
  case Arc
}

class Shape {
  var path: UIBezierPath
  var lineColor: UIColor
  private var tapTarget: UIBezierPath?

  init(path: UIBezierPath, lineColor: UIColor) {
    self.path = path
    self.lineColor = lineColor
    tapTarget = self.tapTargetForPath(path: self.path)
  }

  static func randomShapeInBounds(maxBounds: CGRect) -> Shape {
    var path: UIBezierPath
    let bounds: CGRect = self.randomRectInBounds(maxBounds: maxBounds)
    let type: ShapeType = self.randomShapeType()
    switch (type) {
    case .Rect:
      path = UIBezierPath(rect: bounds)
    case .Ellipse:
      path = UIBezierPath(ovalIn: bounds)
    case .House:
      path = self.houseInRect(bounds: bounds)
    case .Arc:
      path = self.arcInRect(bounds: bounds)
    }
    path.lineWidth = self.randomLineWidth()
    let lineColor: UIColor = self.randomColor()
    
    return Shape(path: path, lineColor: lineColor)
  }
  
  // MARK - Hit Testing
  
  func tapTargetForPath(path: UIBezierPath) -> UIBezierPath {
    let tapTargetPath: CGPath = path.cgPath.copy(strokingWithWidth: max(35.0, path.lineWidth), lineCap: path.lineCapStyle, lineJoin: path.lineJoinStyle, miterLimit: path.miterLimit)
    let tapTarget: UIBezierPath = UIBezierPath(cgPath: tapTargetPath)
    return tapTarget;
  }
  
  func containsPoint(point: CGPoint) -> Bool {
    return self.tapTarget!.contains(point)
  }

  // MARK: - Bounds
  
  func totalBounds() -> CGRect {
    return self.path.bounds.insetBy(dx: -(self.path.lineWidth + 1.0), dy: -(self.path.lineWidth + 1.0))
  }
  
  // MARK: - Modifying Shapes
  
  func moveBy(delta: CGPoint) {
    let transform: CGAffineTransform = CGAffineTransform(translationX: delta.x, y: delta.y);
    self.path.apply(transform)
    self.tapTarget!.apply(transform)
  }

  func shape(path: UIBezierPath, lineColor: UIColor) -> Shape {
    return Shape(path: path, lineColor: lineColor)
  }

  static func randomColor() -> UIColor {
    let colors: [UIColor] = [
      .blue,
      .red,
      .green,
      .yellow,
      .magenta,
      .brown,
      .purple,
      .orange,
    ]
    let colorIndex = Int.random(in: 0..<colors.count)
    return colors[colorIndex]
  }

  static func randomLineWidth() -> CGFloat {
    let maxLineWidth = 15;
    let lineWidth: CGFloat = CGFloat(Int.random(in: 0...maxLineWidth)) + 1.0; // avoid lineWidth == 0.0
    return lineWidth
  }

  static func randomRectInBounds(maxBounds: CGRect) -> CGRect {
    let normalizedBounds: CGRect = maxBounds.standardized;
    let minOriginX = normalizedBounds.origin.x;
    let minOriginY = normalizedBounds.origin.y;
    let minWidth: CGFloat = 44;
    let minHeight: CGFloat = 44;
    
    let maxOriginX = normalizedBounds.size.width - minWidth;
    let maxOriginY = normalizedBounds.size.height - minHeight;
    
    let originX = CGFloat(Int.random(in: 0...Int(maxOriginX - minOriginX))) + minOriginX;
    let originY = CGFloat(Int.random(in: 0...Int(maxOriginY - minOriginY))) + minOriginY;
    
    let maxWidth = normalizedBounds.size.width - originX;
    let maxHeight = normalizedBounds.size.height - originY;
    
    let width = CGFloat(Int.random(in: 0...Int(maxWidth - minWidth))) + minWidth;
    let height = CGFloat(Int.random(in: 0...Int(maxHeight - minHeight))) + minHeight;
    
    let randomRect: CGRect = CGRect(x: originX, y: originY, width: width, height: height);
    return randomRect;
  }

  // MARK: - Random Shape Generator Methods
  
  static func randomShapeType() -> ShapeType {
    return ShapeType(rawValue: UInt32.random(in: 0..<UInt32(ShapeType.allCases.count)))!
  }
  
  static func houseInRect(bounds: CGRect) -> UIBezierPath {
    let bottomLeft: CGPoint = CGPoint(x: bounds.minX, y: bounds.minY)
    let topLeft: CGPoint = CGPoint(x: bounds.minX, y: bounds.minY + bounds.height * 2.0/3.0)
    let bottomRight: CGPoint = CGPoint(x: bounds.maxX, y: bounds.minY)
    let topRight: CGPoint = CGPoint(x: bounds.maxX, y: bounds.minY + bounds.height * 2.0/3.0)
    let roofTip: CGPoint = CGPoint(x: bounds.midX, y: bounds.maxY)
    
    let path: UIBezierPath = UIBezierPath()
    path.move(to: bottomLeft)
    path.addLine(to: topLeft)
    path.addLine(to: roofTip)
    path.addLine(to: topRight)
    path.addLine(to: topLeft)
    path.addLine(to: bottomRight)
    path.addLine(to: topRight)
    path.addLine(to: bottomLeft)
    path.addLine(to: bottomRight)
    
    path.lineJoinStyle = .round;
    
    var transform: CGAffineTransform = .identity
    transform = transform.translatedBy(x: bounds.origin.x, y: bounds.origin.y)
    transform = transform.translatedBy(x: 0.0, y: bounds.size.height)
    transform = transform.scaledBy(x: 1.0, y: -1.0)
    transform = transform.translatedBy(x: -bounds.origin.x, y: -bounds.origin.y);
    path.apply(transform)
    
    return path
  }
  
  static func arcInRect(bounds: CGRect) -> UIBezierPath {
    let center: CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
    let centerRight: CGPoint = CGPoint(x: bounds.maxX, y: bounds.midY)
    let radius: CGFloat = bounds.width / 2.0
    let center2: CGPoint = CGPoint(x: center.x, y: center.y - radius / 2.0)

    let path: UIBezierPath = UIBezierPath()
    path.move(to: centerRight)
    path.addArc(withCenter: center, radius: radius, startAngle: 0.0, endAngle: .pi * 1.5, clockwise: true)
    path.addArc(withCenter: center2, radius: radius/2.0, startAngle: .pi * 1.5, endAngle: .pi, clockwise: true)
    
    path.lineJoinStyle = .round;
    
    var transform: CGAffineTransform = .identity
    transform = transform.translatedBy(x: bounds.origin.x, y: bounds.origin.y)
    transform = transform.translatedBy(x: 0.0, y: bounds.size.height)
    transform = transform.scaledBy(x: 1.0, y: -1.0)
    transform = transform.translatedBy(x: -bounds.origin.x, y: -bounds.origin.y);
    path.apply(transform)
    
    return path
  }
}
