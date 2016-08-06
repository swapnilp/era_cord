prawn_document do |pdf|

  pdf.formatted_text [ 
    { text: "#{@jkci_class.id} - #{@jkci_class.class_name}", :styles => [:bold], :size => 16 }
  ], align: :center

  pdf.define_grid(:columns => 2, :rows => 30, :gutter => 0)
  pdf.grid(1, 0).bounding_box do
    pdf.text "Students count -  #{@jkci_class.students.count}", align: :left
  end
  pdf.move_down(10)
	
    pdf.table([["Student Name", "Mobile", "Divisions"]] + @students.map {|student| [student[:name], student[:mobile], student[:sub_classes]]}, :column_widths => [140, 60, 300], :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 6, :height => 17,}) do
    row(0).font_style = :bold
    row(0).size = 12
    pdf.move_down(20)
  end	
end