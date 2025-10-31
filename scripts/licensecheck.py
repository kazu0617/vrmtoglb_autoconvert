# Licnese under NYSL

import bpy
import sys
import argparse

if '__main__' == __name__:
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True)
    parser.add_argument('--addonfile', required=False)
    
    args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    
    input = args.input
    addonfile = args.addonfile

    bpy.ops.preferences.addon_install(filepath=addonfile, overwrite = True)
    bpy.ops.preferences.addon_enable(module="VRM_Addon_for_Blender-release")
    bpy.ops.import_scene.vrm(filepath=input, extract_textures_into_folder=True)
