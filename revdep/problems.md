# AlphaHull3D

<details>

* Version: 2.0.0
* GitHub: https://github.com/stla/AlphaHull3D
* Source code: https://github.com/cran/AlphaHull3D
* Date/Publication: 2022-11-25 09:00:02 UTC
* Number of recursive dependencies: 43

Run `revdepcheck::revdep_details(, "AlphaHull3D")` for more info

</details>

## Newly broken

*   checking compiled code ... WARNING
    ```
    File ‘AlphaHull3D/libs/AlphaHull3D.so’:
      Found ‘__ZNSt3__14cerrE’, possibly from ‘std::cerr’ (C++)
        Object: ‘alphahull3d.o’
      Found ‘_abort’, possibly from ‘abort’ (C)
        Object: ‘alphahull3d.o’
      Found ‘_exit’, possibly from ‘exit’ (C)
        Object: ‘alphahull3d.o’
    
    Compiled code should not call entry points which might terminate R nor
    write to stdout/stderr instead of to the console, nor use Fortran I/O
    nor system RNGs nor [v]sprintf.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
    ```

# Boov

<details>

* Version: 1.0.0
* GitHub: https://github.com/stla/Boov
* Source code: https://github.com/cran/Boov
* Date/Publication: 2022-10-31 12:52:40 UTC
* Number of recursive dependencies: 42

Run `revdepcheck::revdep_details(, "Boov")` for more info

</details>

## Newly broken

*   checking compiled code ... WARNING
    ```
    File ‘Boov/libs/Boov.so’:
      Found ‘__ZNSt3__14cerrE’, possibly from ‘std::cerr’ (C++)
        Objects: ‘operations.o’, ‘unexported1.o’, ‘unexported2.o’
      Found ‘_abort’, possibly from ‘abort’ (C)
        Objects: ‘operations.o’, ‘unexported1.o’
      Found ‘_exit’, possibly from ‘exit’ (C)
        Objects: ‘operations.o’, ‘unexported1.o’
    
    Compiled code should not call entry points which might terminate R nor
    write to stdout/stderr instead of to the console, nor use Fortran I/O
    nor system RNGs nor [v]sprintf.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
    ```

# delaunay

<details>

* Version: 1.1.1
* GitHub: https://github.com/stla/delaunay
* Source code: https://github.com/cran/delaunay
* Date/Publication: 2022-10-19 08:45:08 UTC
* Number of recursive dependencies: 60

Run `revdepcheck::revdep_details(, "delaunay")` for more info

</details>

## Newly broken

*   checking compiled code ... WARNING
    ```
    File ‘delaunay/libs/delaunay.so’:
      Found ‘__ZNSt3__14cerrE’, possibly from ‘std::cerr’ (C++)
        Object: ‘del3D.o’
      Found ‘_abort’, possibly from ‘abort’ (C)
        Object: ‘del3D.o’
      Found ‘_exit’, possibly from ‘exit’ (C)
        Object: ‘del3D.o’
    
    Compiled code should not call entry points which might terminate R nor
    write to stdout/stderr instead of to the console, nor use Fortran I/O
    nor system RNGs nor [v]sprintf.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
    ```

# MinkowskiSum

<details>

* Version: 1.0.0
* GitHub: https://github.com/stla/MinkowskiSum
* Source code: https://github.com/cran/MinkowskiSum
* Date/Publication: 2022-10-28 16:32:36 UTC
* Number of recursive dependencies: 42

Run `revdepcheck::revdep_details(, "MinkowskiSum")` for more info

</details>

## Newly broken

*   checking compiled code ... WARNING
    ```
    File ‘MinkowskiSum/libs/MinkowskiSum.so’:
      Found ‘__ZNSt3__14cerrE’, possibly from ‘std::cerr’ (C++)
        Objects: ‘MinkowskiSum.o’, ‘unexported1.o’, ‘unexported2.o’
      Found ‘_abort’, possibly from ‘abort’ (C)
        Objects: ‘MinkowskiSum.o’, ‘unexported1.o’
      Found ‘_exit’, possibly from ‘exit’ (C)
        Objects: ‘MinkowskiSum.o’, ‘unexported1.o’
    
    Compiled code should not call entry points which might terminate R nor
    write to stdout/stderr instead of to the console, nor use Fortran I/O
    nor system RNGs nor [v]sprintf.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
    ```

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.9Mb
      sub-directories of 1Mb or more:
        libs   5.8Mb
    ```

# PolygonSoup

<details>

* Version: 1.0.1
* GitHub: https://github.com/stla/PolygonSoup
* Source code: https://github.com/cran/PolygonSoup
* Date/Publication: 2022-10-19 13:37:56 UTC
* Number of recursive dependencies: 42

Run `revdepcheck::revdep_details(, "PolygonSoup")` for more info

</details>

## Newly broken

*   checking compiled code ... WARNING
    ```
    File ‘PolygonSoup/libs/PolygonSoup.so’:
      Found ‘__ZNSt3__14cerrE’, possibly from ‘std::cerr’ (C++)
        Objects: ‘ReadWrite.o’, ‘mesh.o’, ‘unexported1.o’, ‘unexported2.o’
      Found ‘__ZNSt3__14coutE’, possibly from ‘std::cout’ (C++)
        Object: ‘ReadWrite.o’
      Found ‘_abort’, possibly from ‘abort’ (C)
        Objects: ‘mesh.o’, ‘unexported1.o’
      Found ‘_exit’, possibly from ‘exit’ (C)
        Objects: ‘mesh.o’, ‘unexported1.o’
    
    Compiled code should not call entry points which might terminate R nor
    write to stdout/stderr instead of to the console, nor use Fortran I/O
    nor system RNGs nor [v]sprintf.
    
    See ‘Writing portable packages’ in the ‘Writing R Extensions’ manual.
    ```

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘PolygonSoup-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: Mesh
    > ### Title: Make a 3D mesh
    > ### Aliases: Mesh
    > 
    > ### ** Examples
    > 
    > library(PolygonSoup)
    ...
    > # we construct a mesh with a lot of duplicated vertices
    > library(misc3d) # to compute a mesh of an isosurface
    Error: package or namespace load failed for ‘misc3d’:
     .onLoad failed in loadNamespace() for 'tcltk', details:
      call: dyn.load(file, DLLpath = DLLpath, ...)
      error: unable to load shared object '/Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/library/tcltk/libs/tcltk.so':
      dlopen(/Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/library/tcltk/libs/tcltk.so, 10): Library not loaded: /opt/X11/lib/libfreetype.6.dylib
      Referenced from: /opt/R/x86_64/lib/libtk8.6.dylib
      Reason: Incompatible library version: libtk8.6.dylib requires version 25.0.0 or later, but libfreetype.6.dylib provides version 24.0.0
    Execution halted
    ```

