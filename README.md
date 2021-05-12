# SRM_hw_implementation
VHDL implementation of the Spike Response Model

This is a hardware implementation, written in VHDL, of the <a href="https://infoscience.epfl.ch/record/97804/files/SRM.pdf">Spike Response Model</a>. In particular, it adopts the <a href="https://www.frontiersin.org/articles/10.3389/neuro.10.009.2009/full">Multi-timescale Adaptive Threshold model (MAT)</a>. For a brief overview of the project, take a look at this <a href="https://github.com/fairfriend92/SRM_hw_implementation/blob/main/presentazione.pdf">presentation</a>. For a more thorough explaination, you might want to read this <a href="https://github.com/fairfriend92/SRM_hw_implementation/blob/main/vhdl%20implementation%20of%20the%20multi-timescale%20adaptive%20threshold%20neuronal%20model.pdf">technical report</a>

The repository also include testbenches, that utilize experimental data from the <a href="https://infoscience.epfl.ch/record/135231/files/Jolivet08.pdf">Quantitative Single-Neuron Modelling competition</a> to compare the output of the hardware implementation with the in-vivo recording that was originally used to benchmark the MAT model. 
