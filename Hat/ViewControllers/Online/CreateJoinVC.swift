import UIKit

class CreateJoinVC: UIViewController {

    @IBOutlet weak var createButton: MyButton!
    @IBOutlet weak var joinButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        createButton.turnClickSoundOn(sound: K.Sounds.click)
        joinButton.turnClickSoundOn(sound: K.Sounds.click)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createOnline" {
            let newGameVC = segue.destination as? NewGameVC
            newGameVC?.mode = .onlineCreate
        }
    }
}
