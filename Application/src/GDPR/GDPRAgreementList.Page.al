page 6151121 "NPR GDPR Agreement List"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Agreement List';
    CardPageID = "NPR GDPR Agreement Card";
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR GDPR Agreement";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Latest Version"; "Latest Version")
                {
                    ApplicationArea = All;
                }
                field("Current Version"; "Current Version")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetRange("Date Filter", Today);
        CalcFields("Current Version");
    end;
}

