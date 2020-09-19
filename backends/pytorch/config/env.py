import os
import argparse
import random
import torch
import numpy as np

from torch.backends import cudnn

class Settings():
  def __init__(self, seed=0):
    args = self.parse_args()
    os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
    os.environ['CUDA_VISIBLE_DEVICES'] = args.gpus

    # Reproducity
    cudnn.benchmark = False            # if benchmark=True, deterministic will be False
    cudnn.deterministic = True
    torch.manual_seed(seed)            # 为CPU设置随机种子
    torch.cuda.manual_seed(seed)       # 为当前GPU设置随机种子
    torch.cuda.manual_seed_all(seed)   # 为所有GPU设置随机种子
    random.seed(seed)
    np.random.seed(seed)

    # Log
    print("| Env: [GPUs: {0}]".format(args.gpus))


  def parse_args(self):
    parser = argparse.ArgumentParser(description='Action Recognition Framework by Outerspace Lab.')
    parser.add_argument('--gpus', dest='gpus', default="", type=str)
    args, unknown = parser.parse_known_args()
    return args




