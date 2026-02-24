(defun c:AK () (do_align "Kiri"))   ; Perintah AK untuk Kiri
(defun c:AT () (do_align "Tengah")) ; Perintah AT untuk Tengah
(defun c:AN () (do_align "Kanan"))  ; Perintah AN untuk Kanan (AN = kaNan)

(defun do_align (mode / ss i lst pt bpt x_base y_start space obj typ newpt)
  (vl-load-com)
  (princ (strcat "\n--- Align " mode " ---"))
  (if (setq ss (ssget '((0 . "TEXT,MTEXT"))))
    (progn
      ;; Masukkan ke list dan urutkan berdasarkan posisi Y (dari atas ke bawah)
      (setq i 0 lst '())
      (repeat (sslength ss)
        (setq lst (cons (vlax-ename->vla-object (ssname ss i)) lst))
        (setq i (1+ i))
      )
      (setq lst (vl-sort lst '(lambda (a b) (> (cadr (vlax-get a 'InsertionPoint)) (cadr (vlax-get b 'InsertionPoint))))))

      ;; Input titik dan jarak
      (setq bpt (getpoint "\nKlik Titik Acuan (Base Point): "))
      (setq x_base (car bpt))
      (setq y_start (cadr bpt))
      (setq space (getdist bpt "\nMasukkan Jarak Antar Teks: "))

      (setq i 0)
      (foreach obj lst
        (setq typ (vla-get-ObjectName obj))
        
        ;; 1. Atur Justification & Width=0
        (if (= typ "AcDbMText")
          (progn
            (vla-put-Width obj 0.0)
            (cond
              ((= mode "Kiri")   (vla-put-AttachmentPoint obj acAttachmentPointMiddleLeft))
              ((= mode "Tengah") (vla-put-AttachmentPoint obj acAttachmentPointMiddleCenter))
              ((= mode "Kanan")  (vla-put-AttachmentPoint obj acAttachmentPointMiddleRight))
            )
          )
          (cond
            ((= mode "Kiri")   (vla-put-Alignment obj acAlignmentMiddleLeft))
            ((= mode "Tengah") (vla-put-Alignment obj acAlignmentMiddleCenter))
            ((= mode "Kanan")  (vla-put-Alignment obj acAlignmentMiddleRight))
          )
        )

        ;; 2. Atur Posisi (X dan Y)
        (setq newpt (vlax-make-safearray vlax-vbDouble '(0 . 2)))
        (vlax-safearray-fill newpt (list x_base (- y_start (* i space)) 0.0))
        
        (if (and (= typ "AcDbText") (/= (vla-get-Alignment obj) 0))
          (vla-put-TextAlignmentPoint obj newpt)
          (vla-put-InsertionPoint obj newpt)
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nSelesai meratakan " (itoa (length lst)) " teks."))
    )
  )
  (princ)
)