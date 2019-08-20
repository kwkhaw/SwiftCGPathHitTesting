import UIKit

class ViewController: UIViewController, DrawingViewDataSource {
  var shapes: [Shape] = [Shape]()
  var oldSelectionBounds: CGRect = .zero
  var selectedShapeIndex: Int = -1 {
    willSet(newSelectedShapeIndex) {
      oldSelectionBounds = .zero
      guard let selectedShape = self.selectedShape else { return }
      if (selectedShapeIndex < self.shapes.count) {
        oldSelectionBounds = selectedShape.totalBounds()
      }
    }
    didSet {
      var newSelectionBounds: CGRect = .zero
      var rectToRedraw: CGRect = .zero
      self.deleteShapeButton.isEnabled = false
      guard let selectedShape = self.selectedShape else {
        drawingView.setNeedsDisplay()
        return
      }
      
      self.deleteShapeButton.isEnabled = true
      newSelectionBounds = selectedShape.totalBounds()
      rectToRedraw = oldSelectionBounds.union(newSelectionBounds)
      drawingView.reloadDataInRect(rect: rectToRedraw)
    }
  }
  var selectedShape: Shape? {
    get {
      if self.selectedShapeIndex == -1 || self.selectedShapeIndex >= self.shapes.count {
        return nil
      }
      return self.shapes[self.selectedShapeIndex]
    }
  }

  @IBOutlet weak var drawingView: DrawingView!
  
  @IBOutlet weak var deleteShapeButton: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.drawingView.dataSource = self
    
    let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self,  action: #selector(tapDetected))
    self.drawingView.addGestureRecognizer(tapRecognizer)
    
    let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDetected))
    self.drawingView.addGestureRecognizer(panRecognizer)
    
    self.drawingView.reloadData()
  }

  // MARK: - Shape management
  
  @IBAction func addButtonTapped(_ sender: Any) {
    let maxBounds: CGRect = self.drawingView.bounds.insetBy(dx: 10.0, dy: 10.0)
    let newShape: Shape = Shape.randomShapeInBounds(maxBounds: maxBounds)
    self.addShape(newShape: newShape)
  }
  
  func addShape(newShape: Shape) {
    self.shapes.append(newShape)
    self.drawingView.reloadDataInRect(rect: newShape.totalBounds())
  }
  
  @IBAction func deleteButtonTapped(_ sender: Any) {
    if self.selectedShapeIndex == -1 {
      return
    }
    guard let selectedShape = self.selectedShape else { return }
    let rectToRedraw: CGRect = selectedShape.totalBounds()
    self.shapes.remove(at: self.selectedShapeIndex)
    self.selectedShapeIndex = -1
    self.drawingView.reloadDataInRect(rect: rectToRedraw)
  }

  // MARK: - Hit Testing
  
  func hitTest(point: CGPoint) -> Int {
    for (index, shape) in shapes.enumerated() {
      if shape.containsPoint(point: point) {
        return index
      }
    }
    return -1
  }

  // MARK: - Touch handling
  
  @objc func tapDetected(tapRecognizer: UITapGestureRecognizer) {
    let tapLocation: CGPoint = tapRecognizer.location(in: self.drawingView)
    self.selectedShapeIndex = self.hitTest(point: tapLocation)
  }
  
  @objc func panDetected(panRecognizer: UIPanGestureRecognizer) {
    switch panRecognizer.state {
    case .began:
      let tapLocation: CGPoint = panRecognizer.location(in: self.drawingView)
      self.selectedShapeIndex = self.hitTest(point: tapLocation)
    case .changed:
      let translation: CGPoint = panRecognizer.translation(in: self.drawingView)
      guard let selectedShape = self.selectedShape else {
        return
      }
      let originalBounds: CGRect = selectedShape.totalBounds()
      let newBounds: CGRect = originalBounds.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
      let rectToRedraw: CGRect = originalBounds.union(newBounds)
      selectedShape.moveBy(delta: translation)
      self.drawingView.reloadDataInRect(rect: rectToRedraw)
      panRecognizer.setTranslation(CGPoint.zero, in: self.drawingView)
    default:
      return
    }
  }

  // MARK: - DrawingViewDataSource
  
  func numberOfShapesInDrawingView() -> Int {
    return self.shapes.count
  }
  
  func pathForShapeAtIndex(_ shapeIndex: Int) -> UIBezierPath {
    let shape = self.shapes[shapeIndex]
    return shape.path
  }
  
  func lineColorForShapeAtIndex(_ shapeIndex: Int) -> UIColor {
    let shape = self.shapes[shapeIndex]
    return shape.lineColor
  }
  
  func indexOfSelectedShapeInDrawingView() -> Int {
    return self.selectedShapeIndex
  }
}
