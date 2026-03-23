# BLIS Family Model (MATLAB Implementation)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b+-blue.svg)

MATLAB-based implementation and exploration of the **BLIS (Basic Linear Algebra Instantiation Software)** family model for high-performance matrix multiplication (GEMM).

---

## 🚀 Overview

This repository presents a MATLAB implementation of the BLIS family model, aimed at studying and understanding the structural and algorithmic foundations of high-performance matrix multiplication. 

The project is specifically **configured and tuned for the GAP8 processor** (RISC-V architecture), focusing on expressing **GEMM** through BLIS-inspired decomposition strategies. It enables experimentation with:

* **Loop ordering** and transformations specific to the GAP8 memory hierarchy.
* **Blocking (Tiling)** strategies aware of memory hierarchy (L1/L2 constraints).
* **Memory-aware computations** at a conceptual level to maximize data reuse.

---

## 🧠 Key Concepts

* **GAP8 Optimization:** Tailored algorithmic structures for the GreenWaves Technologies GAP8 IoT processor.
* **BLIS Decomposition:** Implementation of the six-loop structure for GEMM.
* **Matrix Reformulation:** Understanding GEMM from an outer-product perspective.
* **Cache-Aware Modeling:** Conceptual algorithmic modeling of high-performance kernels.
* **HW/SW Co-design:** A bridge between theoretical linear algebra and hardware-specific optimization on RISC-V.

---

## 🛠️ Implementation

The repository includes:
* **BLIS-like GEMM:** Structured MATLAB functions following the standard BLIS decomposition.
* **Algorithmic Modeling:** Tools for comparing different loop organizations and their impact on data movement.
* **Reproducibility:** A clear path from the theoretical models described in related publications to functional code.

*Note: This work emphasizes the clarity of the model and structural organization rather than low-level assembly or intrinsics optimization.*

---

## ▶️ Usage

1. Open **MATLAB**.
2. Navigate to the project directory.
3. Run the main entry point:

'''matlab
% Example execution
test

## 📈 Research & Publications

This project serves as the algorithmic foundation for research into AI inference on constrained hardware. It explores strategies such as loop-level transformations and structural decomposition used in:

1. **Performance Analysis of Matrix Multiplication for Deep Learning on the Edge**. 
   [Read on Springer](https://doi.org/10.1007/978-3-031-23220-6_5)
2. **Communication-Avoiding Fusion of GEMM-Based Convolutions for Deep Learning in the RISC-V GAP8 MCU**. 
   [Read on IEEE Xplore](https://doi.org/10.1109/JIOT.2024.3436937)

---

## 👥 Authors

* **Cristian Ramirez**
* **Hector Martinez**

**Under Supervision of:**
* **Enrique S. Quintana-Ortí**
* **Adrian Castelló**

---

## 📜 License & Citation

This project is licensed under the **MIT License**. Proper attribution is appreciated if you use or adapt this work.

### BibTeX
```bibtex
@inbook{Ramirez_2022,
  title={Performance Analysis of Matrix Multiplication for Deep Learning on the Edge},
  author={Ramírez, Cristian and Castelló, Adrián, Martínez, Héctor and Quintana-Ortí, Enrique S.},
  booktitle={High Performance Computing. ISC High Performance 2022 International Workshops},
  year={2022},
  doi={10.1007/978-3-031-23220-6_5}
}

@article{ramirez2024communication,
  title={Communication-Avoiding Fusion of GEMM-Based Convolutions for Deep Learning in the RISC-V GAP8 MCU},
  author={Ramírez, Cristian and Castelló, Adrián, Martínez, Héctor and Quintana-Ortí, Enrique S.},
  journal={IEEE Internet of Things Journal},
  year={2024},
  doi={10.1109/JIOT.2024.3436937}
}