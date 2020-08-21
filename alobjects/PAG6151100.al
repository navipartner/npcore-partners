page 6151100 "NpRi Reimbursement Modules"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NpRi Reimbursement Module";
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
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Subscriber Codeunit ID"; "Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Subscriber Codeunit Name"; "Subscriber Codeunit Name")
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
        NpRiSetupMgt: Codeunit "NpRi Setup Mgt.";
    begin
        NpRiSetupMgt.DiscoverModules(Rec);
    end;
}

