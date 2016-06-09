# Going from M(massive)VC to M(minimum)VC - Part one

All who start developing iOS apps, begins with MVC, Model View Controller. In the beginning thats fine, you get little view controllers with all the business logic and network requests inside. But when the project begins to grow, you realized that code is a mess (a bunch of code with different purpose in a single file), untestable (Have you ever try to test a view controller with it lifecycle and dependencies? in the part two of the article we talk about this), and unscalable (Have you ever try to add a different kind of UITableViewCell to an existing UITableViewDataSource?)

It is imposible to include all type of view controller, but one of the most common is the table view controller _can you name some examples to justify this?_. So we are going to focus on it.

When you develop any application is highly probable that you have to use more than one view controller with a table view, so you have to write a couple of table view delegate and data source repeating the same logic all the time. That’s why we first tried to find a way to write those delegates only once for all the table views in our project, because when you follow the DRY principle it is easier to find bugs and to scale the application.

This is one iteration in many of which we are working, it is not our final approach.  _...then, why are you writing about this? can you preview a little as an introduction to what can be gained with this approach?_

## SectionsViewController

We create a first UIViewController with a table view which implements the main methods of the UITableViewDelegate and UITableViewDataSource protocols (Don’t pay attention to the name of the view controller now, later it will be clear)

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
This code is not going to work but we are going to complete it in a minute.

We wanted to make this view controller support all type of table view so we needed a model who represents an array of section in the table view. It also needed to have an array of objects that represents the rows of each one and its header. We called this object Section. So you can subclass the Section to represent different kinds of sections of row.
```javascript
class Section {

  // MARK: - Rows  

  var rows = [Row]()

  // MARK: - Header

  var headerHeight: CGFloat { return 0.01 }  _why is this needed?_

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

For now it's fine but the rows are not clickable because we did not implement the didSelectRowAtIndexPath method. But we wanted to make the didSelectRowAtIndexPath method a generic one. So we delegate the action to the Row:

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
  func performAction() { fatalError("notImplemented")  }
  ...
}
```
But how can we communicate the action that the view controller has to perform?, maybe open a modal, show an alert view or make a push in a navigationController. For example, in our Recipes project if any tap the recipe cell we want to make a push to a new view controller which details all the ingredients of the recipe.

So we have to add a delegate in the Row and Section models, which is going to be set when the sections property in the SectionsViewController is set. We called this delegate, actionDelegate. When the actionDelegate of a Section is set, it iterates over the rows to set the actionDelegate of each one. We also define an abstract protocol called ActionDelegate, from which all the Row's protocol must inherit:
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
Ultimately, we have to extend your SectionsViewController with the method declare int the Row's protocol. In the Recipes example:
```javascript
extension RecipeSectionsViewController: RecipeActionDelegate {
  func actionDidRequestToOpenRecipe(recipe: Recipe) {
      let vc = RecipeDetailsViewController(recipe: recipe)
      navigationController?.pushViewController(vc, animated: true)
  }
}
```
In our Recipe project we had to declare one more property in the RecipeRow, the delegate, which cast the actionDelegate to the correct subclass of the ActionDelegate protocol, RecipeActionDelegate:
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
```
