;;; ------------------------------------------------------------
;;; MBETWEEN – Move selection so its base point lands at midpoint
;;;            between two reference points, with base point option:
;;;            Pick or automatic Midpoint of 2 points (Mid2).
;;; Author: Syuaidi + Copilot
;;; Usage: MBETWEEN
;;; ------------------------------------------------------------

(defun mid-2pts ( / p1 p2)
  (prompt "\nPick FIRST point for midpoint: ")
  (setq p1 (getpoint))
  (if (not p1) (progn (prompt "\n*No first point picked.*") nil))
  (if p1
    (progn
      (prompt "\nPick SECOND point for midpoint: ")
      (setq p2 (getpoint p1))
      (if (not p2) (progn (prompt "\n*No second point picked.*") nil)
        (mapcar '(lambda (a b) (/ (+ a b) 2.0)) p1 p2)
      )
    )
  )
)

(defun safe-get-basepoint ( / ans bp)
  (initget "Pick Mid2")  ; allow keywords
  (setq ans (getkword "\nBase point option [Pick/Mid2] <Pick>: "))
  (cond
    ((or (null ans) (eq ans "Pick"))
      (setq bp (getpoint "\nPick base point on the selected objects: "))
    )
    ((eq ans "Mid2")
      (setq bp (mid-2pts))
    )
  )
  bp
)

(defun c:MBETWEEN ( / *error* oldcmd oldos ss bp p1 p2 mid vec)

  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (princ (strcat "\nError: " msg))
    )
    (if oldcmd (setvar 'CMDECHO oldcmd))
    (if oldos  (setvar 'OSMODE oldos))
    (princ)
  )

  (setq oldcmd (getvar 'CMDECHO))
  (setq oldos  (getvar 'OSMODE))
  (setvar 'CMDECHO 0)

  (prompt "\nSelect objects to move: ")
  (setq ss (ssget))
  (if (not ss) (progn (prompt "\n*No selection.*") (*error* nil)) )

  ;; === Base point: Pick atau Mid2 (otomatis) ===
  (setq bp (safe-get-basepoint))
  (if (not bp) (progn (prompt "\n*No base point obtained.*") (*error* nil)))

  ;; === Target midpoint: 2 titik referensi seperti biasa ===
  (prompt "\nPick FIRST reference point: ")
  (setq p1 (getpoint))
  (if (not p1) (progn (prompt "\n*No first point picked.*") (*error* nil)))

  (prompt "\nPick SECOND reference point: ")
  (setq p2 (getpoint p1))
  (if (not p2) (progn (prompt "\n*No second point picked.*") (*error* nil)))

  ;; Midpoint = (p1 + p2)/2
  (setq mid (mapcar '(lambda (a b) (/ (+ a b) 2.0)) p1 p2))

  ;; Displacement vector = mid - bp
  (setq vec (mapcar '- mid bp))

  ;; Apply move
  (command "_.MOVE" ss "" '(0 0 0) vec)

  (setvar 'CMDECHO oldcmd)
  (setvar 'OSMODE  oldos)
  (princ "\nDone: Objects moved to the midpoint between the two reference points.")
  (princ)
)