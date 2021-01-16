page 6060096 "NPR Ean Box Setups"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Setups';
    CardPageID = "NPR Ean Box Setup";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Ean Box Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

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

    var
        SearchCode: Text;
        IdentifierDissociationCU: Codeunit "NPR Ean Box Setup Mgt.";
}

