(defun c:wip ( / sel inc ent enx objLayer typ wip )
    (vl-load-com)
    (princ "\n=== SUPER WIPEOUT (CIRCLE & POLYLINE ARC SUPPORT) ===")
    
    (cond
        (   (not
                (or (member "acwipeout.arx" (arx)) (arxload "acwipeout.arx" nil)
                    (member "acismui.arx"   (arx)) (arxload "acismui.arx"   nil)
                )
            )
            (princ "\nError: Wipeout ARX tidak termuat.")
        )
        (   (setq sel (ssget "_:L" '((0 . "CIRCLE,LWPOLYLINE,POLYLINE"))))
            (repeat (setq inc (sslength sel))
                (setq ent (ssname sel (setq inc (1- inc)))
                      enx (entget ent)
                      typ (cdr (assoc 0 enx))
                      objLayer (cdr (assoc 8 enx))
                )
                
                (cond 
                    ;; JIKA LINGKARAN
                    ((= typ "CIRCLE")
                        (setq wip (LM:CircularWipeout (trans (cdr (assoc 10 enx)) ent 1) (cdr (assoc 40 enx))))
                    )
                    ;; JIKA POLYLINE (Lurus maupun Lengkung)
                    ((member typ '("LWPOLYLINE" "POLYLINE"))
                        (setq wip (LM:PlineArcToWipeout ent))
                    )
                )
                
                (if wip
                    (progn
                        (setq wipData (entget wip))
                        ;; Pindah ke Layer asli & Set Color 250
                        (setq wipData (subst (cons 8 objLayer) (assoc 8 wipData) wipData))
                        (if (assoc 62 wipData)
                            (setq wipData (subst (cons 62 250) (assoc 62 wipData) wipData))
                            (setq wipData (append wipData (list (cons 62 250))))
                        )
                        (entmod wipData)
                        (entupd wip)
                        ;; Kirim ke belakang agar objek asli terlihat
                        (command "_.draworder" wip "" "_b")
                    )
                )
            )
            (princ (strcat "\nSelesai: " (itoa (sslength sel)) " objek berhasil diproses."))
        )
    )
    (princ)
)

;; Fungsi Konversi Polyline (Manual Tessellation) - Meniru CLIPIT
(defun LM:PlineArcToWipeout ( ent / dist inc lst maxd obj p1 )
    (setq obj (vlax-ename->vla-object ent)
          dist 0.0
          maxd (vlax-curve-getdistatparam obj (vlax-curve-getendparam obj))
          ;; Semakin kecil angka 0.1, semakin halus lengkungannya
          inc (/ maxd 100.0) 
    )
    (repeat 101
        (setq p1 (vlax-curve-getpointatdist obj dist))
        (setq lst (cons p1 lst))
        (setq dist (min (+ dist inc) maxd))
    )
    ;; Buat Polyline tumbal tanpa Arc
    (setq ent (entmakex
                (append
                    (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") '(100 . "AcDbPolyline")
                          (cons 90 (length lst)) (cons 70 1))
                    (mapcar '(lambda ( p ) (cons 10 (trans p 0 1))) lst)
                )
              ))
    ;; Ubah tumbal jadi wipeout
    (command "_.wipeout" "_polyline" ent "_yes")
    (entlast)
)

;; Fungsi Circular Wipeout (Lee Mac)
(defun LM:CircularWipeout ( cen rad / ang inc lst acc )
    (setq acc 50 inc (/ pi acc 0.5) ang 0.0)
    (repeat acc
        (setq lst (cons (list 14 (* 0.5 (cos ang)) (* 0.5 (sin ang))) lst)
              ang (+ ang inc)
        )
    )
    (entmakex
        (append
            (list '(0 . "WIPEOUT") '(100 . "AcDbEntity") '(100 . "AcDbWipeout")
                (cons 10 (trans (mapcar '- cen (list rad rad)) 1 0))
                (cons 11 (trans (list (+ rad rad) 0.0) 1 0 t))
                (cons 12 (trans (list 0.0 (+ rad rad)) 1 0 t))
                '(280 . 1) '(71 . 2))
            (cons (last lst) lst)
        )
    )
)