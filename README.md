# Going from M(massive)VC to M(minimum)VC - Part one

<!-- Almost all view controllers in iOS use TableViews
Problem with common MVC, how it transforms in Massive VC, and are untestable -->

All who start developing iOS apps, begins with MVC, Model View Controller. In the beginning thats fine, you get little view controllers with all the business logic and network requests inside. But when the project begins to grow, you realized that code is a mess, untestable, and unscalable

<!-- Where is the problem? (In the UITableViewDelegate and UITableViewDataSource, and all logic from model and network requests) -->

It is imposible to include all type of view controller, but one of the most common is the table view controller. So we are going to focus on it.

When you develop any application is highly probable that you have to use more than one view controller with a table view, so you have to write a couple of table view delegate and data source repeating the same logic all the time. That’s why we first tried to find a way to write those delegate only once for all the table views in our project. 

This is one iteration in many of which we are working, it is not our final approach.

## SectionsViewController

We create a first UIViewController with a table view which implements the main methods of both protocols (Don’t pay attention to the name of the view controller now, later it will be clear)

```javascript
class SectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }

  // MARK: — UITableViewDelegate & UITableViewDataSource

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {}

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {}

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {}

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {}

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {}

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {}

}
```
This code is not going to work but we are going to filled in a minute.

We wanted to make this view controller support all type of table view so we needed a model who represents an array of section in the table view. It also needed to have an array of objects that represents the rows of each one and its header. We called this object Section.
```javascript
class Section {

  // MARK: - Rows  

  var rows = [Row]()

  // MARK: - Header

  var headerHeight: CGFloat { return 0.01 }

  var headerCellIdentifier: String? { return nil }

  func configureHeader(cell: UITableViewCell) { }

}
```
As we can see, Section contains all the rows in one of its properties and the others properties and methods are use to configure the header of the section. To complete this section we need the Row, and that object needs to know how to configure it self.
```javascript
class Row {

   var cellIdentifier: String { get { fatalError("notImplemented") } }

   var cellHeight: CGFloat { get { fatalError("notImplemented") } }

   func configureCell(cell: UIView) { fatalError("notImplemented") }

}
```
So the class Row knows which cell represent it self and how to configure it.

Now we can complete the UITableViewDelegate and UITableViewDataSource.
```javascript
class SectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: — Public Interface

    @IBOutlet weak var tableView: UITableView!

    var sections = [Section]() { didSet { reloadData() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func reloadData() { tableView.reloadData() }

    func rowForIndexPath(indexPath: NSIndexPath) -> Row {
        let section = sections[indexPath.section]
        return section.rows[indexPath.row]
    }

    func indexPathForRow(aRow: Row) -> NSIndexPath? {
        var sectionIndex = -1, rowIndex = -1
        for section in sections {
            sectionIndex += 1
            for row in section.rows {
                rowIndex += 1
                if row === aRow { return NSIndexPath(forRow: rowIndex, inSection: sectionIndex) }
            }
            rowIndex = -1
        }
        return nil
    }

    // MARK: — UITableViewDelegate & UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return sections.count }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return section.rows.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = rowForIndexPath(indexPath)
        if let cell = tableView.dequeueReusableCellWithIdentifier(row.cellIdentifier) {
            row.configureCell(cell)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = rowForIndexPath(indexPath)
        return row.cellHeight
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = sections[section]
        if let headerIdentifier = section.headerCellIdentifier {
            let cell = tableView.dequeueReusableCellWithIdentifier(headerIdentifier)!
            section.configureHeader(cell)
            return cell
        }
        return nil
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        return section.headerHeight
    }

}
```
We needed to declare a couple of auxiliary methods, one to find a Row from an indexPath and another to get the indexPath of a Row.

In [the example project](https://github.com/bachino90/recipes) you can see an example of this implementation. The RecipesSectionsViewController looks like this:
```javascript
class RecipeSectionsViewController: SectionsViewController {

    var recipes = [Recipe(name: "Empanada", ingredients: []), Recipe(name: "Pastel de carne", ingredients: [])]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(RecipeCell.self, forCellReuseIdentifier: "RecipeCell")
        tableView.registerClass(RecipesHeaderCell.self, forCellReuseIdentifier: "RecipesHeaderCell")

        sections = [RecipesSection(recipes: recipes)]
    }
}
```
We just have to subclass the SectionsViewController, connect the tableView to a UITableView in a .xib, register the cells and set the sections you want to show.

You can see the entire implementation of the RecipeSection and RecipeRow in the project.

## Make the row actionable

For now it's fine but the rows are not clickable because we did not implement the didSelectRowAtIndexPath method. We are going to delegate this to the Row object, so every time the didSelectRowAtIndexPath is called, the performAction method for the row is called:

```javascript
class SectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  ...
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = rowForIndexPath(indexPath)
        row.performAction()
    }
  ...
}

class Row {
  ...
  fun performAction() { fatalError("notImplemented")  }
  ...
}
```

Explicar los actionDelegates

Por último, para poder diferenciar las acciones que pueden ejecutar las distintas Celdas, decidimos delegar la responsabilidad a un delegado de la Celda. Definimos un protocolo padre ActionDelegate, del cual deberán heredar los protocolos de las disintas celdas y agregamos el delegate a las Celdas.
```javascript
protocol ActionDelegate: class { }

class Row {
    weak var actionDelegate: ActionDelegate?
    ...
}

class Section {
    weak var actionDelegate: ActionDelegate? {
        didSet { rows.map { $0.actionDelegate = self.actionDelegate } }
    }
    ...
}
```  
De este modo cada SectionsViewController va a ser el delegado de las Celdas que muestra, por lo que debe implementar los metodos de los protocolos. En el ejemplo del RecipesSectionsViewController, los
```javascript
protocol RecipeActionDelegate: ActionDelegate {
    func actionDidRequestToOpenRecipe(recipe: Recipe)
}

class Row {
  ...
  override func performAction() {
      delegate?.actionDidRequestToOpenRecipe(recipe)
  }

  private var delegate: RecipeActionDelegate? {
      return actionDelegate as? RecipeActionDelegate
  }
}

extension RecipeSectionsViewController: RecipeActionDelegate {

    func actionDidRequestToOpenRecipe(recipe: Recipe) {
        let vc = RecipeDetailsViewController(recipe: recipe)
        navigationController?.pushViewController(vc, animated: true)
    }
}
```
---
<!--
StateViewController

To go further with the refactor, We are going to deal with all the busness logic and the networks requests in a view model. But first se are going to think in the sectionsviewcontroller a little moré. Generally a table view controller show a list of object that you retrueve from a API, so when the view controller is loaded, you start the request and mean exile you show a loading view un tío the request finish, then maybe you apply soñé business logic to present that data y show it. It is posible that the request returns empty data or occurs some error with it

In that flow we can recognize a couple of states that the view controller may have:

Loading
Success with data
Empty
Error -->
