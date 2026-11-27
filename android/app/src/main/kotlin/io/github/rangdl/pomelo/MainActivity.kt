package io.github.rangdl.pomelo

import com.ryanheise.audioservice.AudioServiceActivity

// 继承 AudioServiceActivity：audio_service 需要在 Activity 里挂载前台 Service
// 的绑定，才能把媒体控制下沉到后台 / 锁屏。
class MainActivity : AudioServiceActivity()
