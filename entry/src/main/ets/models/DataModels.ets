// 视频信息接口
export interface VideoInfo {
  id: string
  title: string
  subtitle: string
  emoji: string
  duration: string
  status?: 'locked' | 'learning' | 'completed'
  category?: string
  videoUrl?: string
}

// 课程信息接口（用于category pages）
export interface CourseInfo {
  id: string
  title: string
  subtitle: string
  emoji: string
  duration: string
  status: string
  category: string
  videoUrl: string
}

// 分类数据接口
export interface CategoryData {
  id: string
  name: string
  icon: string
  color?: string
  description?: string
  courseCount?: number
  gradient?: string[]
}

// 其他数据模型可以在这里添加














