package com.leoho.naverBlogImageDownloader.android.features.photoviewer.view

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leoho.naverBlogImageDownloader.android.features.photoviewer.viewmodel.PhotoViewerViewModel

// region FileInfoContent

/**
 * 檔案資訊 Bottom Sheet 內容，顯示檔案大小與圖片尺寸。
 *
 * 使用 Flutter 傳入的 l10n 字串作為標籤文字。
 *
 * @param viewModel 檢視器的 ViewModel，用於讀取檔案資訊與 l10n 字串。
 */
@Composable
fun FileInfoContent(viewModel: PhotoViewerViewModel) {
    Column(modifier = Modifier.padding(bottom = 32.dp)) {
        Text(
            text = viewModel.localizedStrings["fileInfo"] ?: "File Info",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        )

        val info = remember(viewModel.currentIndex) {
            viewModel.fileInfo(viewModel.currentIndex)
        }

        if (info != null) {
            ListItem(
                headlineContent = {
                    Text(viewModel.localizedStrings["fileSize"] ?: "File Size")
                },
                trailingContent = {
                    Text(info.formattedFileSize, color = Color.Gray)
                },
            )
            ListItem(
                headlineContent = {
                    Text(viewModel.localizedStrings["dimensions"] ?: "Dimensions")
                },
                trailingContent = {
                    Text(info.formattedDimensions, color = Color.Gray)
                },
            )
        }
    }
}

// endregion
