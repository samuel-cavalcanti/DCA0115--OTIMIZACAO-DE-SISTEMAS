clear
clc

function pg_best= particle_swarm(problem_size,population_size,epochs)
     
    population = list()
    
    pg_best = new_particle(random_velocity(problem_size),random_position(problem_size))
   
    
    for i=1:population_size
        p_velocity = random_velocity(problem_size)
        p_position = random_position(problem_size)
        particle = new_particle(p_position,p_velocity)
        
        if particle.cost <= pg_best.cost
            pg_best = particle
        end 
        
        population($+1) = particle
       
    end
    
    for epoch=1:epochs
        for i=1:length(population)
            population(i) = update_particle(population(i),pg_best,problem_size)
            
            if population(i).cost <= pg_best.cost
                pg_best = population(i)
            end
            
            
        end
       // print_population(population)
    end
    
  
    
    
endfunction


function particle =  new_particle(velocity,position)
    particle = tlist(["T_particle","velocity","position","best_pos","cost"])
    
    particle.velocity = velocity
    particle.position = position
    particle.best_pos = position
    particle.cost = evalute_position(position(1),position(2))
     
endfunction

function value = evalute_position(x,y)
    z =-x*sin(sqrt(abs(x)))-y*sin(sqrt(abs(y)))
    // r: Rosenbrock's function
    r1=(y-x^2)^2+(1-x)^2;
  
    value= z*exp(sin(r1));
    
endfunction


function particle =update_particle(old_particle,best_particle,problem_size)
    velocity = update_speed(old_particle,best_particle,problem_size)
    
    position = update_position(old_particle.position,velocity,problem_size)
    
    particle = new_particle(velocity,position)
    
    old_best_cost = evalute_position(old_particle.best_pos(1),old_particle.best_pos(2))
    
    if particle.cost > old_best_cost then
        particle.best_pos = old_particle.best_pos
    end
    
    
    
endfunction

function new_velocity = update_speed(old_particle,best_particle,problem_size)
    w = 0.5
    c_1 = 1.8
    c_2 = 2
    reduce = 0.01
    limit = problem_size 
   
    
    
    cognitive_speed =[]
    
    social_speed =[]
    
    
    inertia = w * old_particle.velocity 
    
    for i=1:length(old_particle.position)
        r_1 = rand()
        r_2 = rand()
        
        cognitive_speed(i) =  c_1*r_1*( old_particle.best_pos(i) - old_particle.position(i))
    
        social_speed(i) = c_2*r_2*(best_particle.position(i) - old_particle.position(i) )
                 
    end
    
    
    new_velocity =  inertia + cognitive_speed + social_speed
    
    
    for i=1:length(new_velocity)
        
        if new_velocity(i) > limit(1) 
             new_velocity(i) = limit(1)
        end
    
        
        if new_velocity(i) < limit(2)
             new_velocity(i) = limit(2)
        end
        
    end
    
   
    
    
    
endfunction

function position= update_position(old_position,velocity,problem_size)
    position = velocity +old_position
    
    for i=1:length(position)
        
         if position(i) > problem_size(1)
              position(i) = problem_size(1)
         end
    
         if position(i) < problem_size(2)
              position(i) = problem_size(2)
          
         end
    end
   
    
endfunction

function velocity = random_velocity(problem_size)
    reduce = 0.01
    
    max_value = problem_size(1) * reduce
    min_value = problem_size(2) * reduce
    
    velocity = rand(2,1,"uniform")*(max_value - min_value) + min_value
    
    
    
endfunction

function position = random_position(problem_size)
    
    position = rand(2,1,"uniform")*(problem_size(1)-problem_size(2)) + problem_size(2)
    
    
endfunction

function print_population(population, epoch)
    disp("epoch: " + string(epoch))
    for individual=population
        disp("cost: "+ string(individual.cost))
    end
    disp(" ")
endfunction

problem_size = [500,-500]
population_size = 8
epochs = 3000

solutions = list()

csv_matrix = []

for i=1:100
    solutions($+1) = particle_swarm(problem_size,population_size,epochs)
    csv_matrix($+1) =  solutions($).cost
    disp( csv_matrix($))
end

csvWrite(csv_matrix,"PSO.csv")

