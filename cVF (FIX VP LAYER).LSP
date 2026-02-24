;; ==========================================================
;; PERINTAH UTAMA:
;; VF    - Toggle (Bolak-balik On/Off)
;; VFON  - Paksa On (Tampilkan) - Tanpa Dialog
;; VFOFF - Paksa Off (Sembunyikan) - Tanpa Dialog
;; ==========================================================

(defun c:VF () (vframe_logic "TOGGLE"))
(defun c:VFON () (vframe_logic "ON"))
(defun c:VFOFF () (vframe_logic "OFF"))

(defun vframe_logic (mode / lay_data cur ss i ent)
  (setvar "CMDECHO" 0)
  
  ;; 1. PASTIKAN LAYER "VP" ADA
  (setq lay_data (tblsearch "LAYER" "VP"))
  (if (null lay_data)
    (command "-layer" "M" "VP" "C" "250" "VP" "P" "N" "VP" "" "")
  )

  ;; 2. PINDAHKAN VIEWPORT KE LAYER "VP"
  (setq ss (ssget "_X" '((0 . "VIEWPORT"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (if (> (cdr (assoc 69 (entget ent))) 1)
          (command "_chprop" ent "" "_LA" "VP" "")
        )
        (setq i (1+ i))
      )
    )
  )

  ;; 3. LOGIKA EKSEKUSI (DIPERBAIKI AGAR OTOMATIS)
  (setq lay_data (tblsearch "LAYER" "VP"))
  (setq cur (cdr (assoc 70 lay_data)))

  (cond
    ;; MODE ON: Thaw dulu baru On (menghindari prompt AutoCAD)
    ((or (and (= mode "TOGGLE") (= (logand cur 1) 1)) (= mode "ON"))
      (command "-layer" "T" "VP" "") ;; Thaw
      (command "-layer" "ON" "VP" "") ;; Turn On
      (princ "\nViewport Frame: TAMPIL (ON).")
    )
    ;; MODE OFF
    ((or (and (= mode "TOGGLE") (= (logand cur 1) 0)) (= mode "OFF"))
      (if (= (getvar "CLAYER") "VP") (setvar "CLAYER" "0"))
      (command "-layer" "F" "VP" "") ;; Freeze
      (princ "\nViewport Frame: SEMBUNYI (OFF).")
    )
  )
  
  (setvar "CMDECHO" 1)
  (princ)
)

(princ "\nLISP Viewport Manager Fix Loaded. Ketik VF, VFON, atau VFOFF.")
(princ)