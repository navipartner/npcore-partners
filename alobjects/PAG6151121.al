page 6151121 "GDPR Agreement List"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Agreement List';
    CardPageID = "GDPR Agreement Card";
    PageType = List;
    SourceTable = "GDPR Agreement";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                }
                field("Latest Version";"Latest Version")
                {
                }
                field("Current Version";"Current Version")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetRange ("Date Filter", Today);
        CalcFields ("Current Version");
    end;
}

