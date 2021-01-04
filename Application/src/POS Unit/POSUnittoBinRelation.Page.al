page 6150621 "NPR POS Unit to Bin Relation"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.51/YAHA/20190717 CASE 360536 Field "POS Unit No.","POS Payment Bin No." set to Mandatory(TRUE)

    Caption = 'POS Unit to Bin Relation';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Unit to Bin Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("POS Unit Status"; "POS Unit Status")
                {
                    ApplicationArea = All;
                    Visible = ShowUnitInfo;
                    ToolTip = 'Specifies the value of the POS Unit Status field';
                }
                field("POS Unit Name"; "POS Unit Name")
                {
                    ApplicationArea = All;
                    Visible = ShowUnitInfo;
                    ToolTip = 'Specifies the value of the POS Unit Name field';
                }
                field("POS Payment Bin No."; "POS Payment Bin No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Visible = ShowBinInfo;
                    ToolTip = 'Specifies the value of the POS Payment Bin No. field';
                }
                field("POS Payment Bin Status"; "POS Payment Bin Status")
                {
                    ApplicationArea = All;
                    Visible = ShowBinInfo;
                    ToolTip = 'Specifies the value of the POS Payment Bin Status field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        ShowBinInfo := true;
        ShowUnitInfo := true;
    end;

    var
        ShowBinInfo: Boolean;
        ShowUnitInfo: Boolean;

    procedure SetShowUnit()
    begin
        ShowBinInfo := false;
        ShowUnitInfo := true;
    end;

    procedure SetShowBin()
    begin
        ShowBinInfo := true;
        ShowUnitInfo := false;
    end;
}

