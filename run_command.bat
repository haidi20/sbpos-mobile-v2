@echo off
del /Q d:\projects\sbpos_mobile_v2\*.txt
git add .
git commit -m "refactor(core): standarisasi impor absolute dan implementasi TDD login" -m "- Mengembalikan impor relative menjadi absolute (package:core/...) di auth repository, model, local datasource, service dan entity." -m "- Menambahkan TDD integration test yang mensimulasikan alur end-to-end user di Login Screen sesuai dokumen." -m "- Mengisolasi modul setting dari modul notifikasi dan produk dengan mengimplementasikan mock route saat menjalankan testing untuk menghindari compilation error." -m "- Menghapus log sisa testing file txt dari workspace."
git push

