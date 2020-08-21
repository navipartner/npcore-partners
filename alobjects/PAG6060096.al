page 6060096 "Ean Box Setups"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Setups';
    CardPageID = "Ean Box Setup";
    Editable = false;
    PageType = List;
    SourceTable = "Ean Box Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EanBoxEvent: Record "Ean Box Event";
        POSAction: Record "POS Action";
        EanBoxSetupMgt: Codeunit "Ean Box Setup Mgt.";
    begin
        POSAction.DiscoverActions();
        EanBoxSetupMgt.DiscoverEanBoxEvents(EanBoxEvent);
        EanBoxSetupMgt.InitDefaultEanBoxSetup();
    end;

    var
        SearchCode: Text;
        IdentifierDissociationCU: Codeunit "Ean Box Setup Mgt.";
}

