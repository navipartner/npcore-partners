page 6184584 "NPR AT Organization List"
{
    ApplicationArea = NPRATFiscal;
    Caption = 'AT Organizations';
    CardPageId = "NPR AT Organization Card";
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT Organization";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the code to identify this AT Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the text that describes this AT Fiskaly organization.';
                }
                field("FON Authentication Status"; Rec."FON Authentication Status")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the status of FinanzOnline authentication. Must be authenticated with FinanzOnline before transitioning Signature Creation Units and Cash Registers to INITIALIZED.';
                }
                field("FON Authenticated At"; Rec."FON Authenticated At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when authentication is done at FinanzOnline.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ATSCUs)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'AT Signature Creation Units';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR AT SCUs";
                ToolTip = 'Opens AT Signature Creation Units page.';
            }
        }
    }
}
