#### 2016-06-24, Friday, Guangjian Zhang. Non-normal distributions. 

#### 2016-06-02, Thursday, Guangjian Zhang


orth.se.augmt <- function(Lambda, Rsample, N, extraction, rotation, normalize, modelerror, 
geomin.delta=NULL, MTarget=NULL, MWeight=NULL, u.r = NULL) {

# source('E:/CurrentSimulation/RCPhi/CorrelationDerivatives.R')
# source('E:/CurrentSimulation/RCPhi/EFAEstimation.R')
# source('E:/CurrentSimulation/RCPhi/EFAModelDerivatives.R')
# source('E:/CurrentSimulation/RCPhi/OrthDerivatives20160610.R')



# We assume that the manifest variables are normally distributed for the time being.

if (is.null(rotation)) stop ("No rotaton criterion is specified for numberical approximation")
if ((rotation=='geomin') & (is.null(geomin.delta))) geomin.delta = 0.01
if ((rotation=='target') & ((is.null(MWeight)) | (is.null(MTarget)))) stop ("MWeight or MTarget is not specified for target rotation")
if (is.null(modelerror)) modelerror='YES' 

p = dim(Lambda)[1]
m = dim(Lambda)[2]
Nc = m * (m-1) / 2 # the number of constraints
Nq = p * m + p  # the number of parameters

Phi = diag(m)

PM = Lambda %*% t(Lambda) 
PM = PM - diag(diag(PM)) + diag(p)

##

if (modelerror== 'NO') Rsample = PM

if (is.null(u.r)) u.r = EliU(Rsample)


# if (modelerror== 'YES') {
#  u.r = EliU(Rsample) 
# } else if (modelerror == 'NO') {
#   u.r = EliU(PM)
# } else {
#  stop("Model Error option is inappropriately specified.")
# }


#### dg2r and Hessian include factor loadings, factor correlations and unique variances
#### factor correlations need to be removed since the function deals with orthogonal rotation

if (extraction == 'ml') {

dg2r = D.g.2.r (Lambda, Phi, extraction='ml')
Hessian = EFA.Hessian (Lambda, Phi, Rsample, extraction='ml')


} else if (extraction == 'ols') {

dg2r = D.g.2.r (Lambda, Phi, extraction='ols')
Hessian = EFA.Hessian (Lambda, Phi, Rsample, extraction='ols')


} else {

stop ('Factor extraction method is incorrectly specified.')
}


#### To remove part of factor correlations

dg2r.orth = matrix(0,p*p, Nq)
dg2r.orth[,1:(p*m)] = dg2r[,1:(p*m)]
dg2r.orth[,(p*m+1):Nq] = dg2r[,(p*m + m*(m-1)/2 + 1): (p*m + m*(m-1)/2 + p)]

Ham = t(dg2r.orth) %*% u.r %*% dg2r.orth

###

if (rotation=='CF-varimax') {

Orth.Con.Parameters = Derivative.Orth.Constraints.Numerical (Lambda, 'CF-varimax',normalize)

} else if (rotation=='CF-quartimax') {

Orth.Con.Parameters = Derivative.Orth.Constraints.Numerical (Lambda, 'CF-quartimax',normalize)

} else if (rotation=='geomin') {

if (is.null(geomin.delta)) geomin.delta = 0.01

Orth.Con.Parameters = Derivative.Orth.Constraints.Numerical(Lambda,'geomin',normalize,geomin.delta)

} else if (rotation=='target') {

Orth.Con.Parameters = Derivative.Orth.Constraints.Numerical(Lambda,'target',normalize,MWeight=MWeight, MTarget=MTarget)

} else if (rotation=='unrotated') {

Orth.Con.Parameters = Derivative.Orth.Constraints.Numerical(Lambda,extraction)

} else {

  stop ("wrong specification for the factor rotation criterion")
}

### 

### Hessian matrix includes factor loadings, factor correlations, and unique variances
### The following code is to remove the part of factor correlations since the function deals with 
### ORTHOGONAL rotation
Temp.Bigger = matrix(0,(Nq+Nc),(Nq+Nc))
Temp.Bigger[1:(p*m),1:(p*m)] = Hessian [1:(p*m),1:(p*m)]
Temp.Bigger[(p*m + 1):(p*m + p), 1:(p*m)] = Hessian [(p*m + m*(m-1)/2 + 1):(p*m + m*(m-1)/2 + p),1:(p*m)]
Temp.Bigger[1:(p*m),(p*m + 1):(p*m + p)] = Hessian [1:(p*m),(p*m + m*(m-1)/2 + 1):(p*m + m*(m-1)/2 + p)]
Temp.Bigger[(p*m+1):Nq, (p*m+1):Nq] = Hessian [(p*m + m*(m-1)/2 + 1):(p*m + m*(m-1)/2 + p),(p*m + m*(m-1)/2 + 1):(p*m + m*(m-1)/2 + p)]

if (m>1) {
Temp.Bigger[1:Nq,(Nq+1):(Nq+Nc)] = t(Orth.Con.Parameters)
Temp.Bigger[(Nq+1):(Nq+Nc),1:Nq] = Orth.Con.Parameters
}

Temp.Bigger.inverse = solve(Temp.Bigger)

Sandwich = Temp.Bigger.inverse[1:Nq,1:Nq] %*% Ham %*% Temp.Bigger.inverse[1:Nq,1:Nq]

###

SE = sqrt(diag(Sandwich)/(N-1))

Lambda.se <- array(SE[1: (p*m) ],dim=c(p,m))


Psi.se <- SE[(p*m+1):Nq]

##
list(Lambda.se = Lambda.se,  Psi.se = Psi.se)

} # orth.se.augmt

