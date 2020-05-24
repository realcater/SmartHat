import UIKit

class CreateJoinVC: UIViewController {

    @IBOutlet weak var createButton: MyButton!
    @IBOutlet weak var joinButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        createButton.turnClickSoundOn(sound: K.sounds.click)
        joinButton.turnClickSoundOn(sound: K.sounds.click)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
            title = Auth().name ?? ""
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createOnline" {
            let newGameVC = segue.destination as? NewGameVC
            newGameVC?.mode = .onlineCreate
        }
        if segue.identifier == "changeName" {
            let settingsVC = segue.destination as? SettingsVC
            settingsVC?.createJoinVCDelegate = self
        }
        
    }
}

protocol CreateJoinVCDelegate: class {
    func update(title: String)
}

extension CreateJoinVC: CreateJoinVCDelegate {
    func update(title: String) {
        self.title = title
    }
}
