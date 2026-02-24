(defun c:BikinLayer ()
  (setq old_cmdecho (getvar "cmdecho"))
  (setvar "cmdecho" 0) ; Mematikan echo command agar lebih cepat dan bersih

  (prompt "\nSedang membuat layer sesuai gambar...")

  ; Memulai perintah -LAYER
  (command "_.-LAYER"
    
    ; 1. Layer CABLE (Kuning)
    "_New" "CABLE" 
    "_Color" "2" "CABLE"
    
    ; 2. Layer EQPT_BRACKET (Cyan - Asumsi nama lengkap)
    "_New" "EQPT_BRACKET" 
    "_Color" "4" "EQPT_BRACKET"

    ; 3. Layer DIM (Putih)
    "_New" "DIM" 
    "_Color" "7" "DIM"

    ; 4. Layer EQPT (Magenta)
    "_New" "EQPT" 
    "_Color" "6" "EQPT"

    ; 5. Layer EQPT_X1 (Merah)
    "_New" "EQPT_X1" 
    "_Color" "1" "EQPT_X1"

    ; 6. Layer EQPT_X2 (Merah)
    "_New" "EQPT_X2" 
    "_Color" "1" "EQPT_X2"

    ; 7. Layer TEXT (Putih)
    "_New" "TEXT" 
    "_Color" "7" "TEXT"

    ; 8. Layer VP (Warna 250 & NO PLOT)
    "_New" "VP" 
    "_Color" "250" "VP"
    "_Plot" "_No" "VP"

    "" ; Akhiri perintah layer
  )

  (setvar "cmdecho" old_cmdecho)
  (princ "\nSelesai! Semua layer sudah dibuat.")
  (princ)
)