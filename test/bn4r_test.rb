require File.dirname(__FILE__) + '/test_helper.rb'

class Bn4rTest < Test::Unit::TestCase

  # Returns the BayesNet used as example in "Artificial Intelligence A 
  # Modern Approach, Rusell & Norvig, 2nd Ed." pp.494
  def self.bayes_net_aima
    bn_aima = BayesNet.new
    
    b = BayesNetNode.new("Burglary")
    e = BayesNetNode.new("Earthquake")
    a = BayesNetNode.new("Alarm")
    j = BayesNetNode.new("JohnCalls")
    m = BayesNetNode.new("MaryCalls")

    bn_aima.add_vertex(b)
    bn_aima.add_vertex(e)
    bn_aima.add_vertex(a)
    bn_aima.add_vertex(j)
    bn_aima.add_vertex(m)
    
    bn_aima.add_edge(b,a)
    bn_aima.add_edge(e,a)
    bn_aima.add_edge(a,j)
    bn_aima.add_edge(a,m)
    
    b.set_probability_table([], [0.001, 0.999] )
    e.set_probability_table([], [0.002, 0.998] )
    
    a.set_probability_table([b,e], [0.95, 0.05, 0.94, 0.06, 0.29, 0.61, 0.001,0.999] )
    
    j.set_probability_table([a], [0.90,0.10,0.05,0.95])
    m.set_probability_table([a], [0.70,0.30,0.01,0.99])
    
    bn_aima
  end

  # Returns the BayesNet used as example in "Artificial Intelligence A 
  # Modern Approach, Rusell & Norvig, 2nd Ed." pp.510
  def self.bayes_net_aima2
    bn_aima = BayesNet.new

    cloudy = BayesNetNode.new("Cloudy")
    sprinkler = BayesNetNode.new("Sprinkler")
    rain = BayesNetNode.new("Rain")
    wetgrass = BayesNetNode.new("WetGrass")

    bn_aima.add_vertex(cloudy)
    bn_aima.add_vertex(sprinkler)
    bn_aima.add_vertex(rain)
    bn_aima.add_vertex(wetgrass)
    
    bn_aima.add_edge(cloudy,sprinkler)
    bn_aima.add_edge(cloudy,rain)
    bn_aima.add_edge(sprinkler,wetgrass)
    bn_aima.add_edge(rain,wetgrass)
    
    cloudy.set_probability_table([], [0.5, 0.5] )

    sprinkler.set_probability_table([cloudy], [0.1, 0.9, 0.5, 0.5] )
    rain.set_probability_table([cloudy], [0.8, 0.2, 0.2, 0.8] )
    
    wetgrass.set_probability_table([sprinkler, rain], [0.99, 0.01, 0.9, 0.1, 0.9, 0.1, 0.0, 1.0] )
    bn_aima
  end

  def bayes_net_aaile
    bn = BayesNet.new
    rel = BayesNetNode.new("relational")
    q = BayesNetNode.new("qualificative")
    a = BayesNetNode.new("Adverbial")
    bn.add_vertex(rel)
    bn.add_vertex(q)
    bn.add_vertex(a)

#    ["preN", ...]    
    preN = BayesNetNode.new("preN")
    bn.add_vertex(preN)
    
    postN = BayesNetNode.new("postN")
    bn.add_vertex(postN)
    
 #   bn.add_edge("ser")
 #   bn.add_edge("G")
 #   bn.add_edge("prep")
    
    bn.add_edge(rel, preN)
    bn.add_edge(q, preN)
    bn.add_edge(a, preN)
    bn.add_edge(q, postN)
    
    bn
  end

  def setup
  end
 
# TESTS
 
  def test_create_sample_bn
    bn = bayes_net_aaile
  
    assert_equal bn.vertices.size, 5
    assert_equal bn.edges.size, 4
  end
  
  
  def test_graph_viz
    bn = bayes_net_aaile
    # print "\n\n" + bn.to_dot_graph.to_s
    
    assert bn.to_dot_graph.to_s.size > 0, "bn.to_dot_graph gives no output."
  end
  
  def test_probability_assingment
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")
    
    assert_equal b.get_probability(true, []), 0.001
    assert_equal b.get_probability(false, []), 0.999
    assert_equal b.get_probability(false, []), 0.999
    
    assert_equal a.get_probability(true, [false,false]), 0.001
    assert_equal a.get_probability(true, [true,false]), 0.94
    assert_equal a.get_probability(false, [true,true]), 0.05
    
    assert_equal j.get_probability(true, [true]), 0.90
    assert_equal m.get_probability(true, [false]), 0.01
    
  end
  
  def test_CPT_size
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    assert_equal b.get_table_size, 2
    assert_equal a.get_table_size, 8
    assert_equal j.get_table_size, 4
    assert_equal m.get_table_size, 4
  end
  
  def test_base_methods
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    a = bn_aima.get_variable("Alarm")
    assert bn_aima.root?(b)
    assert !bn_aima.root?(a)
    
  end
  
  def test_inference_by_enumeration
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")

    assert_equal bn_aima.vertices.size, 5
    assert_equal bn_aima.edges.size, 4
    
    assert !bn_aima.all_nodes_with_values?
    b.set_value(false); assert !bn_aima.all_nodes_with_values?
    e.set_value(false); assert !bn_aima.all_nodes_with_values?
    a.set_value(true); assert !bn_aima.all_nodes_with_values?
    j.set_value(true); assert !bn_aima.all_nodes_with_values?
    m.set_value(true)

    assert bn_aima.all_nodes_with_values?
        
    value = bn_aima.inference_by_enumeration
    assert_in_delta 0.0006281112, value, 10**(-10)
    
    bn_aima.clear_values!
    assert !bn_aima.all_nodes_with_values?
    
  end
  
  def test_inference_by_enumeration_ask
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    j = bn_aima.get_variable("JohnCalls")
    m = bn_aima.get_variable("MaryCalls")    
    j.set_value(true)  
    m.set_value(true)
    
    assert_equal bn_aima.vertices.size, 5
    assert_equal bn_aima.edges.size, 4
    value1 = bn_aima.enumeration_ask(b,[j,m])
    value2 = bn_aima.enumeration_ask(b,[j,m], [j,m,a,b,e])
    value3 = bn_aima.enumeration_ask(b,[j,m], [b,e,a,j,m])
    assert_equal value1[0], value2[0]
    assert_equal value1[0].to_f, value3[0].to_f
    assert_in_delta value1[1].to_f, value2[1].to_f, 10**(-10)
    assert_equal value1[1], value3[1]
    assert_in_delta 0.000592242, bn_aima.enumeration_ask(b,[j,m])[0], 10**(-9)
    bn_aima.clear_values!
    assert !bn_aima.all_nodes_with_values?

  end
  
  
  def test_table_probabilities_for_node
    bn_aima = Bn4rTest.bayes_net_aima
    b = bn_aima.get_variable("Burglary")
    e = bn_aima.get_variable("Earthquake")
    a = bn_aima.get_variable("Alarm")
    BNTPGFromPositiveNegativeRelations.new.table_probabilities_for_node(a, [true,true])

#    BNTPGFromPositiveNegativeRelations.new.populate_bn_with_tags(bn_aima)
    assert true
  end

  def test_prior_sampling

    bn = Bn4rTest.bayes_net_aima2

    hash = Hash.new(0)
    nodes_ordered = bn.nodes_ordered_by_dependencies
    10000.times { hash[ bn.prior_sample(nodes_ordered).collect {|v| v.value} ] += 1 }
    
    combination_of_prob = nodes_ordered.collect { |v|
      case v.name
        when "Cloudy"
          true
        when "Sprinkler"
          false
        when "Rain"
          true
        when "WetGrass"
          true
        else
          raise "Incorrect BayesNet created at Bn4rTest.bayes_net_aima2"
      end
    }
    
    prob = hash[combination_of_prob].to_f/10000.0

    assert_in_delta 0.3, prob, 0.1, "Its inprobable but possible that this error occurs, \
                                      because we are working with statistics and random data, \
                                      try again and if still occurs take care of it."
     
  end

  def test_rejection_sampling
    bn = Bn4rTest.bayes_net_aima2

    rain = bn.get_variable("Rain").copy
    sprinkler = bn.get_variable("Sprinkler").copy

    rain.set_value(true)
    sprinkler.set_value(true)
    
    results = bn.rejection_sampling(rain, sprinkler, 1000)

    str_error = " Its improbable but possible that this error occurs, \
                  because we are working with statistics and random data, \
                  try again and if still occurs take care of it."
    assert ((results[0] > 0.2) and (results[0] < 0.4)), "Results aren't in interval [0.2,0.4] --> " + results[0].to_s + str_error
    assert ((results[1] > 0.6) and (results[1] < 0.8)), "Results aren't in interval [0.6,0.8] --> " + results[1].to_s + str_error
  end

  def test_likelihood_weighting
    bn = Bn4rTest.bayes_net_aima2

    rain = bn.get_variable("Rain").copy
    sprinkler = bn.get_variable("Sprinkler").copy

    rain.set_value(true)
    sprinkler.set_value(true)
    
    results = bn.likelihood_weighting(rain, sprinkler, 100)

    str_error = " Its improbable but possible that this error occurs, \
                  because we are working with statistics and random data, \
                  try again and if still occurs take care of it."
    assert ((results[0] > 0.2) and (results[0] < 0.4)), "Results aren't in interval [0.2,0.4] --> " + results[0].to_s + str_error
    assert ((results[1] > 0.6) and (results[1] < 0.8)), "Results aren't in interval [0.6,0.8] --> " + results[1].to_s + str_error
  end


end