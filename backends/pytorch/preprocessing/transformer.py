import cv2 
import numpy as np

from torchvision import transforms, utils


class Lancet(object):
  def __init__(self, args):
    self.args = args
    self.LANCET={'RandomCrop': RandomCrop, 
                 'RandomHorizontalFlip': RandomHorizontalFlip, 
                 'Resize': Resize,
                 'Normalize':Normalize,}
    self.transformer_list = []
    for i in self.args.preprocess.split(','):
      if i in self.LANCET.keys():
        t = self.LANCET[i]()
        self.transformer_list.append(t)
      else: print("- %s does not exist, skip." % i )
    self.transformer_list.append(self.LANCET['Resize'](self.args.input_size))  
    self.transformer_list.append(self.LANCET['Normalize'](mean=[0.485, 0.456, 0.406],
                                                      std=[0.229, 0.224, 0.225]))
    self.lancet = transforms.Compose(self.transformer_list)
    


class Normalize(object):
  def __init__(self, mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]):
    self.mean = mean
    self.std = std

  def __call__(self, data):
    for i in range(len(data['frames'])):
      for j in range(3):
        data['frames'][i][:, :, :, :, j] = (data['frames'][i][:, :, :, :, j] - \
                                           self.mean[j]) / self.std[j]
    return data

class RandomCrop(object):
  """Crop randomly the image in a sample.

  Args:
      output_size (tuple or int): Desired output size. If int, square crop
          is made.
  """

  def __init__(self, scale = 0.8):
    self.low_threshold = scale

  def __call__(self, data):
    #print('-> debug in Class of RandomCrop.')
    # user code
    batch_size = len(data['frames'])
    num_clips = len(data['frames'][0])
    num_frames = len(data['frames'][0][0])
        
    for i in range(batch_size):
      shape = data['frames'][i].shape
      w = shape[2]
      h = shape[3]
      w_rand_scale = (1 - self.low_threshold) * \
                      np.random.rand() + self.low_threshold
      h_rand_scale = (1 - self.low_threshold) * \
                      np.random.rand() + self.low_threshold
      w_rand_scale = int(w * w_rand_scale) 
      h_rand_scale = int(h * h_rand_scale)
      start_w = np.random.randint(0, w - w_rand_scale + 1) 
      start_h = np.random.randint(0, h - h_rand_scale + 1) 
      data['frames'][i] = data['frames'][i][:, :, start_h:start_h+h_rand_scale,
                                            start_w:start_w+w_rand_scale, :]
    return data

class Resize(object):  
  def __init__(self, input_size=224):
    self.input_size = input_size  

  def __call__(self, data):
    #print('-> debug in Class of Resize')
    # user code
    batch_size = len(data['frames']) 
    num_clips = len(data['frames'][0])
    num_frames = len(data['frames'][0][0])
   

    batch_frame_list = []
    batch_label_list = []

    for i in range(batch_size):
      clip_frame_list = []
      for j in range(num_clips):
        frame_list = []
        for k in range(num_frames):
          frame_list.append(cv2.resize(data['frames'][i][j][k],
                                               (self.input_size,
                                               self.input_size)))
        frame_list = np.stack(frame_list, 0)                                     
        clip_frame_list.append(frame_list)
      clip_frame_list = np.stack(clip_frame_list, 0)
      batch_frame_list.append(clip_frame_list)
      batch_label_list.append(data['labels'][i]) 
    
    data = {"frames": batch_frame_list, "labels": batch_label_list}  
    return data 

class RandomHorizontalFlip(object):
  #def __init__(self):

  def __call__(self, data):
    #print('-> debug in Class of HoriFlip')
    # user code
    batch_size = len(data['frames']) 
    num_clips = len(data['frames'][0])
    num_frames = len(data['frames'][0][0])

    for i in range(batch_size):
      flip = np.random.randint(0, 2, size=(1))[0]
      for j in range(num_clips):
        for k in range(num_frames):
          if flip: data['frames'][i][j][k] = cv2.flip(data['frames'][i][j][k], 1)
    return data 
