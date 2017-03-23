def preprocess_img(img):
    # Histogram normalization in y
    IMG_SIZE = 48
    hsv = color.rgb2hsv(img)
    hsv[:,:,2] = exposure.equalize_hist(hsv[:,:,2])
    img = color.hsv2rgb(hsv)

    # central scrop
    min_side = min(img.shape[:-1])
    centre = img.shape[0]//2, img.shape[1]//2
    img = img[centre[0]-min_side//2:centre[0]+min_side//2,centre[1]-min_side//2:centre[1]+min_side//2,:]

    # rescale to standard size
    #img = transform.resize(img, (IMG_SIZE, IMG_SIZE))

    # roll color axis to axis 0
    img = np.rollaxis(img,-1)

    return img

def recognize():
        I = []
        img = preprocess_img(src)
        #img = io.imread('f.jpg')
        #img = transform.resize(img,(48, 48))
        #img = np.rollaxis(img,-1)
        I.append(img)
        R = modelf.predict_classes(np.array(I,dtype='float32'))
        return R[0]
if __name__ == '__main__':
        a = recognize()
        #eng = matlab.engine.start_matlab('-nojvm')
        #eng.test2
        #print y
        #eng.quit()
