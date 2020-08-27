;;; init.el --- IdiotPro's highly inspired Emacs init


(defvar file-name-handler-alist-original file-name-handler-alist)

(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      file-name-handler-alist-original file-name-handler-alist
      file-name-handler-alist nil
      site-run-file nil)


(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 20000000
                  gc-cons-percentage 0.1
                  file-name-handler-alist file-name-handler-alist-original)
            (makunbound 'file-name-handler-alist-original)))


(add-hook 'minibuffer-setup-hook (lambda () (setq gc-cons-threshold 40000000)))
(add-hook 'minibuffer-exit-hook (lambda ()
                                  (garbage-collect)
                                  (setq gc-cons-threshold 20000000)))

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)


(setq custom-file "~/.emacs.d/to-be-dumped.el") ; custom generated, don't load

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t))


(setq user-full-name "IdiotPro"
      frame-title-format '("Emacs")
      ring-bell-function 'ignore
      default-directory "~/"
      mouse-highlight nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode +1)
(column-number-mode +1)
(setq scroll-margin 0
      scroll-conservatively 10000
      scroll-preserve-screen-position t
      auto-window-vscroll nil)
(setq-default line-spacing 3
              indent-tabs-mode nil
              tab-width 4)

(defun jb/load-init()
  "Reload `.emacs.d/init.el'."
  (interactive)
  (load-file "~/.emacs.d/init.el"))

(defun jb/hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))


(use-package "startup"
  :ensure nil
  :config (setq inhibit-startup-screen t))

(use-package "window"
  :ensure nil
  :config
  (defun jb/split-and-follow-horizontally ()
    "Split window below."
    (interactive)
    (split-window-below)
    (other-window 1))
  (defun jb/split-and-follow-vertically ()
    "Split window right."
    (interactive)
    (split-window-right)
    (other-window 1))
  (global-set-key (kbd "C-x 2") 'jb/split-and-follow-horizontally)
  (global-set-key (kbd "C-x 3") 'jb/split-and-follow-vertically))


;;deletion after char insertion
(use-package delsel
  :ensure nil
  :config (delete-selection-mode +1))


(use-package files
  :ensure nil
  :config
  (setq confirm-kill-processes nil
        make-backup-files nil))


;; like unix mode tail -f filepack
;; (use-package autorevert
;;   :ensure nil
;;   :hook (after-init . global-auto-revert-mode)
;;   :config
;;   (setq auto-revert-interval 2
;;         auto-revert-check-vc-info t
;;         auto-revert-verbose nil))


(use-package eldoc
  :ensure nil
  :diminish eldoc-mode
  :config
  (global-eldoc-mode -1)
  (add-hook 'prog-mode-hook 'eldoc-mode)
  (setq eldoc-idle-delay 0.4))


(use-package xref
  :ensure nil
  :config
  (define-key prog-mode-map (kbd "s-b") 'xref-find-definitions)
  (define-key prog-mode-map (kbd "s-[") 'xref-pop-marker-stack))


(use-package cc-vars
  :ensure nil
  :config
  (setq-default c-basic-offset 4)
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r"))))



(use-package mwheel
  :ensure nil
  :config (setq mouse-wheel-scroll-amount '(5 ((shift) . 1))
                mouse-wheel-progressive-speed nil))



(use-package paren
  :ensure nil
  :config
  (setq show-paren-delay 0)
  (show-paren-mode))

(use-package ediff
  :ensure nil
  :config (setq ediff-split-window-function 'split-window-horizontally))


;; (use-package flyspell
;;    :ensure nil
;;    :hook (prog-mode . flyspell-prog-mode))

(use-package elec-pair
  :ensure nil
  :config (add-hook 'prog-mode-hook 'electric-pair-mode))

(use-package whitespace
  :ensure nil
  :config (add-hook 'before-save-hook 'whitespace-cleanup))


(use-package doom-themes :config (load-theme 'doom-tomorrow-night t))
;; (use-package zenburn-theme :config (load-theme 'zenburn t))

(use-package solaire-mode
  :hook (((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
         (minibuffer-setup . solaire-mode-in-minibuffer))
  :config
  (solaire-global-mode)
  (solaire-mode-swap-bg))

(use-package diminish :demand t)

(use-package evil
  :diminish undo-tree-mode
  :init (setq evil-want-C-u-scroll t)
  :hook (after-init . evil-mode)
  :config
  (with-eval-after-load 'evil-maps ; avoid conflict with company tooltip selection
    (define-key evil-insert-state-map (kbd "C-n") nil)
    (define-key evil-insert-state-map (kbd "C-n") nil)
    (define-key evil-insert-state-map (kbd "C-p") nil))
  (evil-set-initial-state 'term-mode 'emacs)
  (defun jb/save-and-kill-this-buffer ()
    (interactive)
    (save-buffer)
    (kill-this-buffer))
  (evil-ex-define-cmd "q" 'kill-this-buffer)
  (evil-ex-define-cmd "wq" 'jb/save-and-kill-this-buffer)
  (use-package evil-commentary
    :after evil
    :diminish evil-commentary-mode
    :config (evil-commentary-mode)))

(global-linum-mode 1)

;;evil mode overrides
;; (define-key evil-normal-state-map "\C-e" 'evil-end-of-line)
;; (define-key evil-insert-state-map "\C-e" 'end-of-line)
;; (define-key evil-visual-state-map "\C-e" 'evil-end-of-line)
;; (define-key evil-motion-state-map "\C-e" 'evil-end-of-line)
;; (define-key evil-normal-state-map "\C-a" 'evil-beginning-of-line)
;; (define-key evil-insert-state-map "\C-a" 'beginning-of-line)
;; (define-key evil-visual-state-map "\C-a" 'evil-beginning-of-line)
;; (define-key evil-motion-state-map "\C-a" 'evil-beginning-of-line)
;; (define-key evil-normal-state-map "\C-n" 'evil-next-line)
;; (define-key evil-insert-state-map "\C-n" 'evil-next-line)
;; (define-key evil-visual-state-map "\C-n" 'evil-next-line)
;; (define-key evil-normal-state-map "\C-p" 'evil-previous-line)
;; (define-key evil-insert-state-map "\C-p" 'evil-previous-line)
;; (define-key evil-visual-state-map "\C-p" 'evil-previous-line)
;; (define-key evil-normal-state-map "\C-w" 'evil-delete)
;; (define-key evil-insert-state-map "\C-w" 'evil-delete)
;; (define-key evil-visual-state-map "\C-w" 'evil-delete)
;; (define-key evil-normal-state-map "\C-y" 'yank)
;; (define-key evil-insert-state-map "\C-y" 'yank)
;; (define-key evil-visual-state-map "\C-y" 'yank)
;; (define-key evil-normal-state-map "\C-k" 'kill-line)
;; (define-key evil-insert-state-map "\C-k" 'kill-line)
;; (define-key evil-visual-state-map "\C-k" 'kill-line)



(use-package company
  :diminish company-mode
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0
        company-selection-wrap-around t
        company-tooltip-align-annotations t
        company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
                            company-echo-metadata-frontend))
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "C-n") 'company-select-next)
    (define-key company-active-map (kbd "C-p") 'company-select-previous)))


(use-package ido-vertical-mode
  :hook ((after-init . ido-mode)
         (after-init . ido-vertical-mode))
  :config
  (setq
   ;; ido-everywhere t
        ido-enable-flex-matching t
        ido-vertical-define-keys 'C-n-C-p-up-and-down))

(use-package flx-ido :config (flx-ido-mode))

(use-package magit :bind ("C-x g" . magit-status))

(use-package ranger
  :defer t
  :config (setq ranger-width-preview 0.5))


(use-package which-key
  :diminish which-key-mode
  :defer 1
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.4
        which-key-idle-secondary-delay 0.4))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo
        dashboard-banner-logo-title "Dangerously powerful"
        dashboard-items nil
        dashboard-set-footer nil))

(use-package markdown-mode :hook (markdown-mode . visual-line-mode))


;; (use-package format-all
;;   :config
;;   (defun jb/format-code ()
;;     "Auto-format whole buffer"
;;     (interactive)
;;     (format-all-buffer)))


(use-package treemacs
  :after evil
  :config
  (global-set-key (kbd "s-1") 'treemacs)
  (setq treemacs-fringe-indicator-mode nil
        treemacs-no-png-images t
        treemacs-width 40
        treemacs-silent-refresh t
        treemacs-silent-filewatch t
        treemacs-file-event-delay 1000
        treemacs-file-follow-delay 0.1)
  (dolist (face '(treemacs-root-face
                  treemacs-git-unmodified-face
                  treemacs-git-modified-face
                  treemacs-git-renamed-face
                  treemacs-git-ignored-face
                  treemacs-git-untracked-face
                  treemacs-git-added-face
                  treemacs-git-conflict-face
                  treemacs-directory-face
                  treemacs-directory-collapsed-face
                  treemacs-file-face
                  treemacs-tags-face))
    (set-face-attribute face nil :family "San Francisco" :height 130))
  ;; (use-package treemacs-evil
  ;;   :after treemacs
  ;;   :config
  ;;   (evil-define-key 'treemacs treemacs-mode-map (kbd "l") 'treemacs-RET-action)
  ;;   (evil-define-key 'treemacs treemacs-mode-map (kbd "h") 'treemacs-TAB-action))
  (use-package treemacs-projectile :after treemacs projectile)
  (use-package treemacs-magit :after treemacs magit))

;;(define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)

(use-package all-the-icons :config (setq all-the-icons-scale-factor 1.0))

(use-package centaur-tabs
  :demand
  :init (setq centaur-tabs-set-bar 'over)
  :config
  (centaur-tabs-mode)
  (centaur-tabs-headline-match)
  (setq centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker " ● "
        centaur-tabs-cycle-scope 'tabs
        centaur-tabs-height 30
        centaur-tabs-set-icons t
        centaur-tabs-close-button " × ")
  (dolist (centaur-face '(centaur-tabs-selected
                          centaur-tabs-selected-modified
                          centaur-tabs-unselected
                          centaur-tabs-unselected-modified))
    (set-face-attribute centaur-face nil :family "Arial" :height 130))
  :bind
  ("C-S-<tab>" . centaur-tabs-backward)
  ("C-<tab>" . centaur-tabs-forward))

(use-package projectile
  :diminish projectile-mode
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "s-f") 'projectile-find-file)
  (define-key projectile-mode-map (kbd "s-F") 'projectile-grep)
  (setq projectile-sort-order 'recentf
        projectile-indexing-method 'hybrid)
  (projectile-mode +1))


 ;;Scheme related configurations

(defun my-pretty-lambda ()
  "Show lambda as unicode."
  (setq prettify-symbols-alist
        '(("lambda" . 955))))

;;Scheme
(add-hook 'scheme-mode-hook 'my-pretty-lambda)
(global-prettify-symbols-mode 1)
(setenv "MITSCHEME_LIBRARY_PATH"
        "/usr/local/schemeResources")

;;
;; (setq slime-lisp-implementations
;;        '((mit-scheme ("scheme") :init mit-scheme-init)))

;; (defun mit-scheme-init (file encoding)
;;   "Init MIT Scheme"
;;   (format "%S\n\n"
;;           `(begin
;;             (load-option 'format)
;;             (load-option 'sos)
;;             (eval '(create-package-from-description
;;                     (make-package-description '(swank) (list (list))
;;                                               (vector) (vector) (vector) false))
;;                   (->environment '(package)))
;;             (load ,(expand-file-name
;;                     "~/.emacs.d/swank-mit-scheme.scm" ; <-- insert your path
;;                     slime-path)
;;                   (->environment '(swank)))
;;             (eval '(start-swank ,file) (->environment '(swank))))))

;; (defun mit-scheme ()
;;   (interactive)
;;   (slime 'mit-scheme))

;; (defun find-mit-scheme-package ()
;;   (save-excursion
;;     (let ((case-fold-search t))
;;       (and (re-search-backward "^[;]+ package: \\((.+)\\).*$" nil t)
;;            (match-string-no-properties 1)))))


;; (setq slime-find-buffer-package-function 'find-mit-scheme-package)
;; (add-hook 'scheme-mode-hook (lambda () (slime-mode 1)))
;; (setq slime-contribs '(slime-fancy))
;; ;; scheme
;; (setf geiser-active-implementations '(mit-scheme))
;; ;; (global-set-key (kbd
;; ;;                 "<f10>") 'run-mit)
;; (setq scheme-program-name "mit-scheme")


;;ORG Mode

(setq org-agenda-files '("~/org"))

(global-set-key (kbd "C-c C-a") 'org-agenda)

(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(global-set-key (kbd "M-p") 'org-metaup)
(global-set-key (kbd "M-n") 'org-metadown)
(global-set-key (kbd "M-b") 'org-do-promote)
(global-set-key (kbd "M-f") 'org-do-demote)
(global-set-key (kbd "M-s RET") 'org-insert-todo-heading)

;;enable speed comands (Press ? at start of line)
(setq org-use-speed-commands 1)

(setq org-todo-keywords '((sequence "TODO" "INPRO"  "|" "DONE")))



;; ;;ensime
(require 'scala-mode)
(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))
(add-to-list 'load-path "~/.emacs.d/scala/ensime/elisp/")
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
(setq ensime-startup-notification 'nil)
(use-package ensime
  :ensure t)

(setq exec-path (append exec-path '("/usr/local/bin")))
(setq exec-path (append exec-path '("/usr/local/opt/scala@2.11/bin")))
(setenv "PATH" (shell-command-to-string "/bin/bash -c 'echo -n $PATH'"))
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)




;; (use-package eglot
;;   :config
;;   (add-to-list 'eglot-server-programs '(scala-mode . ("metals-emacs")))
;;   ;; (optional) Automatically start metals for Scala files.
;;   :hook (scala-mode . eglot-ensure))




;; column fill (if not using prelude)
(add-hook 'text-mode-hook 'auto-fill-mode)
(setq-default fill-column 200)


;; define function to shutdown emacs server instance
(defun server-shutdown ()
  "Save buffers, Quit, and Shutdown (kill) server."
  (interactive)
  (save-some-buffers)
  (kill-emacs)
  )


;;erlang
(require 'erlang-start)

;;clojure
(add-to-list 'exec-path "~/bin")


;; Enable custom neotree theme (all-the-icons must be installed!)
;;(doom-themes-neotree-config)
;; or for treemacs users
(doom-themes-treemacs-config)

;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

(cancel-function-timers 'auto-revert-buffers)
(setq debug-on-error 1)

(global-set-key (kbd "C-a") 'beginning-of-line)
;;(global-set-key (kbd "C-e") 'end-of-line)

;; Hackernews and eww to open url in right window
(defun my/open-url-in-right-window ()
  "Open the selected link on the right window plane"
  (interactive)
  (delete-other-windows nil)
  (split-window-right nil)
  (other-window 1)
  (eww-follow-link nil))


(global-set-key (kbd "S-r") 'my/open-url-in-right-window)


(defun my/list-buffers-in-right-window ()
  "List buffers on the right window plane"
  (interactive)
  (delete-other-windows nil)
  (split-window-right nil)
  (list-buffers nil)
  (other-window 1))


;;Frequent keys rebinding
(global-set-key (kbd "M-l") 'my/list-buffers-in-right-window)
(global-set-key (kbd "M-w") 'delete-window)
(global-set-key (kbd "M-s") 'other-window)

(setq ido-auto-merge-work-directories-length -1)

(provide 'init)
;;; init.el ends here
