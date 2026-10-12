# win11-cloud — Windows 11 tiny11 core 25H2 trên GitHub Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ALo3217881242/win11-cloud)

Chạy **tiny11 core 25H2** (bản Windows 11 nhẹ nhất, mới nhất của NTDEV – 11/2025) trong GitHub Codespaces,
điều khiển qua **Remote Desktop ngay trên trình duyệt**. Không cần cài gì lên máy của bạn.

| Thành phần | Cấu hình |
|---|---|
| Máy Codespaces | 4 nhân · 16 GB RAM · 32 GB ổ đĩa |
| Windows | tiny11 core 25H2 (ISO 3,1 GB) · 4 nhân · 10 GB RAM · ổ đĩa = toàn bộ dung lượng trống |
| Tài khoản | `Admin` + mật khẩu bạn đặt qua secret `WIN_PASSWORD` (tự tạo khi cài) |
| Điều khiển | RDP qua Apache Guacamole 1.6 (cổng 8080), đã tắt hiệu ứng, bật 60 FPS |
| Xem lúc cài | noVNC (cổng 8006) |

## Cách dùng

1. **(Nên làm, chỉ 1 lần)** Vào [Settings → Codespaces](https://github.com/settings/codespaces):
   - **Region**: chọn `Southeast Asia` (gần Việt Nam nhất → độ trễ thấp nhất).
   - **Default idle timeout**: đặt `240` phút (mặc định 30 phút không thao tác là codespace tự tắt).
2. Bấm nút **Open in GitHub Codespaces** ở trên (hoặc **Code → Codespaces → … → New with options**).
   - **Machine type**: `4-core`.
   - Ô **WIN_PASSWORD** (mục *Recommended secrets*): nhập mật khẩu Windows bạn muốn → **Create codespace**.
3. Đợi codespace mở. Mở tab **PORTS** → cổng **8006** (*Màn hình cài đặt*) → biểu tượng quả địa cầu để xem tiến trình.
   Lần đầu sẽ tự tải ISO (~3,1 GB) và tự cài, mất khoảng 15–25 phút.
4. Khi thấy màn hình desktop Windows → mở cổng **8080** (*Remote Desktop*) → đăng nhập `Admin` + mật khẩu → vào thẳng Windows.

Mẹo trong Remote Desktop:

- `Ctrl + Alt + Shift`: mở menu Guacamole (clipboard, bàn phím ảo, tải file lên/xuống qua ổ **ChuyenFile**).
- `F11`: toàn màn hình. Cửa sổ trình duyệt đổi kích thước thì Windows tự đổi độ phân giải theo.

## Lệnh trong Terminal của codespace

```bash
bash start.sh          # bật lại (tự chạy mỗi lần codespace khởi động)
bash start.sh status   # trạng thái + đường link
bash start.sh logs     # xem log cài đặt Windows
bash start.sh stop     # tắt Windows an toàn
```

Nếu tạo codespace mà quên nhập `WIN_PASSWORD`: mở Terminal, chạy `bash start.sh`, nhập mật khẩu khi được hỏi.

## Lưu ý

- **Mật khẩu không nằm trong repo** (repo công khai). Mật khẩu chỉ được đặt lúc *cài lần đầu*; đổi secret sau đó sẽ không đổi mật khẩu Windows.
- Ổ Windows nằm trong thư mục `storage/` của codespace: **Stop** codespace thì vẫn giữ, **Delete** codespace là mất.
- Hạn mức miễn phí (tài khoản Free): 120 giờ-nhân/tháng → máy 4 nhân ≈ **30 giờ/tháng**, và 15 GB-tháng lưu trữ. Nhớ **Stop** codespace khi không dùng.
- Điều khoản GitHub chỉ cho dùng Codespaces cho việc phát triển/kiểm thử phần mềm; dùng làm máy tính cá nhân lâu dài có thể bị GitHub giới hạn Codespaces.
- tiny11 core đã bị gỡ Windows Update, Defender, WinRE và không cài thêm tính năng Windows được. Muốn bản tiny11 thường (cập nhật được), sửa dòng `VERSION` trong `docker-compose.yml` thành
  `https://archive.org/download/tiny11_25H2/tiny11_25H2_Nov25.iso` rồi xóa thư mục `storage/` và chạy lại `bash start.sh`.
- Nếu bản Nov25 không tự cài được, đổi `VERSION` thành `core11` (bản tiny11 core 25H2 Oct25 được dockur kiểm thử sẵn).

Dựa trên [dockur/windows](https://github.com/dockur/windows) và [Apache Guacamole](https://guacamole.apache.org/).
