page 6060096 "NPR POS Input Box Setups"
{
    Caption = 'POS Input Box Setups';
    CardPageID = "NPR POS Input Box Setup";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Ean Box Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    ToolTip = 'Specifies the value of the POS View field';
                    ApplicationArea = NPRRetail;
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
        EanBoxSetupMgt: Codeunit "NPR POS Input Box Setup Mgt.";
    begin
        POSAction.DiscoverActions();
        EanBoxSetupMgt.DiscoverEanBoxEvents(EanBoxEvent);
        EanBoxSetupMgt.InitDefaultEanBoxSetup();
    end;

}

