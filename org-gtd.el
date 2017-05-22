;;; org-gtd.el --- gtd system for Emacs

;; Copyright (C) 2011-2013 John Wiegley

;; Author: Cosysn <cosysn@163.com>
;; Created: 24 Aug 2011
;; Updated: 16 Mar 2015
;; Version: 0.1
;; Package-Requires: ((org "0.1"))
;; Keywords: gtd emacs
;; X-URL: https://github.com/cosysn/org-gtd

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(require 'org)

(defvar org-agenda-dir "~/myorg"
  "gtd org files location")

(defvar org-agenda-file-gtd "")

(setq org-agenda-file-note (expand-file-name "notes.org" org-agenda-dir))
(setq org-agenda-file-capture (expand-file-name "capture.org" org-agenda-dir))
(setq org-agenda-file-index (expand-file-name "index.org" org-agenda-dir))
(setq org-agenda-file-gtd (expand-file-name "gtd.org" org-agenda-dir))
(setq org-agenda-file-someday (expand-file-name "someday.org" org-agenda-dir))
(setq org-agenda-file-journal (expand-file-name "journal.org" org-agenda-dir))
(setq org-agenda-file-birthday (expand-file-name "birthday.org" org-agenda-dir))
(setq org-agenda-file-code-snippet (expand-file-name "snippet.org" org-agenda-dir))
(setq org-default-notes-file (expand-file-name "index.org" org-agenda-dir))

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "DEFERRED(D@/!)" "|" "CANCELLED(c@/!)"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
			  ("DONE" :foreground "forest green" :weight bold)
			  ("WAITING" :foreground "orange" :weight bold)
			  ("DEFERRED" :foreground "magenta" :weight bold)
			  ("CANCELLED" :foreground "forest green" :weight bold))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("DEFERRED" ("WAITING") ("DEFERRED" . t))
              (done ("WAITING") ("DEFERRED"))
              ("TODO" ("WAITING") ("CANCELLED") ("DEFERRED"))
              ("NEXT" ("WAITING") ("CANCELLED") ("DEFERRED"))
              ("DONE" ("WAITING") ("CANCELLED") ("DEFERRED")))))

(setq org-tags-exclude-from-inheritance '(list "PROJECT" "CATEGORY"))

(setq org-tag-persistent-alist  nil)
(setq org-tag-alist '(("@WORK" . ?w)
                      ("@HOME" . ?h)
                      ("@COMPUTER" . ?c)
                      ("@PHONE" . ?p)
                      ("@SHOPPING" . ?s)
                      ("@OUT" . ?o)
                      ("@LUNCH" . ?l)
                      ("@WRITING" . ?W)
                      ("@READING" . ?r)
                      ("@CODING" . ?C)))

(add-to-list 'org-global-properties
             '("Effort_ALL". "0:05 0:15 0:30 1:00 2:00 3:00 4:00"))

;; define the refile targets
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-targets
      '((nil :maxlevel . 4)
        (org-agenda-files :maxlevel . 4)))
	
(setq org-log-done t)
	
;; the %i would copy the selected text into the template
;;http://www.howardism.org/Technical/Emacs/journaling-org.html
;;add multi-file journal
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-agenda-file-capture "Inbox")
          "* TODO [#B] %?\n  %i\n %U"
          :empty-lines 1)
       ("n" "notes" entry (file+headline org-agenda-file-note "Quick notes")
          "* %?\n  %i\n %U"
          :empty-lines 1)
       ("b" "Blog Ideas" entry (file+headline org-agenda-file-note "Blog Ideas")
          "* TODO [#B] %?\n  %i\n %U"
          :empty-lines 1)
       ("s" "Code Snippet" entry
          (file org-agenda-file-code-snippet)
          "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC")
       ("w" "work" entry (file+headline org-agenda-file-gtd "Cocos2D-X")
          "* TODO [#A] %?\n  %i\n %U"
          :empty-lines 1)
       ("c" "Chrome" entry (file+headline org-agenda-file-note "Quick notes")
          "* TODO [#C] %?\n %(zilongshanren/retrieve-chrome-current-tab-url)\n %i\n %U"
          :empty-lines 1)
       ("l" "links" entry (file+headline org-agenda-file-note "Quick notes")
          "* TODO [#C] %?\n  %i\n %a \n %U"
          :empty-lines 1)
       ("j" "Journal Entry"
          entry (file+datetree org-agenda-file-journal)
          "* %?"
          :empty-lines 1)))

;; Org clock
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(with-eval-after-load 'org
  (org-clock-persistence-insinuate))
  (setq org-clock-persist t)
  (setq org-clock-in-resume t)

  ;; Change task state to NEXT when clocking in
  (setq org-clock-in-switch-to-state "NEXT")

  ;; Save clock data and notes in the LOGBOOK drawer
  (setq org-clock-into-drawer t)

  ;; Removes clocked tasks with 0:00 duration
  (setq org-clock-out-remove-zero-time-clocks t) ;; Show the clocked-in task - if any - in the header line

  ;; Show clock sums as hours and minutes, not "n days" etc.
  (setq org-time-clocksum-format
          '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

  ;;; Show the clocked-in task - if any - in the header line
  (defun sanityinc/show-org-clock-in-header-line ()
      (setq-default header-line-format '((" " org-mode-line-string " "))))

  (defun sanityinc/hide-org-clock-from-header-line ()
      (setq-default header-line-format nil))

  (add-hook 'org-clock-in-hook 'sanityinc/show-org-clock-in-header-line)
  (add-hook 'org-clock-out-hook 'sanityinc/hide-org-clock-from-header-line)
  (add-hook 'org-clock-cancel-hook 'sanityinc/hide-org-clock-from-header-line)

  (with-eval-after-load 'org-clock
                (define-key org-clock-mode-line-map [header-line mouse-2] 'org-clock-goto)
                (define-key org-clock-mode-line-map [header-line mouse-1] 'org-clock-menu))

	;; Org agenda
	(setq org-agenda-files (list org-agenda-dir))

    ;; config stuck project
    (setq org-stuck-projects
          '("TODO={.+}/-DONE" nil nil "SCHEDULED:\\|DEADLINE:"))

    (setq org-agenda-inhibit-startup t) ;; ~50x speedup
    (setq org-agenda-span 'day)
    (setq org-agenda-use-tag-inheritance nil) ;; 3-4x speedup
    (setq org-agenda-window-setup 'current-window)
    (setq org-log-done t)
    ;;An entry without a cookie is treated just like priority ' B '.
    ;;So when create new task, they are default 重要且紧急
    (setq org-agenda-custom-commands
          '(
            ("w" . "任务安排")
            ("wa" "重要且紧急的任务" tags-todo "+PRIORITY=\"A\"")
            ("wb" "重要且不紧急的任务" tags-todo "-Weekly-Monthly-Daily+PRIORITY=\"B\"")
            ("wc" "不重要且紧急的任务" tags-todo "+PRIORITY=\"C\"")
            ("b" "Blog" tags-todo "BLOG")
            ("p" . "项目安排")
            ("pw" tags-todo "PROJECT+WORK+CATEGORY=\"cocos2d-x\"")
            ("pl" tags-todo "PROJECT+DREAM+CATEGORY=\"zilongshanren\"")
            ("W" "Weekly Review"
             ((stuck "") ;; review stuck projects as designated by org-stuck-projects
              (tags-todo "PROJECT") ;; review all projects (assuming you use todo keywords to designate projects)
              ))))

(defun myorg/find-gtdfile ()
      "Edit the `gtdfile', in the current window."
      (interactive)
      (find-file-existing (org-agenda-file-gtd)))

;; 在当前行插入checkbox
;; http://stackoverflow.com/questions/18667385/convert-lines-of-text-into-todos-or-check-boxes-in-org-mode
(defun myorg/org-set-line-checkbox (arg)
  (interactive "P")
  (let ((n (or arg 1)))
    (when (region-active-p)
      (setq n (count-lines (region-beginning)
                           (region-end)))
      (goto-char (region-beginning)))
    (dotimes (i n)
      (beginning-of-line)
      (insert "- [ ] ")
      (forward-line))
    (beginning-of-line)))

;; 为org mode自动分配uuid
;; https://writequit.org/articles/emacs-org-mode-generate-ids.html
(defun myorg/org-custom-id-get (&optional pom create prefix)
  "Get the CUSTOM_ID property of the entry at point-or-marker POM.
   If POM is nil, refer to the entry at point. If the entry does
   not have an CUSTOM_ID, the function returns nil. However, when
   CREATE is non nil, create a CUSTOM_ID if none is present
   already. PREFIX will be passed through to `org-id-new'. In any
   case, the CUSTOM_ID of the entry is returned."
  (interactive)
  (org-with-point-at pom
    (let ((id (org-entry-get nil "CUSTOM_ID")))
      (cond
       ((and id (stringp id) (string-match "\\S-" id))
        id)
       (create
        (setq id (org-id-new (concat prefix "h")))
        (org-entry-put pom "CUSTOM_ID" id)
        (org-id-add-location id (buffer-file-name (buffer-base-buffer)))
        id)))))

(defun myorg/org-add-ids-to-headlines-in-file ()
  "Add CUSTOM_ID properties to all headlines in the current
   file which do not already have one. Only adds ids if the
   `auto-id' option is set to `t' in the file somewhere. ie,
   #+OPTIONS: auto-id:t"
  (interactive)
  (save-excursion
    (widen)
    (goto-char (point-min))
    (when (re-search-forward "^#\\+OPTIONS:.*auto-id:t" (point-max) t)
      (org-map-entries (lambda () (myorg/org-custom-id-get (point) 'create))))))

;; automatically add ids to captured headlines
(add-hook 'org-capture-prepare-finalize-hook
          (lambda () (myorg/org-custom-id-get (point) 'create)))

;; automatically add ids to saved org-mode headlines
(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (when (and (eq major-mode 'org-mode)
                                   (eq buffer-read-only nil))
                          (myorg/org-add-ids-to-headlines-in-file))))))

;;;###autoload

(provide 'org-gtd)

;;; org-gtd.el ends here
