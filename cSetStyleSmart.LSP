(defun c:SetStyleSmart (/ userInp styleName fName baseHeight calcHeight userVal oldEcho)
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (princ "\n--- SETUP: SMART STYLE FIXED (SESUAI GAMBAR REFERENSI) ---")

  ;; 1. INPUT STRING (Contoh: ARIAL8 atau ARIALN1.5)
  (setq userInp (getstring T "\nMasukkan Nama Style (ex: ARIAL8 / ARIALN2): "))
  
  (if (= userInp "")
    (progn (princ "\nError: Input tidak boleh kosong.") (exit))
  )

  (setq styleName (strcase userInp))

  ;; 2. LOGIKA DETEKSI FONT & EKSTRAK ANGKA
  (cond 
    ((wcmatch styleName "ARIALN*")
      (setq fName "Arial Narrow")
      (setq userVal (distof (substr styleName 7))) 
    )
    ((wcmatch styleName "ARIAL*")
      (setq fName "Arial")
      (setq userVal (distof (substr styleName 6)))
    )
    (T 
      (princ "\nFormat salah! Gunakan awalan ARIAL atau ARIALN.")
      (exit)
    )
  )

  (if (null userVal) (setq userVal 1.0))

  ;; 3. PERHITUNGAN TINGGI TEKS (Base 1.4)
  (setq baseHeight 1.4)
  (setq calcHeight (* baseHeight userVal))

  ;; 4. BUAT TEXT STYLE (Fixed Height)
  (command "-STYLE" styleName fName calcHeight "1.0" "0" "N" "N")

  ;; 5. SET VARIABLE DIMENSI (FIXED BERDASARKAN GAMBAR)
  
  ;; --- TAB: LINES ---
  (setvar "DIMCLRD"  8)         ;; Color 8 (Grey)
  (setvar "DIMCLRE"  8)         ;; Color 8 (Grey)
  (setvar "DIMDLE"   0.0)       ;; Extend beyond ticks: 0
  (setvar "DIMDLI"   1.0)       ;; Baseline spacing: 1
  (setvar "DIMEXE"   1.0)       ;; Extend beyond dim lines: 1
  (setvar "DIMEXO"   2.0)       ;; Offset from origin: 2
  
  ;; --- TAB: SYMBOLS AND ARROWS ---
  (setvar "DIMBLK"   ".")       ;; Closed Filled
  (setvar "DIMASZ"   1.8)       ;; Arrow size: 1.8
  (setvar "DIMCEN"   0.0)       ;; Center marks: None (0)
  (setvar "DIMLFAC"  1.0)       ;; Linear factor
  
  ;; --- TAB: TEXT ---
  (setvar "DIMTXSTY" styleName)
  (setvar "DIMTAD"   0)         ;; Vertical: Centered (Sesuai Gambar)
  (setvar "DIMJUST"  0)         ;; Horizontal: Centered
  (setvar "DIMGAP"   1.0)       ;; Offset from dim line: 1
  (setvar "DIMTIH"   0)         ;; Aligned with dimension line (Inside)
  (setvar "DIMTOH"   0)         ;; Aligned with dimension line (Outside)
  
  ;; --- TAB: PRIMARY UNITS ---
  (setvar "DIMLUNIT" 2)         ;; Decimal
  (setvar "DIMDEC"   8)         ;; Precision: 0.00000000
  (command "SETVAR" "DIMDSEP" ",") ;; Decimal Separator: Comma (,)
  (setvar "DIMZIN"   8)         ;; Zero Suppression: Trailing
  (setvar "DIMADEC"  0)         ;; Angular Precision: 0
  
  ;; --- TAB: FIT ---
  (setvar "DIMSCALE" userVal)   ;; Overall Scale (X)
  (setvar "DIMATFIT" 3)         ;; Best fit
  (setvar "DIMTOFL"  1)         ;; Draw dim line between ext lines

  ;; 6. SIMPAN/UPDATE DIMSTYLE
  (if (tblsearch "DIMSTYLE" styleName)
    (command "-DIMSTYLE" "Save" styleName "Y")
    (command "-DIMSTYLE" "Save" styleName)
  )
  (command "-DIMSTYLE" "Restore" styleName)

  (setvar "CMDECHO" oldEcho)
  (princ (strcat "\n[FIXED] Style '" styleName "' Berhasil Diterapkan."))
  (princ)
)