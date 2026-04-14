import router from '@ohos.router'

@Entry
@Component
struct AchievementsPage {
  @Builder BackButton() {
    Stack() {
      Column()
        .width(64)
        .height(64)
        .borderRadius(32)
        .linearGradient({
          angle: 135,
          colors: [['#fbbf24', 0], ['#f59e0b', 1]]
        })
        .shadow({ radius: 30, color: 'rgba(0,0,0,0.4)', offsetY: 2 })

      Text('←')
        .fontSize(38)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .position({ x: 32, y: 20 })
    .onClick(() => {
      router.back()
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#f57f17', 0], ['#ffa726', 0.5], ['#ffb74d', 1]]
        })

      Scroll() {
        Column() {
          this.BackButton()

          Column({ space: 8 }) {
            Text('🏆 成就中心')
              .fontSize(36)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            Text('查看你的学习成就')
              .fontSize(18)
              .fontColor('rgba(255,255,255,0.8)')
          }
          .margin({ top: 96, bottom: 32 })

          Column() {
            Row({ space: 16 }) {
              Text('🏅')
                .fontSize(80)

              Column({ space: 8 }) {
                Text('汉字小达人')
                  .fontSize(28)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)

                Text('继续努力，成为汉字大师！')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.8)')

                Row({ space: 8 }) {
                  Progress({ value: 60, total: 100 })
                    .width('70%')
                    .height(8)
                    .color('#FBBF24')
                    .backgroundColor('rgba(255,255,255,0.3)')
                  Text('60%')
                    .fontSize(14)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .margin({ bottom: 24 })

            GridRow({ columns: 3, gutter: 16 }) {
              GridCol() {
                Column({ space: 4 }) {
                  Text('12')
                    .fontSize(24)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                  Text('已获得')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.7)')
                }
              }
              GridCol() {
                Column({ space: 4 }) {
                  Text('8')
                    .fontSize(24)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                  Text('进行中')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.7)')
                }
              }
              GridCol() {
                Column({ space: 4 }) {
                  Text('20')
                    .fontSize(24)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                  Text('总数')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.7)')
                }
              }
            }
            .width('100%')
          }
          .width('90%')
          .margin({ left: '5%', bottom: 32 })
          .padding(24)
          .borderRadius(24)
          .linearGradient({
            angle: 135,
            colors: [['rgba(255,255,255,0.3)', 0], ['rgba(255,255,255,0.2)', 1]]
          })
          .backdropBlur(10)
          .border({ width: 1, color: 'rgba(255,255,255,0.4)' })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}





















