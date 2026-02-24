(defun c:VSET (/ scale sname ss i en ed factor)
  (setvar "CMDECHO" 0)

  ;; 1. Input Angka Skala (Contoh: 25 atau 1.25)
  (setq scale (getreal "\nMasukkan angka skala (Contoh 25 atau 1.25): "))
  
  (if (and scale (> scale 0))
    (progn
      (setq sname (strcat "1:" (rtos scale 2 2)))
      (setq factor (/ 1.0 scale))

      ;; 2. Daftarkan Nama Skala ke System (SCALELIST)
      ;; Menggunakan command -SCALELISTEDIT untuk menambah nama 1:XX
      (command "_.-scalerules" "_add" sname (rtos scale 2 8) "_exit")
      ;; Jika command di atas tidak jalan di versi Anda, gunakan ini:
      (command "_.-scalelistedit" "_add" sname (strcat "1:" (rtos scale 2 8)) "_exit")

      (princ (strcat "\nNama Skala diatur ke: " sname ". Pilih Viewport..."))
      
      ;; 3. Pilih Viewport
      (setq ss (ssget '((0 . "VIEWPORT"))))
      
      (if ss
        (progn
          (vl-load-com)
          (setq i 0)
          (repeat (sslength ss)
            (setq en (ssname ss i))
            (setq obj (vlax-ename->vla-object en))
            
            ;; Buka kunci, terapkan skala, lalu kunci lagi
            (vl-catch-all-apply 'vla-put-displaylocked (list obj :vlax-false))
            (vl-catch-all-apply 'vla-put-customscale (list obj factor))
            (vl-catch-all-apply 'vla-put-displaylocked (list obj :vlax-true))
            
            (setq i (1+ i))
          )
          (princ (strcat "\nBERHASIL: " (itoa i) " Viewport sekarang bernama " sname))
        )
      )
    )
  )
  (setvar "CMDECHO" 1)
  (princ)
)