require 'csv'

class CensusTract < Struct.new(:statefp, :countyfp, :tractfp, :pop, :lat, :lng)
  OMAHA_METRO = {
    harrison: "19085",
    pottawattamie: "19115",
    mills: "19129",
    saunders: "31155",
    washington: "31177",
    douglash: "31055",
    sarpy: "31153",
    cass: "31025"
  }

  def fips
    "#{statefp}#{countyfp}"
  end

  def population; pop.to_i; end
  def latitude; lat.to_f; end
  def longitude; lng.to_f; end

  def weighted_lat
    population * latitude
  end

  def weighted_lng
    population * longitude
  end
end

class PopInfo < Struct.new(:population, :weighted_lat, :weighted_lng)
  def add_tract(tract)
    self.population += tract.population
    self.weighted_lat += tract.weighted_lat
    self.weighted_lng += tract.weighted_lng
  end

  def center_lat
    weighted_lat / population.to_f
  end

  def center_lng
    weighted_lng / population.to_f
  end
end

def get_omaha_center
  tracts = []
  CSV.foreach("./data/ne_ia_tracts.csv") do |row|
    tract = CensusTract.new(*row)
    tracts << tract if CensusTract::OMAHA_METRO.values.include?(tract.fips)
  end

  omaha_metro_info = tracts.reduce(PopInfo.new(0, 0, 0)){ |omaha, tract| omaha.add_tract(tract); omaha }
  [omaha_metro_info.population, "#{omaha_metro_info.center_lat}, #{omaha_metro_info.center_lng}"]
end

puts get_omaha_center

