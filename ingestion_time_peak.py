'''
Created on 22 ago 2021

@author: lorenzo
'''

import matplotlib.pyplot as pyplt
import numpy as np
import tkinter

if __name__ == '__main__':
    batch_size_500_ingestion = [99.475,52.046,34.436]
    batch_size_1300_ingestion = [62.308,39.73,35.234]
    batch_size_500_emulator = [37.864,38.225,32.926]
    batch_size_1300_emulator = [43.691,38.436,33.093]
    
    pos = np.arange(8)
    bar_width = 1
    
    pos = np.array([x*bar_width for x in pos])
    
    root = tkinter.Tk()
    root.withdraw()
    screen_witdth, screen_height = root.winfo_screenwidth(), root.winfo_screenheight()
    PIXEL_TO_INCH_FACTOR = 0.0104166667

    pyplt.figure(1, (7,5))
    pyplt.bar([0,3,6]*bar_width, batch_size_500_ingestion, width = bar_width, linestyle='-', edgecolor='k', linewidth=0.7, label='500')
    pyplt.bar([1,4,7]*bar_width, batch_size_1300_ingestion, width = bar_width, linestyle='-', edgecolor='k', linewidth=0.7, label='1300')
    ax = pyplt.gca()
    ax.set_xticks([0.5*bar_width, 3.5*bar_width, 6.5*bar_width])
    ax.set_xticklabels(['1','2','4'])
    pyplt.xticks(fontsize=14)
    pyplt.yticks(fontsize=14)
    pyplt.xlim(pos.min() - bar_width, pos.max() + bar_width)
    pyplt.ylim(0,110)
    pyplt.title("Ingestion Time", fontsize=18)
    pyplt.xlabel('Number of Tasks', fontsize=16)
    pyplt.ylabel('Time [s]', fontsize=16)
    pyplt.legend(fontsize=14)
    pyplt.savefig("ingestion_time_peak.pdf")
    
    pyplt.figure(2, (7,5))
    pyplt.bar([0,3,6]*bar_width, batch_size_500_emulator, width = bar_width, linestyle='-', edgecolor='k', linewidth=0.7, label='500')
    pyplt.bar([1,4,7]*bar_width, batch_size_1300_emulator, width = bar_width, linestyle='-', edgecolor='k', linewidth=0.7, label='1300')
    ax = pyplt.gca()
    ax.set_xticks([0.5*bar_width, 3.5*bar_width, 6.5*bar_width])
    ax.set_xticklabels(['1','2','4'])
    pyplt.xticks(fontsize=14)
    pyplt.yticks(fontsize=14)
    pyplt.xlim(pos.min() - bar_width, pos.max() + bar_width)
    pyplt.ylim(0,110)
    pyplt.title("Emulator Time", fontsize=18)
    pyplt.xlabel('Number of Tasks', fontsize=16)
    pyplt.ylabel('Time [s]', fontsize=16)
    pyplt.legend(fontsize=14)
    pyplt.savefig("emulator_time.pdf")