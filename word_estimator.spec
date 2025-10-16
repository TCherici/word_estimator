# -*- mode: python ; coding: utf-8 -*-

# Exclude unnecessary packages to reduce executable size
excludes = [
    'pandas', 'numpy', 'matplotlib', 'scipy', 'sklearn', 'torch', 'torchvision',
    'transformers', 'pydantic', 'fastapi', 'uvicorn', 'notebook', 'jupyter',
    'IPython', 'bokeh', 'seaborn', 'plotly', 'dash', 'tensorflow', 'keras',
    'cv2', 'dask', 'distributed', 'fsspec', 'pyarrow', 'boto3', 'botocore',
    's3fs', 'sqlalchemy', 'numba', 'llvmlite', 'pytest', 'zmq', 'jinja2',
]

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=excludes,
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='word_estimator',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
