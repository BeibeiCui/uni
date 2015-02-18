
"""
Modification of the graph drawing Algorithm from T.Kamada & S.Kawai for purpose of
local beatification used in algorithm from D.Harel and Y.Koren, 
"A fast multi-scale mathod for drawing large graphs", 2002 

"""

import numpy as np
from graphToDraw import *

def dEnergyOfSprings(radius, n, p, dist, k, l):
    #compute the partial derivatives of energy function
        
    dEx=np.zeros([n,1])
    dEy=np.zeros([n,1])
    # thats inefficient (use slicing, numpy sum ect.), but since its only O(n^2) and we already have O(n^3) it stays for now
    for m in range(n):
        for i in k_neighborhood(m, dist, radius):
            
            dEx[m] += k[m,i] * ((p[0,m] - p[0,i]) - l[m,i] *(p[0,m] - p[0,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
            dEy[m] += k[m,i] * ((p[1,m] - p[1,i]) - l[m,i] *(p[1,m] - p[1,i]) / np.sqrt(( (p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)) ) 
        # end for i
    # end for m      
    return dEx, dEy
#end EnergyOfSprings


# ---------------------------------------------------------------------------
def moveNode_m(radius, n, p, dist, k, l, Ex, Ey, Delta_m, m):
        
    Hess = np.zeros([2,2])
    for i in k_neighborhood(m, dist, radius):
            
        Hess[0,0] += 2* k[m,i] * (1 - l[m,i] *(p[1,m] - p[1,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
        Hess[1,1] += 2* k[m,i] * (1 - l[m,i] *(p[0,m] - p[0,i])**2                / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 )  
        Hess[0,1] += 2* k[m,i] * (    l[m,i] *(p[1,m] - p[1,i])*(p[0,m] - p[0,i]) / ((p[0,m] - p[0,i])**2 + (p[1,m] - p[1,i])**2)**1.5 ) 
    # end for i
    Hess[1,0]=Hess[0,1]
            
    delta = np.linalg.solve(Hess, np.array([-Ex[m],-Ey[m]]))
    p[:,m] = p[:,m] + delta.T

    return p
#End modeNode_m    


# ---------------------------------------------------------------------------        
def mainAlgorithm(radius, n, p, dist, k, l , nit):
    
    maxit_outer=0 
    
    #compute the partial derivatives of energy function
    Ex, Ey = dEnergyOfSprings(radius, n, p, dist, k, l)    
    Delta = np.sqrt(Ex*Ex + Ey*Ey)
    
    while(maxit_outer< nit):
        m = np.argmax(Delta)
        
        # move one node
        p = moveNode_m(radius, n, p, dist, k, l, Ex, Ey, Delta[m], m)

        #recompute the partial derivatives of energy function
        Ex, Ey = dEnergyOfSprings(radius, n, p, dist, k, l)  
        Delta = np.sqrt(Ex*Ex + Ey*Ey)    
    
        maxit_outer += 1
    # end while(np.max(Delta)>eps):   
    return p, maxit_outer
# end newtonraphson    