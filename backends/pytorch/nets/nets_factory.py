import argparse

from nets import model

class Settings():
  def __init__(self, dataset):
    args = self.parse_args()
    self.model = model.Backbone(args, dataset.data)

    # Log
    print("| Networks: [backbone: {0}]".format(args.backbone))

  def parse_args(self):
    parser = argparse.ArgumentParser(description=
                    'Action Recognition Framework by Outerspace Lab.')
    parser.add_argument('--backbone', dest='backbone', default="resnet18", type=str)  
    parser.add_argument('--train_dir', dest='train_dir', default=None, type=str)  
    parser.add_argument('--log_steps', dest='log_steps', default=100, type=int)  
    parser.add_argument('--save_epoches', dest='save_epoches', default=1, type=float)  
    parser.add_argument('--lr', dest='lr', default=0.000125, type=float)  
    args, unknown = parser.parse_known_args()
    return args
