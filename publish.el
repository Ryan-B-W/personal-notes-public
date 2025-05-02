#!/usr/bin/emacs -x

;; Bootstrap Elpaca.
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Default to shallow clones for Elpaca.
(setf elpaca-order-defaults '(:protocol https
                              :inherit t
                              :depth 1))



(setf default-directory (expand-file-name "~/doc-public/"))
(setf default-publish-directory (expand-file-name "~/doc-publish/"))
(setf org-id-locations-file (concat default-directory ".org-id-locations"))
(setf org-roam-db-location (concat default-directory ".org-roam.db"))

(require 'epa-file)
(elpaca pinentry)
(require 'calc)
(elpaca org)
(elpaca citar)
(elpaca org-roam)
(elpaca org-roam-export)
(elpaca citar-org-roam)
(elpaca org-roam-ui)
(elpaca ol-man)
(elpaca ob-tmux)
(elpaca ob-asymptote)
(elpaca ob-mermaid)
(elpaca ob-typescript)
(elpaca orgit)
(elpaca orgit-forge)
(elpaca verb)
(elpaca htmlize)

(elpaca-wait)

(require 'subr-x)
(require 'ox-publish)

(add-to-list 'calc-language-alist '(org-mode . latex))
(setf org-todo-keywords '((sequence "TODO(t)" "CURRENT(s!)" "|" "CANCELED(c!)"
                                    "DONELATE(l!)" "PARTIALCOMPLETE(p!)" "FAILED(f!)"
                                    "DONE(d!)")))
(setf org-tags-exclude-from-inheritance '("ARCHIVE" "ATTACH" "directory" "lists" "blog" "blog_post" "essay" "searches" "class_homework" "class_assignment"))
(setf org-directory default-directory)
(setf org-export-backends '(ascii beamer html icalendar latex man md odt org texinfo))
(setf org-format-latex-header
   "\\documentclass{article}
\\usepackage[usenames]{color}
[PACKAGES]
[DEFAULT-PACKAGES]
\\pagestyle{empty}             % do not remove
% The settings below are copied from fullpage.sty
\\setlength{\\textwidth}{\\paperwidth}
\\addtolength{\\textwidth}{-3cm}
\\setlength{\\oddsidemargin}{1.5cm}
\\addtolength{\\oddsidemargin}{-2.54cm}
\\setlength{\\evensidemargin}{\\oddsidemargin}
\\setlength{\\textheight}{\\paperheight}
\\addtolength{\\textheight}{-\\headheight}
\\addtolength{\\textheight}{-\\headsep}
\\addtolength{\\textheight}{-\\footskip}
\\addtolength{\\textheight}{-3cm}
\\setlength{\\topmargin}{1.5cm}
\\addtolength{\\topmargin}{-2.54cm}")
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (asymptote . t)
   (awk . t)
   (C . t)
   (calc . t)
   (clojure . t)
   (comint . t)
   (css . t)
   (ditaa . t)
   (dot . t)
   (eshell . t)
   (gnuplot . t)
   (groovy . t)
   (haskell . t)
   (latex . t)
   (java . t)
   (js . t)
   (lisp . t)
   (makefile . t)
   (mermaid . t)
   (org . t)
   (perl . t)
   ;;(php . t)
   (plantuml . t)
   (python . t)
   (R . t)
   ;;(redis . t)
   (ruby . t)
   (sass . t)
   (scheme . t)
   (screen . t)
   (shell . t)
   (sql . t)
   (sqlite . t)
   (typescript . t)))
(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("mla" "\\documentclass[12pt,letterpaper]{mla}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
               nil (lambda (x y) (equal (car x) (car y)))))
(setf citar-bibliography (list (concat org-directory "bibliography/references.bib")))
(setf org-cite-global-bibliography (list (concat org-directory "bibliography/references.bib")))

(setf org-roam-directory org-directory)
(setf org-roam-file-exclude-regexp
      `("data/"
        ,(concat "^" (expand-file-name org-roam-directory) "/other/")
        ,(concat "^" (expand-file-name org-roam-directory) "/.git/")
        ".*\\.gpg"))
(setf org-roam-database-connector 'sqlite-builtin)
(setf org-roam-graph-executable "sfdp"
      org-roam-graph-max-title-length 40
      org-roam-graph-extra-config '(("overlap" . "prism")
                                    ("sep" . "1"))
      org-roam-graph-node-extra-config '(("id"
                                          ("style" . "bold,rounded,filled")
                                          ("shape" . "circle")
                                          ("fixedsize" . "shape")
                                          ("fillcolor" . "#EEEEEE")
                                          ("color" . "#C9C9C9")
                                          ("fontcolor" . "#111111"))
                                         ("http"
                                          ("style" . "rounded,filled")
                                          ("shape" . "circle")
                                          ("fixedsize" . "shape")
                                          ("fillcolor" . "#EEEEEE")
                                          ("color" . "#C9C9C9")
                                          ("fontcolor" . "#0A97A6"))
                                         ("https"
                                          ("style" . "rounded,filled")
                                          ("shape" . "circle")
                                          ("fixedsize" . "shape")
                                          ("fillcolor" . "#EEEEEE")
                                          ("color" . "#C9C9C9")
                                          ("fontcolor" . "#0A97A6"))))

(citar-org-roam-mode)
(epa-file-enable)

(setf calendar-date-style "iso")



(defun custom-publish-sass-scss-to-css (_plist filename pub-dir)
  "Publish scss/sass as css."
  (unless (file-directory-p pub-dir)
    (make-directory pub-dir))
  (let ((ext (file-name-extension filename))
        (outfile (expand-file-name (file-name-nondirectory filename) pub-dir)))
    (cond ((and (or (string= "scss" ext)
                    (string= "sass" ext))
                (executable-find "sassc"))
           (message "Converting %s to CSS with sassc." (file-name-nondirectory filename))
           (setf outfile (replace-regexp-in-string "\\.scss$" ".css" outfile))
           (call-process "sassc" nil nil nil "--style" "compressed" filename outfile))
          (t (copy-file filename outfile t)))
    outfile))

(setf org-html-doctype "xhtml5"
      org-html-html5-fancy t
      org-html-link-org-files-as-html t
      org-html-prefer-user-labels t
      ;org-html-meta-tags (lambda (x) x)
      ;org-html-link-home ""
      ;org-html-link-use-abs-url t
      org-html-validation-link nil
      org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/personal-notes-public/main.css\" />"
      org-html-head-include-default-style nil
      org-html-viewport '((width "device-width")
                          (initial-scale "")
                          (minimum-scale "1")
                          (maximum-scale "")
                          (user-scalable ""))
      ;org-html-container-element "article"
      org-html-divs '((preamble "div" "preamble")
                      (content "main" "content")
                      (postamble "div" "postamble"))
      org-html-checkbox-type 'unicode
      org-html-with-latex 'mathjax
      org-html-text-markup-alist '((bold . "<b>%s</b>")
                                   (code . "<code>%s</code>")
                                   (italic . "<i>%s</i>")
                                   (strike-through . "<del>%s</del>")
                                   (underline . "<u class=\"underline\">%s</u>")
                                   (verbatim . "<pre class=\"verbatim\">%s</pre>"))
      org-html-wrap-src-lines t
      ;org-org-htmlized-css-url "org-htmlize.css"
      org-html-htmlize-output-type 'css
      ;org-html-preamble "<header>\n<hgroup role=\"group\" aria-roledescription=\"Heading group\">\n<h1 class=\"title\">%t</h1>\n<p class=\"subtitle\" aria-roledescription=\"subtitle\">%s</p>\n</hgroup>\n</header>\n"
      org-html-preamble "<nav aria-labelledby=\"nav-head-main\">\n<h1 id=\"nav-head-main\">Navigation</h1>\n<menu>\n<li><a href=\"/personal-notes-public/\" title=\"Home\">Home</a></li>\n<li><a href=\"/personal-notes-public/directory.html\" title=\"Directory\">Directory</a></li>\n</menu>\n</nav>"
      org-html-footnotes-section "<section id=\"footnotes\">\n<h2 class=\"footnotes\">%s: </h2>\n<div id=\"text-footnotes\">\n%s\n</div>\n</section>"
      org-html-postamble "<footer>\n<p class=\"date\">Last Modified: %C</p>\n<p class=\"author\">Author: %a</p>\n</footer>"
      org-export-with-broken-links :mark
      org-export-with-properties '("ROAM_REFS" "ROAM_ALIASES")
      org-export-filter-paragraph-functions (list (lambda (content _backend _info) (string-trim content))
                                                  (lambda (content _backend _info) (replace-regexp-in-string "\\(<p ?\\(?:[[:word:]]+=\"[[:word:]]+\" ?\\)*>\\)[[:space:]]*\\(.*\\)?[[:space:]]*\\(</p>\\)" "\\1\\2\\3" content t nil)))
      org-export-filter-item-functions (list (lambda (content _backend _info) (replace-regexp-in-string "<br /></li>$" "</li>" content t nil)))
      org-export-filter-headline-functions (list (lambda (content _backend _info) (replace-regexp-in-string "<br /></li>$" "</li>" content t nil)))
      org-publish-project-alist
      `(("meta"
         :components ("styles" "notes" "public"))
        ("styles"
         :base-directory ,org-directory
         :base-extension "scss\\|sass\\|css"
         :recursive nil
         :publishing-function custom-publish-sass-scss-to-css
         :publishing-directory ,(expand-file-name "personal-notes-public" default-publish-directory))
        ;("assets"
        ; :base-directory ,org-directory
        ; :base-extension "svg"
        ; :recursive t
        ; :publishing-directory ,(expand-file-name "personal-notes-public" default-publish-directory)
        ; :publishing-function: org-publish-attachment)
        ("notes"
         :base-directory ,org-directory
         :exclude "public/" :exclude "data/" :exclude "ltximg"
         :exclude "resume/" :exclude "notes.org-images/"
         :exclude "other/" :exclude "tmp/" :exclude ".git/"
         :recursive nil
         :publishing-directory ,(expand-file-name "personal-notes-public" default-publish-directory)
         :publishing-function org-html-publish-to-html
         :htmlized-source t
         :section-numbers nil :with-toc nil
         :auto-sitemap t
         :sitemap-title "Sitemap for Personal Notes (Meta-Repo)")
        ("public"
         :base-directory ,(concat org-directory "public")
         :recursive t
         :publishing-directory ,(expand-file-name "personal-notes-public/public" default-publish-directory)
         :publishing-function org-html-publish-to-html
         :htmlized-source t
         :section-numbers nil
         :with-toc nil
         :auto-sitemap t
         :sitemap-title "Sitemap for Personal Notes, Public Submodule Repository")))

(org-roam-db-sync nil)
(org-roam-update-org-id-locations)
(setf org-id-extra-files (org-roam-list-files))

(org-publish "meta" t)
