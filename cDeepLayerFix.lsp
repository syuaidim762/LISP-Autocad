(defun c:DeepLayerFix (/ targetLayer replacementLayer blocks block obj eData)
  (setq targetLayer (getstring T "\nMasukkan nama layer yang susah dihapus: "))
  
  (if (not (tblsearch "LAYER" targetLayer))
    (progn (princ "\nError: Layer tidak ditemukan.") (exit))
  )

  (setq replacementLayer (getstring T "\nPindahkan isinya ke layer apa? [Default: 0]: "))
  (if (= replacementLayer "") (setq replacementLayer "0"))

  (princ (strcat "\nMemproses database... Mencari " targetLayer " di dalam Block."))

  ;; 1. SCAN SEMUA DEFINISI BLOCK (Bahkan yang tidak di-insert)
  (setq blocks (tablegui "BLOCK")) ;; Helper atau gunakan loop tblnext
  
  (setq block (tblnext "BLOCK" T))
  (while block
    (setq eData (entget (cdr (assoc -2 block))))
    (while eData
      ;; Jika objek di dalam block menggunakan targetLayer
      (if (= (cdr (assoc 8 eData)) targetLayer)
        (progn
          (setq eData (subst (cons 8 replacementLayer) (assoc 8 eData) eData))
          (entmod eData)
        )
      )
      (if (setq nextEnt (entnext (cdr (assoc -1 eData))))
          (setq eData (entget nextEnt))
          (setq eData nil)
      )
    )
    (setq block (tblnext "BLOCK"))
  )

  ;; 2. SCAN SEMUA OBJEK DI MODELSPACE & LAYOUT
  (setq ss (ssget "_X" (list (cons 8 targetLayer))))
  (if ss
    (command "_.CHPROP" ss "" "_LA" replacementLayer "")
  )

  (princ (strcat "\nSelesai! Semua isi " targetLayer " telah dipindah ke " replacementLayer "."))
  (princ "\nSilakan jalankan perintah PURGE sekarang.")
  (princ)
)

;; Helper function sederhana jika tblnext dirasa lambat
(defun tablegui (tab)
  (setq lst nil)
  (setq d (tblnext tab t))
  (while d
    (setq lst (cons (cdr (assoc 2 d)) lst))
    (setq d (tblnext tab))
  )
  lst
)