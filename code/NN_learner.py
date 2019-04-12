import numpy as np
import scipy as sp
import pandas as pd
import os, sys
import torch as th
from tensorboardX import SummaryWriter

BATCH_SIZE = 512
LEARNING_RATE = .0001
NUM_NEURONS_LAYER1 = 100
MAX_ITER = 10
DEVICE = 'cuda'
NAME = 'DEFAULT'

def iterate_batches(tensorX, tensorY, batch_size=BATCH_SIZE, device = DEVICE):
    ''' Generate the iterate batches
    Input:
        tensorX : torch tensor 2d
        tensorY : torch tensor 2d
        n : int, number of rows in tensorX
    '''
    n = tensorX.shape[0]
    i = 0
    tmp = th.randperm(n)
    tensorX = tensorX[tmp,:]
    tensorY = tensorY[tmp,:]
    iter = 0
    while True:
        if i + BATCH_SIZE > n:
            tmp = th.randperm(n)
            tensorX = tensorX[tmp,:]
            tensorY = tensorY[tmp,:]
            i = 0
        yield iter, tensorX[i:(i+BATCH_SIZE),:], tensorY[i:(i+BATCH_SIZE),:]
        i = i + BATCH_SIZE
        iter += 1
        
class NN(th.nn.Module):
    def __init__(self, input_dim, num_neurons1, output_dim, initialization = 'uniform', activation = 'ReLU'):
        super(NN, self).__init__()
        if activation == 'ReLU':
            self.pipe = th.nn.Sequential(
                th.nn.Linear(input_dim, num_neurons1),
                th.nn.ReLU(),
                th.nn.Linear(num_neurons1, output_dim),
            )
        elif activation == 'tanh':
            self.pipe = th.nn.Sequential(
                th.nn.Linear(input_dim, num_neurons1),
                th.nn.tanh(),
                th.nn.Linear(num_neurons1, output_dim),
            )
        else:
            raise ValueError('activation cannot be found (%s).'%(activation))
        
    def forward(self, x):
        return self.pipe(x)

def NN_learner(X, y, 
               initial_model = None,
               batch_size = BATCH_SIZE,
               learning_rate = LEARNING_RATE,
               num_neurons_layer1 = NUM_NEURONS_LAYER1,
               device = DEVICE, 
               max_iter = MAX_ITER,
               method = 'adam',
               name = NAME):
    ''' Train a NMF auto encoder using X
    Input:
        X : numpy array 2d, n * d
        y : numpy array 2d, n * 1
    '''
    input_dim = X.shape[1]
    output_dim = 1
    writer = SummaryWriter('runs/'+name)
    if initial_model is None:
        nn = NN(input_dim, 
              num_neurons1=num_neurons_layer1,
              output_dim = output_dim).to(device)
    else:
        nn = initial_model
    if method == 'adam':
        optimizer = th.optim.Adam(params=nn.parameters(), lr=learning_rate, betas=(.5, .999))
    elif method == 'sgd':
        optimizer = th.optim.SGD(params=nn.parameters(), lr=learning_rate)
    else:
        raise ValueError('optimization method not allowed (%s)'%(method))
    l2loss = th.nn.MSELoss(reduction='mean')
    tensorX = th.tensor(X.astype(np.float32)).to(device)
    tensorY = th.tensor(y.astype(np.float32)).to(device)
    for iter, batch_x, batch_y in iterate_batches(tensorX, tensorY, device):
        nn.zero_grad()  # zero out the gradient
        output = nn(batch_x)
        label = (output > .5)
        obj = l2loss(output, batch_y)
        writer.add_scalar('precision', th.mean(batch_y[label]), iter)
        writer.add_scalar('objective', obj, iter)
        writer.add_scalar('recall', th.mean(output[batch_y > .5]), iter)
        writer.add_scalar('accuracy', th.mean(((batch_y > .5) == label).type(th.cuda.FloatTensor)), iter)    
        obj.backward()
        optimizer.step()
        if iter > max_iter:
            break
    writer.close()
    return nn
            
