(defun c:K (/ n g ent i dist ss p1dist p2dist)
  (vl-load-com)
  (setvar "CMDECHO" 0)

  ;; 1. Setup Layer CABLE (Kuning)
  (command "-layer" "M" "CABLE" "C" "2" "" "")

  ;; 2. Input Jalur & Jarak (Bisa Ketik atau Klik)
  (setq n (getint "\nJumlah jalur: "))
  (setq g (getdist "\nMasukkan jarak atau klik 2 titik untuk gap: "))

  ;; 3. Gambar Jalur Utama
  (princ "\nKlik titik-titik jalur. Tekan ENTER jika selesai.")
  (command "_.PLINE")
  (while (= (getvar "CMDACTIVE") 1) (command pause))
  
  (setq ent (entlast)
        ss (ssadd))

  ;; 4. Proses Offset & Explode agar jadi LINE yang tersambung
  (if (and ent (= (cdr (assoc 0 (entget ent))) "LWPOLYLINE"))
    (progn
      (setq i 0)
      (repeat n
        (setq dist (- (* i g) (/ (* (1- n) g) 2.0)))
        (if (not (equal dist 0.0 1e-6))
          (vla-offset (vlax-ename->vla-object ent) dist)
        )
        (ssadd (entlast) ss)
        (setq i (1+ i))
      )
      (command "_.EXPLODE" ss "")
      (if (= (rem n 2) 0) (entdel ent))
    )
  )
  (setvar "CMDECHO" 1)
  (princ (strcat "\nSelesai dengan gap: " (rtos g 2 2)))
  (princ)
)