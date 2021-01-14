page 6151100 "NPR NpRi Reimburs. Modules"
{
    Caption = 'Reimbursement Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpRi Reimbursement Module";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NpRiSetupMgt: Codeunit "NPR NpRi Setup Mgt.";
    begin
        NpRiSetupMgt.DiscoverModules(Rec);
    end;
}

