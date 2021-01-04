page 6014680 "NPR Endpoint QueryFilt. S.form"
{
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Endpoint Query Filter Subform';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Endpoint Query Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Text"; "Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Text field';
                }
            }
        }
    }

    actions
    {
    }
}

