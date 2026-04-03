import SwiftUI
import UIKit

/// 可捏合縮放的圖片視圖，使用 `UIViewRepresentable` 包裝 `UIScrollView`。
///
/// `UIScrollView` 原生支援流暢的捏合縮放與慣性彈跳，
/// 搭配 `UITapGestureRecognizer` 實現雙擊切換 1x/2x 縮放。
/// 頁面切換時（`filePath` 改變）自動重設縮放至 1x。
struct ZoomableImageView: UIViewRepresentable {

    // MARK: - Properties

    /// 圖片檔案的本機絕對路徑。
    let filePath: String

    // MARK: - UIViewRepresentable

    /// 建立 UIScrollView 並設定圖片內容。
    ///
    /// - Parameter context: SwiftUI 的 UIViewRepresentable 上下文。
    /// - Returns: 設定完成的 UIScrollView。
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = .clear

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        scrollView.addSubview(imageView)

        // 雙擊手勢：切換 1x / 2x
        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        return scrollView
    }

    /// 更新 UIScrollView 的圖片內容（頁面切換時觸發）。
    ///
    /// - Parameters:
    ///   - scrollView: 要更新的 UIScrollView。
    ///   - context: SwiftUI 的 UIViewRepresentable 上下文。
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard let imageView = scrollView.viewWithTag(100) as? UIImageView else {
            return
        }

        // 檔案路徑改變時才重新載入
        if context.coordinator.currentFilePath != filePath {
            context.coordinator.currentFilePath = filePath
            let image = UIImage(contentsOfFile: filePath)
            imageView.image = image

            // 重設縮放
            scrollView.zoomScale = 1.0

            // 更新 imageView frame 以匹配 scrollView bounds
            if let image {
                imageView.frame = CGRect(origin: .zero, size: image.size)
                scrollView.contentSize = image.size
                Coordinator.centerImage(imageView, in: scrollView)
            }
        }
    }

    /// 建立 Coordinator，作為 UIScrollView 的 delegate。
    ///
    /// - Returns: ``Coordinator`` 實例。
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

// MARK: - Coordinator

extension ZoomableImageView {

    /// UIScrollView 的 delegate 與手勢處理 Coordinator。
    final class Coordinator: NSObject, UIScrollViewDelegate {

        // MARK: - Properties

        /// 目前載入的檔案路徑，用於偵測頁面切換。
        var currentFilePath: String = ""

        // MARK: - UIScrollViewDelegate

        /// 回傳 scrollView 中要縮放的視圖（UIImageView）。
        ///
        /// - Parameter scrollView: 發起縮放的 scrollView。
        /// - Returns: tag 為 100 的 UIImageView。
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.viewWithTag(100)
        }

        /// 縮放完成後將圖片置中。
        ///
        /// - Parameter scrollView: 發起縮放的 scrollView。
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.viewWithTag(100) as? UIImageView else {
                return
            }
            Self.centerImage(imageView, in: scrollView)
        }

        // MARK: - Internal Methods

        /// 將圖片置中於 scrollView 中（當內容小於可視區域時）。
        ///
        /// - Parameters:
        ///   - imageView: 要置中的圖片視圖。
        ///   - scrollView: 圖片所在的 scrollView。
        static func centerImage(_ imageView: UIImageView, in scrollView: UIScrollView) {
            let boundsSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize

            let offsetX = max((boundsSize.width - contentSize.width) / 2, 0)
            let offsetY = max((boundsSize.height - contentSize.height) / 2, 0)

            imageView.center = CGPoint(
                x: contentSize.width / 2 + offsetX,
                y: contentSize.height / 2 + offsetY
            )
        }

        /// 處理雙擊手勢：在 1x 與 2x 之間切換縮放。
        ///
        /// - Parameter gesture: 雙擊手勢辨識器。
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else {
                return
            }

            if scrollView.zoomScale > 1.0 {
                scrollView.setZoomScale(1.0, animated: true)
            } else {
                let point = gesture.location(in: scrollView.viewWithTag(100))
                let zoomRect = zoomRectForScale(2.0, center: point, in: scrollView)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
}

// MARK: - Private Methods

private extension ZoomableImageView.Coordinator {

    /// 計算以指定中心點為基準的縮放矩形。
    ///
    /// - Parameters:
    ///   - scale: 目標縮放倍率。
    ///   - center: 縮放中心點（相對於內容視圖）。
    ///   - scrollView: 發起縮放的 scrollView。
    /// - Returns: 要縮放至的目標矩形。
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint, in scrollView: UIScrollView) -> CGRect {
        let size = CGSize(
            width: scrollView.bounds.width / scale,
            height: scrollView.bounds.height / scale
        )
        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
