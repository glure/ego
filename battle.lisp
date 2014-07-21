(defvar turn 'player)

(defun battle ()
  (fv)
  (generateBattleMapArray)
  (defvar tempPos (pos *avatar*))
  (defvar tempPos2 (pos *enemy*))
  (defvar moved 0)
  (setf moved 0)
  (setf (pos *avatar*) #(0 0))
  (setf (pos *enemy*) #(0 7))
  (setf battle 0)
  (sdl:with-events (:poll)
    (:quit-event () t)
    (:key-down-event (:key key)
		     (format t "Key down: ~S~%" key)
		     (case key
		       (:sdl-key-k (progn (move2 *avatar* 1)
					  (setf turn 'AI)
					  (setf moved 1)))
		       (:sdl-key-j (progn (move2 *avatar* 2)
					  (setf turn 'AI)
					  (setf moved 1)))
		       (:sdl-key-h (progn (move2 *avatar* 3)
					  (setf turn 'AI)
					  (setf moved 1)))
		       (:sdl-key-l (progn (move2 *avatar* 4)
					  (setf turn 'AI)
					  (setf moved 1)))
		       (:sdl-key-space (if (> (length vektori3) 0)
					   (move2 *enemy* (case (vector-pop VEKTORI3)
							    (U 1)
							    (D 2)
							    (L 3)
							    (R 4))))))
		     (case key
		       (:sdl-key-s (stats)))
		     (case key
		       (:sdl-key-q (sdl:push-quit-event)))) 
		     
    (:idle ()
	   (sdl:clear-display sdl:*black*)
	   (drawBattleBoard)
	   (sdl:draw-string-solid-* (format NIL "turn: ~S" turn) 0 0)
	   (sdl:draw-string-solid-* (format NIL "pos_player: ~S ~S" (elt (pos *avatar*) 0)
					                            (elt (pos *avatar*) 1)) 0 40)
	   (sdl:draw-string-solid-* (format NIL "pos_enemy: ~S ~S" (elt (pos *enemy*) 0)
					                        (elt (pos *enemy*) 1)) 0 80)
	   (if (string-equal turn 'AI)
	       (sdl:draw-string-solid-* (format NIL "<press SPACE>") 500 40))
	   (sdl:draw-string-solid-* (format NIL "turn: ~S" turn) 0 0)
	   ;(sdl:draw-string-solid-* (format NIL "vektori: ~S" (elt vektori 0)) 0 120)
	   (if (eq moved 1)
	       (progn (fv)
		      (path *avatar* *enemy*)
		      (setf moved 0)))
	   ;(fv)
	   (drawPlayer2)
	   (drawEnemies2)
	   ;(path *avatar* *enemy*)
	   (if (AND (> (elt (pos *avatar*) 0) 0)
		    (> (elt (pos *avatar*) 1) 0)) 
	       (drawPath))
	   ;(drawArrow #(5 5) 4)
	   ;(drawArrow #(6 5) 1)
	   ;(drawArrow #(6 4) 4)
	   ;(drawArrow #(5 5) 4)
	   ;(drawPath)
	   (sdl:update-display)
	   )
)
  (setf (pos *avatar*) tempPos)
  (setf (pos *enemy*) tempPos2)
)





;		  (if (AND (string-equal turn 'AI) (< (elt (pos *enemy*) 1) 12))
;	       (progn (move2 *enemy* 2)
;		      (sdl:with-events (:poll)
;			(:quit-event () T)
;			(:key-down-event (:key key)
;					 (format T "Key down: ~S~%" key)
;					 (case key
;					   (:sdl-key-space (sdl:push-quit-event))))
;			(:idle ()
;			       (AI)
;			       (setf turn 'AI)
;			;(sleep 1)
;		      ))))



(defparameter CTC 0)
    
(defun drawBattleBoard ()
  (loop for j from 0 to 7
    do (loop for i from 0 to 7
      do (progn (sdl:draw-surface-at-* *grassScarce* 
				(+ (* 6 48) (* 48 i))     ; x
				(+ (* 4 48) (* 48 j))))))
  (loop for i from 0 to 8
      do (sdl:draw-line-* (+ (* 6 48) (* i 48)) (+ (* 4 48) (* 0 48))
			  (+ (* 6 48) (* i 48)) (+ (* 4 48) (* 8 48))
			  :color sdl:*blue*))
  (loop for j from 0 to 8
     do (sdl:draw-line-* (+ (* 6 48) (* 0 48)) (+ (* 4 48) (* j 48))
			 (+ (* 6 48) (* 8 48)) (+ (* 4 48) (* j 48))
			 :color sdl:*blue*))) ; y

(defparameter battleMap (make-array '(8 8)))
(defun generateBattleMapArray ()
  (loop for j from 0 to 7
    do (loop for i from 0 to 7
	  do (setf (aref battleMap i j) (vector (+ (* 6 48) (* 48 i))
						(+ (* 4 48) (* 48 j)))))))
