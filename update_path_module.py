import os
import yaml

def write_pubspec_yaml(data, path):
    """Menulis pubspec.yaml dengan format Flutter yang benar."""
    lines = []

    # Urutan kunci utama yang umum di pubspec.yaml
    main_keys = [
        'name', 'description', 'version', 'publish_to',
        'environment', 'dependencies', 'dev_dependencies'
    ]

    for key in main_keys:
        if key in data:
            value = data[key]
            if key == 'environment':
                lines.append("environment:")
                for env_key, env_val in value.items():
                    lines.append(f"  {env_key}: '{env_val}'")
            elif key == 'dependencies':
                lines.append("dependencies:")
                for dep_name, dep_val in value.items():
                    if isinstance(dep_val, str):
                        # Cek apakah ini seharusnya objek (sdk atau path)
                        if dep_val.startswith("sdk: ") or dep_val.startswith("path: "):
                            prefix, rest = dep_val.split(": ", 1)
                            lines.append(f"  {dep_name}:")
                            lines.append(f"    {prefix}: {rest}")
                        else:
                            lines.append(f"  {dep_name}: {dep_val}")
                    elif isinstance(dep_val, dict):
                        lines.append(f"  {dep_name}:")
                        for sub_key, sub_val in dep_val.items():
                            lines.append(f"    {sub_key}: {sub_val}")
                    else:
                        lines.append(f"  {dep_name}: {dep_val}")
            elif key == 'dev_dependencies':
                lines.append("dev_dependencies:")
                for dep_name, dep_val in value.items():
                    if isinstance(dep_val, dict):
                        lines.append(f"  {dep_name}:")
                        for sub_key, sub_val in dep_val.items():
                            lines.append(f"    {sub_key}: {sub_val}")
                    else:
                        lines.append(f"  {dep_name}: {dep_val}")
            else:
                if isinstance(value, str):
                    lines.append(f"{key}: {value}")
                else:
                    lines.append(f"{key}: {value}")

    # Tambahkan baris kosong di akhir
    content = "\n".join(lines) + "\n"

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def update_pubspec_dependencies(root_dir):
    pubspec_files = []

    root_pubspec = os.path.join(root_dir, 'pubspec.yaml')
    if os.path.exists(root_pubspec):
        pubspec_files.append(root_pubspec)

    core_pubspec = os.path.join(root_dir, 'core', 'pubspec.yaml')
    if os.path.exists(core_pubspec):
        pubspec_files.append(core_pubspec)

    features_dir = os.path.join(root_dir, 'features')
    feature_names = []
    if os.path.exists(features_dir):
        for name in os.listdir(features_dir):
            path = os.path.join(features_dir, name)
            if os.path.isdir(path) and name != '.git':
                feature_names.append(name)
                pubspec_path = os.path.join(path, 'pubspec.yaml')
                if os.path.exists(pubspec_path):
                    pubspec_files.append(pubspec_path)

    for pubspec_path in pubspec_files:
        try:
            with open(pubspec_path, "r", encoding="utf-8") as f:
                content = f.read()

            data = yaml.safe_load(content) or {}

            relative_path_from_root = os.path.relpath(pubspec_path, root_dir)
            parent_dir = os.path.dirname(relative_path_from_root).replace("\\", "/")

            # --- Buat dependency internal sebagai DICT, bukan string ---
            internal_deps = {
                "flutter": {"sdk": "flutter"}
            }

            if parent_dir == "":
                internal_deps["core"] = {"path": "core"}
                for name in feature_names:
                    internal_deps[name] = {"path": f"features/{name}"}
            elif parent_dir == "core":
                for name in feature_names:
                    internal_deps[name] = {"path": f"../features/{name}"}
            elif parent_dir.startswith("features/"):
                current_feature = os.path.basename(parent_dir)
                internal_deps["core"] = {"path": "../../core"}
                for name in feature_names:
                    if name != current_feature:
                        internal_deps[name] = {"path": f"../{name}"}

            # --- Gabungkan ke dependencies ---
            if "dependencies" not in data:
                data["dependencies"] = {}

            # Pertahankan semua dependency lama, tapi timpa internal
            for key, value in internal_deps.items():
                data["dependencies"][key] = value

            # --- publish_to: none untuk feature ---
            if parent_dir.startswith("features/"):
                data["publish_to"] = "none"

            # --- Tulis ulang dengan format rapi ---
            write_pubspec_yaml(data, pubspec_path)
            print(f"✅ Berhasil memperbarui {pubspec_path}")

        except Exception as e:
            print(f"❌ Gagal memperbarui {pubspec_path}: {e}")

if __name__ == "__main__":
    current_directory = os.getcwd()
    print(f"Mencari dan memperbarui pubspec.yaml di: {current_directory}")
    update_pubspec_dependencies(current_directory)
