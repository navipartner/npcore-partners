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
                field("Code";Code)
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                }
                field(Type;Type)
                {
                    Editable = false;
                }
                field("Subscriber Codeunit ID";"Subscriber Codeunit ID")
                {
                    Editable = false;
                }
                field("Subscriber Codeunit Name";"Subscriber Codeunit Name")
                {
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

