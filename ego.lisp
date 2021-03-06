(defparameter objects (make-array 512 :adjustable t :fill-pointer 0)
  "All objects in current screen.")
(defparameter *edit-mode* 'add)
(defparameter *editor-area* 1)
(defparameter *editor-screen* 50)
(defparameter *game-root-dir* "E:/coding/ego/")


(defparameter *x* 60)
(defparameter *y* 420)

(defparameter *default-font-path* "/usr/share/fonts")
(defparameter *windows-font-path* "C:/Users/glure/quicklisp/dists/quicklisp/software/lispbuilder-20140113-svn/lispbuilder-sdl/assets/")
(defparameter *linux-font-path* "/home/migrayn/quicklisp/dists/quicklisp/software/lispbuilder-20130312-svn/lispbuilder-sdl/assets/")

(defparameter *vera-ttf* (make-instance 'SDL:ttf-font-definition
                          :size 32
			  :filename (merge-pathnames "Vera.ttf" *windows-font-path*)))

(unless (sdl:initialise-default-font *vera-ttf*)
   (error "Cannot create font."))



(defclass objekti ()
  ((name :accessor name 
	 :initform 'blank
	 :initarg :name)
   (id :accessor id
       :initform 'blank
       :initarg :id)
   (x :accessor x
      :initform 480 
      :initarg :x)
   (y :accessor y
      :initform 360
      :initarg :y)
   (pos :accessor pos
	:initform #(480 360)
	:initarg :pos)
   (x_v :accessor x_v
      :initform 0.0
      :initarg :x_v)
   (y_v :accessor y_v
      :initform 0.0
      :initarg :y_v)
   (a :accessor a
      :initform #(0 0)
      :initarg :a)
   (state :accessor state
      :initform 'idle
      :initarg :state)
   (direction :accessor direction
      :initform 0
      :initarg :direction)
   (gfx :accessor gfx
	:initform nil
	:initarg :gfx)
   (needs :accessor needs
	  :initform #(0 0 0)
	  :initarg :needs)
   (inventory :accessor inventory
	      :initform '(keycard)
	      :initarg :inventory)))


(let ((direction 'up))
  (defun toggle ()
    (setq direction
	  (if (eq direction 'up)
	      'down
	      'up))
	  T)
  (defun nosta ()
    (let ((x 0))
      (lambda () 
	(if (eq direction 'up)
	    (incf x)
	    (decf x)))))
)

(defmacro tst ()
  `(print ,(funcall (nosta))))



(defmacro tm (arg_1 arg_2)
  (let ((direction 'up)
        (g (gensym)))
    `(defun ,arg_1 ()
      (setq ,direction
	    (if (eq ,direction up)
		down
		up)))
    `(defun ,arg_2 ()
       (let ((,g 0))
	 (lambda () 
	   (if (eq ,direction up)
	       (incf ,g)
	       (decf ,g)))
        `(defun tulosta ()
	   (print ,g))))))

;------------------------------------------------------------------------------------
; PHYSICS


(defun keyDown (key)
  (if (sdl:key-down-p key)
      T
      NIL))

;------------------------------------------------------------------------------------
; RADIAL MENU

(defun drawRadialMenu (direction)
  (sdl:draw-surface-at-* *radial-interact* (round (- (x *avatar*) 72)) 
			                   (round (- (y *avatar*) 24)))
  (sdl:draw-surface-at-* *radial-inspect* (round (- (x *avatar*) 24))
			                  (round (- (y *avatar*) 72)))
  (sdl:draw-surface-at-* *radial-use* (round (+ (x *avatar*) 24))
			              (round (- (y *avatar*) 24)))
  (sdl:draw-surface-at-* *radial-choose* (case direction
					   (0 (round (- (x *avatar*) 30)))
					   (1 (round (- (x *avatar*) 30)))
					   (2 (round (- (x *avatar*) 30)))
					   (3 (round (- (x *avatar*) 78)))
					   (4 (round (+ (x *avatar*) 18))))
			                 (case direction
					   (0 (round (- (y *avatar*) 30)))
					   (1 (round (- (y *avatar*) 78)))
					   (2 (round (+ (y *avatar*) 66)))
					   (3 (round (- (y *avatar*) 30)))
					   (4 (round (- (y *avatar*) 30))))))
  ;(sdl:draw-surface-at-* *radial-use* (round (x *avatar*)) 
;			              (round (+ (y *avatar*) 48))))
;)

; (defun drawReticle (direction)

(defun execute (action)
  (defparameter key NIL)
  (cond ((eq action 'cancel)
	 (setf key 0))
	((eq action 'interact)
	 (setf key 1))
	((eq action 'inspect)
	 (setf key 2))
	((eq action 'use)
	 (setf key 3)))
  (case key
    (1 (if (searchInteractive)
	   (eval (object-use (eval (closest (searchInteractive)))))
	   (print (format nil "No object found for action ~S" action))))
    (2 ())
    (3 ())
    (4 ())))

(defun searchInteractive ()
  "Return vector comprising all objects within radius r."
  (let ((IAO (make-array 10 :adjustable t :fill-pointer 0))
	(r 50))
    (if objects
	(progn (loop for n from 0 to (- (length objects) 1)
		  do (if (< (absDistanceObj *avatar* (eval (elt objects n))) r)
			 (vector-push (elt objects n) IAO)))
	       (if (> (length IAO) 0)
		   IAO
		   NIL))
	NIL)))

(defun absDistance (ent1 ent2)
  "Return absolute distance between two entities."
  (sqrt (+ (expt (abs (- (x ent1) 
			 (x ent2))) 2)
	   (expt (abs (- (y ent1) 
			 (y ent2))) 2))))

(defun absDistanceObj (ent obj)
  "Return absolute distance between entity and object."
  (sqrt (+ (expt (abs (- (elt (slot-value ent 'pos) 0) 
			 (elt (slot-value obj 'pos) 0))) 2)
	   (expt (abs (- (y ent) 
			 (elt (slot-value obj 'pos) 1))) 2))))

(defun absDistanceObjCursor (obj)
  "Return absolute distance between mouse cursor and object."
  (sqrt (+ (expt (abs (- (elt mouse 0) 
			 (elt (slot-value obj 'pos) 0))) 2)
	   (expt (abs (- (elt mouse 1) 
			 (elt (slot-value obj 'pos) 1))) 2))))


(defun modify2 ()
  "Add/remove an object to/from the objects vector."
  (let ((hit 0))
    (if (> (length objects) 0)
	(loop for i from 0 to (1- (length objects))
	   do (if (cursor-inside-hitbox (elt objects i))
		  (progn (format t "~S" (object-name (eval (elt objects i))))
			 (setf (object-dead (elt objects i)) 1)
			 (setf hit 1))))
	(progn (place-object2)
	       (setf hit 1)))
    (if (eq hit 0)
	(place-object2))))

(defun modify3 ()
  (if (eq *edit-mode* 'add)
      (place-object2))
  (if (eq *edit-mode* 'remove)
      (remove-object)))

(defun place-object2 ()
  (if *brush*
      (progn (vector-push (make-object
		    :name (elt *brush* 0)
		    :id nil
		    :contents '()
		    :pos (if (eq *snap-to-grid* 1)
			     `(,(+ (* 48 (truncate (sdl:mouse-x) 48)) 24)
			       ,(+ (* 48 (truncate (sdl:mouse-y) 48)) 24))
			     `(,(sdl:mouse-x) ,(sdl:mouse-y)))
		    :hitbox (elt *brush* 1)
		    :gfx (copy-tree (elt *brush* 2))
		    :tags (elt *brush* 3)
		    :use (elt *brush* 4)
		    :dead 0) 
		   objects)
	     (format t "Placed object."))))


(defun remove-object ()
  (for-all-objects (if (cursor-inside-hitbox object)
		       (progn (setf (object-dead object) 1)
			      (format t "Removed object.")))))
			    

(defmacro for-all-objects (&rest body)
;  `(defmacro object ()
 ;    (defparameter object (elt objects i)))
  `(loop for i from 0 to (1- (length objects))
      do (let ((object (elt objects i)))
	   (progn ,@body))))


(defun removeDeadObjects (objList)
  (let ((tempObjects objList))
    (loop for i from 0 to (1- (length objects))
      do (if (eq (object-dead (eval (elt objects i))) 1)
	  (setf tempObjects (delete-if (constantly t) tempObjects :start i :count 1))))
    objList))

(defun remove-dead-objects (objList)
  (let ((tempObjects objList))
    (loop for i from (1- (length objects)) downto 0
      do (if (eq (object-dead (eval (elt tempObjects i))) 1)
	     (setf tempObjects (delete-if (constantly t) tempObjects
					  :start i :count 1))))
    tempObjects))

(defun struct->list (struct)
  (list (object-name struct)
	(object-id struct)
	(object-contents struct)
	(object-pos struct)
	(object-hitbox struct)
	(object-gfx struct)
	(object-tags struct)
	(object-use struct)
	(object-dead struct)))

(defun list->struct (list)
  (make-object
   :name (elt list 0)
   :id (elt list 1)
   :contents (elt list 2)
   :pos (elt list 3)
   :hitbox (elt list 4)
   :gfx (elt list 5)
   :tags (elt list 6)
   :use (elt list 7)
   :dead (elt list 8)))

(defun create-object-list ()
  "Return object list to be written into file (map objects)."
  (if (NOT (eq (length objects) 0))
      (let ((list NIL))
	(loop for i from 0 to (1- (length objects))
	   do (setf list (append list (list (struct->list (elt objects i))))))
	list)
      ()))


(defun write-objects ()
  "Write objects into file as a list."
  (let ((file (open (map-file *editor-area* *editor-screen*) :direction :output :if-exists :supersede)))
    (print (create-object-list) file)
    (close file)))


  

(defun read-objects ()
  "Read objects in list form from a file into structs and populate objects vector."
  (if (probe-file (map-file *editor-area* *editor-screen*))
      (let ((file (open (map-file *editor-area* *editor-screen*) :direction :input)))
	(let ((objectsList (read file)))
	  ;(if (NOT (eq (read file) NIL))
	  ;    (setf (cell-checkbox (elt *screen-index-cells* *editor-screen*)) 1))
	  (setf (fill-pointer objects) 0)
	  (loop for i from 0 to (1- (length objectsList))
	     do (vector-push (list->struct (elt objectsList i)) objects))
	  (close file)))
      (progn (setf objects (make-array 512 :adjustable t :fill-pointer 0))
	     ())))

(defun recurse (list)
  (when list 
    (progn (print (car list) 
	   (recurse (cdr list))))))

(defun map-file (area screen)
  "Return path of map file according to current *game-root-dir*, 
   *editor-area* and *editor-screen*."
  (merge-pathnames (concatenate 'string
				"area" (write-to-string area)
				"-"
				"screen" (write-to-string screen)
				".map")
		   (merge-pathnames "mapdata/"
				    *game-root-dir*)))

(defun place-object ()
  (vector-push (make-object
		:name 'laatikko
		:id 01
		:contents '(knife laserpointer)
		:pos `(,(sdl:mouse-x) ,(sdl:mouse-y))
		:hitbox '(12 12 36 36)
		:gfx '*drawer*
		:tags '(container locked)
		:use '(openInventory (closest objects))
		:dead 0) 
	       objects))
 
(defun cursor-inside-hitbox (obj)
  "Check if mouse cursor overlaps hitbox of object."
  (multiple-value-bind (lower-x higher-x lower-y higher-y) (hitbox2 obj)
    (if (AND (AND (>= (sdl:mouse-x) lower-x)
		  (<= (sdl:mouse-x) higher-x))
	     (AND (>= (sdl:mouse-y) lower-y)
		  (<= (sdl:mouse-y) higher-y)))
	T)))

(defun sword-inside-hitbox (obj)
  "Check if mouse cursor overlaps hitbox of object."
  (multiple-value-bind (lower-x higher-x lower-y higher-y) (hitbox2 obj)
    (if (AND (AND (>= (elt *sword-tip* 0) lower-x)
		  (<= (elt *sword-tip* 0) higher-x))
	     (AND (>= (elt *sword-tip* 1) lower-y)
		  (<= (elt *sword-tip* 1) higher-y)))
	T)))


(defun hitbox (obj)
  " IN: object
   OUT: hitbox coordinates x0 x1 y0 y1"
  (let ((x-offset (/ (- (elt (slot-value obj 'hitbox) 2) 
			(elt (slot-value obj 'hitbox) 0))
		     2))
	(y-offset (/ (- (elt (slot-value obj 'hitbox) 3) 
			(elt (slot-value obj 'hitbox) 1))
		     2))
	(object-x (elt (slot-value obj 'pos) 0))
	(object-y (elt (slot-value obj 'pos) 1)))
    (values (- object-x x-offset)
	    (+ object-x x-offset)
	    (- object-y y-offset)
	    (+ object-y y-offset))))

(defun hitbox2 (obj)
  " IN: object
   OUT: hitbox coordinates x0 x1 y0 y1"
  (let ((x-offset (/ (- (elt (slot-value obj 'hitbox) 2) 
			(elt (slot-value obj 'hitbox) 0))
		     2))
	(y-offset (/ (- (elt (slot-value obj 'hitbox) 3) 
			(elt (slot-value obj 'hitbox) 1))
		     2))
	(object-x (elt (slot-value obj 'pos) 0))
	(object-y (elt (slot-value obj 'pos) 1)))
    (values (- object-x (elt (slot-value obj 'hitbox) 0)) 
	    (+ object-x (elt (slot-value obj 'hitbox) 1))
	    (- object-y (elt (slot-value obj 'hitbox) 2))
	    (+ object-y (elt (slot-value obj 'hitbox) 3)))))
    
(defun cat (objectName)
  "Concatenate object name with accessor function or something."
  (concatenate 'string (write-to-string (symbol-name (quote objectName))) "-name"))

(defun closest (entlist)
  "Take vector containing entity list and return object closest to player."
  (let ((closestObject nil))
    (loop for n from 0 to (- (length entlist) 1)
       do (if closestObject
	      (if (< (absDistanceObj *avatar* (eval (elt entlist n)))
		     (absDistanceObj *avatar* (eval closestObject)))
		  (setf closestObject (elt entlist n)))
	      (setf closestObject (elt entlist n))))
    closestObject))




(defun radial ()
  (setf radialMenu 1)
  (setf radial 0))

(defun toy (msg)
  (let ((x 0))
    (lambda (msg) 
      (case msg
	((:inc) (+ x 1))
	((:dec) (- x 1))))))

(defstruct object
  "Objects that can be interacted with and may contain items."
  name     ; e.g. 'drawer
  id       ; array index?
  contents ; item list '(a b c d)
  pos      ; #(x y)
  hitbox
  gfx      ; (sdl:load-image "gfx.png") <- no
  tags     ; e.g. '(container locked)
  use
  dead)     

(defstruct item
  "Items that fit in inventories and can be used."
  name
  id
  gfx
  tags)

(defparameter keycard
  (make-item
   :name 'keycard01
   :id 01
   :gfx '*keycard*
   :tags '()))
(defparameter knife
  (make-item
   :name 'knife
   :id 01
   :gfx '*knife*
   :tags '()))
(defparameter pistol
  (make-item
   :name 'pistol
   :id 01
   :gfx '*pistol*
   :tags '()))
(defparameter laserpointer
  (make-item
   :name 'laserpointer
   :id 01
   :gfx '*laserpointer*
   :tags '()))



(defparameter laatikko
  (make-object
   :name 'drawer
   :id 0001
   :contents '(keycard pistol marble)
   :pos #(500 200)
   :hitbox '(12 12 36 36)
   :gfx '*drawer*
   :tags '(container)
   :use '(openInventory laatikko)))



(defun openInventory (object)
  (let ((foreignInventory (object-contents object)))
	(sdl:with-events (:poll)
	  (:quit-event () t)
	  (:key-down-event (:key key)
			   (case key
			     (:sdl-key-i ())
			     (:sdl-key-q (sdl:push-quit-event))))
	  (:idle ()
		 (sdl:clear-display sdl:*black*)
		 (draw-inventory foreignInventory #(600 200))
		 (draw-inventory (inventory *avatar*) #(200 200))
		 ;(sdl:draw-string-solid-* (format nil "kyl: ~D" (elt foreignInventory 0) 20 20))
		 
		 (sdl:update-display)))))

(defun draw-inventory (itemList pos)
  (defparameter item NIL)
  (let ((x (elt pos 0))
	(y (elt pos 1)))
    (sdl:draw-surface-at *inventoryBare* pos)
    (loop for n from 0 to (1- (length itemList))
	 do (progn (setf item (eval (nth n itemList)))
		   (sdl:draw-surface-at-* (eval (item-gfx item)) 
					  (+ (elt pos 0) (* n 72))
					  200)))))


(defun addObject (objectName)
  (vector-push (slot-value objectName 'name)  objects))

(defun draw-objects ()
  (loop for n from 0 to (1- (length objects))
       do (sdl:draw-surface-at-* (eval (elt (object-gfx (elt objects n)) 0))
			       (- (elt (object-pos (elt objects n)) 0) 24)
			       (- (elt (object-pos (elt objects n)) 1) 24)
			       :cell (elt (object-gfx (eval (elt objects n))) 1))))

    
;------------------------------------------------------------------------------------
; EDITOR: SCREEN SELECTOR

(defun screen-selection ()
  (sdl:with-events (:poll)
    (:quit-event () t)
    (:key-down-event (:key key)
		     (case key
		       (:sdl-key-tab (progn (read-objects)
					    (sdl:push-quit-event))
					    )))
    (:mouse-motion-event (:x mouse-x :y mouse-y)
			 ())
    (:idle ()
	   (sdl:clear-display (sdl:color :r 50 :b 80 :g 0))
	   (if (sdl:mouse-left-p)
	       (progn (editor-select-screen)
		      ;(read-objects)
		      (print *editor-screen*)))
	   (draw-area-indices)
	   (draw-map-info)
	   (draw-active-screen-indicator)
	   (draw-checkboxes)
	   (sdl:draw-surface-at-* *cursor* (- (sdl:mouse-x) 17) 
				           (- (sdl:mouse-y) 17))
	   (sdl:update-display)
	   )))
(defun draw-map-info ()
  (sdl:draw-string-solid-* (format nil "Area: ~D" *editor-area*) 100 600)
  (sdl:draw-string-solid-* (format nil "Screen: ~D" *editor-screen*) 100 630))

(defstruct cell
  "Objects for different map cells for holding values."
  pos
  hitbox
  value
  checkbox)

(defparameter *screen-index-cells* (make-array 100 :adjustable t :fill-pointer 0))
(defparameter worldIndex NIL)

(defun editor-select-screen ()
  (loop for i from 0 to (1- (length *screen-index-cells*))
    do (if (cursor-inside-hitbox (elt *screen-index-cells* i))
	   (setf *editor-screen* (cell-value (elt *screen-index-cells* i))))))

(defun create-screen-index-cells ()
  (let ((x-offset 230)
	(y-offset 150))
    (loop for j from 0 to 9
       do (loop for i from 0 to 9
	     do (vector-push (make-cell 
			      :pos `(,(+ (* i 51) x-offset) ,(+ (* j 39) y-offset))
			      :hitbox '(0 48 0 36)
			      :value (fill-pointer *screen-index-cells*)
			      :checkbox 0)
			     *screen-index-cells*)))))

(defun drawWorldIndex ()
  (let ((x-offset 230)
	(y-offset 150))
    (loop for i from 0 to 500
       do (loop for j from 0 to 380
	     do (if (AND (eq (rem i 51) 0)
			 (eq (rem j 39) 0))
		    (sdl:draw-box-* (+ i x-offset) 
				    (+ j y-offset) 
				    48 36 
				    :color (sdl:color :r 100 :b 100 :g 100) ))))))

(defun tick-checkboxes ()
  "Read all screen files of an area and set checkbox to 1 if they contain objects.
   !!! ONLY DO THIS ONCE !!!"
  (loop for i from 0 to (1- (length *screen-index-cells*))
    do (if (probe-file (map-file 1 i))
	   (let ((file (open (map-file 1 i))))
	     (if (NOT (eq (read file) NIL))
		 (setf (cell-checkbox (elt *screen-index-cells* i)) 1))))))

(defun draw-area-indices ()
    (loop for i from 0 to (1- (length *screen-index-cells*))
      do (sdl:draw-box-* (elt (cell-pos (elt *screen-index-cells* i)) 0)
			 (elt (cell-pos (elt *screen-index-cells* i)) 1)
			 48 36 
			 :color (sdl:color :r 100 :b 100 :g 100) )))

(defun draw-checkboxes ()
  (loop for i from 0 to (1- (length *screen-index-cells*))
    do (if (eq (cell-checkbox (elt *screen-index-cells* i)) 1)
	   (sdl:draw-box-* (+ (elt (cell-pos (elt *screen-index-cells* i)) 0) 18)
			   (+ (elt (cell-pos (elt *screen-index-cells* i)) 1) 12)
			   12 12
			   :color (sdl:color :r 255 :b 0 :g 0)))))

(defun draw-active-screen-indicator ()
  (sdl:draw-box-* (elt (cell-pos (elt *screen-index-cells* *editor-screen*)) 0)
		  (elt (cell-pos (elt *screen-index-cells* *editor-screen*)) 1)
		  48 36
		  :color sdl:*green*))
;------------------------------------------------------------------------------------
; DRAWING THE MAP

(defparameter mapArray (make-array '(20 15) :initial-element NIL))

(defun modify ()
  (let ((x (elt (pos *avatar*) 0))
        (y (elt (pos *avatar*) 1)))
    (setf (aref mapArray x y) (if (aref mapArray x y)
                                  NIL
                                  'river));(tile-id (getTileStruct))))
        )
)



;; Create the cells.
;; Each 'cell' is the x/y width/height of an image in the sprite sheet
(defun createCells ()
  (defparameter *cells* (loop for y from 0 to 144 by 48
			   append (loop for x from 0 to 144 by 48
				     collect (list x y 48 48))))
  (setf (sdl:cells *river*) *cells*))

(defun drawCells ()
;; Assign the cells to the sprite-sheet
  (sdl:draw-surface-at-* *wall* 150 150 :cell 5))

;------------------------------------------------------------------------------------


(defparameter F1 NIL)
(defparameter F2 NIL)
(defparameter F3 NIL)
(defparameter FTC 0)

(defun animate3 ()
  (if (< FTC 3)
      (incf FTC (sdl:dt))
      (setf FTC 0))
  ;(sdl:blit-surface *rock* :src-rect (sdl:rectangle :x 10 :y 10 :w 10 :h 10) sdl:*default-display* #(50 50))
  (sdl:draw-surface-at-* (cond ((AND (>= FTC 0)
				     (< FTC 1))
				(car FrameList))
			       ((AND (>= FTC 1)
				     (< FTC 2))
				(car (cdr FrameList)))
			       ((AND (>= FTC 2)
				     (< FTC 4))
				(car (cddr FrameList))) (t F1))
				
  ; (sdl:draw-surface-at-* F1 50 50))
			 (* 48 13) (* 48 13)))

(defun animate4 ()
  (if (< FTC 3)
      (progn (sdl:draw-surface-at-* (nth (truncate FTC) FrameList)
			 (* 48 13) (* 48 13))
	     (incf FTC (sdl:dt)))
      (setf FTC 0)))


(defvar ELAPSED)
(defvar currState)
(defvar prevState)
(defvar FRAME)

(defvar terrain0)
(setq terrain0 (make-array '(15 20)))

(defvar terrain1)
(defvar terrain2)
(defvar terrain3)
(defvar terrain4)
(setq terrain1 (make-array '(15 20)))
(setq terrain2 (make-array '(15 20)))
(setq terrain3 (make-array '(15 20)))
(setq terrain4 (make-array '(15 20)))

(defvar foo)
(setq foo (make-array '(3 2)))

(defvar bs)
(setf bs 'x)

(defun run ()
  (let ((file (open (concatenate 'string "screen" (write-to-string 
				  (aref world xWorldIndex yWorldIndex)) ".map") 
		    :if-does-not-exist nil)))
    (loop for i from 0 to 14 
       do (loop for j from 0 to 19
	       do
	       (if (string-not-equal (peek-char t file) #\Newline)
		    (progn (setf bs (read-char file))
			   (setf (aref terrain0 i j) bs))
		   (read-char file))))
  (close file)))


(defun runUp ()
  (let ((file (open (concatenate 'string "screen" (write-to-string 
				  (aref world xWorldIndex (- yWorldIndex 1))) ".map") 
		    :if-does-not-exist nil)))
    (loop for i from 0 to 14 
       do (loop for j from 0 to 19
	       do
	       (if (string-not-equal (peek-char t file) #\Newline)
		    (progn (setf bs (read-char file))
			   (setf (aref terrain1 i j) bs))
		   (read-char file))))
  (close file)))


(defun runDown ()
  (let ((file (open (concatenate 'string "screen" (write-to-string 
				  (aref world xWorldIndex (+ yWorldIndex 1))) ".map") 
		    :if-does-not-exist nil)))
    (loop for i from 0 to 14 
       do (loop for j from 0 to 19
	       do
	       (if (string-not-equal (peek-char t file) #\Newline)
		    (progn (setf bs (read-char file))
			   (setf (aref terrain2 i j) bs))
		   (read-char file))))
  (close file)))

(defun runLeft ()
  (let ((file (open (concatenate 'string "screen" (write-to-string 
				  (aref world (- xWorldIndex 1) yWorldIndex)) ".map") 
		    :if-does-not-exist nil)))
    (loop for i from 0 to 14 
       do (loop for j from 0 to 19
	       do
	       (if (string-not-equal (peek-char t file) #\Newline)
		    (progn (setf bs (read-char file))
			   (setf (aref terrain3 i j) bs))
		   (read-char file))))
    (close file)))

(defun runRight ()
  (let ((file (open (concatenate 'string "screen" (write-to-string 
				  (aref world (+ xWorldIndex 1) yWorldIndex)) ".map") 
		    :if-does-not-exist nil)))
    (loop for i from 0 to 14 
       do (loop for j from 0 to 19
	       do
	       (if (string-not-equal (peek-char t file) #\Newline)
		    (progn (setf bs (read-char file))
			   (setf (aref terrain4 i j) bs))
		   (read-char file))))
  (close file)))





(defun drawTerrain ()
  (loop for i from 0 to 14
       do (loop for j from 0 to 19
	       do (sdl:draw-surface-at-* (case (aref terrain0 i j)
					   (#\g (chooseTile3 i j))
					   (#\G *grassLush*)
					   (#\S *slime*)
					   ((#\U5DDD  #\r) *river*)
					   (#\e *rat*)
					   (#\i *road*)
					   (#\o *rock*)
					   (#\D *door*)
					   ;(#\T *tree*)
					   ;(#\T (chooseTile))
		    ;(#\T (cond ((AND (eq #\T (aref terrain (dec-i i) j)) 
		;		    (eq #\T (aref terrain i (dec-j j))) 
		;		    (eq #\T (aref terrain (inc-i i) j))
		;		    (eq #\T (aref terrain i (inc-j j))))
		;		    *tree*)
		;	        (t *treeEdge*)))
		;			   (#\T (chooseTile i j))
					   (#\L *lion*)
					   (#\T (chooseTile2 i j))
					   (#\B *bridge_vert*)
					   (#\W *spiderweb*)
					   (#\H *spider*))
					 (* j 48) (* i 48)))))
(defun scrollTerrain (direction offset)
  (defvar terrainIndex)
  (defvar terrainIndex1 NIL)
  (cond ((string-equal direction "north")
	 (setf terrainIndex terrain1))
	((string-equal direction "south")
	 (setf terrainIndex terrain2))
	((string-equal direction "west")
	 (setf terrainIndex terrain3))
	((string-equal direction "east")
	 (setf terrainIndex terrain4))) 
  (loop for i from 0 to 14
       do (loop for j from 0 to 19
	     do (sdl:draw-surface-at-* (case (aref terrain0 i j)
					 (#\g (chooseTile3 i j))
					 (#\G *grassLush*)
					 (#\S *slime*)
					 ((#\U5DDD  #\r) *river*)
					 (#\e *rat*)
					 (#\i *road*)
					 (#\o *rock*)
					 (#\T (chooseTile2 i j))
					 (#\B *bridge_vert*)
					 (#\W *spiderweb*)
					 (#\H *spider*))
				       (cond ((OR (string-equal direction "north")
						  (string-equal direction "south"))
					      (* j 48))
					     ((string-equal direction "west")
					      (+ (* j 48) offset))
					     ((string-equal direction "east")
					      (+ (* j 48) offset)))
				       (cond ((OR (string-equal direction "west")
						  (string-equal direction "east"))
					      (* i 48))
					     ((string-equal direction "north")
					      (+ (* i 48) offset))
					     ((string-equal direction "south")
					      (+ (* i 48) offset)))
				       
				       )))
  (loop for i from 0 to 14
     do (loop for j from 0 to 19
	   do (sdl:draw-surface-at-* (case (aref terrainIndex i j)
					   (#\g (chooseTile3 i j))
					   (#\G *grassLush*)
					   (#\S *slime*)
					   ((#\U5DDD  #\r) *river*)
					   (#\e *rat*)
					   (#\i *road*)
					   (#\o *rock*)
					   (#\T (chooseTile2 i j))
					   (#\B *bridge_vert*)
					   (#\W *spiderweb*)
					   (#\H *spider*))
					 (cond ((OR (string-equal direction "north")
						    (string-equal direction "south"))
						(* j 48))
					       ((string-equal direction "west")
						(- (+ (* j 48) offset) 960))
					       ((string-equal direction "east")
						(+ (+ (* j 48) offset) 960))
					       (T (* j 48)))
					 (cond ((OR (string-equal direction "west")
						    (string-equal direction "east"))
						(* i 48))
					       ((string-equal direction "north")
						(- (+ (* i 48) offset) 720))
					       ((string-equal direction "south")
						(+ (+ (* i 48) offset) 720)))
					 )
	     )
       )
  )


(defvar bogusbs 0)


(defun ltest ()
  (let ((y 5))
    (lambda (x)
      (incf y x))))

(defun counter-class ()
  (let ((counter 0))
    (lambda () (incf counter))))

(defmacro units (value unit)
  `(sleep
    (* ,value 
     ,(case unit
	    ((s) 1)
	    ((m) 60)
	    ((h) 3600)))))


(defun scrollLoop (direction)
  ;(setf inventory 0)
  (defvar offset 0)
  (defvar x 0)
  (defvar delta 0)
  (defvar gamma 0)
  (sdl:with-events (:poll) 
    (:quit-event () t)
    
   ;(sdl:update-display)
    (:idle ()
   ;(sdl:draw-surface-at-* *status* 0 0)
   ;(sdl:draw-surface-at-* *invSelect* (slot-value *invReticle* 'x)
			  ;(slot-value *invReticle* 'y))
	   (setf gamma (+ gamma delta))
	   (incf delta (sdl:dt))
	   
	   (sdl:clear-display sdl:*black*)
	   (scrollTerrain direction offset)
	   (if (> delta 0.005) 
	       (progn (cond ((string-equal direction "north") 
			     (incf offset 10))
			    ((string-equal direction "south")
			     (decf offset 10))
			    ((string-equal direction "west")
			     (incf offset 10))
			    ((string-equal direction "east")
			     (decf offset 10)))
		      (setf delta 0)))
	   ;(sleep 3)
	   (cond ((AND (string-equal direction "north") 
		       (> offset 720))
		  (progn (setf offset 0)
			 (sdl:push-quit-event)))
		 ((AND (string-equal direction "south")
		       (< offset -720))
		  (progn (setf
			  offset 0)
			 (sdl:push-quit-event)))
		 ((AND (string-equal direction "west")
		       (> offset 960))
		  (progn (setf offset 0)
			 (sdl:push-quit-event)))
		 ((AND (string-equal direction "east")
		       (< offset -960))
		  (progn (setf offset 0)
			 (sdl:push-quit-event))))
	   (sdl:update-display)
	   )
    )

  )
  

(defun chooseTile (i j) 
	(cond ((AND (eq #\T (aref terrain0 (inc-i i) j))
		    (eq #\T (aref terrain0 (dec-i i) j))
		    (eq #\T (aref terrain0 i (inc-j j)))
		    (eq #\T (aref terrain0 i (dec-j j)))
		    (eq #\T (aref terrain0 (inc-i i) (inc-j j)))
		    (eq #\T (aref terrain0 (dec-i i) (inc-j j)))
		    (eq #\T (aref terrain0 (inc-i i) (dec-j j)))
		    (eq #\T (aref terrain0 (dec-i i) (dec-j j))))
	       *treeDeep*)
	      ((AND (eq #\T (aref terrain0 (inc-i i) j))
		    (eq #\T (aref terrain0 (dec-i i) j))
		    (eq #\T (aref terrain0 i (inc-j j)))
		    (eq #\T (aref terrain0 i (dec-j j))))
	       *tree*)
	(T *treeEdge*)
	)
)

(defun chooseTile2 (i j)
  (cond ((AND (checkProximityTree 2 27 #\T i j)
	      (eq (checkProximityTree 1 9 #\T i j) T))
	*treeDeep*)
	((AND (checkProximityTree 1 6 #\T i j)
	      (eq (checkProximityGrass 1 0 #\g i j) NIL))
	*tree*)
	((checkProximityTree 1 1 #\T i j)
	 *treeEdge*)
	(T *treeEdge*))
  )

(defun chooseTile3 (i j)
  (cond ((AND (checkProximityGrass 1 8 #\g i j) 
	      (eq (checkProximityTree 1 1 #\T i j) NIL))
	 *land2*)
	((AND (checkProximityGrass 1 4 #\g i j)
	      (eq (checkProximityTree 1 2 #\T i j) NIL))
	 *grassScarce*)
	((checkProximityGrass 1 1 #\g i j)
	 *land3*)
	(T *land3*))
)

; case matching string (case (find-symbol (string-upcase input) 
;              :keyword) (:foo stuff) (:bar other-stuff))

(defvar counter 0)

(defvar zone)
(setq zone (make-array '(4 4)))

(defvar a 0)
(defvar b 0)
(defvar p 0)
(defvar q 0)

(defun checkProximityTree (radius minimum entity i j)
  (setf counter 0)
  (if (OR (< (- i radius) 0)
	  (> (+ i radius) 14)
	  (< (- j radius) 0)
	  (> (+ j radius) 19))
      ;(progn (setf a 0) (setf b 0))
      (return-from checkProximityTree T)
      (progn (setf a (- i radius)) (setf b (+ i radius))
	     (setf p (- j radius)) (setf q (+ j radius)))
)
      ;(progn (setf a i) (setf b (+ 0 radius)))
      ;(progn (setf a (- i radius)) (setf b (+ 1 radius)))) 
  (loop for y from a to b
	  do (loop for x from p to q
		  do (case (aref terrain0 y x)
		       (#\T (incf counter 1)))
		  )
	  )
  (if (> counter (- minimum 1))
      (return-from checkProximityTree T))
  (return-from checkProximityTree NIL)


)


(defun checkProximityGrass (radius minimum entity i j)
  (setf counter 0)
  (if (OR (< (- i radius) 0)
	  (> (+ i radius) 14)
	  (< (- j radius) 0)
	  (> (+ j radius) 19))
      (progn (setf a 0) (setf b 0))
      (progn (setf a (- i radius)) (setf b (+ i radius))
	     (setf p (- j radius)) (setf q (+ j radius)))
)
      ;(progn (setf a i) (setf b (+ 0 radius)))
      ;(progn (setf a (- i radius)) (setf b (+ 1 radius)))) 
  (loop for y from a to b
	  do (loop for x from p to q
		  do (case (aref terrain0 y x)
		       (#\g (incf counter 1)))
		  )
	  )
  (if (> counter minimum)
      (return-from checkProximityGrass T))
  (return-from checkProximityGrass NIL)


)


(defun inc-i (y)
  (cond ((> 14 y) (incf y 1))
	 (t (setf y 0))))

(defun dec-i (y)
  (cond ((< 0 y) (decf y 1))
	 (t (setf y 14))))


(defun inc-j (x)
  (cond ((> 19 x) (incf x 1))
	 (t (setf x 0))))

(defun dec-j (x)
  (cond ((< 0 x) (decf x 1))
	 (t (setf x 19))))

(defvar screen 1)

(defun checkEdges (direction)
  (defvar counter)
  (cond ((AND (string-equal direction "up") 
	      (eq (slot-value *avatar* 'y) 0.0)) 
	 (return-from checkEdges T))
	((AND (string-equal direction "down")
	      (eq (slot-value *avatar* 'y) 14.0))
	 (return-from checkEdges T))
	((AND (string-equal direction "left")
	      (eq (slot-value *avatar* 'x) 0.0))
	 (return-from checkEdges T))
	((AND (string-equal direction "right")
	      (eq (slot-value *avatar* 'x) 19.0)) 
	 (return-from checkEdges T))
	;(T (print "asdf"))
	)
  )



(defun alusta ()
  (setf (slot-value *avatar* 'x) 13)
  (setf (slot-value *avatar* 'y) 10)
  (setf xWorldIndex 1)
  (setf yWorldIndex 1))

(defun where ()
  (print (slot-value *avatar* 'x))
  (print (slot-value *avatar* 'y))
  (print xWorldIndex)
  (print yWorldIndex)
  T)


(defvar world)
(setq world (make-array '(3 3)))
(defvar xWorldIndex)
(defvar yWorldIndex)
(setf xWorldIndex 1)
(setf yWorldIndex 1)

(defun run2 ()
  (defvar counter 0)
  (loop for i from 0 to 2
       do (loop for j from 0 to 2
	       do (progn (setf (aref world j i) counter)
		   (incf counter))
	       )
       )
  (setf counter 0)
)

(defun scrollScreen (direction)
  (cond ((string-equal direction "up") 
	 (progn (setf screen (aref world xWorldIndex (- yWorldIndex 1)))
		(decf yWorldIndex)
		(scrollLoop "north")))
	((string-equal direction "down") 
	 (progn (setf screen (aref world xWorldIndex (+ yWorldIndex 1)))
		(incf yWorldIndex)
		(scrollLoop "south")))
	((string-equal direction "left") 
	 (progn (setf screen (aref world (- xWorldIndex 1) yWorldIndex))
		(decf xWorldIndex)
		(scrollLoop "west")))
	((string-equal direction "right") 
	 (progn (setf screen (aref world (+ xWorldIndex 1) yWorldIndex))
		(incf xWorldIndex)
		(scrollLoop "east")))
	)
)






(defun move (direction)
  "Move player to direction."
 ;(unless (stringp direction)
  ;  (setq direction (string direction)))
  ;(print direction)
  ;(cond ((string-equal direction "up") ( 

  (cond ((AND (string-equal direction "up") 
	      (eq (checkEdges "up") T)) 
	 (progn (setf (slot-value *avatar* 'y) 14) 
		(scrollScreen "up")
		(return-from move))) ; if player is on edge, go to next screen
	((AND (string-equal direction "up")
	      (eq (elt (pos *avatar*) 0) (elt (pos *enemy*) 0))
	      (eq (1- (elt (pos *avatar*) 1)) (elt (pos *enemy*) 1)))
	 (progn (setf battle 1)
		(return-from move))) 
	((string-equal direction "up") 
	 (progn (unless (obstacles (- (elt (pos *avatar*) 1) 1)
				   (elt (pos *avatar*) 0)) 
		  (decf (elt (pos *avatar*) 1) 1))
		(return-from move)))) ; else, move up
  (cond ((AND (string-equal direction "down") 
	      (eq (checkEdges "down") T))
	 (progn (setf (slot-value *avatar* 'y) 0) 
		(scrollScreen "down"))) ; if player is on edge, go to next screen
	((string-equal direction "down") 
	 (progn (unless (obstacles (+ (elt (pos *avatar*) 1) 1)
				   (elt (pos *avatar*) 0))
		  (incf (elt (pos *avatar*) 1) 1))
		(return-from move)))) 
  (cond ((AND (string-equal direction "left") 
	      (eq (checkEdges "left") T)) 
	 (progn (setf (slot-value *avatar* 'x) 19) 
		(scrollScreen "left"))) ; if player is on edge, go to next screen
	((string-equal direction "left") 
	 (progn (unless (obstacles (elt (pos *avatar*) 1)
				   (- (elt (pos *avatar*) 0) 1))
		  (decf (elt (pos *avatar*) 0) 1))
		(return-from move)))) ; else, move up
  (cond ((AND (string-equal direction "right") 
	      (eq (checkEdges "right") T)) 
	 (progn (setf (slot-value *avatar* 'x) 0) 
		(scrollScreen "right"))) ; if player is on edge, go to next screen
	((string-equal direction "right") 
	 (progn (unless (obstacles (elt (pos *avatar*) 1)
				(+ (elt (pos *avatar*) 0) 1))
		  (incf (elt (pos *avatar*) 0) 1))
		(return-from move)))) ; else, move up
  (setf (elt (pos *avatar*) 0) (slot-value *avatar* 'x))
  (setf (elt (pos *avatar*) 1) (slot-value *avatar* 'y))
)


(defun host (pilipali)
  (print (stringp pilipali))
  (case pilipali
    (#\a (print "yksi"))
    (2 (print "kaksi"))
    )
)

(defun obstacles (i j)
  "Check for obstacles by comparing player position with terrain array.
   -   T: blocked
   - NIL: free to go"
  (if (string-not-equal #\T (aref terrain0 (round i) (round j))) 
      (return-from obstacles NIL))
  (return-from obstacles NIL)
)
  
(setq terrain0 (make-array '(15 20)))

(defun draw-player ()
  ;(sdl:draw-surface-at *player* (map 'vector #'* (pos *avatar*) #(48 48))))
  (sdl:draw-surface-at-* *character* (round (- (x *avatar*) 24))
			          (round (- (y *avatar*) 24))))

(defun board->coord (position)
  (map 'vector #'+ (map 'vector #'* position #(48 48)) #(288 192)))

(defun drawPlayer2 ()
  (sdl:draw-surface-at *player* (board->coord (pos *avatar*)))) 


(defun draw2 ()
  (sdl:draw-surface-at-* FRAME (round (slot-value *avatar* 'x))
			       (round (slot-value *avatar* 'y))))

;(defun (setf x) (x pelaaja)
;  (setf (slot-value pelaaja 'x) pelaaja))


(defun pause ()
  (setf inventory 0)
 (sdl:with-events (:poll) 
  (:quit-event () t)
   (sdl:update-display)
   (:key-down-event (:key key)
		       (format t "Key down: ~S~%" key)
		       (case key
			 (:sdl-key-i (sdl:push-quit-event))
			 (:sdl-key-h (decf (slot-value *invReticle* 'x) 72))
			 (:sdl-key-l (incf (slot-value *invReticle* 'x) 72))
			 (:sdl-key-k (decf (slot-value *invReticle* 'y) 72))
			 (:sdl-key-j (incf (slot-value *invReticle* 'y) 72))))
   (:idle ()
	  (sdl:draw-surface-at-* *status* 0 0)
	  (sdl:draw-surface-at-* *knife* 555 123)
	  (sdl:draw-surface-at-* *invSelect* (slot-value *invReticle* 'x)
				 (slot-value *invReticle* 'y))
	  (sdl:update-display))
))


(defun fuxor (key)
  (if (sdl:key-down-p key)
      "down"))

(defvar scroll 0)

(defvar inventory 0)
(defvar battle 0)

(defparameter *avatar*
  (make-instance 'objekti :name 'pelaaja 
		 :x 480
		 :y 360
		 :pos #(12 8)))


(defparameter *bullet*
    (make-instance 'objekti :name 'bullet :x 0 :y 0))

(defparameter *invReticle*
  (make-instance 'objekti :name 'invReticle :x 547 :y 115)) 


(defparameter *enemy* (make-instance 'objekti :name 'rat
				              :pos #(13 3)
					      :needs #(1 0 0)))
(defun drawEnemies ()
  (sdl:draw-surface-at *rat* (map 'vector #'* (pos *enemy*) #(48 48))))

(defun drawEnemies2 ()
  (sdl:draw-surface-at *rat* (board->coord (pos *enemy*))))
;------------------------------------------------------------------------------------
; PLAYER MOVEMENT


    





;------------------------------------------------------------------------------------
; ENEMY MOVEMENT

(defun move2 (entity direction)
  (case direction
    (1 (setf (pos entity) (map 'vector #'- (pos entity) #(0 1))))
    (2 (setf (pos entity) (map 'vector #'+ (pos entity) #(0 1))))
    (3 (setf (pos entity) (map 'vector #'- (pos entity) #(1 0))))
    (4 (setf (pos entity) (map 'vector #'+ (pos entity) #(1 0))))))


;------------------------------------------------------------------------------------
; AI
; (needs <objectname>) = #(a b c) = #(aggression b c)
(defparameter posB #(6 11))
(defun AI ()
  (setf turn 'player)
  ;(sdl:draw-line 
  ; (map 'vector #'+ (map 'vector #'* (pos *enemy*) #(48 48)) #(24 24))
  ; (map 'vector #'+ (map 'vector #'* posB #(48 48)) #(24 24))
  ; )
					;:color sdl:*red*)
  ;(- posB (pos *enemy*))

  ;(let ((x-diff (- (elt posB 0) (elt (pos *enemy*) 0)))
;	(y-diff (- (elt posB 1) (elt (pos *enemy*) 1)))) 
    ;(if (eq (mod x-diff 2) 0)))
  ;(loop for m from 1 to (- (elt posB 1) (elt (pos *enemy*) 1))
  ;   do (loop for n from 1 to (/ (- (elt posB 0) (elt (pos *enemy*) 0))
;				 (- (elt posB 1) (elt (pos *enemy*) 1)))
;	   do (vector-push 'L byu))
 ;      (vector-push 'D byu))



  ;(drawEnemies)
  ;(sdl:update-display)
  
)

(defun fv ()
  (defparameter VEKTORI (make-array 30 :fill-pointer 0))
  (defparameter VEKTORI2 (make-array 30 :fill-pointer 0))
  (defparameter VEKTORI3 (make-array 30 :fill-pointer 0)))

(defun asdfg ()
  (let ((x-diff 5);(- (elt posB 0) (elt (pos *enemy*) 0)))
	(y-diff 3));(- (elt posB 1) (elt (pos *enemy*) 1))))
    (loop for n from 1 to y-diff
       do (progn (loop for m from 1 to (rem (rem x-diff y-diff) y-diff)
		    do (vector-push 'L VEKTORI))
		 (vector-push 'D VEKTORI))))

    )

(defun center (bposVector)
  (map 'vector #'+ bposVector #(24 24)))

(defun drawPath ()
  ;(defvar VEKTORI2 NIL)
  (defparameter arrowFrom (pos *enemy*))
  (loop for h from 0 to (- (length VEKTORI3) 1)
       do (vector-push (elt VEKTORI3 h) VEKTORI2))
  
  (loop for n from 0 to (- (length VEKTORI2) 1)
       do (progn ;(loop for m from 0 to (- (length vektori2) 1)
		  ;  do (print (format nil "~S" (elt vektori m)))) ;(print (format nil "vektori" vektori))
	    ;(print (format nil "arrowFrom: ~S ~S" (elt arrowFrom 0) (elt arrowFrom 1)))
		 (drawArrow arrowFrom (case (elt (reverse VEKTORI2) 0)
					(U 1)
					(D 2)
					(L 3)
					(R 4)))
		 (setf arrowFrom (case (vector-pop VEKTORI2)
				   (U (map 'vector #'- arrowFrom #(0 1)))
				   (D (map 'vector #'+ arrowFrom #(0 1)))
				   (L (map 'vector #'- arrowFrom #(1 0)))
				   (R (map 'vector #'+ arrowFrom #(1 0)))))
		 )))


(defun drawArrow (position direction)
  (defvar pos2 NIL)
  (case direction
      (1 (setf pos2 (map 'vector #'- position #(0 1))))
      (2 (setf pos2 (map 'vector #'+ position #(0 1))))
      (3 (setf pos2 (map 'vector #'- position #(1 0))))
      (4 (setf pos2 (map 'vector #'+ position #(1 0)))))

  (let ((pos (center (aref battlemap (elt position 0) (elt position 1))))
        (pos3 (center (aref battlemap (elt pos2 0) (elt pos2 1)))))
   ; (sdl:draw-line ;(map 'vector #'+ (map 'vector #'* (pos *enemy*) #(48 48)) #(24 24))
     ;(center (pos *enemy*))
		 ;(map 'vector #'+ (map 'vector #'* (pos *avatar*) #(48 48)) #(24 24))
     ;(center (pos *avatar*))
;		      :color sdl:*green*)
 ;   (sdl:draw-line (center (aref battleMap 0 0)) 
;		   (center (aref battleMap 1 0)))
 ;   (sdl:draw-line (center (aref battleMap 1 0)) 
;		   (center (map 'vector #'- (aref battleMap 1 0) #(10 -10))))
 ;   (sdl:draw-line (center (aref battleMap 1 0)) 
;		   (center (map 'vector #'- (aref battleMap 1 0) #(10 10))))
    (sdl:draw-line pos pos3 :color sdl:*red*)
))

(defun path (entity1 entity2)
  ;(setf vektori nil)
  ;(fv)
  (let ((x-diff (- (elt (pos entity1) 0) (elt (pos entity2) 0)))
	(y-diff (- (elt (pos entity1) 1) (elt (pos entity2) 1))))
    (cond ((eq x-diff 0)
	   (loop for n from 1 to (abs y-diff) 
	      do (vector-push (cond ((< y-diff 0)
				     'U)
				    ((> y-diff 0)
				     'D)) VEKTORI)))
	  ((eq y-diff 0)
	   (loop for n from 1 to (abs x-diff) 
	      do (vector-push (cond ((< x-diff 0)
				     'L)
				    ((> x-diff 0)
				     'R)) VEKTORI)))
	  (t 
	   (progn 
	     (loop for n from 1 to (- (abs y-diff) (rem (abs x-diff) (abs y-diff)))
		do (progn (loop for m from 1 to (truncate (/ (abs x-diff) (abs y-diff)))
			     do (vector-push (cond ((< x-diff 0)
						    'L)
						   ((> x-diff 0)
						    'R))
					     VEKTORI))
			  (vector-push (cond ((< y-diff 0)
					      'U)
					     ((> y-diff 0)
					      'D))
				       VEKTORI)))
	     (loop for h from 1 to (rem (abs x-diff) (abs y-diff))
		do (progn (loop for k from 1 to (+ (truncate (/ (abs x-diff) (abs y-diff))) 1)
			     do (vector-push (cond ((< x-diff 0)
						    'L)
						   ((> x-diff 0)
						    'R))
					     VEKTORI))
			  (vector-push (cond ((< y-diff 0)
					      'U)
					     ((> y-diff 0)
					      'D))
				       VEKTORI)))))))


;    (princ (format nil "A: ~D ~D~%" (elt (pos *enemy*) 0) (elt (pos *enemy*) 1)))
 ;   (princ (format nil "B: ~D ~D~%" (elt (pos *avatar*) 0) (elt (pos *avatar*) 1)))
 ;    (princ (format nil "x-diff: ~S~%" x-diff))
 ; (princ (format nil "y-diff: ~S~%" y-diff))
 ; (princ (format nil "loop1-1 to: ~S~%" (- (abs y-diff) 
;					 (rem (abs x-diff) (abs y-diff)))))
 ; (princ (format nil "loop1-2 to: ~S~%" (truncate (/ x-diff y-diff))))
 ; (princ (format nil "loop2-1 to: ~S~%" (rem (abs x-diff) (abs y-diff))))
 ; (princ (format nil "loop2-2 to: ~S~%" (+ 1 (truncate (abs x-diff) (abs y-diff)))))
 ; (if (AND (OR (eq (count 'R VEKTORI) (abs x-diff))
;	       (eq (count 'L VEKTORI) (abs x-diff)))
;	   (OR (eq (count 'U VEKTORI) (abs y-diff))
;	       (eq (count 'D VEKTORI) (abs y-diff))))
 ;     (print "CORRECT!")
  ;    (print "wrong ,,|,")))
			    ;   ^^^ LOL
  (loop for i from 0 to (- (length VEKTORI) 1)
       do (vector-push (elt (reverse VEKTORI) i) VEKTORI3))
  VEKTORI)

;------------------------------------------------------------------------------------
; EDITOR'S OBJECT SELECTION MENU

(defun draw-object-list ()
  (loop for i from 0 to 0
       do ()))


(defparameter object-menu-filter-buttons (make-array 10 :adjustable t :fill-pointer 0))
(defparameter *brush* nil)
(defparameter *templates* nil)

(defun generate-cell-grid (&key cell-container rows columns cell-width cell-height spacing x-offset y-offset)
  (setf (fill-pointer cell-container) 0)  
  (loop for j from 0 to (1- rows) 
      do (loop for i from 0 to (1- columns)
	   do (vector-push (make-cell          ; CHECK FOR SYNC WITH VISUAL 
			    :pos `(,(+ (* i (+ (1- cell-width) spacing)) x-offset) 
				   ,(+ (* j (+ (1- cell-height) spacing)) y-offset))
			    :hitbox `(0 ,cell-width 0 ,cell-height)
			    :value nil
			    :checkbox 0)
			   cell-container)))
    (vector-push `(,cell-width ,cell-height)
		 cell-container))

(defun draw-cell-grid (cell-container &key r g b)
  (loop for i from 0 to (- (length cell-container) 2)
    do (sdl:draw-box-* (elt (cell-pos (elt cell-container i)) 0)
		       (elt (cell-pos (elt cell-container i)) 1)
		       (1- (elt (elt cell-container (1- (length cell-container))) 0))
		       (1- (elt (elt cell-container (1- (length cell-container))) 1))
		       :color (sdl:color :r r :g g :b b))))

(defun load-objects-from-file ()
  "Load object templates from a file and assign the contents to variable *templates*."
  (let ((file (open (merge-pathnames "object-templates.lisp" *game-root-dir*))))
    (let ((templates (read file)))
      ;(setf (fill-pointer object-menu-cells) 0)
      ;(loop for i from 0 to (- (length templates) 1)
      ;do (setf (cell-value (elt object-menu-cells i))
      ;	 (elt templates i))))
      (setf *templates* templates))
    (close file)))

(defun load-objects-from-file2 ()
  (let ((file (open (merge-pathnames "object-templates.lisp" *game-root-dir*))))
    (setf *templates* (read file))
    (close file)))

(defun load-objects-into-cells ()
  "Load object templates from *templates* into value-properties of object-menu-cells."
  ;(defparameter object-menu-cells (make-array 101 :adjustable t :fill-pointer 0)) 
  ;(setf (fill-pointer object-menu-cells) 0)
  (let ((temp-templates-vector (make-array 100 :adjustable t :fill-pointer 0)))
    (loop for i from 0 to (1- (length *templates*))
       do (if (in-tags i)
	      (vector-push (copy-tree (elt *templates* i))
			   temp-templates-vector)))
    (loop for i from 0 to (1- (length temp-templates-vector))
      do (setf (cell-value (elt object-menu-cells i))
	       (copy-tree (elt temp-templates-vector i))))))

(defun draw-selected-brush-indicator ()
  (if *brush*
      (loop for i from 0 to (- (length object-menu-cells) 2)
	 do (if (equal *brush* (cell-value (elt object-menu-cells i)))
		(sdl:draw-surface-at-* *objectreticle*
				       (- (elt (cell-pos (elt object-menu-cells i)) 0) 3)
				       (- (elt (cell-pos (elt object-menu-cells i)) 1) 3))))))
(defun in-tags (object-index)
  (let ((test-clause nil))
    (loop for i from 0 to (1- (length *filter-tags*))
       do (if (member (elt *filter-tags* i) (elt (elt *templates* object-index) 3))
	      (setf test-clause t)))
    test-clause))

(defun draw-objects-onto-cells ()
  (loop for i from 0 to (- (length object-menu-cells) 2)
    do (if (cell-value (elt object-menu-cells i))
	   (sdl:draw-surface-at-* (eval (elt (elt (cell-value (elt object-menu-cells i)) 2) 0))
				  (elt (cell-pos (elt object-menu-cells i)) 0)
				  (elt (cell-pos (elt object-menu-cells i)) 1)))))

(defun draw-cursor ()
  (sdl:draw-surface-at-* (case *edit-mode*
			   ('add *cursor*)
			   ('remove *cursor2*))
			 (- (sdl:mouse-x) 17) 
			 (- (sdl:mouse-y) 17)))
(defun brush-tags ()
  (elt *brush* 3))

(defparameter *snap-to-grid* 0)

(defun draw-brush ()
  (if (AND *brush*
	   (eq *edit-mode* 'add))
      (let ((brush-x nil)
	    (brush-y nil))
	(if (eq *snap-to-grid* 1)
	    (progn (setf brush-x (+ (* 48 (truncate (sdl:mouse-x) 48)) 0))
		   (setf brush-y (+ (* 48 (truncate (sdl:mouse-y) 48)) 0)))
	    (progn (setf brush-x (- (sdl:mouse-x) 24))
		   (setf brush-y (- (sdl:mouse-y) 24))))

	(sdl:draw-surface-at-* (eval (elt (elt *brush* 2) 0))
			       brush-x
			       brush-y))))

(defun select-brush ()
  (loop for i from 0 to (- (length object-menu-cells) 2)
    do (if (cursor-inside-hitbox (elt object-menu-cells i))
	   (setf *brush* (cell-value (elt object-menu-cells i))))))

(defun select-filter-tags ()
  (loop for i from 0 to (- (length object-menu-filter-buttons) 2)
    do (if (cursor-inside-hitbox (elt object-menu-filter-buttons i))
	   (if (member (cell-value (elt object-menu-filter-buttons i)) *filter-tags*)
	       (setf *filter-tags* (remove (cell-value (elt object-menu-filter-buttons i)) *filter-tags*))
	       (setf *filter-tags* (append *filter-tags* (list (cell-value (elt object-menu-filter-buttons i)))))))))



(defun draw-hitboxes ()
  (loop for i from 0 to (1- (length objects))
    do (sdl:draw-box-* (- (elt (object-pos (elt objects i)) 0)
			  (elt (object-hitbox (elt objects i)) 0))
		       (- (elt (object-pos (elt objects i)) 1)
			  (elt (object-hitbox (elt objects i)) 2))
		       (+ (elt (object-hitbox (elt objects i)) 0)
			  (elt (object-hitbox (elt objects i)) 1))
		       (+ (elt (object-hitbox (elt objects i)) 2)
			  (elt (object-hitbox (elt objects i)) 3))
		       :color (sdl:color :r 0 :g 155 :b 100))))
		       



(defparameter *display-hitboxes* 0)
(defparameter *display-grid* 0)
(defparameter *filter-tags* (list nil))

(defun toggle-hitboxes ()
  (if (eq *display-hitboxes* 0)
      (setf *display-hitboxes* 1)
      (setf *display-hitboxes* 0)))
(defun toggle-grid()
  (if (eq *display-grid* 0)
      (setf *display-grid* 1)
      (setf *display-grid* 0)))
(defun toggle-snap ()
  (if (eq *snap-to-grid* 0)
      (setf *snap-to-grid* 1)
      (setf *snap-to-grid* 0)))

(defun draw-tile-grid ()
  (loop for i from 0 to 19
    do (loop for j from 0 to 14
	 do (sdl:draw-line-* (* i 48) (* j 48)
			     (* i 48) (* j 48)
			     :color (sdl:color :r 200 :g 200 :b 255)))))

(defun draw-filter-button-texts ()
  (let ((color-off (sdl:color :r 115 :g 50 :b 50))
	(color-on (sdl:color :r 100 :g 255 :b 0)))
  (sdl:draw-string-solid-* (format nil "terrain") 
			   (elt (cell-pos (elt object-menu-filter-buttons 0)) 0)
			   (elt (cell-pos (elt object-menu-filter-buttons 0)) 1)
			   :color (if (member 'terrain *filter-tags*)
				      color-on
				      color-off))
  (sdl:draw-string-solid-* (format nil "containers") 
			   (elt (cell-pos (elt object-menu-filter-buttons 1)) 0)
			   (elt (cell-pos (elt object-menu-filter-buttons 1)) 1)
			   :color (if (member 'container *filter-tags*)
				      color-on
				      color-off))
  (sdl:draw-string-solid-* (format nil "enemies") 
			   (elt (cell-pos (elt object-menu-filter-buttons 2)) 0)
			   (elt (cell-pos (elt object-menu-filter-buttons 2)) 1)
			   :color (if (member 'enemy *filter-tags*)
				      color-on
				      color-off))))
(defun set-filter-button-tags ()
  (setf (cell-value (elt object-menu-filter-buttons 0)) 'terrain)
  (setf (cell-value (elt object-menu-filter-buttons 1)) 'container)
  (setf (cell-value (elt object-menu-filter-buttons 2)) 'enemy))

(defun editor-object-select-menu ()
  (defparameter object-menu-cells (make-array 101 :adjustable t :fill-pointer 0))


; bullshit 
(defun drawMapArray ()
  (loop for j from 0 to 14
     do (loop for i from 0 to 19
	   do (if (aref mapArray i j)
		  (sdl:draw-surface-at-* *wall* (* 48 i) (* 48 j)
					 :cell (2b->10b (drawmaparraytile i j)))))))
(defun adjacency (x y)
  
  (loop for i from 0 to (1- (length objects))
     do (let ((checkbyte #*0000))
	  (loop for j from 0 to (1- (length objects))
	     do 
	       (progn (if (AND (eq 'river ; if the object is river...
				   (object-name (elt objects j)))
			       (eq (- y 48)
				   (elt (object-pos (elt objects j)) 1)))
			  (setf checkbyte (bit-ior #*1000 checkbyte)))
		      (if (AND (eq 'river ; if the object is river...
				   (object-name (elt objects j)))
			       (eq (+ y 48)
				   (elt (object-pos (elt objects j)) 1)))
			  (setf checkbyte (bit-ior #*0100 checkbyte))) 
		      (if (AND (eq 'river ; if the object is river...
				   (object-name (elt objects j)))
			       (eq (- x 48)
				   (elt (object-pos (elt objects j)) 0)))
			  (setf checkbyte (bit-ior #*0010 checkbyte)))
		      (if (AND (eq 'river ; if the object is river...
				   (object-name (elt objects j)))
			       (eq (+ x 48)
				   (elt (object-pos (elt objects j)) 0)))
			  (setf checkbyte (bit-ior #*0001 checkbyte)))
		      (setf (elt (object-gfx (elt objects i)) 1)
			    (2b->10b checkbyte)))))))

(defun set-gfx-cell (obj)
  (setf (elt (object-gfx obj) 1)
	(2b->10b (get-checkbyte obj))))
    

(defun get-checkbyte (obj)
  (let ((x (elt (object-pos obj) 0))
	(y (elt (object-pos obj) 1))
	(checkbyte #*0000))
    (loop for j from 0 to (1- (length objects))
       do (if (AND (eq 'river ; if the object is river...
		       (object-name (elt objects j)))
		   (AND (eq (- y 48)
			    (elt (object-pos (elt objects j)) 1))
			(eq x
			    (elt (object-pos (elt objects j)) 0))))
	      (setf checkbyte (bit-ior #*1000 checkbyte)))
	 (if (AND (eq 'river ; if the object is river...
		      (object-name (elt objects j)))
		  (AND (eq (+ y 48)
			   (elt (object-pos (elt objects j)) 1))
		       (eq x
			   (elt (object-pos (elt objects j)) 0))))
	     (setf checkbyte (bit-ior #*0100 checkbyte))) 
	 (if (AND (eq 'river ; if the object is river...
		      (object-name (elt objects j)))
		  (AND (eq (- x 48)
			   (elt (object-pos (elt objects j)) 0))
		       (eq y
			   (elt (object-pos (elt objects j)) 1))))
	     (setf checkbyte (bit-ior #*0010 checkbyte)))
	 (if (AND (eq 'river ; if the object is river...
		      (object-name (elt objects j)))
		  (AND (eq (+ x 48)
			   (elt (object-pos (elt objects j)) 0))
		       (eq y
			   (elt (object-pos (elt objects j)) 1))))
	     (setf checkbyte (bit-ior #*0001 checkbyte))))
    checkbyte))
       

(defun adjacency2 (x y)
  (let ((checkbyte #*0000))
    (loop for i from 0 to (1- (length objects))
      do (if (AND (eq 'river ; if the object is river...
		      (object-name (elt objects j)))
		  (eq (+ (elt (object-pos (elt objects i)) 1) 48)
		      (elt (object-pos (elt objects j)) 0)))
	     (setf checkbyte (bit-ior #*0001 checkbyte))))))



(defun drawMapArrayTile (x y)
  (let ((checkByte #*0000))
    (if (AND (> y 0)
             (string-equal (aref mapArray x (1- y)) 'river))
        (setf checkByte (bit-ior #*1000 checkByte)))
    (if (AND (< y 14)
             (string-equal (aref mapArray x (1+ y)) 'river))
        (setf checkByte (bit-ior #*0100 checkByte)))
    (if (AND (> x 0)
             (string-equal (aref mapArray (1- x) y) 'river))
        (setf checkByte (bit-ior #*0010 checkByte)))
    (if (AND (< x 19)
             (string-equal (aref mapArray (1+ x) y) 'river));
        (setf checkByte (bit-ior #*0001 checkByte)))
    checkByte))

(defun 2b->10b (vect)
  (reduce (let ((e 1)) (lambda (accum bit)
                        (prog1 (+ accum (* e bit))
                               (setf e (* e 2)))))
          (reverse vect) :initial-value 0))

 (generate-cell-grid :cell-container object-menu-filter-buttons
		     :rows 3
		     :columns 1
		     :cell-width 185
		     :cell-height 48
		     :spacing 5
		     :x-offset 10
		     :y-offset 100)
 (load-objects-from-file2)
 (set-filter-button-tags)
 (sdl:with-events (:poll)
    (:quit-event () t)
    (:key-down-event (:key key)
		     (format t "Key down: ~S~%" key)
		     (case key
		       (:sdl-key-space (sdl:push-quit-event))))
    (:mouse-motion-event (:x mouse-x :y mouse-y))
    (:idle ()
	   (defparameter object-menu-cells (make-array 101 :adjustable t :fill-pointer 0))
	   (generate-cell-grid :cell-container object-menu-cells
		     :rows 10
		     :columns 10
		     :cell-width 48
		     :cell-height 48
		     :spacing 5
		     :x-offset 200
		     :y-offset 100)
	   (load-objects-into-cells)
	   (sdl:clear-display sdl:*black*)
	   (if (AND *brush*
		    (member 'terrain (brush-tags)))
	       (setf *snap-to-grid* 1)
	       (setf *snap-to-grid* 0))
	   (draw-cell-grid object-menu-cells :r 50 :g 50 :b 90)
	   (draw-cell-grid object-menu-filter-buttons :r 80 :g 50 :b 50)
	   (draw-filter-button-texts)
	   (draw-objects-onto-cells)
	   (draw-selected-brush-indicator)
	   (draw-cursor)
	   (if (AND (sdl:mouse-left-p)
		    (> CTC 0.1))
	       (progn (setf CTC 0)
		      (select-filter-tags)
		      (select-brush))
	       (incf CTC (sdl:dt)))
	   (sdl:update-display))))

;------------------------------------------------------------------------------------
; 


(defparameter mousex NIL)
(defparameter mousey NIL)
(defparameter mouse #(0 0))

(defmacro gfx-object (var-name graphics-file alpha)
  `(defparameter ,var-name (sdl-image:load-image ,(merge-pathnames 
						   (string-downcase graphics-file)
						   (merge-pathnames "gfx/"
								    *game-root-dir*))
						 :alpha ,alpha)))
(defparameter radial 0)
(defparameter radialMenu 0)

(defparameter *sword-tip* `(,(elt (pos *avatar*) 0)
			    ,(+ (elt (pos *avatar*) 1) 24)))
(defparameter *sword-motion* 'retracted)


(defun check-sword-collisions ()
  (for-all-objects (if (sword-inside-hitbox object)
		       (bump object))))

(defun bump (obj)
  (decf (elt (object-pos obj) 0) 20))


(defun swing-sword (&optional (a 0))
    (let ((alpha (/ pi 2))
	  (time 0))
      (lambda (a)
	(if (eq a 1)
	    (setf alpha 0))
	(symbol-macrolet ((x (elt *sword-tip* 0))
			  (y (elt *sword-tip* 1)))
	  
	  (if (eq *sword-motion* 'swinging)
	      (progn (setf x (+ (x *avatar*) (* 50 (cos alpha))))
		     (setf y (+ (y *avatar*) (* 50 (sin alpha))))
		     (if (> alpha (- 0 (* (/ pi 2) 3)))
			 (decf alpha (/ pi 16))
			 (progn (setf *sword-motion* 'retracted)
				(setf alpha 0))
			 )))))
      ))

(defparameter vittu (swing-sword))

(defun visualize-sword-swing ()
  (sdl:draw-line-* (round (elt (pos *avatar*) 0)) (round (elt (pos *avatar*) 1))
		   (round (elt *sword-tip* 0)) (round (elt *sword-tip* 1))
		   :color sdl:*red*))

(defun joop ()
  (let ((alpha 0))
    (lambda ()
      (incf alpha))
    ))

;------------------------------------------------------------------------------------
; MAIN LOOP

(defun test2 ()
  (create-screen-index-cells)
  (sdl:with-init ()
    (sdl:window 960 720 :title-caption "rogue")
    (setf ELAPSED 0) 
    (setf prevState 'idle)
    (setf currState 'idle)
    (setf FRAME 1)
    (setf cl-opengl-bindings:*gl-get-proc-address* #'sdl-cffi::sdl-gl-get-proc-address)

    (load (merge-pathnames "gfx.lisp" *game-root-dir*))
    (load (merge-pathnames "physics.lisp" *game-root-dir*))
    (load (merge-pathnames "battle.lisp" *game-root-dir*))
    
    (createCells)
    (tick-checkboxes)

    (setf (sdl:frame-rate) 60)
    (sdl-cffi::SDL-Show-Cursor sdl-cffi::sdl-disable)
    (sdl:with-events (:poll)
;;      (enable-key-repeat 1 0.5)
      (:quit-event () t)
      (setf prevState currState)
      (:key-down-event (:key key)
		       (format t "Key down: ~S~%" key)
		       (case key ; UP
			 (:sdl-key-i (if (keyDown :sdl-key-a)
					 (progn (setf radial 1)
						(setf radialMenu 1))
					 (setf (y_v *avatar*) -75)))
			 (:sdl-key-k (if (keyDown :sdl-key-a)
					 (progn (setf radial 2)
						(setf radialMenu 1))
					 (setf (y_v *avatar*) 75)))
			 (:sdl-key-j (if (keyDown :sdl-key-a)
					 (progn (setf radial 3)
						(setf radialMenu 1))
					 (setf (x_v *avatar*) -75)))
			 (:sdl-key-l (if (keyDown :sdl-key-a)
					 (progn (setf radial 4)
						(setf radialMenu 1))
					 (setf (x_v *avatar*) 75)))
			 (:sdl-key-h (toggle-hitboxes))
			 (:sdl-key-g (toggle-grid))
			 (:sdl-key-s (toggle-snap))
			 (:sdl-key-escape (sdl:push-quit-event))
			 (:sdl-key-space (editor-object-select-menu))
			 (:sdl-key-y (setf inventory 1))
			 (:sdl-key-q (radial))
			 (:sdl-key-r (setf *edit-mode* 'remove))
			 (:sdl-key-a (setf *edit-mode* 'add))
			 (:sdl-key-z (progn (setf *sword-motion* 'swinging)
					     (funcall vittu 1)))
			 (:sdl-key-tab (progn (write-objects)
					      (screen-selection)))))
      (:key-up-event (:key key)
		     (format t "Key up: ~S~%" key)
		     (case key
		       (:sdl-key-a (progn (setf radialMenu 0)
					  (execute (case radial
						     (0 'cancel)
						     (1 'inspect)
						     (2 'none)
						     (3 'interact)))))))
      (:MOUSE-MOTION-EVENT (:X mouse-x :Y mouse-y)
			   (sdl:clear-display sdl:*white*)
			   (sdl:draw-surface-at-* *cursor* 100 100)
			   (setf (elt mouse 0) mouse-x)
			   (setf (elt mouse 1) mouse-y))
			 
      (:idle ()

      (sdl:clear-display (sdl:color :r 20 :g 40 :b 120))

      (if (NOT (keyDown :sdl-key-z))
	  (progn (setf (elt *sword-tip* 0)
		       (x *avatar*))
		 (setf (elt *sword-tip* 1)
		       (- (y *avatar*) 50))))
      (if (keyDown :sdl-key-z)
	  (funcall vittu 0))
;      (run)
 ;     (if (< 0 yWorldIndex)
;	  (runUp))
 ;     (if (> 2 yWorldIndex)
;	  (runDown))
 ;     (if (< 0 xWorldIndex)
;	  (runLeft))
 ;     (if (> 2 xWorldIndex)
;	  (runRight))
	   
      ;(drawTerrain)
      ;(if (eq scroll 1)
	;  (progn (scrollLoop "north") (setf scroll 0))
	;  )
      (cond ((eq (+ (slot-value *avatar* 'x_v) (slot-value *avatar* 'y_v)) 0)
	     (setf (slot-value *avatar* 'state) 'idle))
	    (t (setf (slot-value *avatar* 'state) 'walking)))
      (cond ((eq (slot-value *avatar* 'state) 'walking)
	     (setf currState 'walking))
	    (t (setf currState 'idle)))
      (cond ((eq currState 'walking)
	     (setf ELAPSED (+ ELAPSED (sdl:dt))))
	     (t (setf ELAPSED 0)))
      ;(print (round ELAPSED))
      ;(animatePlayer)
	  ;(pause))
      ;(sdl:draw-surface-at-* *drawer* (* 12 48) (* 10 48))
      (physics *avatar*) 
     ; (drawEnemies)
      
      ;(drawCells)
      ;(drawMapArray)
      (if (eq radialMenu 1)
	  (progn (drawRadialMenu radial)
		 ()))
      ;(drawReticle radial)
      (animate4)
      (remove-dead-objects objects)
;      (if (eq inventory 1)
;	     (sdl:draw-surface-at-* *status* 0 0))
      ;(print (* 1.0 (sdl:dt)))
      ;(print (* 1.0 FTC))
      (if (eq inventory 1)
	  (pause))
      (if (eq battle 1)
	  (battle))
      (if (AND (sdl:mouse-left-p)
	       (> CTC 0.1))
	  (progn (setf CTC 0)
		 (modify3)
		 (sdl:draw-box-* (* 48 (truncate (sdl:mouse-x) 48))
				 (* 48 (truncate (sdl:mouse-y) 48))
				 48 48
				 :color sdl:*red*))
	  (incf CTC (sdl:dt)))
      (draw-objects)
      (if (eq *display-hitboxes* 1)
	  (draw-hitboxes))
      (if (eq *display-grid* 1)
	  (draw-tile-grid))
      (check-sword-collisions)
      (draw-player)
      (draw-brush)
      (visualize-sword-swing)
      (loop for i from 0 to (1- (length objects))
	   do (if (eq 'river
		      (object-name (elt objects i)))
		  (set-gfx-cell (elt objects i))))
	  ; (setf (elt (object-gfx (elt objects i)) 1)
	;	 (2b->10b (get-checkbyte (elt objects i)))))
      ;(if (> (length objects) 0)
;	  (set-gfx-cell (elt objects 0)))
		   
		      ;(2b->10b (get-checkbyte (elt objects i)))))
      (draw-cursor)
      ;(sdl:draw-surface-at-* *cursor* (- (sdl:mouse-x) 17) 
;			              (- (sdl:mouse-y) 17))
      (cond ((OR (eq ELAPSED 2.5) (> ELAPSED 2.5))
	     (setf ELAPSED 0)))
      (sdl:draw-string-solid-* (format nil "~D" (x_v *avatar*)) 10 10)
      (sdl:draw-string-solid-* (format nil "~D" (y_v *avatar*)) 10 40)
       ;; Redraw the display
       (sdl:update-display)
;       (if (eq inventory 1)
;	   (progn (setf inventory 0) (pause)))
)))


)
