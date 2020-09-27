import torch
import os 

from config import env
from datasets import datasets_factory
from preprocessing import preprocessing_factory
from nets import nets_factory

def main():
  # Start
  os.system('clear')
  print("+ Video Recognition")

  # System
  env.Settings(seed=0)

  # Preprocessing
  preprocess = preprocessing_factory.Settings()

  # Dataset
  dataset = datasets_factory.Settings(preprocess)

  # Net
  net = nets_factory.Settings(dataset) 

  # Run
  for d in dataset.data:
    # display d [b, n, t, h, w, 3]
    #dataset.data.show(d)
    
    # inference
    net.model(d)

  # End
  print("\n- Finish.")


if __name__ == "__main__":
  main()
