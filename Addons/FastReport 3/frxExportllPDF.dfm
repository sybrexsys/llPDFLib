object llPDFExportDialog: TllPDFExportDialog
  Left = 412
  Top = 233
  BorderStyle = bsDialog
  Caption = 'Export to PDF'
  ClientHeight = 324
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    455
    324)
  PixelsPerInch = 96
  TextHeight = 13
  object blBottom: TBevel
    Left = 8
    Top = 280
    Width = 438
    Height = 10
    Shape = bsBottomLine
  end
  object OkButton: TButton
    Left = 291
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object CancelButton: TButton
    Left = 371
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object pcSettings: TPageControl
    Left = 0
    Top = 0
    Width = 455
    Height = 281
    ActivePage = stSettings
    Align = alTop
    TabOrder = 2
    object stSettings: TTabSheet
      Caption = 'Settings'
      object GroupPageRange: TGroupBox
        Left = 4
        Top = 4
        Width = 438
        Height = 121
        Caption = ' Page range  '
        TabOrder = 0
        object DescrL: TLabel
          Left = 12
          Top = 82
          Width = 414
          Height = 29
          AutoSize = False
          Caption = 
            'Enter page numbers and/or page ranges, separated by commas. For ' +
            'example, 1,3,5-12'
          WordWrap = True
        end
        object AllRB: TRadioButton
          Left = 12
          Top = 20
          Width = 77
          Height = 17
          HelpContext = 108
          Caption = 'All'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object CurPageRB: TRadioButton
          Left = 12
          Top = 40
          Width = 93
          Height = 17
          HelpContext = 118
          Caption = 'Current page'
          TabOrder = 1
        end
        object PageNumbersRB: TRadioButton
          Left = 12
          Top = 60
          Width = 77
          Height = 17
          HelpContext = 124
          Caption = 'Pages:'
          TabOrder = 2
        end
        object PageNumbersE: TEdit
          Left = 92
          Top = 58
          Width = 165
          Height = 21
          HelpContext = 133
          TabOrder = 3
        end
      end
      object gbFileOptions: TGroupBox
        Left = 4
        Top = 136
        Width = 438
        Height = 113
        Caption = 'File options'
        TabOrder = 1
        object cbOpenafterexport: TCheckBox
          Left = 4
          Top = 20
          Width = 253
          Height = 17
          Caption = 'Open after export'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbImagesasjpeg: TCheckBox
          Left = 4
          Top = 41
          Width = 253
          Height = 17
          Caption = 'Images as Jpeg'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbUrlDetection: TCheckBox
          Left = 4
          Top = 62
          Width = 253
          Height = 17
          Caption = 'URL detection'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object cbCompressed: TCheckBox
          Left = 4
          Top = 84
          Width = 121
          Height = 17
          Caption = 'Compressed'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
      end
    end
    object tsFonts: TTabSheet
      Caption = 'Fonts'
      ImageIndex = 1
      object lbAlways: TLabel
        Left = 4
        Top = 49
        Width = 72
        Height = 13
        Caption = 'Always Embed:'
      end
      object lbNewer: TLabel
        Left = 240
        Top = 48
        Width = 70
        Height = 13
        Caption = 'Newer Embed:'
      end
      object cbEmbedAllFonts: TCheckBox
        Left = 14
        Top = 10
        Width = 97
        Height = 17
        Caption = 'Embed all fonts'
        TabOrder = 0
        OnClick = cbEmbedAllFontsClick
      end
      object cbEmulateStandard: TCheckBox
        Left = 185
        Top = 10
        Width = 200
        Height = 17
        Caption = 'Emulate standard fonts'
        TabOrder = 1
      end
      object liboAlways: TListBox
        Left = 4
        Top = 68
        Width = 200
        Height = 180
        ItemHeight = 13
        Sorted = True
        TabOrder = 2
      end
      object liboNewer: TListBox
        Left = 240
        Top = 67
        Width = 200
        Height = 180
        ItemHeight = 13
        Sorted = True
        TabOrder = 3
      end
      object btnInOne: TButton
        Left = 210
        Top = 89
        Width = 25
        Height = 25
        Caption = '->'
        TabOrder = 4
        OnClick = btnInOneClick
      end
      object btnInAll: TButton
        Left = 210
        Top = 119
        Width = 24
        Height = 25
        Caption = '->>'
        TabOrder = 5
        OnClick = btnInAllClick
      end
      object btnOutOne: TButton
        Left = 210
        Top = 169
        Width = 25
        Height = 25
        Caption = '<-'
        TabOrder = 6
        OnClick = btnOutOneClick
      end
      object btnOutAll: TButton
        Left = 210
        Top = 199
        Width = 25
        Height = 25
        Caption = '<<-'
        TabOrder = 7
        OnClick = btnOutAllClick
      end
    end
    object tsSecurity: TTabSheet
      Caption = 'Security'
      ImageIndex = 2
      object lbSMethod: TLabel
        Left = 8
        Top = 16
        Width = 79
        Height = 13
        Caption = 'Security method:'
      end
      object cbSecurityMethod: TComboBox
        Left = 96
        Top = 8
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbSecurityMethodChange
        Items.Strings = (
          'No Security'
          'Low Security (RC4 40 bit)'
          'High Security ( RC4 128 bit)'
          'High Security ( AES 128 bit)')
      end
      object gbPasswords: TGroupBox
        Left = 4
        Top = 36
        Width = 438
        Height = 81
        Caption = 'Passwords'
        TabOrder = 1
        object lbUser: TLabel
          Left = 16
          Top = 24
          Width = 74
          Height = 13
          Caption = 'User Password:'
        end
        object lbOwner: TLabel
          Left = 16
          Top = 48
          Width = 83
          Height = 13
          Caption = 'Owner Password:'
        end
        object edUser: TEdit
          Left = 114
          Top = 17
          Width = 310
          Height = 21
          PasswordChar = '*'
          TabOrder = 0
        end
        object edOwner: TEdit
          Left = 114
          Top = 43
          Width = 310
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
        end
      end
      object gbResources: TGroupBox
        Left = 4
        Top = 125
        Width = 438
        Height = 125
        Caption = 'Enabled Resources'
        TabOrder = 2
        object cbPrintTheDocument: TCheckBox
          Left = 4
          Top = 21
          Width = 220
          Height = 17
          Caption = 'Print the document'
          TabOrder = 0
        end
        object cbModifyContext: TCheckBox
          Left = 4
          Top = 43
          Width = 220
          Height = 17
          Caption = 'Modify the content of the document'
          TabOrder = 1
        end
        object cbCopyText: TCheckBox
          Left = 4
          Top = 66
          Width = 220
          Height = 17
          Caption = 'Copy text and graphics from the document'
          TabOrder = 2
        end
        object cbAddAnnot: TCheckBox
          Left = 4
          Top = 89
          Width = 220
          Height = 17
          Caption = 'Add or modify annotations'
          TabOrder = 3
        end
        object cbFillForm: TCheckBox
          Left = 228
          Top = 21
          Width = 200
          Height = 17
          Caption = 'Fill in interactive form fields'
          TabOrder = 4
        end
        object cbExtractTextAndGraphics: TCheckBox
          Left = 228
          Top = 43
          Width = 200
          Height = 17
          Caption = 'Extract text and graphics from PDF'
          TabOrder = 5
        end
        object cbAssemble: TCheckBox
          Left = 228
          Top = 66
          Width = 200
          Height = 17
          Caption = 'Assemble the document'
          TabOrder = 6
        end
        object cbPrintHigh: TCheckBox
          Left = 228
          Top = 89
          Width = 200
          Height = 17
          Caption = 'Print the document with high resolution'
          TabOrder = 7
        end
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 277
    Top = 120
  end
end
