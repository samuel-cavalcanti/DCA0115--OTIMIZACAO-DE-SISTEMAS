import numpy as np
from matplotlib import pyplot


def plot_box(dir_path:str, algorithm:str,title:str):

    pyplot.figure(algorithm)
    pyplot.title(title)

    for size in ["4","8","16"]:
        file_name = dir_path +size+ "u.csv"
        data  =  np.loadtxt(file_name,delimiter=",")
        pyplot.hist(data,normed=False,label= algorithm + size )
    
    pyplot.legend()

    pyplot.show()






if __name__ == "__main__":
    pso_file = "nuvemDeParticulas/PSO"

    ga_file = "arquivosCSV/GA/GA_mutation_0.03_"


    
    #plot_box(pso_file,"PSO")
    
    plot_box(ga_file,"GA ","Comparação entre as populações com 3% de mutação")
    

    pass