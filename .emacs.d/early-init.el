;;; package --- summary
;;; Commentary:
;;; Code:


;; use straight package manager.
(setq package-enable-at-startup nil)

(setq garbage-collection-messages t)
(setq gc-cons-threshold (* 100 1024 1024))
(setq gc-cons-percentage 0.6)
(setq default-frame-alist '((width . 200)
                            (height . 50)
                            (left . 100)
                            (top . 50)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
;; 禁止启动屏幕
(setq inhibit-startup-message t)

(provide 'early-init)
;;; early-init.el ends here
