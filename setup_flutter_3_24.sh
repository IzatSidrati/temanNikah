#!/bin/bash
set -e

echo "========================================================"
echo "  Instalasi Flutter 3.24.5 untuk macOS 13 (Intel x64)   "
echo "========================================================"
echo ""

TARGET_DIR="$HOME/development"
FLUTTER_ZIP="flutter_macos_3.24.5-stable.zip"
DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/$FLUTTER_ZIP"

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

if [ -d "$TARGET_DIR/flutter" ]; then
  echo "⚠️ Folder $TARGET_DIR/flutter sudah ada. Memeriksa versi..."
  "$TARGET_DIR/flutter/bin/flutter" --version || {
    echo "Menghapus versi lama yang bermasalah..."
    rm -rf "$TARGET_DIR/flutter"
  }
fi

if [ ! -d "$TARGET_DIR/flutter" ]; then
  echo "📥 Mengunduh Flutter 3.24.5 (~1.2 GB, mohon tunggu sebentar)..."
  curl -C - -# -O "$DOWNLOAD_URL"

  echo "📦 Mengekstrak berkas Flutter..."
  unzip -q "$FLUTTER_ZIP"
  
  echo "🧹 Menghapus file zip sementara..."
  rm -f "$FLUTTER_ZIP"
fi

echo "⚙️ Menambahkan PATH Flutter ke shell..."
ZSHRC="$HOME/.zshrc"
PATH_LINE='export PATH="$HOME/development/flutter/bin:$PATH"'

if [ -f "$ZSHRC" ]; then
  if ! grep -q "development/flutter/bin" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "$PATH_LINE" >> "$ZSHRC"
    echo "✅ Ditambahkan ke ~/.zshrc"
  else
    echo "ℹ️ PATH sudah terdaftar di ~/.zshrc"
  fi
else
  echo "$PATH_LINE" > "$ZSHRC"
  echo "✅ Dibuat ~/.zshrc baru"
fi

export PATH="$HOME/development/flutter/bin:$PATH"

echo ""
echo "🎉 Verifikasi instalasi Flutter:"
flutter --version

echo ""
echo "========================================================"
echo "  Instalasi Selesai!                                    "
echo "  Untuk menjalankan aplikasi nikah_plan:                "
echo "    cd /Users/izatsidrati/projectapp                    "
echo "    flutter pub get                                     "
echo "    flutter run -d chrome                               "
echo "========================================================"
