page 6014680 "Endpoint Query Filter Subform"
{
    // NPR5.25\BR\20160801  CASE 234602 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Endpoint Query Filter Subform';
    PageType = ListPart;
    SourceTable = "Endpoint Query Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name";"Field Name")
                {
                }
                field("Filter Text";"Filter Text")
                {
                }
            }
        }
    }

    actions
    {
    }
}

