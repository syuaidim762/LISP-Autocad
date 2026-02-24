(defun c:RenameMassalLengkap (/ path ext newBaseName startNum files f batch-file count old-name new-name suffix)
  (vl-load-com)
  
  (princ "\n=== PROGRAM PENGGANTI NAMA FILE MASSAL ===")
  
  ;; 1. Input Data
  (setq path (getstring T "\n1. Masukkan path folder: "))
  (setq ext (getstring "\n2. Masukkan ekstensi file (contoh: dwg, pdf, txt): "))
  (setq newBaseName (getstring T "\n3. Masukkan Nama File Baru: "))
  (setq startNum (getint "\n4. Mulai dari nomor urut berapa? (Contoh: 1): "))
  
  (if (null startNum) (setq startNum 1))
  
  ;; Bersihkan input ekstensi (buang titik jika user memasukkannya)
  (if (= (substr ext 1 1) ".") (setq ext (substr ext 2)))

  ;; Perbaikan format path
  (if (/= (substr path (strlen path)) "\\")
    (setq path (strcat path "\\"))
  )

  ;; 2. Ambil semua file berdasarkan ekstensi yang dipilih
  (setq files (vl-directory-files path (strcat "*." ext) 1))

  (if files
    (progn
      (setq batch-file (strcat path "eksekusi_rename_massal.bat"))
      (setq f (open batch-file "w"))
      (write-line "@echo off" f)
      (write-line "echo Menjalankan proses rename..." f)
      
      (setq count startNum)

      (foreach old-name files
        ;; Logika Nomor Urut (Format 01, 02, dst)
        (if (< count 10)
          (setq suffix (strcat "_0" (itoa count)))
          (setq suffix (strcat "_" (itoa count)))
        )

        ;; Gabungkan Nama Baru + Nomor + Ekstensi
        (setq new-name (strcat newBaseName suffix "." ext))
        
        ;; Tulis ke file Batch
        (write-line (strcat "ren \"" old-name "\" \"" new-name "\"") f)
        
        (setq count (1+ count))
      )
      
      (write-line "echo Selesai! Nama file telah diperbarui." f)
      (write-line "pause" f)
      (close f)
      
      (princ (strcat "\n\n[BERHASIL] File batch dibuat di: " batch-file))
      (princ "\nSilakan buka folder tersebut dan klik dua kali file .bat-nya.")
    )
    (princ (strcat "\n[ERROR] Tidak ada file dengan ekstensi ." ext " di folder tersebut."))
  )
  (princ)
)