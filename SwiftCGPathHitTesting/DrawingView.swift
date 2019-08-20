import UIKit

protocol DrawingViewDataSource {
  func numberOfShapesInDrawingView() -> Int
  func pathForShapeAtIndex(_ shapeIndex: Int) -> UIBezierPath
  func lineColorForShapeAtIndex(_ shapeIndex: Int) -> UIColor
  func indexOfSelectedShapeInDrawingView() -> Int
}

class DrawingView: UIView {
  var dataSource: DrawingViewDataSource?

  func reloadData() {
    setNeedsDisplay()
  }
  
  func reloadDataInRect(rect: CGRect) {
    self.setNeedsDisplay(rect)
  }
  
  override func draw(_ rect: CGRect) {
    guard let dataSource = self.dataSource else { return }
    let numberOfShapes = dataSource.numberOfShapesInDrawingView()
    let indexOfSelectedShape: Int = dataSource.indexOfSelectedShapeInDrawingView()
    for shapeIndex in 0..<numberOfShapes {
      let path: UIBezierPath = dataSource.pathForShapeAtIndex(shapeIndex)
      
      if rect.intersects(path.bounds.insetBy(dx: -(path.lineWidth + 1.0), dy: -(path.lineWidth + 1.0))) {
        let lineColor: UIColor = dataSource.lineColorForShapeAtIndex(shapeIndex)
        lineColor.setStroke()
        path.stroke()
        
        if shapeIndex == indexOfSelectedShape {
          let pathCopy: UIBezierPath = path.copy() as! UIBezierPath
          let cgPathSelectionRect: CGPath = pathCopy.cgPath.copy(strokingWithWidth: pathCopy.lineWidth, lineCap: pathCopy.lineCapStyle, lineJoin: pathCopy.lineJoinStyle, miterLimit: pathCopy.miterLimit)
          let selectionRect: UIBezierPath = UIBezierPath(cgPath: cgPathSelectionRect)
          
          let dashStyle: [CGFloat] = [ 5.0, 5.0 ]
          selectionRect.setLineDash(dashStyle, count: 2, phase: 0)
          UIColor.black.setStroke()
          selectionRect.stroke()
        }
      }
    }
  }
}
