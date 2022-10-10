object MainForm: TMainForm
  Width = 864
  Height = 559
  Caption = '3'
  object WebLabel1: TWebLabel
    Left = 128
    Top = 25
    Width = 52
    Height = 13
    Caption = 'User Name'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
  object WebLabel2: TWebLabel
    Left = 128
    Top = 60
    Width = 46
    Height = 13
    Caption = 'Password'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
  object WebLabel3: TWebLabel
    Left = 378
    Top = 60
    Width = 95
    Height = 13
    Caption = 'Connection Status: '
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
  object StatusLabel: TWebLabel
    Left = 475
    Top = 60
    Width = 64
    Height = 13
    Caption = 'Disconnected'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
  end
  object ConnectButton: TWebButton
    Left = 16
    Top = 20
    Width = 96
    Height = 25
    Caption = 'Connect'
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = ConnectButtonClick
  end
  object ebUserName: TWebEdit
    Left = 192
    Top = 22
    Width = 121
    Height = 22
    ChildOrder = 2
    HeightPercent = 100.000000000000000000
    Text = 'User'
    WidthPercent = 100.000000000000000000
  end
  object ebPassword: TWebEdit
    Left = 192
    Top = 57
    Width = 121
    Height = 22
    ChildOrder = 4
    HeightPercent = 100.000000000000000000
    Text = 'synopse'
    WidthPercent = 100.000000000000000000
  end
  object DisconnectButton: TWebButton
    Left = 376
    Top = 20
    Width = 96
    Height = 25
    Caption = 'Disconnect'
    ChildOrder = 16
    Enabled = False
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = DisconnectButtonClick
  end
  object MainPanel: TWebPanel
    Left = 16
    Top = 100
    Width = 297
    Height = 361
    BorderColor = clTeal
    ChildOrder = 17
    Visible = False
    object AddButton: TWebButton
      Left = 16
      Top = 20
      Width = 96
      Height = 25
      Caption = 'Add'
      ChildOrder = 5
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = AddButtonClick
    end
    object WebEdit1: TWebEdit
      Left = 140
      Top = 22
      Width = 121
      Height = 22
      ChildOrder = 6
      HeightPercent = 100.000000000000000000
      Text = '2'
      WidthPercent = 100.000000000000000000
    end
    object WebEdit2: TWebEdit
      Left = 140
      Top = 56
      Width = 121
      Height = 22
      ChildOrder = 7
      HeightPercent = 100.000000000000000000
      Text = '3'
      WidthPercent = 100.000000000000000000
    end
    object AddEdit: TWebEdit
      Left = 140
      Top = 96
      Width = 121
      Height = 22
      ChildOrder = 8
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object SumButton: TWebButton
      Left = 16
      Top = 152
      Width = 96
      Height = 25
      Caption = 'Sum'
      ChildOrder = 9
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = SumButtonClick
    end
    object SumEdit: TWebEdit
      Left = 140
      Top = 154
      Width = 121
      Height = 22
      ChildOrder = 10
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object CountButton: TWebButton
      Left = 16
      Top = 212
      Width = 96
      Height = 25
      Caption = 'Count'
      ChildOrder = 11
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = CountButtonClick
    end
    object CountEdit: TWebEdit
      Left = 140
      Top = 214
      Width = 121
      Height = 22
      ChildOrder = 10
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object ValueButton: TWebButton
      Left = 16
      Top = 274
      Width = 96
      Height = 25
      Caption = 'Get Value'
      ChildOrder = 13
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
      OnClick = ValueButtonClick
    end
    object ValueEdit: TWebEdit
      Left = 140
      Top = 306
      Width = 121
      Height = 22
      ChildOrder = 10
      HeightPercent = 100.000000000000000000
      WidthPercent = 100.000000000000000000
    end
    object IndexEdit: TWebEdit
      Left = 140
      Top = 276
      Width = 69
      Height = 22
      ChildOrder = 10
      HeightPercent = 100.000000000000000000
      Text = '2'
      WidthPercent = 100.000000000000000000
    end
  end
end
