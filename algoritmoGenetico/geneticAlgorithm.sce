clear
clc

function s_best = geneticAlgorithm(population_size,problem_size,p_mutation,epochs,max_variance)
    population = initialize_population(population_size,problem_size)
    population = evaluate_population(population)
    
    s_best = get_best_solution(population)
    
    //disp("first best " + string(s_best.score))
    
    epoch = 0
    variance_population = 10*max_variance
    
    while  epoch < epochs // && variance_population > max_variance
        parents = select_parents(population,population_size)
        
        childrens = list()
        // garantir que a varivel parents possua sempre um tamanho par
        for i=1: round(length(parents)/2)
             new_childrens = crossover(parents(i),parents(length(parents) -i +1))
             childrens($+1) = mutate(new_childrens(1),p_mutation)
             childrens($+1) =  mutate(new_childrens(2),p_mutation)
             
        end
          
        childrens = evaluate_population(childrens)
        best_children = get_best_solution(childrens)

        if best_children.score < s_best.score
            s_best = best_children
            
        end

        population = replace(population,childrens,s_best,best_children)
        
        epoch = 1 + epoch
        
        variance_population = calcule_variance(population)
        
    //    disp(" best " + string(s_best.score))
        
       // disp("variance "+ string(variance_population))
        //disp(" ")
        
        

   end
    
    //for individual=population
      //  disp("score "+string(individual.score))
    //end
    
    //disp("variance "+ string(variance_population))
    
    //disp("epoch "+ string(epoch))


endfunction


function individual = individual_new(chromossome_x, chromossome_y,max_value,min_value)
    individual = tlist(["T_individual","chromossome_x","chromossome_y","max","min","score"])
    individual.chromossome_x = chromossome_x
    individual.chromossome_y = chromossome_y
    individual.max = max_value
    individual.min = min_value
    individual.score = -%inf
endfunction


function value = bit_to_float(bit_vector,max_value,min_value)

    value = 0  
    length_vec = length(bit_vector)
    for i=2:length_vec
        value = bit_vector(i)*2^(1-i) + value
    end

    value = inv_normalize(value,max_value,min_value)

endfunction

function norm_value = normalize_value(value,max_value,min_value)
    
    norm_value = (value - min_value)/(max_value - min_value)

endfunction

function real_value = inv_normalize(value,max_value,min_value)
    real_value = value*(max_value - min_value) + min_value
endfunction

function bit_vector = real_to_bit(real_value,max_value,min_value)

    norm_value = normalize_value(real_value,max_value,min_value)
    number_bits = 50
    bit_vector = []

    for i=1:number_bits
        bit_vector(i) = int(norm_value)
        norm_value = norm_value - bit_vector(i)
        norm_value = norm_value *2       
    end

endfunction

function individual = generate_random_individual(problem_size)
    x =  inv_normalize(rand(1,"uniform"),problem_size(1),problem_size(2)) 
    y =  inv_normalize(rand(1,"uniform"),problem_size(1),problem_size(2)) 
    
    chromossome_x = real_to_bit(x,problem_size(1),problem_size(2))
    chromossome_y = real_to_bit(y,problem_size(1),problem_size(2))
    
    individual = individual_new(chromossome_x,chromossome_y,problem_size(1),problem_size(2))
    
endfunction

function population = initialize_population(population_size,problem_size)
    population = list()
    for i=1:population_size
        population($+1) = generate_random_individual(problem_size)
    end
endfunction


function value = fitness_function(x,y)
    z =-x*sin(sqrt(abs(x)))-y*sin(sqrt(abs(y)))
    // r: Rosenbrock's function
    r1=(y-x^2)^2+(1-x)^2;
  
    value= z*exp(sin(r1));
    
endfunction

function score = evaluate_individual(individual)
    x = bit_to_float(individual.chromossome_x,individual.max,individual.min)
    y = bit_to_float(individual.chromossome_y,individual.max,individual.min)
    score = fitness_function(x,y)
    individual.score = score
    
endfunction

function population = evaluate_population(population)
    for i=1:length(population)
        population(i).score = evaluate_individual(population(i))
        //disp("population("+ string(i)+ ") "+ string(population(i).score))
        
    end
   

endfunction

function s_best = get_best_solution(population)
    s_best = population(1)
    best_score = population(1).score
    
    for individual=population
        if individual.score < best_score 
            best_score = individual.score
            s_best = individual     
        end
          
    end
endfunction

function roulette = create_roulette(population)
    big_M = 3000
    total = 0
    
    for individual=population
        total = -individual.score + big_M + total
    end
    
    roulette = list()
    limit_min = 0
    for individual= population
        prob = (-individual.score + big_M)/total
        limit_max = limit_min + prob
        roulette($+1) = [limit_min,limit_max ]
        limit_min = limit_min + prob
    end
    
    
endfunction

function parents = spin_roulette(roulette,n_spins,population)
    
    parents = list()
    
   
    
    for i=1:n_spins
        chossen = rand()
        
        for j =1:length(roulette)
            if roulette(j)(1) <= chossen && chossen <= roulette(j)(2)
               parents($+1) = population(j)
               break
            end
            
            
          
            
        end
            
    end        
   
endfunction

function parents = select_parents(population,population_size)
    
    
    roulette = create_roulette(population)
    
    parents = spin_roulette(roulette,population_size,population)
    
    
endfunction

function childrens= crossover(father, mother)
    n_bits = length(father.chromossome_x)
    child_1_chromossome_x = []
    child_1_chromossome_y = []
    
    child_2_chromossome_x = []
    child_2_chromossome_y = []
    childrens= list()
    

    point = round(rand(1,1,"uniform")*(n_bits-1) +1)
   
    
    for i=1:point
        child_1_chromossome_x(i) =  father.chromossome_x(i)       
        child_1_chromossome_y(i) =  father.chromossome_y(i)
        
        child_2_chromossome_x(i) =  mother.chromossome_x(i)
        child_2_chromossome_y(i) =  mother.chromossome_y(i)
        
    end
    
   
    
    for i=point:n_bits
               
        child_1_chromossome_x(i) =  mother.chromossome_x(i)
        child_1_chromossome_y(i) =  mother.chromossome_y(i)
        
        child_2_chromossome_x(i) =  father.chromossome_x(i)
        child_2_chromossome_y(i) =  father.chromossome_y(i)
    end
  
    
    new_child_1 = individual_new(child_1_chromossome_x, child_1_chromossome_y,father.max,father.min)
    
   
    
    new_child_2 = individual_new(child_2_chromossome_x,child_2_chromossome_y,father.max,father.min)
    
    childrens($+1)= new_child_1
    
    childrens($+1)= new_child_2  
    
    
endfunction


function children = mutate(child,p_mutation)
    if rand()< p_mutation 
       children = execute_mutation(child)
        
    else
        children = child
    end
    
endfunction

function children = execute_mutation(child)
    n_bits = length(child.chromossome_x)
    n_mutate_bits = 5
    
     for i=1:n_mutate_bits
            
            rand_pos = round(rand(1,1,"uniform")*(n_bits-1)+1)
            child.chromossome_x(rand_pos) = round(rand(1,1,"uniform"))
            
            rand_pos = round(rand(1,1,"uniform")*(n_bits-1)+1)
            child.chromossome_y(rand_pos) = round(rand(1,1,"uniform"))
     end
        
    
    children = child
    
endfunction

function new_population = replace(population,childrens,s_best,best_child)
    
    if best_child.score < s_best.score
        new_population = childrens
        
    else
        new_population = list()
        new_population($+1) = s_best
        
        for i=2:length(childrens)
            new_population($+1) = childrens(i)
        end
    
    end

    
    
    
    
endfunction

function  variance_population = calcule_variance(population)
    variance_vector = []
    
    for individual=population
        variance_vector($+1) = individual.score
    end
    
    variance_population = variance(variance_vector)
    
endfunction

function new_population =  remove_best_solution(population,best)
    for i=1:length(population)
        if population(i) == best
            population(i) = null()
            break
        end
        
    end
    
    new_population = population
    
    
    
endfunction

function test_GA(population_size,file_name)
    
    problem_size = [500,-500]
    p_mutation = 0.01
    epochs = 3000
    max_variance =0.01

    solutions = list()

    csv_matrix = []
    for i=1:100
        solutions($+1) = geneticAlgorithm(population_size,problem_size,p_mutation,epochs,max_variance)
        csv_matrix($+1) = solutions($).score
    
    end

    csvWrite(csv_matrix,file_name)
    
    disp(file_name + "savend !!")
    
    
endfunction

population_size_list = list(4,8,16)

for population_size=population_size_list
    file_name =  "GA_mutation_0.01_" + string(population_size) + "u.csv"
    test_GA(population_size,file_name)
end
