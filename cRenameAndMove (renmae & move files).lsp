(defun c:RenameAndMove (/ path ext newBaseName startNum targetFolder files f batch-file count old-name new-name suffix)
  (vl-load-com)
  
  (princ "\n=== PROGRAM RENAME + PEMINDAH FOLDER ===")
  
  ;; 1. Input Data
  (setq path (getstring T "\n1. Masukkan path folder asal: "))
  (setq ext (getstring "\n2. Masukkan ekstensi file (dwg, pdf, dll): "))
  (setq newBaseName (getstring T "\n3. Masukkan Nama File Baru: "))
  (setq startNum (getint "\n4. Mulai dari nomor urut berapa? (Contoh: 1): "))
  (setq targetFolder (getstring T "\n5. Nama folder tujuan (misal: FINAL): "))
  
  (if (null startNum) (setq startNum 1))
  (if (= (substr ext 1 1) ".") (setq ext (substr ext 2)))

  ;; Perbaikan format path
  (if (/= (substr path (strlen path)) "\\")
    (setq path (strcat path "\\"))
  )

  ;; 2. Cari file
  (setq files (vl-directory-files path (strcat "*." ext) 1))

  (if files
    (progn
      (setq batch-file (strcat path "eksekusi_rename_pindah.bat"))
      (setq f (open batch-file "w"))
      
      (write-line "@echo off" f)
      ;; Perintah membuat folder jika belum ada
      (write-line (strcat "if not exist \"" targetFolder "\" mkdir \"" targetFolder "\"") f)
      
      (setq count startNum)

      (foreach old-name files
        ;; Format Nomor Urut
        (if (< count 10)
          (setq suffix (strcat "_0" (itoa count)))
          (setq suffix (strcat "_" (itoa count)))
        )

        (setq new-name (strcat newBaseName suffix "." ext))
        
        ;; Perintah: Pindahkan file sekaligus ganti nama ke dalam folder tujuan
        ;; move "nama_lama.dwg" "FINAL\nama_baru_01.dwg"
        (write-line (strcat "move \"" old-name "\" \"" targetFolder "\\" new-name "\"") f)
        
        (setq count (1+ count))
      )
      
      (write-line "echo Selesai! File dipindahkan ke folder baru." f)
      (write-line "pause" f)
      (close f)
      
      (princ (strcat "\n\n[BERHASIL] File batch: " batch-file))
      (princ (strcat "\nFolder tujuan: " path targetFolder))
    )
    (princ "\n[ERROR] File tidak ditemukan.")
  )
  (princ)
)