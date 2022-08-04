;;; init.el --- Load the full configuration
;;; Commentary:

;;; Code:


(defvar lmmv/emacs-in-wsl (if (string-match "WSL" operating-system-release) t nil)
  "Emacs if run wsl, is t else nil.")

(when lmmv/emacs-in-wsl
  (setenv "PATH" "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl")
  (setq exec-path (split-string "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl" path-separator))
  (setq browse-url-browser-function (lambda(url &rest args)
                                      (start-process
                                       (concat "WinExplorer " url)
                                       nil
                                       "/mnt/c/Windows/explorer.exe"
                                       url))))

(defvar lmmv/emacs-config-file "EmacsConfig.org"
  "Main Config file, .org or .el.")

(defvar lmmv/emacs-config-tangle-file (concat (file-name-base lmmv/emacs-config-file) ".el")
  "Config file for 'lmmv/emacs-config-file', if it is a org file.")

(defun lmm/emacs-load-config()
  "Load config file, '.el' or '.org' file."
  (let* ((init-file (expand-file-name  lmmv/emacs-config-tangle-file user-emacs-directory))
         (init-org-file (expand-file-name lmmv/emacs-config-file user-emacs-directory)))
    (if (file-exists-p init-file)
        (load-file init-file)
      (if (file-exists-p init-org-file)
          (org-babel-load-file init-org-file)
        (display-warning :warning (format "File %s not exitsed!!!" init-org-file))))))

(lmm/emacs-load-config)

(defun lmm/emacs-build-config-file()
  "Build config file for org, add to 'kill-emacs-hook'."
  (interactive)
  (let* ((init-file (expand-file-name  lmmv/emacs-config-tangle-file user-emacs-directory))
         (init-org-file (expand-file-name lmmv/emacs-config-file user-emacs-directory)))
    (when (file-exists-p init-file)
      (delete-file init-file))
    (when (file-exists-p init-org-file)
      (org-babel-tangle-file init-org-file init-file)
      (let ((byte-compile-warnings nil))
        (byte-compile-file init-file)))))

(add-hook 'kill-emacs-hook #'lmm/emacs-build-config-file)

;; 消除启动提示消息
(fset 'display-startup-echo-area-message 'ignore)
;; 让hook顺序倒过来， 符合EmacsConfig.org配置编写逻辑
(setq after-init-hook (reverse after-init-hook))

(provide 'init)
;;; init.el ends here
