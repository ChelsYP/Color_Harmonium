#!/bin/bash

DATA_FILE="koleksi.json"
WARNA_FILE="warna.json"

[ ! -f "$DATA_FILE" ] && echo "[]" > "$DATA_FILE"

if [ ! -f "$WARNA_FILE" ]; then
  echo '[ "golden yellow", "sunflower yellow", "pale yellow", "lemon yellow", "pumpkin orange", "burnt orange", "vermilion", "tomato red", "burgundy", "rosewood", "deep burgundy", "berry red", "grass green", "lime green", "light sea green", "emerlad green", "sea green", "forest green", "leaf green", "dark green", "teal", "cobalt blue", "royal blue", "baby blue", "space blue", "denim", "navy blue", "midnight blue", "perwinkle blue", "ultra violet", "violet", "magenta", "plum purple", "lilac", "dark pink", "pink pastel", "blush pink", "pink", "coral pink", "baby pink", "dark brown", "warm taupe", "warm brown", "beige", "dark grey", "light grey", "black", "white" ]' > "$WARNA_FILE"
fi

declare -A grup=(
  [🟡 Yellow]="golden yellow|sunflower yellow|pale yellow|lemon yellow"
  [🟠 Orange]="pumpkin orange|burnt orange|vermilion"
  [🔴 Red]="tomato red|burgundy|rosewood|deep burgundy|berry red"
  [🟢 Green]="grass green|lime green|light sea green|emerlad green|sea green|forest green|leaf green|dark green"
  [🔵 Blue]="teal|cobalt blue|royal blue|baby blue|space blue|denim|navy blue|midnight blue|perwinkle blue"
  [🟣 Purple]="ultra violet|violet|magenta|plum purple|lilac"
  [🌸 Pink]="dark pink|pink pastel|blush pink|pink|coral pink|baby pink"
  [🟤 Brown]="dark brown|warm taupe|warm brown|beige"
  [⚫ Gray/Black]="dark grey|light grey|black|white"
)

pilih_warna_dari_dataset() {
  while true; do
    tema=$(zenity --list --title="🌈 Pilih Grup Warna" --column="Tema Warna" "${!grup[@]}")
    [ -z "$tema" ] && return 1

    mapfile -t daftar < <(jq -r ".[] | select(test(\"${grup[$tema]}\"; \"i\"))" "$WARNA_FILE")
    warna=$(zenity --list --title="🎨 Pilih Warna dari Grup $tema" --column="Warna" "${daftar[@]}")
    if [ -z "$warna" ]; then
      continue  # kembali ke tema warna
    fi
    echo "$warna"
    return 0
  done
}

submenu_tambah_koleksi() {
  while true; do
    jenis=$(zenity --list --title="👕 Pilih Jenis Pakaian" --column="Jenis" Atasan Bawahan)
    [ -z "$jenis" ] && break

    nama=$(zenity --entry --title="📝 Nama Pakaian" --text="Masukkan nama pakaian:")
    [ -z "$nama" ] && continue

    while true; do
      warna=$(pilih_warna_dari_dataset)
      [ $? -ne 0 ] && continue  # kembali ke input warna

      if [ -n "$warna" ]; then
        jq ". += [{\"jenis\": \"$jenis\", \"nama\": \"$nama\", \"warna\": \"$warna\"}]" "$DATA_FILE" > tmp && mv tmp "$DATA_FILE"
        zenity --info --text="✅ Koleksi berhasil ditambahkan!"
        break
      fi
    done
  done
}

submenu_rekomendasi() {
  while true; do
    if [ "$(jq length "$DATA_FILE")" -eq 0 ]; then
      zenity --info --text="❌ Belum ada koleksi untuk direkomendasikan."
      break
    fi

    tema=$(zenity --list --title="🌤 Pilih Tema Musim" --column="Tema" AUTUMN SPRING SUMMER WINTER)
    [ -z "$tema" ] && break

    case $tema in
      AUTUMN) pattern="grass green|forest green|dark green|pumpkin orange|burnt orange|warm taupe|dark brown|golden yellow|vermilion|burgundy";;
      SPRING) pattern="lime green|leaf green|royal blue|navy blue|lilac|violet|beige|warm brown|pink pastel|dark pink|sunflower yellow|tomato red";;
      SUMMER) pattern="coral pink|pink|baby blue|denim|perwinkle blue|light sea green|sea green|blush pink|rosewood|light grey|pale yellow|baby pink";;
      WINTER) pattern="lemon yellow|white|magenta|baby pink|berry red|deep burgundy|dark grey|black|cobalt blue|space blue|plum purple|emerlad green";;
      *) continue ;;
    esac

    jq -r --arg pattern "$pattern" '
      [ .[] | select(.warna | test($pattern; "i")) ] as $filtered |
      $filtered | map(select(.jenis == "Atasan")) as $atasan |
      $filtered | map(select(.jenis == "Bawahan")) as $bawahan |
      $atasan[] as $a |
      $bawahan[] as $b |
      "\($a.warna) (\($a.nama))  +  \($b.warna) (\($b.nama))"
    ' "$DATA_FILE" > /tmp/rekom.txt

    if [ -s /tmp/rekom.txt ]; then
      zenity --text-info --title="🎯 Rekomendasi untuk $tema" --filename=/tmp/rekom.txt --width=400 --height=400
    else
      zenity --info --text="Tidak ada koleksi yang cocok dengan tema $tema."
    fi
  done
}

submenu_hapus_koleksi() {
  while true; do
    mapfile -t list < <(jq -r '.[] | .nama' "$DATA_FILE")
    [ ${#list[@]} -eq 0 ] && zenity --info --text="📭 Tidak ada koleksi untuk dihapus." && break

    selected=$(zenity --list --title="🗑 Hapus Koleksi" --column="Nama Pakaian" "${list[@]}")
    [ -z "$selected" ] && break

    jq "del(.[] | select(.nama == \"$selected\"))" "$DATA_FILE" > tmp && mv tmp "$DATA_FILE"
    zenity --info --text="🧹 Koleksi berhasil dihapus."
  done
}

tampilkan_koleksi() {
  if [ "$(jq length "$DATA_FILE")" -eq 0 ]; then
    zenity --info --text="Belum ada koleksi."
    return
  fi
  {
    echo "👚 Atasan:"
    jq -r 'map(select(.jenis == "Atasan")) | to_entries[] | "  \(.key+1). \(.value.nama) (\(.value.warna))"' "$DATA_FILE"
    echo ""
    echo "👖 Bawahan:"
    jq -r 'map(select(.jenis == "Bawahan")) | to_entries[] | "  \(.key+1). \(.value.nama) (\(.value.warna))"' "$DATA_FILE"
  } > /tmp/list.txt

  zenity --text-info --title="🧵 Koleksi Pakaian" --filename="/tmp/list.txt" --width=400 --height=400
}

# Menu Utama
while true; do
  pilihan=$(zenity --list --title="🎨 Color Harmonium" --text="📋 Pilih menu utama:" --column="Menu" \
    "👕 Tambah Koleksi" "🧾 Tampilkan Koleksi" "🎯 Rekomendasi Warna" "🗑 Hapus Koleksi" "🚪 Keluar")

  case $pilihan in
    "👕 Tambah Koleksi") submenu_tambah_koleksi ;;
    "🧾 Tampilkan Koleksi") tampilkan_koleksi ;;
    "🎯 Rekomendasi Warna") submenu_rekomendasi ;;
    "🗑 Hapus Koleksi") submenu_hapus_koleksi ;;
    "🚪 Keluar") exit ;;
    *) break ;;
  esac
done