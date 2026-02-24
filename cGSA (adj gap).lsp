(defun c:GSA (/ *error* gap groups continue sel i ent align_type stack_dir ref_val cur_val last_ref_y this_ref_y off_y off_x minp maxp doc g_min_x g_max_x p1 p2 old_osnap)
  (vl-load-com)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (vla-startundomark doc)
  
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (if old_osnap (setvar "OSMODE" old_osnap))
    (vla-endundomark doc)
    (princ)
  )

  ;; Simpan setting OSNAP agar tidak mengganggu pemindahan
  (setq old_osnap (getvar "OSMODE"))
  (setvar "CMDECHO" 0)

  ;; 1. Input Parameter
  (setq gap (getdist "\nMasukkan Jarak Bersih (Gap): "))
  (if (null gap) (setq gap 0.0))

  (initget "Atas Bawah")
  (setq stack_dir (getkword "\nSusun ke arah [Atas/Bawah] <Bawah>: "))
  (if (not stack_dir) (setq stack_dir "Bawah"))

  (initget "KI T KA")
  (setq align_type (getkword "\nPerataan [KI-Kiri / T-Tengah / KA-Kanan] <T>: "))
  (if (not align_type) (setq align_type "T"))

  ;; 2. Seleksi Grup (Apapun objeknya)
  (setq groups nil continue t)
  (while continue
    (princ (strcat "\nPilih Grup Ke-" (itoa (1+ (length groups))) " (Enter jika selesai): "))
    (setq sel (ssget))
    (if sel
      (progn
        (setq i 0 current_objs nil)
        (repeat (sslength sel)
          (setq current_objs (cons (ssname sel i) current_objs))
          (setq i (1+ i))
        )
        (setq groups (cons current_objs groups))
      )
      (setq continue nil)
    )
  )

  (setq groups (reverse groups))

  (if (> (length groups) 1)
    (progn
      (setvar "OSMODE" 0) ;; Matikan OSNAP sementara

      ;; 3. Cari Patokan X dari Grup Pertama
      (setq g_min_x 1e99 g_max_x -1e99)
      (foreach ent (car groups)
        (vla-getboundingbox (vlax-ename->vla-object ent) 'minp 'maxp)
        (setq x1 (car (vlax-safearray->list minp)) x2 (car (vlax-safearray->list maxp)))
        (if (< x1 g_min_x) (setq g_min_x x1))
        (if (> x2 g_max_x) (setq g_max_x x2))
      )
      (setq ref_val (cond ((= align_type "KI") g_min_x) ((= align_type "KA") g_max_x) (t (/ (+ g_min_x g_max_x) 2.0))))

      ;; 4. Proses Pemindahan
      (setq i 1)
      (while (< i (length groups))
        (setq prev_group (nth (1- i) groups) this_group (nth i groups))

        ;; Batas referensi grup sebelumnya
        (setq last_ref_y (if (= stack_dir "Bawah") 1e99 -1e99))
        (foreach ent prev_group
          (vla-getboundingbox (vlax-ename->vla-object ent) 'minp 'maxp)
          (setq y (if (= stack_dir "Bawah") (cadr (vlax-safearray->list minp)) (cadr (vlax-safearray->list maxp))))
          (if (= stack_dir "Bawah") (if (< y last_ref_y) (setq last_ref_y y)) (if (> y last_ref_y) (setq last_ref_y y)))
        )

        ;; Batas grup sekarang
        (setq this_ref_y (if (= stack_dir "Bawah") -1e99 1e99) g_min_x 1e99 g_max_x -1e99)
        (foreach ent this_group
          (vla-getboundingbox (vlax-ename->vla-object ent) 'minp 'maxp)
          (setq p1 (vlax-safearray->list minp) p2 (vlax-safearray->list maxp))
          (setq y (if (= stack_dir "Bawah") (cadr p2) (cadr p1)))
          (if (= stack_dir "Bawah") (if (> y this_ref_y) (setq this_ref_y y)) (if (< y this_ref_y) (setq this_ref_y y)))
          (if (< (car p1) g_min_x) (setq g_min_x (car p1)))
          (if (> (car p2) g_max_x) (setq g_max_x (car p2)))
        )

        ;; Hitung pergeseran
        (setq off_y (if (= stack_dir "Bawah") (- (- last_ref_y gap) this_ref_y) (+ (- last_ref_y this_ref_y) gap)))
        (setq cur_val (cond ((= align_type "KI") g_min_x) ((= align_type "KA") g_max_x) (t (/ (+ g_min_x g_max_x) 2.0))))
        (setq off_x (- ref_val cur_val))

        ;; Eksekusi Move tanpa gangguan OSNAP
        (foreach ent this_group 
          (vl-cmdf "_move" ent "" "0,0,0" (list off_x off_y 0))
        )
        (setq i (1+ i))
      )
      (setvar "OSMODE" old_osnap) ;; Kembalikan OSNAP
    )
  )
  (vla-endundomark doc)
  (princ (strcat "\nSelesai! Jarak bersih diatur ke: " (rtos gap 2 2)))
  (princ)
)