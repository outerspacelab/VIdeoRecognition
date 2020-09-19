import torch
import os
import numpy as np
import pandas as pd  
import matplotlib.pyplot as plt
from torch.utils.data import Dataset, DataLoader
from skimage import io, transform

class Dataset(Dataset):
  def __init__(self, args, transformer=None):
    self.args = args
    self.step = 0
    self.epoch = 0
    self.transformer = transformer

    self.dataset_dir = os.path.join(args.dataset_root_dir,
                                    args.dataset,
                                    args.dataset_type)
    self.train_info = pd.read_csv(os.path.join(args.dataset_root_dir, args.dataset,
                             "info", "train_split"+args.split+".txt"), " ",
                             header=None)
    self.test_info = pd.read_csv(os.path.join(args.dataset_root_dir, args.dataset,
                             "info", "test_split"+args.split+".txt"), " ",
                             header=None)
    self.num_classes = np.max(self.train_info.iloc[:, 2]) + 1
    self.INFO = {"num_train": len(self.train_info), "num_test": len(self.test_info), 
                 "num_classes": self.num_classes}  
    if self.args.mode == "train":             
      self.INFO["max_steps"] = int(self.args.epoches * self.INFO['num_train']/\
                     (len(self.args.gpus.split(',')) * self.args.batch_size))           
    else:
      self.INFO["max_steps"] = int(self.args.epoches * self.INFO['num_test']/\
                     (len(self.args.gpus.split(',')) * self.args.batch_size))  

    self.INFO['train'] = self.train_info
    self.INFO['test'] = self.test_info
    self.idx = list(range(self.INFO['num_'+self.args.mode]))
    self.INFO['iterms_name'] = self.INFO[self.args.mode].iloc[self.idx, 0]
    self.INFO['iterms_num'] = self.INFO[self.args.mode].iloc[self.idx, 1]
    self.INFO['iterms_label'] = self.INFO[self.args.mode].iloc[self.idx, 2]
    self.INFO['period'] = self.args.temporal_stride * (self.args.num_frames-1) + 1
    self.INFO['steps_per_epoch'] = self.INFO['num_' +self.args.mode] / \
                                (self.args.batch_size * len(self.args.gpus.split(',')))

  def __len__(self): return self.INFO['num_'+self.args.mode]

  def __getitem__(self, idx):
    if torch.is_tensor(idx):
      idx = idx.tolist()

    batch_frame_list = []
    batch_label_list = []
    
    for i in idx:
      iterm_path = os.path.join(self.dataset_dir,
                              self.INFO['iterms_name'][i]).split('.')[0] 
      iterm_num   = self.INFO['iterms_num'][i]
      iterm_label = self.INFO['iterms_label'][i]
      clip_frame_list = []

      for k in range(self.args.num_clips):
        if self.args.mode == "train":
          start_index = np.random.randint(0, 
                            np.max([iterm_num-self.INFO['period'], 0])+1, size=[1])[0]
        elif self.args.mode == "test": 
          start_index = int(k*iterm_num/self.args.num_clips)

        frame_list = []

        for j in range(self.args.num_frames):
          frame_index = start_index + j * self.args.temporal_stride + 1
          frame_index = np.clip(frame_index, 1, iterm_num)
          iterm_sub_path = os.path.join(iterm_path,
                                        "image_"+str('%04d'%frame_index + ".jpg"))
          frame = io.imread(iterm_sub_path)/255.
          # rgb -> bgr                              
          #frame = io.imread(iterm_sub_path)[:, :, [2, 1, 0]]/255
          frame_list.append(frame)

        frame_list = np.stack(frame_list, 0)    
        clip_frame_list.append(frame_list)  

      clip_frame_list = np.stack(clip_frame_list, 0)
      batch_frame_list.append(clip_frame_list) 
      batch_label_list.append(iterm_label)
    
    # [[clips, num_frames, h, w, 3],...] [0, 1, 4, ...] 
    data = {"frames": batch_frame_list, "labels": batch_label_list} 
   
    if self.transformer: 
      data = self.transformer(data)  
      data['frames'] = np.stack(data['frames'], 0)
    data['labels'] = np.eye(self.num_classes)[np.stack(data['labels'], 0)]

    return data 


  def __iter__(self): return self

  def __next__(self):
    if self.step >= self.INFO["max_steps"]:
      raise StopIteration()

    if self.args.mode == "train":
      index_list = np.random.randint(0, 
                                self.INFO['num_train'], size=(self.args.batch_size))
      data = self[index_list]
    elif  self.args.mode == "test": 
      index_list = np.linspace(self.step*self.args.batch_size, 
                 np.minimum((self.step+1)*self.args.batch_size, self.INFO['num_test']), 
                 self.args.batch_size+1).astype(int)
      index_list = index_list[:-1]              
      data = self[index_list]
    self.step += 1
    if self.args.mode == "train":               
      self.epoch = int(self.step * (len(self.args.gpus.split(',')) * 
                   self.args.batch_size) / self.INFO['num_train'])
    else:
      self.epoch = int(self.step * (len(self.args.gpus.split(',')) * 
                   self.args.batch_size) / self.INFO['num_test'])
      
    return data 

  def show(self, data):
    print("| Show images.")
    assert len(data['frames']) == len(data['labels'])
    batch_size = len(data['frames'])
    for i in range(batch_size):
      num_clips = len(data['frames'][i])
      for k in range(num_clips):
        num_frames = len(data['frames'][i][k])
        plt.ion()
        for j in range(num_frames):
          plt.figure("Read frames")
          plt.imshow(data['frames'][i][k][j]/7+0.5)
          plt.title("[%d/%d][i/batch], [%d/%d][k/clips], [%d/%d][j/frames], class:%d"%
                    (i, batch_size, k, num_clips, j, num_frames, np.argmax(data['labels'][i])))
          plt.show()
          plt.pause(0.01)
          plt.clf()
        plt.ioff()
