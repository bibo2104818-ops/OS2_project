#!/bin/bash
# ===============================
# generate_pdf.sh
# Convert a hardware report text file into a professional LaTeX PDF
# Usage: ./generate_pdf.sh path/to/full_hardware_info.txt
# ===============================

# Check input file
if [ -z "$1" ]; then
    echo "Usage: $0 path/to/hardware_report.txt"
    exit 1
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' does not exist."
    exit 1
fi

# Output PDF
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"
PDF_FILE="$OUTPUT_DIR/hardware_info_$(date +%Y%m%d_%H%M%S).pdf"
TEX_FILE="/tmp/hardware_report.tex"

# Create LaTeX template
cat > "$TEX_FILE" <<EOL
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{xcolor}
\usepackage{longtable}
\usepackage{fancyvrb}
\usepackage{fontspec} % Optional: for nicer fonts
\usepackage{titlesec}
\titleformat{\section}{\bfseries\Large\color{cyan}}{}{0em}{}

\title{\textbf{Hardware Info Scan}}
\date{\today}

\begin{document}
\maketitle
\hrule
\vspace{1em}

% Begin verbatim environment to preserve text layout
\begin{Verbatim}[fontsize=\small]
EOL

# Insert the text from input, escape backslashes
sed 's/\\/\\\\/g' "$INPUT_FILE" >> "$TEX_FILE"

# End LaTeX document
cat >> "$TEX_FILE" <<EOL
\end{Verbatim}

\end{document}
EOL

# Compile LaTeX to PDF
if command -v xelatex >/dev/null 2>&1; then
    xelatex -interaction=nonstopmode -output-directory="$OUTPUT_DIR" "$TEX_FILE" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\e[32mPDF successfully generated: $PDF_FILE\e[0m"
    else
        echo -e "\e[31mError: LaTeX compilation failed\e[0m"
    fi
else
    echo -e "\e[31mError: xelatex not installed. Install TeX Live (sudo apt install texlive-xetex)\e[0m"
fi

# Optional: clean temporary tex file
rm -f "$TEX_FILE"
