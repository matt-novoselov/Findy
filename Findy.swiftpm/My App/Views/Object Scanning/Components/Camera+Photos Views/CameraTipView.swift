                Group{
                    if !isOnboardingActive{
                        TipView(tip, arrowEdge: .trailing)
                            .tipImageStyle(Color.secondary)
                            .ignoresSafeArea()
                            .frame(width: 400)
                            .padding(.trailing, 90)
                            .transition(.blurReplace)
                    }
                }
                .animation(.spring, value: isOnboardingActive)