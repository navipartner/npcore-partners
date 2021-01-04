page 6151100 "NPR NpRi Reimburs. Modules"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpRi Reimbursement Module";
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Subscriber Codeunit ID"; "Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Codeunit Name"; "Subscriber Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpRiSetupMgt: Codeunit "NPR NpRi Setup Mgt.";
    begin
        NpRiSetupMgt.DiscoverModules(Rec);
    end;
}

