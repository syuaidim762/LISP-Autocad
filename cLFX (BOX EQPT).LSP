(defun c:LFX (/ p1 p3 p4 mid_box mid_oval oldos b1 b2_in t_in box_h half_h i num_str_b num_str_t prefix_b prefix_t count_b count_t len_t full_eq full_tag tag_num first_x gap ans_2row min_gap user_gap)
  (vl-load-com)
  (setq oldos (getvar "OSMODE"))
  (setvar "CMDECHO" 0)

  ;; SETUP LAYER & FONT
  (if (not (tblsearch "LAYER" "EQPT")) (command "-layer" "M" "EQPT" "C" "6" "" ""))
  (if (not (tblsearch "LAYER" "EQPT TAG NO")) (command "-layer" "M" "EQPT TAG NO" "C" "8" "" ""))
  (if (not (tblsearch "STYLE" "CALIBRI")) (command "-style" "CALIBRI" "calibri.ttf" "0.0" "1.0" "0" "N" "N"))
  (if (not (tblsearch "STYLE" "ARIALN1")) (command "-style" "ARIALN1" "arialn.ttf" "0.0" "1.0" "0" "N" "N"))

  ;; 1. INPUT MODE BARIS
  (initget "Yes No")
  (setq ans_2row (getkword "\nGunakan 2 Baris di Box Bawah? [Yes/No] <Yes>: "))
  (if (null ans_2row) (setq ans_2row "Yes"))

  (if (= ans_2row "Yes")
    (progn
      (setq b1 (getstring T "\n[Bawah] Baris 1: "))
      (setq b2_in (getstring T "\n[Bawah] Baris 2 Start (Contoh: SWITCH 7): "))
    )
    (setq b2_in (getstring T "\n[Bawah] Teks & No Start (Contoh: STATION 1): "))
  )

  (setq t_in (getstring T "\n[Atas] Tag No Start (Contoh: GH-KH-SW-03): "))
  
  ;; 2. INPUT TINGGI BOX & HITUNG MINIMUM GAP
  (setq box_h (getreal "\nMasukkan Tinggi Box Bawah (Default 12): "))
  (if (null box_h) (setq box_h 12.0))
  (setq half_h (/ box_h 2.0))
  
  ;; LOGIKA: Jarak minimal adalah Tinggi Box + 4.75
  (setq min_gap (+ box_h 4.75))

  ;; 3. MUNCULKAN INFO MINIMUM GAP SEBELUM INPUT USER
  (princ (strcat "\n>>> JARAK VERTIKAL MINIMAL ADALAH: " (rtos min_gap 2 2) " <<<"))
  (setq user_gap (getdist (strcat "\nMasukkan Jarak yang diinginkan (Atau ENTER untuk " (rtos min_gap 2 2) "): ")))
  
  ;; Validasi: Gunakan yang terbesar antara input user atau min_gap
  (if (or (null user_gap) (< user_gap min_gap))
    (setq gap min_gap)
    (setq gap user_gap)
  )
  (princ (strcat "\nJarak Fix: " (rtos gap 2 2)))

  ;; --- LOGIKA DETEKSI ANGKA SEQUENCING ---
  (setq i (strlen b2_in) num_str_b "")
  (while (and (> i 0) (member (substr b2_in i 1) '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")))
    (setq num_str_b (strcat (substr b2_in i 1) num_str_b))
    (setq i (1- i))
  )
  (setq prefix_b (substr b2_in 1 i))
  (setq count_b (atoi num_str_b))

  (setq i (strlen t_in) num_str_t "")
  (while (and (> i 0) (member (substr t_in i 1) '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")))
    (setq num_str_t (strcat (substr t_in i 1) num_str_t))
    (setq i (1- i))
  )
  (setq prefix_t (substr t_in 1 i))
  (setq count_t (atoi num_str_t))
  (setq len_t (strlen num_str_t))

  ;; --------------------------------------------------------
  ;; PROSES GAMBAR
  ;; --------------------------------------------------------
  (princ "\nKlik lokasi pertama...")
  (setq p1 (getpoint "\nTitik Pertama: "))
  
  (if p1
    (progn
      (setq first_x (car p1))
      (while p1
        (setvar "OSMODE" 0)
        (setq p1 (list first_x (cadr p1) 0.0))

        (if (= ans_2row "Yes")
          (setq full_eq (strcat b1 "\\P" prefix_b (itoa count_b)))
          (setq full_eq (strcat prefix_b (itoa count_b)))
        )

        (setq tag_num (itoa count_t))
        (while (< (strlen tag_num) len_t) (setq tag_num (strcat "0" tag_num)))
        (setq full_tag (strcat prefix_t tag_num))

        ;; GAMBAR BOX BAWAH (MAGENTA)
        (setvar "CLAYER" "EQPT")
        (command "_rectang" "_F" "0.0" p1 (list (+ (car p1) 20) (+ (cadr p1) box_h)))
        (setq mid_box (list (+ (car p1) 10) (+ (cadr p1) half_h)))
        (command "_mtext" mid_box "_J" "_MC" "_ST" "CALIBRI" "_H" "1.6" "_W" "0" full_eq "")
        (command "_chprop" "_L" "" "_C" "7" "")

        ;; GAMBAR BOX ATAS (GRAY)
        (setvar "CLAYER" "EQPT TAG NO")
        (setq p3 (list (- (car p1) 1) (+ (cadr p1) box_h 1))) 
        (setq p4 (list (+ (car p3) 22) (+ (cadr p3) 2.75)))
        (command "_rectang" "_F" "1.375" p3 p4)
        (setq mid_oval (list (+ (car p3) 11) (+ (cadr p3) 1.375)))
        (command "_mtext" mid_oval "_J" "_MC" "_ST" "ARIALN1" "_H" "1.6" "_W" "0" full_tag "")
        (command "_chprop" "_L" "" "_C" "7" "")

        (setq count_b (1+ count_b) count_t (1+ count_t))
        (setq p1 (list first_x (- (cadr p1) gap) 0.0))
        
        (setvar "OSMODE" oldos)
        (princ (strcat "\nKlik berikutnya (Jarak: " (rtos gap 2 2) ")..."))
        (if (null (getpoint)) (setq p1 nil))
      )
    )
  )
  (setvar "OSMODE" oldos)
  (princ "\nSelesai.")
  (princ)
)