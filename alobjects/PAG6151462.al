page 6151462 "Magento Setup Post on Import"
{
    // MAG2.23/MHA /20191017  CASE 373262 Object created - defines entities to Post on Import

    Caption = 'Post on Import Setup';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Magento Post on Import Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

