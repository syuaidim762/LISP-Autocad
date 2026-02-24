(defun c:FOCUS ()
  (setq ent (car (entsel "\nSelect object to focus on: ")))
  (if ent
    (progn
      (command "LAYISO" ent "")
      (setvar "LAYLOCKFADECTL" 70) ; Dims locked layers by 70%
      (princ "\nFocus Mode Active. Use 'UNFOCUS' to restore.")
    )
  )
  (princ)
)

(defun c:UNFOCUS ()
  (command "LAYUNISO")
  (princ "\nWorld restored.")
  (princ)
)