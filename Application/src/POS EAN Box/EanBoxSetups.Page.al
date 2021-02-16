page 6060096 "NPR Ean Box Setups"
{
    Caption = 'Ean Box Setups';
    CardPageID = "NPR Ean Box Setup";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Ean Box Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EanBoxEvent: Record "NPR Ean Box Event";
        POSAction: Record "NPR POS Action";
        EanBoxSetupMgt: Codeunit "NPR Ean Box Setup Mgt.";
    begin
        POSAction.DiscoverActions();
        EanBoxSetupMgt.DiscoverEanBoxEvents(EanBoxEvent);
        EanBoxSetupMgt.InitDefaultEanBoxSetup();
    end;

}

