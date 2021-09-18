
import UIKit

extension AddVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func AddImageAC(_ choice:Int){
        switch choice {
        case 0:
            self.camera()
        case 1:
            self.photoLibrary()
        case 2:
            saving.ReplaceIndex = -1
        default:
            break
        }
    }
    
    
    private func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    private func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let image = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let newiMage = image.Resize(targetSize: CGSize(width: 500, height: 500))

        if saving.ReplaceIndex == -1{
            saving.NewRecipe.Images.insert(newiMage.jpegData(compressionQuality: 0.3)!, at: 0)
        }else{
            saving.NewRecipe.Images.insert(newiMage.jpegData(compressionQuality: 0.3)!, at: saving.ReplaceIndex)
            saving.NewRecipe.Images.remove(at: saving.ReplaceIndex + 1)
            saving.ReplaceIndex = -1
        }
        
        self.imageLimit = saving.NewRecipe.Images.count >= 5 ? false : true
        ///relaod image cell if we have reached 5 image
        if self.imageLimit == false{
            self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
        }
        
        dismiss(animated: true) {
            if saving.ReplaceIndex == -1{
                self.collectionView.insertItems(at: [IndexPath(row: 1, section: 0)])
            }else{
                self.collectionView.reloadItems(at: [IndexPath(row: saving.ReplaceIndex + 1, section: 0)])
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
