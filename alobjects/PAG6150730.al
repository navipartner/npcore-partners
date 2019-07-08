page 6150730 "POS Sales Workflow Steps"
{
    // NPR5.39/MHA /20180202  CASE 302779 Object created - POS Workflow
    // NPR5.45/MHA /20180820  CASE 321266 Moved field 1 to 3 "Workflow Code" and added Field 1 "Set Code" to Primary key

    Caption = 'POS Sales Workflow Steps';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "POS Sales Workflow Step";
    SourceTableView = SORTING("Sequence No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Set Code";"Set Code")
                {
                    Visible = false;
                }
                field("Workflow Code";"Workflow Code")
                {
                    Visible = false;
                }
                field("Subscriber Codeunit ID";"Subscriber Codeunit ID")
                {
                    Visible = false;
                }
                field("Subscriber Codeunit Name";"Subscriber Codeunit Name")
                {
                    Visible = false;
                }
                field("Subscriber Function";"Subscriber Function")
                {
                }
                field(Description;Description)
                {
                }
                field("Sequence No.";"Sequence No.")
                {
                }
                field(Enabled;Enabled)
                {
                }
            }
        }
    }

    actions
    {
    }
}

