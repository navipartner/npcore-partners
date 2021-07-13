page 6150621 "NPR POS Unit to Bin Relation"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017
    // NPR5.51/YAHA/20190717 CASE 360536 Field "POS Unit No.","POS Payment Bin No." set to Mandatory(TRUE)

    Caption = 'POS Unit to Bin Relation';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR POS Unit to Bin Relation";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Status"; Rec."POS Unit Status")
                {

                    Visible = ShowUnitInfo;
                    ToolTip = 'Specifies the value of the POS Unit Status field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {

                    Visible = ShowUnitInfo;
                    ToolTip = 'Specifies the value of the POS Unit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin No."; Rec."POS Payment Bin No.")
                {

                    ShowMandatory = true;
                    Visible = ShowBinInfo;
                    ToolTip = 'Specifies the value of the POS Payment Bin No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin Status"; Rec."POS Payment Bin Status")
                {

                    Visible = ShowBinInfo;
                    ToolTip = 'Specifies the value of the POS Payment Bin Status field';
                    ApplicationArea = NPRRetail;
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

