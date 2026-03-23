# BLIS Family Model (MATLAB Implementation)

MATLAB-based implementation and exploration of the BLIS family model for high-performance matrix multiplication (GEMM).

---

## 🚀 Overview

This repository presents a MATLAB implementation of the BLIS family model, aimed at studying and understanding the structural and algorithmic foundations of high-performance matrix multiplication.

The project focuses on expressing GEMM through BLIS-inspired decomposition strategies, enabling experimentation with loop ordering, blocking, and memory-aware computations.

---

## 🧠 Key Concepts

- BLIS decomposition (six-loop structure)
- Matrix multiplication reformulation (outer-product perspective)
- Loop transformations and ordering
- Cache-aware computation (conceptual level)
- Algorithmic modeling of high-performance kernels

---

## 🛠️ Implementation

The repository includes:

- MATLAB implementations of GEMM following BLIS-like structure
- Loop decomposition experiments
- Algorithmic modeling of matrix multiplication
- Comparative exploration of different loop organizations

This work emphasizes clarity of the model and structure rather than low-level hardware-specific optimization.

---

## ▶️ Usage

Open MATLAB and run the corresponding scripts/functions.

Example:

```matlab
main

## 📈 Motivation & Publications

This project was developed as part of a deeper exploration into:

High-performance computing (HPC)
Algorithmic structure of linear algebra libraries
Foundations of optimized GEMM implementations
📚 Related Publications
Performance Analysis of Matrix Multiplication for Deep Learning on the Edge
https://doi.org/10.1007/978-3-031-23220-6_5
Communication-Avoiding Fusion of GEMM-Based Convolutions for Deep Learning in the RISC-V GAP8 MCU

These publications explore matrix multiplication strategies based on the BLIS family model, including:

Loop-level transformations
Structural decomposition of GEMM
Performance-oriented algorithm design
🔬 Research-to-Code Connection

This repository provides an implementation-oriented perspective of the ideas developed in the publications above, enabling:

Conceptual validation of BLIS-based formulations
Reproducibility of algorithmic structures
A bridge between theoretical models and practical implementations
👥 Authors
Developers
Cristian Ramirez
Hector Martinez
Under Supervision
Enrique Quintana
Adrian Castellon

##📜 License

This project is licensed under the MIT License — see the LICENSE file for details.

© Attribution

If you use or adapt this work, proper attribution is appreciated :).

## Citation
@inbook{Ramirez_2022,
  title={Performance Analysis of Matrix Multiplication for Deep Learning on the Edge},
  author={Ramírez, Cristian and Castelló, Adrián and Martínez, Héctor and Quintana-Ortí, Enrique S.},
  booktitle={High Performance Computing. ISC High Performance 2022 International Workshops},
  publisher={Springer International Publishing},
  year={2022},
  pages={65--76},
  doi={10.1007/978-3-031-23220-6_5}
}

@article{ramirez2024communication,
  title={Communication-Avoiding Fusion of GEMM-Based Convolutions for Deep Learning in the RISC-V GAP8 MCU},
  author={Ram{\'\i}rez, Cristian and Castell{\'o}, Adri{\'a}n and Mart{\'\i}nez, H{\'e}ctor and Quintana-Ort{\'\i}, Enrique S.},
  journal={IEEE Internet of Things Journal},
  volume={11},
  number={21},
  pages={35640--35653},
  year={2024},
  publisher={IEEE}
}