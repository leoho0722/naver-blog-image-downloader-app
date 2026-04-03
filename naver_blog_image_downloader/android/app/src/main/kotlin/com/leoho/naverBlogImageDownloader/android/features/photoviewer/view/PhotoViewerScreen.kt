package com.leoho.naverBlogImageDownloader.android.features.photoviewer.view

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.leoho.naverBlogImageDownloader.android.features.photoviewer.viewmodel.PhotoViewerViewModel

// region PhotoViewerScreen

/**
 * 圖片檢視器主畫面 Composable。
 *
 * 使用 [Scaffold] + [TopAppBar] 提供 Material 3 標準導航列，
 * [HorizontalPager] 實現水平翻頁，底部膠囊列以 overlay 方式呈現。
 *
 * @param viewModel 檢視器的狀態管理 ViewModel。
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PhotoViewerScreen(viewModel: PhotoViewerViewModel) {
    val pagerState = rememberPagerState(initialPage = viewModel.currentIndex) {
        viewModel.filePaths.size
    }
    val context = LocalContext.current
    val activity = context as? PhotoViewerActivity

    // 監聽頁面變化
    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.settledPage }.collect { page ->
            viewModel.onPageChanged(page)
        }
    }

    // 沉浸模式控制系統列
    LaunchedEffect(viewModel.isImmersive) {
        activity?.let {
            val controller = WindowCompat.getInsetsController(it.window, it.window.decorView)
            controller.systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            if (viewModel.isImmersive) {
                controller.hide(WindowInsetsCompat.Type.systemBars())
            } else {
                controller.show(WindowInsetsCompat.Type.systemBars())
            }
        }
    }

    Scaffold(
        containerColor = Color.Black,
        topBar = {
            AnimatedVisibility(
                visible = !viewModel.isImmersive,
                enter = slideInVertically(tween(250)) { -it },
                exit = slideOutVertically(tween(250)) { -it },
            ) {
                TopAppBar(
                    title = {
                        Text(
                            "${viewModel.currentIndex + 1} / ${viewModel.totalCount}",
                            color = Color.White,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                        )
                    },
                    navigationIcon = {
                        IconButton(onClick = { viewModel.dismiss() }) {
                            Icon(
                                Icons.AutoMirrored.Filled.ArrowBack,
                                contentDescription = "Back",
                                tint = Color.White,
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Transparent,
                    ),
                    modifier = Modifier.windowInsetsPadding(WindowInsets.statusBars),
                )
            }
        },
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
        ) {
            // 照片翻頁
            HorizontalPager(
                state = pagerState,
                modifier = Modifier.fillMaxSize(),
            ) { page ->
                ZoomableImage(
                    filePath = viewModel.filePaths[page],
                    onSingleTap = { viewModel.isImmersive = !viewModel.isImmersive },
                )
            }

            // 底部膠囊列
            AnimatedVisibility(
                visible = !viewModel.isImmersive,
                enter = slideInVertically(tween(250)) { it },
                exit = slideOutVertically(tween(250)) { it },
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 32.dp),
            ) {
                CapsuleBottomBar(viewModel = viewModel)
            }
        }
    }

    // 檔案資訊 Bottom Sheet
    if (viewModel.showFileInfo) {
        ModalBottomSheet(
            onDismissRequest = { viewModel.showFileInfo = false },
            sheetState = rememberModalBottomSheetState(),
        ) {
            FileInfoContent(viewModel = viewModel)
        }
    }
}

// endregion
