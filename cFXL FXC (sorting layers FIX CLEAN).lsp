;; ==========================================================
;; 1. PERINTAH FXL (SORTING LAYERS) - SUPPORT UNDO
;; ==========================================================
(defun c:FXL (/ ss i ent objData objType oldEcho userSel)
  (setq oldEcho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; Memulai grup transaksi agar bisa di-undo sekaligus
  (command "_.UNDO" "_Begin")

  (princ "\n--- [FXL] SORTING LAYERS ---")

  ;; BUAT/UPDATE LAYER
  (defun CreateLyr (n c)
    (if (not (tblsearch "LAYER" n))
      (command "-LAYER" "M" n "C" c "" "")
      (command "-LAYER" "C" c n "")
    )
  )
  
  (CreateLyr "TEXT" "7")
  (CreateLyr "DIM" "7")
  (CreateLyr "EQPT" "6")
  ;; Khusus VP (No Plot)
  (if (not (tblsearch "LAYER" "VP"))
    (command "-LAYER" "M" "VP" "C" "250" "VP" "P" "N" "VP" "" "")
    (command "-LAYER" "C" "250" "VP" "P" "N" "VP" "")
  )

  ;; SELEKSI
  (princ "\nPilih objek (ENTER untuk ALL): ")
  (setq userSel (ssget))
  (if (null userSel) (setq ss (ssget "_X")) (setq ss userSel))

  ;; PROSES
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq objData (entget ent))
        (setq objType (cdr (assoc 0 objData)))

        (defun SimpleMove (eData lName)
          ;; Ganti Layer
          (setq eData (subst (cons 8 lName) (assoc 8 eData) eData))
          ;; Paksa Warna ke ByLayer (62 . 256)
          (if (assoc 62 eData)
            (setq eData (subst (cons 62 256) (assoc 62 eData) eData))
            (setq eData (append eData (list (cons 62 256))))
          )
          (entmod eData)
        )

        (cond
          ((member objType '("TEXT" "MTEXT" "LEADER" "MULTILEADER")) (SimpleMove objData "TEXT"))
          ((= objType "DIMENSION") (SimpleMove objData "DIM"))
          ((= objType "VIEWPORT") (if (> (cdr (assoc 69 objData)) 1) (SimpleMove objData "VP")))
          ((member objType '("LINE" "LWPOLYLINE" "POLYLINE" "HATCH" "CIRCLE" "ARC" "ELLIPSE" "SPLINE" "SOLID" "3DFACE")) 
           (SimpleMove objData "EQPT"))
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nSelesai: " (itoa i) " objek diproses."))
    )
  )

  (command "_.UNDO" "_End")
  (setvar "CMDECHO" oldEcho)
  (princ "\n[FXL DONE] Gunakan UNDO jika ingin membatalkan.")
  (princ)
)

;; ==========================================================
;; 2. PERINTAH FXC (CLEANING DATABASE) - AUDIT & PURGE
;; ==========================================================
(defun c:FXC ()
  (setvar "CMDECHO" 0)
  (princ "\n--- [FXC] CLEANING DATABASE (Audit & Purge) ---")
  
  (princ "\nSedang Audit...")
  (command "_.AUDIT" "Y")
  
  (princ "\nSedang Purge All...")
  (command "_.PURGE" "A" "*" "N")
  
  (princ "\n[FXC DONE] File sudah bersih!")
  (princ)
)