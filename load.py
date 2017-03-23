from keras.models import load_model
from skimage import io, color, exposure, transform
import h5py
import numpy as np
modelf = load_model('model_aug.h5')
