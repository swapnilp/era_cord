prawn_document do |pdf|

  pdf.formatted_text [ 
    { text: "#{@jkci_class.id} - #{@jkci_class.class_name}", :styles => [:bold], :size => 16 }
  ], align: :center

  pdf.define_grid(:columns => 2, :rows => 30, :gutter => 0)
  pdf.grid(1, 0).bounding_box do
    pdf.text "Students count -  #{@jkci_class.students.count}", align: :left
  end
  pdf.move_down(10)
  
  @sub_classes.each do |sub_class|
    pdf.formatted_text [ 
      { text: "#{sub_class.name}", :size => 12 }
      ], align: :left
      if sub_class.students.count > 0
      	 pdf.table(sub_class.students.collect{ |p| [p.name]}, :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 6, :height => 17}) do
    	 end
	 pdf.move_down(20)
       end	
  end      
end