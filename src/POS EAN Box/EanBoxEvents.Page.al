page 6060097 "NPR Ean Box Events"
{
    // NPR5.32/NPKNAV/20170526  CASE 272577 Transport NPR5.32 - 26 May 2017
    // NPR5.40/THRO/20180306  CASE 306684 Added Discovery to OnOpenPage()
    // NPR5.45/MHA /20180814  CASE 319706 Reworked Identifier Dissociation to Ean Box Event Handler

    Caption = 'Ean Box Events';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Ean Box Event";
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
                    Editable = false;
                }
                field("Module Name"; "Module Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Action Description"; "Action Description")
                {
                    ApplicationArea = All;
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Event Codeunit"; "Event Codeunit")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Parameters)
            {
                Caption = 'Parameters';
                Image = List;
                ApplicationArea=All;

                trigger OnAction()
                var
                    EanBoxParameter: Record "NPR Ean Box Parameter";
                    EanBoxSetupMgt: Codeunit "NPR Ean Box Setup Mgt.";
                begin
                    EanBoxSetupMgt.InitEanBoxEventParameters(Rec);

                    EanBoxParameter.SetRange("Setup Code", '');
                    EanBoxParameter.SetRange("Event Code", Code);
                    PAGE.Run(0, EanBoxParameter);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        POSAction: Record "NPR POS Action";
        EanBoxSetupMgt: Codeunit "NPR Ean Box Setup Mgt.";
    begin
        POSAction.DiscoverActions();
        EanBoxSetupMgt.DiscoverEanBoxEvents(Rec);
        EanBoxSetupMgt.InitDefaultEanBoxSetup();
    end;
}

