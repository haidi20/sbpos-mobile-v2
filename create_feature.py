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
    project_name = "landing_page_menu"  # Ganti dengan nama modul yang diinginkan
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

    # Step 2: Daftar semua folder sesuai struktur referensi
    folders = [
        "lib/data/datasources",
        "lib/data/datasources/tables",
        "lib/data/models",
        "lib/data/repositories",
        "lib/data/responses",
        "lib/domain/entities",
        "lib/domain/repositories",
        "lib/domain/usecases",
        "lib/presentation/controllers",
        "lib/presentation/providers",
        "lib/presentation/screens",
        "lib/presentation/viewmodels",
        "lib/presentation/widgets",
    ]

    for folder in folders:
        os.makedirs(folder, exist_ok=True)

    # Step 3: File yang harus ada (hanya buat jika belum ada)
    files = {
        # Data Layer
        f"lib/data/models/{project_name}_model.dart": f"// Model for {project_name} from API",
        f"lib/data/responses/{project_name}_response.dart": f"// Response wrapper for {project_name}",
        f"lib/data/datasources/{project_name}_remote_data_source.dart": f"// Remote data source for {project_name}",
        f"lib/data/datasources/{project_name}_local_data_source.dart": f"// Local data source (optional) for {project_name}",
        f"lib/data/repositories/{project_name}_repository_impl.dart": f"// Implementation of {project_name} repository",
        f"lib/data/datasources/{project_name}_database.dart": f"// Local database for {project_name}",
        f"lib/data/datasources/tables/{project_name}_table.dart": f"// Database table for {project_name}",

        # Domain Layer
        f"lib/domain/entities/{project_name}_entity.dart": f"// Domain entity for {project_name}",
        f"lib/domain/repositories/{project_name}_repository.dart": f"// Abstract repository for {project_name}",
        f"lib/domain/usecases/get_{project_name}s.dart": f"// Use case to get {project_name}s",
        f"lib/domain/usecases/save_{project_name}.dart": f"// Use case to save {project_name}",

        # Presentation Layer
        f"lib/presentation/screens/{project_name}_screen.dart": f"// UI screen for {project_name}",
        f"lib/presentation/viewmodels/{project_name}_viewmodel.dart": f"// ViewModel for {project_name}",
        f"lib/presentation/controllers/{project_name}_controller.dart": f"// Controller for {project_name} (manages TextEditingController, UI logic)",
        f"lib/presentation/widgets/{project_name}_card.dart": f"// Reusable widget for {project_name}",
        f"lib/presentation/providers/{project_name}_provider.dart": f"// Riverpod provider for {project_name}ViewModel",
        f"lib/presentation/providers/{project_name}_repository_provider.dart": f"// Repository provider for {project_name}",

        # $project_name export file (penting untuk modul)
        "lib/{project_name}.dart": f"// Export all public APIs of {project_name} module\n"
                         f"export 'domain/entities/{project_name}_entity.dart';\n"
                         f"export 'domain/repositories/{project_name}_repository.dart';\n"
                         f"export 'domain/usecases/get_{project_name}s.dart';\n"
                         f"export 'presentation/providers/{project_name}_provider.dart';\n"
                         f"export 'presentation/screens/{project_name}_screen.dart';",

        # Test
        "test/widget_test.dart": "// Basic widget tests",
        f"test/{project_name}_repository_test.dart": f"// Unit test for {project_name} repository",
        f"test/{project_name}_usecase_test.dart": f"// Unit test for {project_name} use cases",

        # Lainnya
        "analysis_options.yaml": "# Add linter rules as needed\ninclude: package:flutter_lints/flutter.yaml\n",
        "README.md": f"# {project_name.capitalize()}\n\nMVVM + Riverpod module using ViewModel → Controller → Screen.\n",
    }

    for path, content in files.items():
        create_file_if_not_exists(path, content)

    print(f"\n✅ Module '{project_name}' is ready at: {full_project_path}")
    if is_new_module:
        print("💡 Don't forget to add it to root pubspec.yaml as a path dependency, e.g.:\n"
              f"  {project_name}:\n"
              f"    path: features/{project_name}")

if __name__ == "__main__":
    main()
