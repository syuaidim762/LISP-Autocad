(defun c:LF (/ old_fillet old_layer last_ent)
  (setvar "CMDECHO" 0)
  
  ;; 1. Setup Layer 'CABLE' dengan Color 2 (Yellow)
  (if (not (tblsearch "LAYER" "CABLE"))
    (command "-layer" "M" "CABLE" "C" "2" "" "")
    (command "-layer" "S" "CABLE" "")
  )

  ;; 2. Simpan setting lama
  (setq old_fillet (getvar "FILLETRAD"))
  
  ;; 3. Set radius ke 1
  (setvar "FILLETRAD" 1.0)
  
  (princ "\n--- Mode Gambar CABLE (Output: LINE & ARC) ---")
  (princ "\nKlik titik-titik jalur kabel Anda...")
  
  ;; 4. Jalankan perintah PLINE sebagai alat bantu
  (command "_pline")
  (while (= (getvar "CMDACTIVE") 1)
    (command pause)
  )

  ;; 5. Terapkan Fillet ke seluruh sudut Polyline
  (setq last_ent (entlast))
  (command "_fillet" "_P" last_ent)
  
  ;; 6. PECAHKAN (EXPLODE) agar menjadi LINE dan ARC terpisah
  (command "_explode" last_ent)
  
  ;; 7. Kembalikan setting radius
  (setvar "FILLETRAD" old_fillet)
  
  (princ "\nSelesai. Objek telah dipecah menjadi LINE dan ARC terpisah.")
  (princ)
)