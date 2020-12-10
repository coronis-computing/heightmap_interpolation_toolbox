# Heightmap Interpolation Toolbox

Heightmap interpolation toolbox for matlab, developed within the EMODnet Bathymetry HRSM. 

Includes a suite of generic scattered data interpolation functions, as well as inpainting methods devised for efficient large area hole filling.

## Installation

Just clone the data and add the folders of the toolbox to the Matlab's path. Therefore, start with:

```
git clone https://github.com/coronis-computing/heightmap_interpolation_toolbox.git
```

And then, we provide a convenience function adding the required sub-folders to the path. From Matlab:

```
cd <path_to_cloned_heightmap_interpolation_toolbox>
hmitInitialize
```

## Quick User Guide

This toolbox includes both generic interpolation methods and inpainting methods. 

### Generic Interpolation Methods

Generic interpolation methods do not assume any structure in the input data, and you can just pass your data using the `x`, `y` and `z` variables:

While all the methods in the toolbox can be used individually, we provide the convenience function `interpolateScattered` which acts as
 interphase to the different interpolation methods in the Heightmap Interpolation Toolbox. The output are the interpolated `zi` values, 
 in a matrix with size equal to the size of the input `z` parameter. It requires the following parameters:
  
* `x, y, z`: the known function values of the bivariate function `f(x,y)=z`, used to create the interpolant.
* `xi, yi`: locations to interpolate.
* `'method'`: the method to use. Available:
    - `'Nearest'`: Nearest Neighbor.
    - `'Delaunay'`: Delaunay triangulation (linear interpolation).
    - `'Natural'`: Natural neighbors.
    - `'IDW'`: Inverse Distance Weighted.
    - `'Kriging'`: Kriging interpolation.
    - `'MLS'`: Moving Least Squares.
    - `'RBF.<rbf_type>'`: Radial Basis Functions.
    - `'QTPURBF.<rbf_type>'`: QuadTree Partition of Unity BRF.
    
    For the last two cases, you need to indicate in <rbf_type>
    the type of the Radial Basis Function to use. Available:
    
    - `'linear'`
    - `'cubic'`
    - `'quintic'`
    - `'multiquadric'`
    - `'thinplate'`
    - `'green'`
    - `'tensionspline'`
    - `'regularizedspline'`
    - `'gaussian'`
    - `'wendland'`
    
    For more information on each RBF, please check their individual documentation in their corresponding functions on the `rbf` folder of this toolbox.
    
* `options`: Options data structure. 

Regarding this last `options` parameter, each algorithm has its own set of options that may be tuned according to the data. 
In case this structure is not provided, a set of default values will be generated using the `hmitScatteredDefaultOptions` function.
The values returned by this function may not fit your data at all. We encourage the user to read the documentation of the 
individual methods in order to set the options properly. The parameters structure should follow that returned by the `hmitScatteredDefaultOptions`
function, so a good way of setting parameters is to generate this structure using the function, and then change some of them as required. 
Note: "Nearest", "Delaunay" and "Natural" methods do not require any parameters, so you can skip this parameter.
  
### Inpainting Methods

Inpainting methods assume the data is already gridded, and present a more efficient way of computing the interpolation of 
large areas of missing data by taking advantage of this regular lattice. The individual inpainting functions can be found at:
`inpainting` folder. They are the following:

* `SobolevInpainter`: implements an inpainting method equivalent to a harmonic interpolant. 
* `TVInpainter`: implements an inpainting method following the Total Variation Partial Differential Equation (PDE).
* `CCSTInpainter`: implements the method described in "W. H. F. Smith, and P. Wessel, 1990, Gridding with continuous curvature splines in tension, Geophysics, 55, 293-305." the PDE equivalent of a RBF interpolation using Green functions. It allows tuning the tension parameter. When tension = 0, it behaves as a biharmonic interpolant, and when the tension = 1, as a harmonic interpolant, a value in between is a mix of both.
* `AMLEInpainter`: implements the method described in: "A. Almansa, F. Cao, Y. Gousseau, and B. Rougé. Interpolation of Digital Elevation Models Using AMLE and Related Methods. IEEE Transactions on Geoscience and remote sensing, vol. 40, no. 2, February 2002."
* `BertalmioInpainter`: implements the method described in "M. Bertalmio, G. Sapiro, V. Caselles, and C. Ballester. 2000. Image inpainting. In Proceedings of the 27th annual conference on Computer graphics and interactive techniques (SIGGRAPH ’00). ACM Press/Addison-Wesley Publishing Co., USA, 417–424. DOI: https://doi.org/10.1145/344779.344972". **WARNING**: this function is still under development and may not work as expected...
  
Since this project is part of the EMODnet HRSM project, we provide the `interpolateNetCDF` function for applying all these inpainting solutions 
to NetCDF files complying with the [EMODnet format](https://www.emodnet-bathymetry.eu/internal_html/qaqc-and-dtm-production-details/9).
This function includes the same functionality as in `interpolateScattered`, that is, we can apply all the generic interpolants to gridded data.
However, in addition, it allows applying the inpainting solutions. Thus, the "method" parameter of `interpolateScattered` is expanded with the following set of valid options:

* method:
    - `inpainting.<type>`: Inpainting method. Available types:
        - `sobolev`
        - `tv`
        - `amle`
        - `ccst`
        - `bertalmio`

## More Documentation

The code is self-documented. Each function in the toolbox can be queried for `help` in the usual Matlab way, for instance:

```
help interpolateScattered
```

In addition, we provide a complete per-function documentation (generated with [m2html](https://www.artefact.tk/software/matlab/m2html/)) at: [hmit-docs.coronis.es](http://hmit-docs.coronis.es)

Finally, take a look at the different demos on the `demo` folder. In addition to showing the behaviour of the methods on some sample data, their sources also show how to call the different interpolation functions/objects individually.

## 3rd Party Dependencies

This project uses some third party dependencies (included in the present code, in the `3rd_party` folder):

* [fminsearchbnd](https://uk.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon).
* Some functions from [The Numerical Tours of Signal Processing](http://www.numerical-tours.com/about/). G. Peyré, The Numerical Tours of Signal Processing - Advanced Computational Signal and Image Processing IEEE Computing in Science and Engineering, vol. 13(4), pp. 94-97, 2011.

## Acknowledgements

This project has been developed by Coronis Computing S.L. within the EMODnet HRSM project.

* EMODnet: http://www.emodnet.eu/
* EMODnet (bathymetry): http://www.emodnet-bathymetry.eu/
* Coronis: http://www.coronis.es
