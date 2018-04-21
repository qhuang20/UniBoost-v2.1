//
//  ResponseMessageCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import SimpleImageViewer
import LBTAComponents

class ResponseMessageCell: PostMessageCell {
   
    var responseMessage: ResponseMessage? {
        didSet {
            guard let responseMessage = responseMessage else { return }
            thumbnailImageView.backgroundColor = brightGray
            
            if let thumbnailImageUrl = responseMessage.thumbnailUrl {
                postTextViewHeightAnchor?.constant = 0
                thumbnailImageViewHeightAnchor?.constant = responseMessage.imageHeight!
                activityIndicatorView.startAnimating()
                thumbnailImageView.loadImage(urlString: thumbnailImageUrl, completion: {
                    self.activityIndicatorView.stopAnimating()
                })
                
                postTextView.text = nil
                thumbnailImageView.isHidden = false
                postTextView.isHidden = true
                
            } else {
                
                postTextViewHeightAnchor?.constant = estimateHeightFor(text: responseMessage.text ?? "") + 18
                thumbnailImageViewHeightAnchor?.constant = 0
                postTextView.text = responseMessage.text
                
                thumbnailImageView.image = nil
                thumbnailImageView.isHidden = true
                postTextView.isHidden = false
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        for recognizer in thumbnailImageView.gestureRecognizers ?? [] {
            thumbnailImageView.removeGestureRecognizer(recognizer)
        }
        thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImageView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc private func zoomImageView() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = thumbnailImageView

            let imageUrl = responseMessage?.imageUrl ?? ""
            let highQImageView = CachedImageView(cornerRadius: 0, emptyImage: nil)

            config.imageBlock = { imageCompletion in
                highQImageView.loadImage(urlString: imageUrl, completion: {
                    imageCompletion(highQImageView.image)
                    self.thumbnailImageView.image = highQImageView.image
                })
            }
        }

        let imageViewerController = ImageViewerController(configuration: configuration)
        postContentController?.present(imageViewerController, animated: true)
    }
    
}
