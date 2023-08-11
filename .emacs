(require 'package)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wheatgrass))
 '(haskell-indentation-layout-offset 4)
 '(haskell-indentation-left-offset 4)
 '(haskell-indentation-starter-offset 4)
 '(haskell-indentation-where-post-offset 4)
 '(haskell-indentation-where-pre-offset 4)
 '(haskell-process-auto-import-loaded-modules t)
 '(haskell-process-log t)
 '(haskell-process-suggest-remove-import-lines t)
 '(package-archives
   '(("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "http://stable.melpa.org/packages/")))
 '(package-selected-packages
   '(utop req-package use-package speed-type lsp-mode docker docker-cli docker-compose-mode rustic flycheck-rust cargo typit haskell-snippets flymake-haskell-multi proof-general company-coq python-mode graphviz-dot-mode go-mode protobuf-mode cmake-mode dockerfile-mode flycheck-ocaml caml yaml-mode function-args jinja2-mode markdown-mode ghc haskell-mode yasnippet-classic-snippets yasnippet auctex)))

;; Mirror shell's path
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$" "" (shell-command-to-string
					  "$SHELL --login -c 'echo $PATH'"
						    ))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;;Steve Yegge's suggestions


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
;lose the UI
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(autoload 'gfm-mode "markdown-mode"
   "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

;;RDman's scroll other window
;;procedures for scrolling 1 line at a time for the other window
(defun scroll-other-window-n-lines-ahead (&optional n)
  "Scroll ahead N lines (1 by default) in the other window"
  (interactive "P")
  (scroll-other-window (prefix-numeric-value n)))

(defun scroll-other-window-n-lines-behind (&optional n)
  "Scroll behind N lines (1 by default) in the other window"
  (interactive "P")
  (scroll-other-window (- (prefix-numeric-value n))))

(global-set-key "\C-\M-a" 'scroll-other-window-n-lines-behind)
(global-set-key "\C-\M-q" 'scroll-other-window-n-lines-ahead)

;scrolling functions for scrolling one line at a time (WGE Chapter 2)
(defalias 'scroll-ahead 'scroll-up)
(defalias 'scroll-behind 'scroll-down)

(defun scroll-n-lines-ahead (&optional n)
  "scroll ahead n lines"
(interactive "P")
(scroll-ahead (prefix-numeric-value n)))

(defun scroll-n-lines-behind (&optional n)
  "scroll ahead n lines"
(interactive "P")
(scroll-behind (prefix-numeric-value n)))

(defun scroll-n-lines-left (&optional n)
  "scroll left n lines"
(interactive "P")
(scroll-left (prefix-numeric-value n)))

(defun scroll-n-lines-right (&optional n)
  "scroll left n lines"
(interactive "P")
(scroll-right (prefix-numeric-value n)))

(global-set-key "\C-z" 'scroll-n-lines-behind)
(global-set-key "\C-q" 'scroll-n-lines-ahead)
(global-set-key "\C-\M-a" 'scroll-n-lines-left)
(global-set-key "\C-\M-s" 'scroll-n-lines-right)
(global-set-key "\C-c\C-q" 'quoted-insert)

;defining desired behaviour when opening a symlink file(WGE Chapter 2)
(add-hook 'find-file-hooks
	    (lambda ()
	          (if (file-symlink-p buffer-file-name)
		      (progn
			  (setq buffer-read-only t)
			    (message "File is a symlink")))))

(defun visit-target-instead ()
  "Replace this buffer with a buffer visiting the link target"
  (interactive)
  (if buffer-file-name
      (let ((target (file-symlink-p buffer-file-name)))
	(if target
	        (find-alternate-file target)
	    (error "Not visiting a symlink")))
    (error "Not visiting a file")))

(defun clobber-symlink ()
  "Replace symlink with a copy of the file"
  (interactive)
  (if buffer-file-name
      (let ((target (file-symlink-p buffer-file-name)))
	(if target
	        (if (yes-or-no-p (format "Replace %s with %s?" buffer-file-name target))
		    (progn
		        (delete-file buffer-file-name)
			  (write-file buffer-file-name)))
	    (error "Not visiting a symlink")))
    (error "Not visiting a file")))

;undoing scrolling (WGE Chapter 3)
(defvar unscroll-point nil
  "Cursor position for next call to 'unscroll'.")
(defvar unscroll-window-start nil
  "Window start for next call to 'unscroll'.")

(defadvice scroll-up (before remember-for-unscroll
			          activate compile)
  "Remember where we started from, for 'unscroll'."
(if (not (eq last-command 'scroll-up))
    (progn
      (setq unscroll-point (point))
      (setq unscroll-window-start (window-start)))))
(defun unscroll ()
  "Jump to the position specified by 'unscroll-to'."
  (interactive)
  (if (and (not unscroll-point) (not unscroll-window-start))
      (error "cannot unscroll yet"))
  (progn
    (goto-char unscroll-point)
    (set-window-start nil unscroll-window-start)))

;;replace tabs with spaces
(setq-default indent-tabs-mode nil)



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 200 :width normal)))))

(fset 'rahul-open-next-link
   "\C-n\C-c\C-o")

;;count words
;;; Final version: while
(defun count-words-region (beginning end)
  "Print number of words in the region."
  (interactive "r")
  (message "Counting words in region ... ")

;;; 1. Set up appropriate conditions.
  (save-excursion
    (let ((count 0))
      (goto-char beginning)

;;; 2. Run the while loop.
      (while (and (< (point) end)
                  (re-search-forward "\\w+\\W*" end t))
        (setq count (1+ count)))

;;; 3. Send a message to the user.
      (cond ((zerop count)
             (message
              "The region does NOT have any words."))
            ((= 1 count)
             (message
              "The region has 1 word."))
            (t
             (message
              "The region has %d words." count))))))

(global-set-key "\C-cw" 'count-words-region)

(global-set-key "\C-xj" 'join-lines)

(setq ispell-program-name "aspell") ; could be ispell as well, depending on your preferences
(setq ispell-dictionary "english") ; this can obviously be set to any language your spell-checking program supports

(defun turn-on-outline-minor-mode ()
  (outline-minor-mode 1))
(add-hook 'LaTeX-mode-hook #'outline-minor-mode)
(global-unset-key "\C-o")
(setq outline-minor-mode-prefix "\C-o")

(global-auto-revert-mode t)

;; Google C++ style guide
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; Proof General
(require 'package)
;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3") ; see remark below
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Haskell interactive
(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
(define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
(define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
(define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
(define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
(define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
(define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)

;; Common Lisp (SBCL)
(load (expand-file-name "~/quicklisp/slime-helper.el"))
;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "/usr/local/bin/sbcl")

;; OCamlFormat
(add-to-list 'load-path "/Users/saurabhjha/.opam/4.13.1/share/emacs/site-lisp")
(require 'ocp-indent)
(require 'ocamlformat)
