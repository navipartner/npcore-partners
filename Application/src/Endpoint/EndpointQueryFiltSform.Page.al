page 6014680 "NPR Endpoint QueryFilt. S.form"
{
    Extensible = False;
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Endpoint Query Filter Subform';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Endpoint Query Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Text"; Rec."Filter Text")
                {

                    ToolTip = 'Specifies the value of the Filter Text field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

