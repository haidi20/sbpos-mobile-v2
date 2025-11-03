import os
import subprocess
import sys

def run_command(cmd, cwd=None):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
    if result.returncode != 0:
        print(f"Error running command: {cmd}\n{result.stderr}")
        sys.exit(1)
    return result.stdout

def create_file_if_not_exists(path, content=""):
    if os.path.exists(path):
        print(f"⏩ Skipping (already exists): {path}")
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip() + "\n")
    print(f"✅ Created: {path}")

def main():
    project_name = "warehouse"
    base_dir = "features"
    project_path = os.path.join(base_dir, project_name)
    full_project_path = os.path.abspath(project_path)

    # Step 1: Buat folder features jika belum ada
    os.makedirs(base_dir, exist_ok=True)

    is_new_module = not os.path.exists(project_path)

    if is_new_module:
        print(f"🆕 Creating new Flutter module: {project_path}")
        run_command(f"flutter create --template=module --org id.myapp {project_name}", cwd=base_dir)
    else:
        print(f"🔁 Module '{project_name}' already exists. Updating structure only...")

    os.chdir(full_project_path)

    # Step 2: Daftar folder MVVM yang diinginkan
    folders = [
        "lib/data/datasources",
        "lib/data/models",
        "lib/data/repositories",
        "lib/domain/entities",
        "lib/domain/repositories",
        "lib/domain/usecases",
        "lib/presentation/screens",
        # "lib/presentation/controllers",
        "lib/presentation/viewmodels",
        "lib/presentation/widgets",
        "lib/presentation/providers",
    ]

    for folder in folders:
        os.makedirs(folder, exist_ok=True)

    # Step 3: File yang harus ada (hanya buat jika belum ada)
    files = {
        f"lib/data/models/{project_name}_model.dart": f"// Model for {project_name} from API",
        f"lib/data/models/{project_name}_response.dart": f"// Response wrapper for {project_name}",
        f"lib/data/datasources/{project_name}_remote_data_source.dart": f"// Remote data source for {project_name}",
        f"lib/data/repositories/{project_name}_repository_impl.dart": f"// Implementation of {project_name} repository",
        f"lib/domain/entities/{project_name}.dart": f"// Domain entity for {project_name}",
        f"lib/domain/repositories/{project_name}_repository.dart": f"// Abstract repository for {project_name}",
        f"lib/domain/usecases/get_{project_name}s.dart": f"// Use case to get {project_name}s",
        f"lib/presentation/screens/{project_name}_screen.dart": f"// UI screen for {project_name}",
        f"lib/presentation/viewmodels/{project_name}_viewmodel.dart": f"// ViewModel for {project_name}",
        "lib/presentation/widgets/warehouse_card.dart": "// Reusable widget (optional)",
        f"lib/presentation/providers/{project_name}_provider.dart": f"// Riverpod providers for {project_name}",
        "test/widget_test.dart": "// Widget tests",
        f"test/{project_name}_repository_test.dart": f"// Unit test for {project_name} repository",
        "analysis_options.yaml": "# Add linter rules as needed\n",
        "README.md": f"# {project_name.capitalize()}\n\nMVVM + Riverpod module.\n",
    }

    for path, content in files.items():
        create_file_if_not_exists(path, content)

    # Step 4: Update pubspec.yaml hanya jika perlu (opsional)
    pubspec_path = "pubspec.yaml"
    if os.path.exists(pubspec_path):
        with open(pubspec_path, "r", encoding="utf-8") as f:
            content = f.read()
        # Catatan: Tidak otomatis tambah dependensi karena `core` dan `riverpod` biasanya di-handle di root app
        # Modul biasanya tidak punya dependensi berat — cukup export API

    print(f"\n✅ Module '{project_name}' is ready at: {full_project_path}")
    if is_new_module:
        print("💡 Don't forget to add it to root pubspec.yaml as a path dependency.")

if __name__ == "__main__":
    main()
