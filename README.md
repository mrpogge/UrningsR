# UrningsR package developer notes

## Note:
The package is under development, if you want to contribute please fork the project and submit a pull request to the dev branch. 
The master branch contains the current release version, please do not pull request to that, otherwise it will be denied.

## About:
This package contains function with which one can simulate the behaviour of adaptive learning systems, and can analyse exsisting datasets coming from adaptive learning systesms. The focus of the package is the Urnings algorithm, and its variants for response time and multidimensional data, but it also includes wrappers for the Elo rating system(?).

For details see References.


## Package structure:
Users going to only interact with high level wrapper functions. In case you want to contribute please follow the following structure.

1. Create a separate .R files for each wrapper function and don't forget to add the "@export" decorator and some documentation.
2. Lower level functions, that are of a similar nature can be packed together in a .R file with the naming convention "util_*TYPEOFFUNCTION*".
3. Please do not create subfolders of the main R folder, and source the lower level functions using "source("./R/util_*LOWERFUNCTION*")"
4. Documentation should be created with "devtools::document()", for each exported function.
5. Testing should be created separately for each exported function, but tests for a given function should be in one file.
6. Please use the naming conventions for git commits. INIT: setup something new, DEV: adding new feature, FIX: fixing bugs, DEL: deleting something.


## What's New?:
I initialised the package structure, including the R folder, documentation folder and testthat. I also implemented a basic CI/CD based on github actions
which is triggered when there are pushes to the master branch. 


## References
- Bolsinova, M., Brinkhuis, M. J., Hofman, A. D., & Maris, G. (2022). Tracking a multitude of abilities as they develop. British Journal of Mathematical and Statistical Psychology, 75(3), 753-778.
- Bolsinova, M., Maris, G., Hofman, A. D., van der Maas, H. L., & Brinkhuis, M. J. (2022). Urnings: A new method for tracking dynamically changing parameters in paired comparison systems. Journal of the Royal Statistical Society. Series C: Applied Statistics, 71(1), 91-118.
- Deonovic, B., Bolsinova, M., Bechger, T., & Maris, G. (2020). A Rasch model and rating system for continuous responses collected in large-scale learning systems. Frontiers in psychology, 11, 500039.
- Gergely, B., van der Maas, H. L., Maris, G., Bolsinova, M. (2023). Warming up the Cold Start: Adaptive step size methods for the Urnings algorithm, in press
