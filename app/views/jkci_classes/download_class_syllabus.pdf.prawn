prawn_document do |pdf|

  pdf.formatted_text [ 
    { text: "#{@jkci_class.id} - #{@jkci_class.class_name}", :styles => [:bold], :size => 16 }
  ], align: :center

  pdf.define_grid(:columns => 2, :rows => 30, :gutter => 0)
  pdf.grid(1, 0).bounding_box do
    pdf.text "Students count -  #{@jkci_class.students.count}", align: :left
  end
  
  pdf.move_down(10)
  pdf.stroke_horizontal_line 0, 525
  pdf.move_down(10)
  @subjects.each do |subject|
    pdf.text "Subject -  #{subject.std_name}", align: :left
  
    pdf.text "Teacher -  #{@jkci_class.teacher.try(:name) || '____________________'}", align: :right
  
    pdf.table(@jkci_class.chapters_table_format(subject, @points_hash), :column_widths => [100, 420],  :cell_style => { :overflow => :shrink_to_fit, :size => 10, :inline_format => true}) do
      row(0).font_style = :bold
      row(0).size = 12
    end 
    pdf.start_new_page
  end
end