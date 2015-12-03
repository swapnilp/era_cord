prawn_document do |pdf|

  pdf.formatted_text [ 
    { text: "#{@student.id} - #{@student.name}", :styles => [:bold], :size => 18 }
  ], align: :center

  pdf.text "Classes -  #{@student.classes_names}", align: :left
  pdf.text "Parent Mobile -  #{@student.p_mobile}", align: :right
  pdf.stroke_horizontal_rule

  pdf.move_down 10
  pdf.formatted_text [ 
    { text: "Exams", :styles => [:bold], :size => 18 }
  ], align: :left

  pdf.table(@exam_catlogs, :column_widths => [35, 155, 55, 80, 60, 55, 45, 35],  :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 6, :height => 18}) do
    row(0).font_style = :bold
    row(0).font_size = 10

    values = cells.columns(1..-1).rows(1..-1)
    
    bad_sales = values.filter do |cell|
      cell.content == 'false'
    end
    
    bad_sales.background_color = "FFAAAA"
  end			   

end