import torch
import torchvision
import time
import os
import matplotlib.pyplot as plt
import numpy as np
import torch.nn as nn
import torch.optim as optim
import torchvision.models as models

from torch.utils.tensorboard import SummaryWriter

class Backbone(object):
  def __init__(self, args, data):
    self.args = args
    self.data = data

    if not os.path.exists(self.args.train_dir): 
      os.makedirs(self.args.train_dir)
      self.backbone = models.resnet18(pretrained=True)
      self.backbone.fc = nn.Linear(in_features=512, out_features=self.data.num_classes)
    else:
      # Load
      model_list = os.listdir(self.args.train_dir)
      max_index = 0
      for i, model_name in enumerate(model_list):
        if model_name.startswith('model'):
          index = int(model_name.split('-')[1].split('.')[0])
          if max_index < index:
            max_index = index
      self.data.step = max_index
      load_path = os.path.join(self.args.train_dir, 'model-{0}.pth'.format(self.data.step))
      print("| Load model: {0}".format(load_path))
      self.backbone = models.resnet18(pretrained=False)
      self.backbone.fc = nn.Linear(in_features=512, out_features=self.data.num_classes)
      device = torch.device("cuda")
      self.backbone.load_state_dict(torch.load(load_path))
      if torch.cuda.is_available(): self.backbone.to('cuda')
      self.backbone.eval()

      if self.data.args.mode == 'test': 
        self.data.step = 0
        self.tp_list = [0]*10000
        self.pre_list = [0]*10000
        self.label_list = [0]*10000


    self.writer = SummaryWriter(os.path.join(self.args.train_dir, 'summary'))

    for para in list(self.backbone.parameters()):
      para.requires_grad=True
    self.c = nn.CrossEntropyLoss()
    self.optimizer = optim.SGD([{'params': self.backbone.parameters(), 
                                 'initial_lr': self.args.lr}], 
                               lr=self.args.lr, momentum=0.9)
    self.lr = optim.lr_scheduler.CosineAnnealingLR(
                       self.optimizer, 
                       self.data.INFO['max_steps'], eta_min=0,
                       last_epoch=self.data.step)
    self.smooth_loss = 0
  
  def __call__(self, data):
    """
        Args: data['frames'] [b, n, t, h, w, 3]
                             [0, 1, 2, 3, 4, 5]
    """
    #print("-> debug Backbone in model.py")
    labels = torch.from_numpy(np.argmax(data['labels'], 1))
    data_shape = data['frames'].shape
    data = np.reshape(data['frames'], 
                      [-1, data_shape[3], data_shape[4], data_shape[-1]])
    data = np.transpose(data, [0, 3, 1, 2])                  
    data = torch.from_numpy(data).float()

    # TODO
    #self.writer.add_graph(self.backbone)

    # GPU
    if torch.cuda.is_available():
      data = data.to('cuda')
      labels = labels.to('cuda')
      self.backbone = self.backbone.to('cuda')
    
    # Inference
    logits = self.backbone(data)
    logits = logits.reshape([data_shape[0], data_shape[1], data_shape[2], -1])
    logits = logits.mean([1,2])
    
    if self.data.args.mode == 'train':
      # Loss
      l = self.c(logits, labels)

      # Grad
      self.optimizer.zero_grad()
      l.backward()
      self.optimizer.step()
      self.lr.step()
    
      # Log
      alpha = 0.6
      self.smooth_loss = alpha * self.smooth_loss + (1 - alpha) * l
      if self.data.step % self.args.log_steps == 0 or \
         self.data.step == 1:
        # summary 
        dis_data = data 
        dis_data[:, 0, :, :] = data[:, 0, :, :]*0.229+0.485 
        dis_data[:, 1, :, :] = data[:, 1, :, :]*0.224+0.456 
        dis_data[:, 2, :, :] = data[:, 2, :, :]*0.225+0.406 
        img_grid = torchvision.utils.make_grid(dis_data)
        self.writer.add_image('input_images', img_grid)

        # screen print
        print("| [\033[32m{1:" "3d}%\033[0m {0}] Epoch: {2}/{3}, Step: {4}/{5}, Learning_rate: {8:.6f}, Loss: {6:.4f} ({7:.4f})".format(
             time.ctime(),
             int(self.data.step/self.data.INFO['max_steps']*100), self.data.epoch, 
             self.data.args.epoches, 
             self.data.step, self.data.INFO['max_steps'], l, self.smooth_loss,
             self.optimizer.state_dict()['param_groups'][0]['lr']), 
             end='\r', flush=True)

      # Save
      if (self.data.step % \
         int(self.args.save_epoches*self.data.INFO['steps_per_epoch']) == 0) \
         or (self.data.step == self.data.INFO['max_steps'] - 1) or self.data.step == 1 :
        save_path = os.path.join(self.args.train_dir, 
                                 'model-{0}.pth'.format(self.data.step))
        torch.save(self.backbone.state_dict(), save_path) 
        model_list = os.listdir(self.args.train_dir)
        max_index = 0
        index_list = []

        for i, model_name in enumerate(model_list):
          if model_name.startswith('model'):
            index = int(model_name.split('-')[1].split('.')[0])
            index_list.append(index)
        
        index_list = np.sort(index_list)[-10:]

        for i, model_name in enumerate(model_list):
          if model_name.startswith('model'):
            model_path = os.path.join(self.args.train_dir, model_name)
            if int(model_name.split('-')[1].split('.')[0]) not in index_list:
              os.system('rm {0}'.format(model_path))
    elif self.data.args.mode == 'test':
      pre_index = torch.argmax(logits, dim=1)
      if pre_index == labels:
        self.tp_list[pre_index] += 1
      self.pre_list[pre_index] += 1
      self.label_list[labels] += 1

      # re
      label_sel = np.array(self.label_list) > 0
      all_label_sel = np.array(self.label_list)[label_sel]
      all_tp_sel = np.array(self.tp_list)[label_sel]
      all_re = all_tp_sel / all_label_sel

      # acc
      pre_sel = np.array(self.pre_list) > 0
      all_pre_sel = np.array(self.pre_list)[pre_sel]
      all_tp_sel = np.array(self.tp_list)[pre_sel]
      all_acc = all_tp_sel / all_pre_sel 
     
      # log
      print("| [\033[32m{1:" "3d}%\033[0m {0}] Epoch: {2}/{3}, Step: {4}/{5}, Acc: {6:.4f}, Re: {7:.5f}".format(
            time.ctime(), int(self.data.step/self.data.INFO['max_steps']*100), 
            self.data.epoch, self.data.args.epoches, self.data.step, 
            self.data.INFO['max_steps'], all_acc.mean(), all_re.mean()
            ))
       
      # display
      plt.ion()
      plt.figure("Test Performance")
      plt.subplot(121)
      plt.title('Recall')
      plt.bar(np.linspace(1, len(all_label_sel), len(all_label_sel)), all_re)
      plt.subplot(122)
      plt.title('Accuracy')
      plt.bar(np.linspace(1, len(all_pre_sel), len(all_pre_sel)), all_acc)
      plt.show()
      plt.pause(0.01)
      plt.clf()

