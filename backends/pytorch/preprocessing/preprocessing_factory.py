import argparse


from preprocessing import transformer

class Settings():
  def __init__(self):
    args = self.parse_args()
    self.transformer = transformer.Lancet(args)
 
    # Log
    print("| Preprocessing: [input_size: {0}, preprocess: {1}]".format(args.input_size,
           args.preprocess))

  def parse_args(self): 
    parser = argparse.ArgumentParser(description=
                                     'Action Recognition Framework by Outerspace Lab.')
    parser.add_argument('--input_size', dest='input_size', 
                        default=224, type=int)      
    parser.add_argument('--preprocess', dest='preprocess', 
                        default="Resize", type=str)      
    args, unknown = parser.parse_known_args()
    return args
