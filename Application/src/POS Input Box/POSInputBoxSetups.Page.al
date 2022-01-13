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

                    ToolTip = 'Specifies the Box Sales Setup unique Code';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Box Sales Setup Description';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    ToolTip = 'Specifies the Box Sales Setup POS View Type';
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

