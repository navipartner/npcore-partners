page 6151100 "NPR NpRi Reimburs. Modules"
{
    Extensible = False;
    Caption = 'Reimbursement Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpRi Reimbursement Module";
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

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                    ApplicationArea = NPRRetail;
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

