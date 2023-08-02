page 6059940 "NPR SMS Template List"
{
    Extensible = False;
    Caption = 'SMS Template List';
    ContextSensitiveHelpPage = 'docs/retail/communication/reference/sms_template_ref/';
    CardPageID = "NPR SMS Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR SMS Template Header";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the SMS template';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the SMS template.';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the number of the table in which the SMS template is going to be inserted.';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ToolTip = 'Specifies the name of the table in which the SMS template is going to be inserted.';
                    ApplicationArea = NPRRetail;
                }
                field("Table Filters"; Rec."Table Filters".HasValue())
                {

                    Caption = 'Filters on Table';
                    ToolTip = 'Specifies which filters are set on the table.';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the report ID that is going to be executed for that SMS template';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

