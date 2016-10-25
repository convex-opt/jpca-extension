## Objective

![image](https://cloud.githubusercontent.com/assets/1677179/19693508/d4bac9f2-9aa9-11e6-806b-76ca4dc124c2.png)

![image](https://cloud.githubusercontent.com/assets/1677179/19276723/4edc2cae-8fa5-11e6-9ef2-78435a3ad130.png)

Given noisy (high-d) observations, find latent (low-d) space with linear dynamics.

### Approach: Coordinate descent on `A,B,C`:

First, we introduce a matrix `C` in place of one of the `A`s. Our new objective is now:

![image](https://cloud.githubusercontent.com/assets/1677179/19693601/1fb9561c-9aaa-11e6-81d1-bc24aeca7632.png)

Now, we solve the objective iteratively:

* Given `A` and `C`, minimize the objective in `B` via linear regression.
* Given `B` and `C`, minimize the objective in `A` via some form of gradient descent.
* Given `A` and `B`, minimize the objective in `C` via reduced-rank Procrustes rotation.
