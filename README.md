## Objective

![image](https://cloud.githubusercontent.com/assets/1677179/19276723/4edc2cae-8fa5-11e6-9ef2-78435a3ad130.png)

Given noisy (high-d) observations, find latent (low-d) space with linear dynamics.

![image](https://cloud.githubusercontent.com/assets/1677179/19276559/c2110754-8fa4-11e6-9483-e96dc54f35a3.png)

### Approach 1: Iteratively solve for `A,B,C`:

* Given `B`, minimize the second term in the objective for `C` via some form of gradient descent.
* Given `C`, solve for `A` in the first term of the objective via a reduced-rank Procrustes rotation.
* Set `C = A`. Given `C`, solve for `B` via linear regression.

![image](https://cloud.githubusercontent.com/assets/1677179/19276585/dc1d7f1a-8fa4-11e6-9290-aa371ac484d5.png)
