(defun c:LEFIX ()
  (vl-load-com)
  (let ((dict (vla-item (vla-get-dictionaries (vla-get-activedocument (vlax-get-acad-object))) "ACAD_MLEADERSTYLE")))
    (vlax-for style dict
      ;; 2 = Middle of Text
      (vla-put-TextLeftAttachmentType style 2)
      (vla-put-TextRightAttachmentType style 2)
    )
  )
  (princ "\nAll MLeader Styles set to Middle Attachment.")
  (princ)
)