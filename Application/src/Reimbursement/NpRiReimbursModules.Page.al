page 6151100 "NPR NpRi Reimburs. Modules"
{
    Extensible = False;
    Caption = 'Reimbursement Modules';
    ContextSensitiveHelpPage = 'docs/retail/reimbursement/intro/';
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
                    ToolTip = 'Specifies the code of the reimbursement module';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the reimbursement module';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Editable = false;
                    ToolTip = 'Specifies the type of the reimbursement module';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the subscriber codeunit ID executed for the reimbursement module';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {
                    ToolTip = 'Specifies the subscriber codeunit name executed for the reimbursement module';
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

