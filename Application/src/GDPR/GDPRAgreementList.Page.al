page 6151121 "NPR GDPR Agreement List"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Agreement List';
    CardPageID = "NPR GDPR Agreement Card";
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Agreement";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Latest Version"; Rec."Latest Version")
                {

                    ToolTip = 'Specifies the value of the Latest Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Version"; Rec."Current Version")
                {

                    ToolTip = 'Specifies the value of the Current Version field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Rec.SetRange("Date Filter", Today);
        Rec.CalcFields("Current Version");
    end;
}

