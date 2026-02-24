(defun c:FixLayersSelect (/ ss i ent objData objType oldEcho userSel)
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (princ "\n--- SORTING OBJECTS TO LAYERS (KEEP ORIGINAL COLORS) ---")

  ;; 1. PASTIKAN LAYER STANDAR SUDAH ADA (DIM, TEXT, VP, EQPT)
  (if (not (tblsearch "LAYER" "TEXT")) (command "-LAYER" "M" "TEXT" "C" "2" "" ""))
  (if (not (tblsearch "LAYER" "DIM")) (command "-LAYER" "M" "DIM" "C" "3" "" ""))
  (if (not (tblsearch "LAYER" "VP")) (command "-LAYER" "M" "VP" "C" "4" "" "P" "N" "" ""))
  (if (not (tblsearch "LAYER" "EQPT")) (command "-LAYER" "M" "EQPT" "C" "7" "" ""))

  ;; 2. OPSI PILIH OBJEK
  (princ "\nPilih objek yang ingin dirapikan [Tekan ENTER untuk pilih semua]: ")
  (setq userSel (ssget))

  ;; Jika user tidak memilih apa-apa (tekan Enter), ambil semua objek (X)
  (if (null userSel)
    (progn
      (princ "\nMode: Memproses seluruh gambar...")
      (setq ss (ssget "_X"))
    )
    (setq ss userSel)
  )

  ;; 3. PROSES PEMINDAHAN LAYER
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq objData (entget ent))
        (setq objType (cdr (assoc 0 objData)))

        ;; Fungsi internal untuk ganti layer saja tanpa sentuh data warna/linetype
        (defun SimpleMove (eData lName)
          (setq eData (subst (cons 8 lName) (assoc 8 eData) eData))
          (entmod eData)
        )

        (cond
          ;; A. TEXT & LEADER
          ((member objType '("TEXT" "MTEXT" "LEADER" "MULTILEADER"))
           (SimpleMove objData "TEXT"))

          ;; B. DIMENSION
          ((= objType "DIMENSION")
           (SimpleMove objData "DIM"))

          ;; C. VIEWPORT
          ((= objType "VIEWPORT")
           (SimpleMove objData "VP"))

          ;; D. DRAWING OBJECTS (EQPT)
          ((member objType '("LINE" "LWPOLYLINE" "POLYLINE" "HATCH" "CIRCLE" "ARC" "ELLIPSE" "SPLINE" "SOLID" "3DFACE"))
           (SimpleMove objData "EQPT"))
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nSukses! " (itoa i) " objek telah dipindahkan ke layer masing-masing tanpa mengubah warna."))
    )
    (princ "\nTidak ada objek yang dipilih.")
  )

  (setvar "CMDECHO" oldEcho)
  (princ)
)