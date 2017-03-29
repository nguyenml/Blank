
import Firebase
import FirebaseDatabase

class ELViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref = FIRDatabaseReference!
    var handle = FIRDatabaseHandle?
    
    @IBOutlet weak var tableView

    let entries = [Constants.Entry()]
    
    override func viewDidLoad(){
        //set database reference
        ref = FIRDatabase.database().reference()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        handle = ref.child("Entries").queryOrderedByKey().observe(.childAdded, with:{
            snapshot in
            
            self.entries.append("")

        })
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
    }
    
    
    
    

}
