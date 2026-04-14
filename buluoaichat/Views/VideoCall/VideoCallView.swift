//
//  VideoCallView.swift
//  buluaichat
//
//  视频通话界面 — URLSessionWebSocketTask 信令 + 全屏控制栏

import SwiftUI
import Combine

// MARK: - WebSocket Video Call Manager

final class VideoCallManager: ObservableObject {

    enum CallState: Equatable { case connecting, ringing, connected, ended }

    @Published var state: CallState = .connecting
    @Published var isMuted    = false
    @Published var isCameraOn = true
    @Published var isSpeaker  = true
    @Published var duration   = 0

    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?

    var formattedDuration: String {
        String(format: "%02d:%02d", duration / 60, duration % 60)
    }

    // ── 连接 ─────────────────────────────────────────────────────────
    // 实际部署时把下方注释打开，替换信令服务器地址即可
    func connect(roomId: String) {
        state = .connecting

        // ── 真实 WebSocket 信令（WebRTC 或自定义协议）─────────────
        // let url = URL(string: "wss://signal.yourserver.com/room/\(roomId)")!
        // webSocketTask = URLSession.shared.webSocketTask(with: url)
        // webSocketTask?.resume()
        // receiveSignal()

        // ── 演示模式：模拟连接过程 ─────────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.state = .ringing
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.state = .connected
            self?.startTimer()
        }
    }

    // ── WebRTC 信令接收（offer / answer / ICE candidate）────────────
    private func receiveSignal() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let msg):
                DispatchQueue.main.async {
                    switch msg {
                    case .string(let json): self?.handleSignal(json)
                    case .data(let d):      self?.handleSignal(String(data: d, encoding: .utf8) ?? "")
                    @unknown default: break
                    }
                    self?.receiveSignal()          // 持续监听
                }
            case .failure:
                DispatchQueue.main.async { self?.state = .ended }
            }
        }
    }

    private func handleSignal(_ json: String) {
        // 解析并转发给 WebRTC PeerConnection
        // e.g. { "type":"offer","sdp":"..." } / { "type":"candidate","candidate":"..." }
        print("[VideoCall Signal] \(json)")
    }

    func sendSignal(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let text = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(text)) { _ in }
    }

    // ── 控制 ─────────────────────────────────────────────────────────
    func toggleMute()   { isMuted    = !isMuted    }
    func toggleCamera() { isCameraOn = !isCameraOn }
    func toggleSpeaker(){ isSpeaker  = !isSpeaker  }

    func endCall() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        timer?.invalidate()
        state = .ended
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.duration += 1
        }
    }

    deinit {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        timer?.invalidate()
    }
}

// MARK: - Video Call View

struct VideoCallView: View {
    let conversation: Conversation
    @StateObject private var manager = VideoCallManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // 深色渐变背景
            background

            // 远端视频（模拟占位）
            remoteVideo

            // 本地小窗（右上角）
            VStack {
                HStack {
                    Spacer()
                    localPreview
                        .padding(.top, 72)
                        .padding(.trailing, 20)
                }
                Spacer()
            }

            // 顶部状态栏
            VStack(spacing: 0) {
                topBar
                Spacer()
                controlBar
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear { manager.connect(roomId: conversation.id.uuidString) }
        .onChange(of: manager.state) { _, newState in
            if newState == .ended { dismiss() }
        }
    }

    // MARK: - Background
    private var background: some View {
        LinearGradient(
            colors: [Color(hex: "#0C1829"), Color(hex: "#1A2640"), Color(hex: "#080D18")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Remote Video
    private var remoteVideo: some View {
        VStack(spacing: 20) {
            AvatarView(
                imageName: conversation.displayAvatarName,
                displayName: conversation.displayName,
                size: 110,
                isGroup: conversation.isGroup
            )
            .shadow(color: BlahajTheme.primaryMid.opacity(0.5), radius: 36, x: 0, y: 12)
            .scaleEffect(manager.state == .connected ? 1.0 : 0.88)
            .animation(.spring(response: 0.55, dampingFraction: 0.72), value: manager.state)

            VStack(spacing: 8) {
                Text(conversation.displayName)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                callStatusLabel
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.62))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var callStatusLabel: some View {
        switch manager.state {
        case .connecting: Text("正在连接…")
        case .ringing:
            HStack(spacing: 6) {
                BouncingDot(delay: 0.0)
                BouncingDot(delay: 0.15)
                BouncingDot(delay: 0.30)
                Text("正在呼叫")
            }
        case .connected: Text(manager.formattedDuration)
        case .ended:     Text("通话已结束")
        }
    }

    // MARK: - Local Preview (corner)
    private var localPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#1C2C42"))
                .frame(width: 92, height: 128)

            if manager.isCameraOn {
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.35))
            } else {
                Image(systemName: "video.slash.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.28))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // 最小化 / 返回
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()

            // 连接状态指示
            if manager.state == .connected {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("视频通话中")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.white.opacity(0.1), in: Capsule())
                .transition(.scale.combined(with: .opacity))
            } else if manager.state == .ringing {
                Text("等待接听…")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .transition(.opacity)
            }

            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 22)
        .padding(.top, 52)
        .animation(.spring(response: 0.35), value: manager.state)
    }

    // MARK: - Control Bar
    private var controlBar: some View {
        HStack(spacing: 0) {
            // 静音
            CallCtrlButton(
                icon: manager.isMuted ? "mic.slash.fill" : "mic.fill",
                label: manager.isMuted ? "取消静音" : "静音",
                tint: manager.isMuted ? Color.white.opacity(0.22) : Color.white.opacity(0.1)
            ) { manager.toggleMute() }

            // 摄像头
            CallCtrlButton(
                icon: manager.isCameraOn ? "video.fill" : "video.slash.fill",
                label: manager.isCameraOn ? "摄像头" : "已关闭",
                tint: manager.isCameraOn ? Color.white.opacity(0.1) : Color.white.opacity(0.22)
            ) { manager.toggleCamera() }

            // 挂断（中央，突出）
            Button(action: { manager.endCall() }) {
                VStack(spacing: 7) {
                    ZStack {
                        Circle().fill(Color.red).frame(width: 66, height: 66)
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text("挂断")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .frame(maxWidth: .infinity)

            // 扬声器
            CallCtrlButton(
                icon: manager.isSpeaker ? "speaker.wave.3.fill" : "speaker.slash.fill",
                label: manager.isSpeaker ? "扬声器" : "听筒",
                tint: manager.isSpeaker ? BlahajTheme.primaryMid.opacity(0.35) : Color.white.opacity(0.1)
            ) { manager.toggleSpeaker() }

            // 翻转摄像头
            CallCtrlButton(
                icon: "arrow.triangle.2.circlepath.camera.fill",
                label: "翻转",
                tint: Color.white.opacity(0.1)
            ) { /* 需要 AVCaptureSession 切换摄像头 */ }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        .padding(.horizontal, 14)
        .padding(.bottom, 44)
    }
}

// MARK: - Call Control Button

struct CallCtrlButton: View {
    let icon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    Circle().fill(tint).frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Bouncing Dot (ringing animation)

struct BouncingDot: View {
    let delay: Double
    @State private var up = false

    var body: some View {
        Circle()
            .fill(.white.opacity(0.65))
            .frame(width: 5, height: 5)
            .offset(y: up ? -4 : 0)
            .animation(
                .easeInOut(duration: 0.45).repeatForever().delay(delay),
                value: up
            )
            .onAppear { up = true }
    }
}

#Preview {
    VideoCallView(conversation: Conversation.samples[0])
        .environmentObject(AppState())
}
