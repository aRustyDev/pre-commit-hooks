#!/usr/bin/env python3
"""Setup configuration for pre-commit-hooks package."""

import os
from setuptools import setup, find_packages

# Read version from VERSION file
with open('VERSION', 'r') as f:
    version = f.read().strip()

# Read long description from README
with open('README.md', 'r', encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='arustydev-pre-commit-hooks',
    version=version,
    description='Collection of pre-commit hooks for various languages and tools',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='aRustyDev',
    author_email='',
    url='https://github.com/aRustyDev/pre-commit-hooks',
    project_urls={
        'Bug Tracker': 'https://github.com/aRustyDev/pre-commit-hooks/issues',
        'Documentation': 'https://github.com/aRustyDev/pre-commit-hooks#readme',
        'Source Code': 'https://github.com/aRustyDev/pre-commit-hooks',
    },
    packages=find_packages(exclude=['tests*', 'docs*']),
    include_package_data=True,
    package_data={
        '': ['hooks/**/*.sh', 'hooks/**/*.nix', '.pre-commit-hooks.yaml'],
    },
    python_requires='>=3.6',
    install_requires=[
        'pre-commit>=2.0.0',
        'pyyaml>=5.0',
    ],
    entry_points={
        'console_scripts': [
            'validate-frontmatter=pre_commit_hooks.validate_frontmatter:main',
        ],
    },
    extras_require={
        'dev': [
            'pytest>=6.0',
            'pytest-cov>=2.0',
            'black>=22.0',
            'flake8>=4.0',
        ],
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Topic :: Software Development :: Quality Assurance',
        'Topic :: Software Development :: Testing',
        'Topic :: Software Development :: Version Control :: Git',
    ],
    keywords='pre-commit hooks git linting formatting testing',
    zip_safe=False,
)
