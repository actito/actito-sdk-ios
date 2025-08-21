//
// Copyright (c) 2025 Actito. All rights reserved.
//

import ActitoKit
import UIKit

public class ActitoImageGalleryViewController: ActitoBaseNotificationViewController {
    // UI references
    internal private(set) var collectionView: UICollectionView!
    internal private(set) var pageControl: UIPageControl!

    private var images = [UIImage?]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFinishPresentingNotification: self.notification)
    }

    private func setupViews() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = .zero

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.scrollIndicatorInsets = .zero
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(ActitoImageGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "standard")
        if let colorStr = theme?.backgroundColor {
            collectionView.backgroundColor = UIColor(hexString: colorStr)
        } else {
            if #available(iOS 13.0, *) {
                collectionView.backgroundColor = .systemBackground
            } else {
                collectionView.backgroundColor = .white
            }
        }

        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = notification.content.count
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0

        view.addSubview(collectionView)
        view.addSubview(pageControl)

        // Constrain the collection view.
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Constraint the page control.
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
        ])
    }

    private func setupContent() {
        guard !notification.content.isEmpty else {
            Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didFailToPresentNotification: self.notification)
            return
        }

        // Prepare the array with empty images.
        images = .init(repeating: nil, count: notification.content.count)

        notification.content.enumerated().forEach { index, content in
            let url = URL(string: content.data as! String)!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.images[index] = UIImage(data: data)
                        self.collectionView.reloadData()
                    }
                }
            }.resume()
        }

        Actito.shared.pushUI().delegate?.actito(Actito.shared.pushUI(), didPresentNotification: self.notification)
    }

    private func openSharingActionSheet(for image: UIImage) {
        let placeholderText = ActitoLocalizable.string(resource: .actionsShareImageTextPlaceholder)
        let items: [Any] = placeholderText == ActitoLocalizable.StringResource.actionsShareImageTextPlaceholder.rawValue
        ? [image]
        : [image, placeholderText]

        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = [.postToWeibo, .assignToContact, .message, .mail]

        present(controller, animated: true, completion: nil)
    }
}

extension ActitoImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        images.count
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "standard", for: indexPath) as! ActitoImageGalleryCollectionViewCell
        cell.imageView.image = images[indexPath.row]

        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.size.width
        let horizontalCenter = width / 2

        pageControl.currentPage = Int((offset + horizontalCenter) / width)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Actito.shared.options!.imageSharingEnabled == true, let image = images[indexPath.row] {
            openSharingActionSheet(for: image)
        }
    }
}

extension ActitoImageGalleryViewController: ActitoNotificationPresenter {
    internal func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
