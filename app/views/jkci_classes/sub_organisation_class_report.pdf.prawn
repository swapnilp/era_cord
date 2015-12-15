prawn_document do |pdf|

  pdf.formatted_text [ 
    { text: "#{@jkci_class.id} - #{@jkci_class.class_name}", :styles => [:bold], :size => 16 }
  ], align: :center

  pdf.define_grid(:columns => 2, :rows => 30, :gutter => 0)
  pdf.grid(1, 0).bounding_box do
    pdf.text "Students count -  #{@jkci_class.students.count}", align: :left
  end
  pdf.grid(1, 1).bounding_box do
    pdf.text "Date -  #{Date.today}", align: :right
  end
  pdf.move_down(10)
  pdf.text "Exams", :size => 18
  pdf.table(@exams_table_format, :column_widths => [30, 70, 70, 70, 90, 90, 90],  :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 6, :height => 17}) do
    row(0).font_style = :bold
    row(0).size = 12
  end
  pdf.move_down(10)
  pdf.text "Daily Teaching", :size => 18
  pdf.table(@daily_teaching_table_format, :column_widths => [30, 70, 70, 70, 90, 90, 90],  :cell_style => { :overflow => :shrink_to_fit, :min_font_size => 6, :height => 17}) do
    row(0).font_style = :bold
    row(0).size = 12
  end
end