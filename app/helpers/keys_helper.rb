module KeysHelper
  include Redmine::Export::PDF
  include Redmine::Export::PDF::IssuesPdfHelper

  def key_types
    [[t('activerecord.models.password'),'Vault::Password'], [t('activerecord.models.key_file'),'Vault::KeyFile']]
  end

  def keys_to_pdf(keys, project, query)
    pdf = ITCPDF.new(current_language, "L")
    title = "#{project} #{t('export.pdf.title')}"
    pdf.set_title(title)
    pdf.alias_nb_pages
    pdf.footer_date = format_date(Date.today)
    pdf.set_auto_page_break(false)
    pdf.add_page("L")

    # Landscape A4 = 210 x 297 mm
    page_height   = pdf.get_page_height # 210
    page_width    = pdf.get_page_width  # 297
    left_margin   = pdf.get_original_margins['left'] # 10
    right_margin  = pdf.get_original_margins['right'] # 10
    bottom_margin = pdf.get_footer_margin
    row_height    = 4

    # column widths
    table_width = page_width - right_margin - left_margin

    # title
    pdf.SetFontStyle('B',11)
    pdf.RDMCell(190,10, title)
    pdf.ln

    pdf.RDMMultiCell(100,row_height,t('key.attr.name'),1,"",0,0)
    pdf.RDMMultiCell(100,row_height,t('key.attr.url'),1,"",0,0)
    pdf.RDMMultiCell(30,row_height,t('key.attr.login'),1,"",0,0)
    pdf.RDMMultiCell(50,row_height,t('key.attr.body'),1,"",0,1)

    pdf.SetFontStyle('',8)

    keys.each { |key|
      base_y     = pdf.get_y
      key.name = "-" if key.name == nil
      key.url = "-" if key.url == nil
      key.login = "-" if key.login == nil
      key.body = "-" if key.body == nil

      pdf.RDMMultiCell(100,row_height,key.name,1,"",0,0)
      pdf.RDMMultiCell(100,row_height,key.url,1,"",0,0)
      pdf.RDMMultiCell(30,row_height,key.login,1,"",0,0)
      pdf.RDMMultiCell(50,row_height,key.body,1,"",0,1)

      max_height = 6*row_height
      space_left = page_height - base_y - bottom_margin

      if max_height > space_left
        pdf.add_page("L")
        base_y = pdf.get_y
      end

    }

    pdf.output
  end

end
