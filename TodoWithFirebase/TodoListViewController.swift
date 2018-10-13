//
//  TodoListViewController.swift
//  TodoWithFirebase
//
//  Created by Ahmet on 7.10.2018.
//  Copyright © 2018 Ahmet Keskin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseRemoteConfig
import GoogleSignIn
import FirebaseAuth

class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableView.automaticDimension
            tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "TaskCell")
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var addTaskTextField: UITextField! {
        didSet {
            addTaskTextField.returnKeyType = .done
            addTaskTextField.leftViewMode = .always
        }
    }
    @IBOutlet weak var addTaskTextFieldBottomConstraint: NSLayoutConstraint!
    
    var taskDbRef: DatabaseReference!
    var remoteConfig: RemoteConfig!
    
    
    var dataSnapshot: DataSnapshot? {
        didSet {
            self.tasks = dataSnapshot?.children.allObjects.compactMap({ (data) -> Task? in
                return Task(dict: (data as? DataSnapshot)?.value as? [String:String], key: (data as? DataSnapshot)?.key)
            }) ?? [Task]()
            self.tableView.reloadData()
        }
    }
    
    var tasks: [Task] = [Task]()
    
    //MARK: UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareDatabase()
        prepareRemoteConfig()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TodoListViewController.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(TodoListViewController.keyboardWillHide(_:)), name :UIWindow.keyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    private func prepareUI() {
        self.title = "TodoList"
        addTaskTextField.delegate = self
        addTaskTextField.borderStyle = .roundedRect
        addTaskTextField.placeholder = "Add a to-do.."
        
        prepareRightButtonBarItem()
    }
    
    private func prepareDatabase() {
        
        taskDbRef = Database.database().reference().child("tasks")
        
        taskDbRef.child(currentUser.uid).observe(.childAdded) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            let task = Task(dict: snapshot.value as? [String : String], key: snapshot.key)
            strongSelf.tasks.append(task)
            let indexPath = IndexPath(row: strongSelf.tasks.count - 1, section: 0)
            strongSelf.tableView.insertRows(at: [indexPath], with: .automatic)
        }

        taskDbRef.child(currentUser.uid).observe(.childRemoved) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard let index = strongSelf.findIndexOfRemovedTask(key: snapshot.key) else { return }
            strongSelf.tasks.remove(at: index)
            strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
//        taskDbRef.child(currentUser.uid).observe(.value) { [weak self] (snapshot) in
//            self?.dataSnapshot = snapshot
//        }
        
    }
    
    private func prepareRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.fetch(withExpirationDuration: TimeInterval(5)) { (status, error) -> Void in
            if status == .success {
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func prepareRightButtonBarItem() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.addTarget(self, action: #selector(TodoListViewController.logoutButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_exit"), for: .normal)
        let rightButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    private func findIndexOfRemovedTask(key: String) -> Int? {
        for (index,task) in tasks.enumerated() {
            if task.key == key {
                return index
            }
        }
        return nil
    }
    
    @objc func logoutButtonTapped() {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.disconnect()
        try? Auth.auth().signOut()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardFrame: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        addTaskTextFieldBottomConstraint.constant = keyboardFrame.height + 8.0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        addTaskTextFieldBottomConstraint.constant = 8.0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
 
}

extension TodoListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let text = textField.text, text.count > 0 {
            taskDbRef.child(currentUser.uid).childByAutoId().setValue(["taskDesc" : text, "date": createFormattedDate()])
        }
        
        self.view.endEditing(true)
        addTaskTextField.text = ""
        return true
    }
    
    fileprivate func createFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
        
    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let task = self.tasks[indexPath.row]
        cell.configure(task: task)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction.init(style: .default, title: "Sil") { (rowAction, indexPath) in
            let task = self.tasks[indexPath.row]
            self.taskDbRef.child(currentUser.uid).child(task.key).removeValue()
        }
        return [action]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isRemoveEnabled = remoteConfig.configValue(forKey: "isRemoveEnabled").boolValue
        return isRemoveEnabled
    }
    
}
