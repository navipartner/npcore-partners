page 6059956 "NPR MCS Person Group Setup"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Group Setup';
    PageType = List;
    SourceTable = "NPR MCS Person Groups Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table Id"; "Table Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Id field';
                }
                field("Person Groups Id"; "Person Groups Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Groups Id field';
                }
                field("Person Groups Name"; "Person Groups Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Groups Name field';
                }
            }
        }
    }

    actions
    {
    }
}

