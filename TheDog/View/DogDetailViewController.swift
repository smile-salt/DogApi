//
//  DogPhotoDetailViewController.swift
//  TheDog
//
//  Created by 山本雅浩 on 2024/02/03.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class DogDetailViewController: UIViewController {
    
    @IBOutlet private var mainScrollView: UIScrollView! {
        didSet {
            mainScrollView.delegate = self
            mainScrollView.contentSize = CGSize(
                width: calculateX(at: imageURLs.count),
                height: mainScrollView.bounds.height
            )
        }
    }

    var imageURLs: [URL] = []
    var selectedIndex = 0
    
    private let minZoomScale: CGFloat = 1.0
    private let maxZoomScale: CGFloat = 4.0

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        (0..<imageURLs.count).forEach { page in
            let subScrollView = generateSubScrollView(at: page)
            mainScrollView.addSubview(subScrollView)
            let imageView = generateImageView(at: page)
            subScrollView.addSubview(imageView)
        }

        // 該当ページを表示
        mainScrollView.scrollToPage(page: selectedIndex, animated: false)
    }
    
    @objc func didDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let subScrollView = gesture.view as? UIScrollView else { return }

        if subScrollView.zoomScale < subScrollView.maximumZoomScale {
            let location = gesture.location(in: subScrollView)
            let rect = calculateRectForZoom(location: location, scale: subScrollView.maximumZoomScale)
            subScrollView.zoom(to: rect, animated: true)
        } else {
            subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: true)
        }
    }

    private func generateSubScrollView(at page: Int) -> UIScrollView {
        let frame = calculateSubScrollViewFrame(at: page)
        let subScrollView = UIScrollView(frame: frame)

        subScrollView.delegate = self
        subScrollView.maximumZoomScale = 3.0
        subScrollView.minimumZoomScale = 1.0
        subScrollView.showsHorizontalScrollIndicator = false
        subScrollView.showsVerticalScrollIndicator = false

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        gesture.numberOfTapsRequired = 2
        subScrollView.addGestureRecognizer(gesture)

        return subScrollView
    }
    
    

    private func generateImageView(at page: Int) -> UIImageView {
        let imageView = UIImageView(frame: mainScrollView.bounds)
        imageView.contentMode = .scaleAspectFit

        let imageURL = imageURLs[page]
        AF.request(imageURL).responseImage { response in
            switch response.result {
            case .success(let image):
                imageView.image = image
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }

        return imageView
    }

    private func calculateX(at position: Int) -> CGFloat {
        return mainScrollView.bounds.width * CGFloat(position)
    }

    private func calculatePage(of scrollView: UIScrollView) -> Int {
        let width = scrollView.bounds.width
        let offsetX = scrollView.contentOffset.x
        let position = (offsetX - (width / 2)) / width
        return Int(floor(position) + 1)
    }

    private func calculateRectForZoom(location: CGPoint, scale: CGFloat) -> CGRect {
        let size = CGSize(
            width: mainScrollView.bounds.width / scale,
            height: mainScrollView.bounds.height / scale
        )
        let origin = CGPoint(
            x: location.x - size.width / 2,
            y: location.y - size.height / 2
        )
        return CGRect(origin: origin, size: size)
    }

    private func calculateSubScrollViewFrame(at page: Int) -> CGRect {
        var frame = mainScrollView.bounds
        frame.origin.x = calculateX(at: page)
        return frame
    }

    private func resetZoomScaleOfSubScrollViews(without exclusionSubScrollView: UIScrollView) {
        for subview in mainScrollView.subviews {
            guard
                let subScrollView = subview as? UIScrollView,
                subScrollView != exclusionSubScrollView
            else {
                continue
            }
            subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: false)
        }
    }
    
    func zoomForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.mainScrollView.frame.size.height / scale
        zoomRect.size.width = self.mainScrollView.frame.size.width  / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        return zoomRect
    }
    
    private func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        let size = CGSize(
            width: scrollView.frame.width / scale,
            height: scrollView.frame.height / scale
        )
        let rect = CGRect(
            origin: CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            ),
            size: size
        )
        return rect
    }
}

extension DogDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != mainScrollView { return }

        let page = calculatePage(of: scrollView)
        if page == selectedIndex { return }
        selectedIndex = page

        resetZoomScaleOfSubScrollViews(without: scrollView)

        print("🚀 scrollViewDidEndDecelerating page=\(page)")
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first as? UIImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = scrollView.subviews.first as? UIImageView else { return }

        scrollView.contentInset = UIEdgeInsets(
            top: max((scrollView.frame.height - imageView.frame.height) / 2, 0),
            left: max((scrollView.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0
        )
    }
}

private extension UIScrollView {
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: animated)
    }
}
