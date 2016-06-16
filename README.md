# Going from M(massive)VC to M(minimum)VC - Part one

All who start developing iOS apps begin with **MVC**, Model View Controller. In the beginning thats fine, you get little view controllers with all the business logic and network requests inside. But when the project begins to grow, you realize the code is a mess (a lot of code with different purpose in a single file), untestable (Have you ever try to test a view controller with its lifecycle and dependencies? in the part two of the article we'll talk about this), and unscalable (Have you ever tried to add different kinds of `UITableViewCell` to an existing `UITableViewDataSource`?)

It is impossible to include all types of view controller, but one of the most common is the table view controller where you can list anything. So we are going to focus on it.

## SectionsViewController

When you develop any application is highly probable that you have to use more than one view controller with a table view, so you have to write a couple of table view delegate and data source repeating the same logic all the time.

In our [example](https://github.com/bachino90/recipes) we wanted to create a list of recipes sorted by kind of meal (Appetizers, Side Dishes, Dinners, Desserts), and when you selected one it showed you the ingredients and how to prepare it. So we need two view controllers with tables views, one for the list of recipes and another for de recipe details. If we followed our first learnings of developing apps with MVC, the `UITableViewDataSource` methods start to get verbosely, like the `RecipeDetailsTableViewController`:
```javascript
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell") as! IngredientCell
        cell.configureForIngredient(recipe.ingredients[indexPath.row])
        return cell
    } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell") as! DescriptionCell
        cell.configureForDescription(recipe.description)
        return cell
    }
}
```
When you have only one type of cell it's fine, like the `RecipeTableViewController`
```javascript
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = recipes[indexPath.section]
    let recipe = section[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell") as! RecipeCell
    cell.configureForRecipe(recipe)
    return cell
}
```
So we not only want to write only once the `delegate` and `dataSource` of the `UITableView`, we want to add cells easily. Also when you follow the **DRY** principle it is easier to find bugs and to scale the application.

So we create a `UIViewController` with a table view which implements the main methods of the `UITableViewDelegate` and `UITableViewDataSource` protocols and we name it `SectionsViewController`
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
This code is not working but we are going to complete it in a minute.

We want to make this view controller support all types of table views so we need a model that represents an array of sections in the table view. It also needs to have an array of objects that represents the rows of each one and its header. We call this object **Section**. So now you can subclass the `Section` to represent different kinds of sections of rows.
```javascript
class Section {

    // MARK: - Rows  

    var rows = [Row]()

    // MARK: - Header

    var headerHeight: CGFloat? { return nil }

    var headerCellIdentifier: String? { return nil }

    func configureHeader(cell: UITableViewCell) { }

}
```
As we can see, `Section` contains all the rows in one of its properties and the others properties and methods are used to configure the header of the section. To complete this section we need the `Row` class, and that object needs to know how to configure itself.
```javascript
class Row {

   var cellIdentifier: String { get { fatalError("notImplemented") } }

   var cellHeight: CGFloat { get { fatalError("notImplemented") } }

   func configureCell(cell: UIView) { fatalError("notImplemented") }

}
```
So, the class `Row` knows what kind of cell represents and how to configure it.

Now we can complete the `UITableViewDelegate` and `UITableViewDataSource`.
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
        return section.headerHeight ?? 0.01 //If it's nil, should not be displayed
    }

}
```
We needed to declare a couple of auxiliary methods, one to find a `Row` from an `indexPath` and another to get the `indexPath` of a `Row`.

In [the example project](https://github.com/bachino90/recipes) you can see an example of this implementation. The `RecipesSectionsViewController` looks like this:
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
We just have to:

1. Subclass the `SectionsViewController`,
2. Connect the `tableView` to a `UITableView` in a .xib and
3. Register the cells and set the sections you want to show.

You can see the entire implementation of the `RecipeSection` and `RecipeRow` in the project.

## Make the row actionable

For now it's fine but the rows are not clickable because we did not implement the `didSelectRowAtIndexPath` method. But we wanted to make the `didSelectRowAtIndexPath` method a generic one. So we delegate the action to the `Row`
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
But how can we communicate the action that the view controller has to perform?, maybe open a modal, show an alert view or make a push in a `navigationController`. For example, in our Recipes project if any tap the recipe cell we want to make a push to a new view controller which details all the ingredients of the recipe.

So we have to add a delegate in the Row and Section models, which is going to be set when the sections property in the `SectionsViewController` is set. We called this delegate, actionDelegate. When the `actionDelegate` of a `Section` is set, it iterates over the rows to set the `actionDelegate` of each one. We also define an abstract protocol called `ActionDelegate`, from which all the Row's protocol must inherit:
```javascript
protocol ActionDelegate: class { }

class Row {
    weak var actionDelegate: ActionDelegate?
    ...
}

class Section {
    weak var actionDelegate: ActionDelegate? {
        didSet { for row in rows { row.actionDelegate = self.actionDelegate } }
    }
    ...
}

class SectionsViewController: UIViewController, ActionDelegate, UITableViewDelegate, UITableViewDataSource {
    ...
    var sections = [Section]() {
        didSet {
            for section in sections { section.actionDelegate = self }
            reloadData()
        }
    }
    ...
}
```  
Ultimately, we have to extend your `SectionsViewController` with the method declare int the Row's protocol. In the Recipes example:
```javascript
extension RecipeSectionsViewController: RecipeActionDelegate {
    func actionDidRequestToOpenRecipe(recipe: Recipe) {
        let vc = RecipeDetailsViewController(recipe: recipe)
        navigationController?.pushViewController(vc, animated: true)
    }
}
```
In our Recipe project we had to declare one more property in the `RecipeRow`, the `delegate`, which cast the `actionDelegate` to the correct subclass of the `ActionDelegate` protocol, `RecipeActionDelegate`:
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
##Next steps

This is one iteration in many of which we are working, but it is not going to be the last one. Everyday we face new troubles and find better solutions, so as we go improving this approach we are going to release new posts.

In the next part of the post we are going to talk about how to retrieve those recipes from the network. Where goes the business logic? Short answer: view model.
