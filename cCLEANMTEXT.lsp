(defun c:CLEANMTEXT (/ ss i ename elist str)
  (setq ss (ssget "_:L" '((0 . "MTEXT")))) ; Select only MText on unlocked layers
  (if ss
    (progn
      (repeat (setq i (sslength ss))
        (setq ename (ssname ss (setq i (1- i))))
        (setq elist (entget ename))
        (setq str (cdr (assoc 1 elist))) ; Get the text string
        
        ; The Regex pattern to strip formatting codes
        (while (wcmatch str "*\\*;*")
          (setq str 
            (vl-string-right-trim "}" 
              (vl-string-left-trim "{" 
                (vl-regexp-replace "(\\\\[ACHLfFHQTW].*?;)" str "")
              )
            )
          )
        )
        
        (entmod (subst (cons 1 str) (assoc 1 elist) elist))
      )
      (princ (strcat "\nSuccessfully cleaned " (itoa (sslength ss)) " MText objects."))
    )
    (princ "\nNo MText selected.")
  )
  (princ)
)