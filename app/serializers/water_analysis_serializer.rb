class WaterAnalysisSerializer
  def initialize(water_analysis)
    @water_analysis = water_analysis
  end

  def as_json(*)
    {
      'id'         => @water_analysis.id.to_s,
      'reference'  => @water_analysis.reference_date.strftime('%m/%Y'),
      'parameter'  => @water_analysis.parameter,
      'required'   => @water_analysis.required_value.to_f,
      'analyzed'   => @water_analysis.analyzed_value.to_f,
      'conformity' => @water_analysis.conformity_value.to_f,
      'compliant'  => @water_analysis.analyzed_value.to_f <= @water_analysis.conformity_value.to_f,
    }
  end
end
