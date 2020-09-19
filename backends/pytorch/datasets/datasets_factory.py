import argparse

from preprocessing import transformer
from datasets import loader

class Settings():
  def __init__(self, preprocess=None):
    args = self.parse_args()
    self.data = loader.Dataset(args, preprocess.transformer.lancet)

    # 
    print("| Dataset: [dataset: {0}, dataset_type: {1}, \
\n|           split: {2}, mode: {3}, \
\n|           num_clips: {4}, num_frames: {5}, \
\n|           temporal_stride: {6}, batch_size: {7}, \
\n|           eoches: {8}]".format(
          args.dataset, args.dataset_type, args.split, args.mode, args.num_clips,
          args.num_frames, args.temporal_stride, args.batch_size, args.epoches))

  def parse_args(self):
    parser = argparse.ArgumentParser(description=
                                'Action Recognition Framework by Outerspace Lab.')
    parser.add_argument('--dataset', dest='dataset', default="ucf101", type=str)
    parser.add_argument('--dataset_type', dest='dataset_type', 
                        default="rgb", type=str)
    parser.add_argument('--dataset_root_dir', dest='dataset_root_dir', 
                        default=None, type=str)
    parser.add_argument('--split', dest='split', default="1", type=str)
    parser.add_argument('--mode', dest='mode', default="train", type=str)
    parser.add_argument('--num_clips', dest='num_clips', default=1, type=int)
    parser.add_argument('--num_frames', dest='num_frames', default=8, type=int)
    parser.add_argument('--temporal_stride', dest='temporal_stride', 
                        default=1, type=int)
    parser.add_argument('--batch_size', dest='batch_size', default=1, type=int)
    parser.add_argument('--epoches', dest='epoches', default=1, type=int)
    parser.add_argument('--gpus', dest='gpus', default="", type=str)
    args, unknown = parser.parse_known_args()
    return args
