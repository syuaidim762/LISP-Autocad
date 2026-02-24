(defun C:JX (/ ssTarget ssCutter i j entT entC p1 p2 p3 p4 pInt brkLen userGap ang pGap1 pGap2)
  (vl-load-com)
  (setvar "CMDECHO" 0)

  ;; 1. Input Jarak Gap
  (if (not GLOBAL_BRK) (setq GLOBAL_BRK 1.0))
  (setq userGap (getstring (strcat "\nMasukkan jarak celah (Gap) <" (rtos GLOBAL_BRK 2 2) ">: ")))
  (if (/= userGap "") (setq GLOBAL_BRK (atof userGap)))
  (setq brkLen GLOBAL_BRK)

  ;; 2. Pilih Objek
  (prompt "\nPilih garis yang akan DIPUTUS (Target): ")
  (setq ssTarget (ssget '((0 . "LINE,LWPOLYLINE"))))
  
  (prompt "\nPilih garis PEMOTONG: ")
  (setq ssCutter (ssget '((0 . "LINE,LWPOLYLINE"))))

  (if (and ssTarget ssCutter)
    (progn
      (setq i 0)
      (while (< i (sslength ssTarget))
        (setq entT (ssname ssTarget i))
        (setq p1 (vlax-curve-getStartPoint entT))
        (setq p2 (vlax-curve-getEndPoint entT))
        
        (setq j 0)
        (while (< j (sslength ssCutter))
          (setq entC (ssname ssCutter j))
          (setq p3 (vlax-curve-getStartPoint entC))
          (setq p4 (vlax-curve-getEndPoint entC))
          
          ;; Menggunakan inters (2D check) untuk stabilitas maksimal
          (setq pInt (inters p1 p2 p3 p4 T))

          (if pInt
            (progn
              ;; Dapatkan arah garis target di titik potong
              (setq ang (angle p1 p2))
              (setq pGap1 (polar pInt ang brkLen))
              (setq pGap2 (polar pInt ang (* brkLen -1)))
              
              ;; Eksekusi Break
              (if (> brkLen 0)
                (command "_.break" (list entT pInt) "_F" "_none" pGap1 "_none" pGap2)
                (command "_.break" (list entT pInt) "@")
              )
            )
          )
          (setq j (1+ j))
        )
        (setq i (1+ i))
      )
      (princ "\nProses JX selesai.")
    )
    (princ "\nSeleksi tidak lengkap.")
  )
  (setvar "CMDECHO" 1)
  (princ)
)