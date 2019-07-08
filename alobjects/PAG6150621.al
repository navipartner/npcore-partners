page 6150621 "POS Unit to Bin Relation"
{
    // NPR5.36/NPKNAV/20171003  CASE 282251 Transport NPR5.36 - 3 October 2017

    Caption = 'POS Unit to Bin Relation';
    PageType = List;
    SourceTable = "POS Unit to Bin Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("POS Unit Status";"POS Unit Status")
                {
                    Visible = ShowUnitInfo;
                }
                field("POS Unit Name";"POS Unit Name")
                {
                    Visible = ShowUnitInfo;
                }
                field("POS Payment Bin No.";"POS Payment Bin No.")
                {
                    Visible = ShowBinInfo;
                }
                field("POS Payment Bin Status";"POS Payment Bin Status")
                {
                    Visible = ShowBinInfo;
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

