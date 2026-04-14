// 应用常量

// 屏幕尺寸常量
export class ScreenConstants {
  static readonly DEVICE_WIDTH = 1220
  static readonly DEVICE_HEIGHT = 580
  static readonly SCREEN_WIDTH = 1196
  static readonly SCREEN_HEIGHT = 556
  static readonly STATUS_BAR_HEIGHT = 40
  static readonly CORNER_RADIUS = 40
}

// 颜色常量
export class ColorConstants {
  // 主题色
  static readonly PRIMARY_COLOR = '#d4af37'
  static readonly SECONDARY_COLOR = '#8b4513'
  
  // 功能色
  static readonly SUCCESS_COLOR = '#52c41a'
  static readonly WARNING_COLOR = '#faad14'
  static readonly ERROR_COLOR = '#f5222d'
  static readonly INFO_COLOR = '#1890ff'
  
  // 背景渐变
  static readonly HOME_GRADIENT = ['#8b4513', '#a0522d', '#cd853f', '#daa520']
  static readonly LEARNING_GRADIENT = ['#a0522d', '#cd853f', '#daa520']
  static readonly PRACTICE_GRADIENT = ['#6a1b9a', '#8e24aa', '#ab47bc']
  static readonly PROFILE_GRADIENT = ['#1565c0', '#1976d2', '#42a5f5']
}

// 动画时长常量
export class AnimationConstants {
  static readonly DURATION_SHORT = 300
  static readonly DURATION_MEDIUM = 500
  static readonly DURATION_LONG = 1000
}

// 路由常量
export class RouterConstants {
  static readonly PAGE_SPLASH = 'pages/SplashPage'
  static readonly PAGE_HOME = 'pages/HomePage'
  static readonly PAGE_EXPLORE = 'pages/ExplorePage'
  static readonly PAGE_ANIMALS = 'pages/categories/AnimalsPage'
  static readonly PAGE_PLANTS = 'pages/categories/PlantsPage'
  static readonly PAGE_NATURE = 'pages/categories/NaturePage'
  static readonly PAGE_BODY = 'pages/categories/BodyPage'
  static readonly PAGE_DAILY = 'pages/categories/DailyPage'
  static readonly PAGE_WATCH = 'pages/WatchPage'
  static readonly PAGE_LISTEN = 'pages/ListenPage'
  static readonly PAGE_QUIZ = 'pages/QuizPage'
  static readonly PAGE_ACHIEVEMENTS = 'pages/AchievementsPage'
  static readonly PAGE_PROFILE = 'pages/ProfilePage'
  static readonly PAGE_VIDEO_PLAYER = 'pages/VideoPlayerPage'
}

