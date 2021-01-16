page 6150730 "NPR POS Sales WF Steps"
{
    // NPR5.39/MHA /20180202  CASE 302779 Object created - POS Workflow
    // NPR5.45/MHA /20180820  CASE 321266 Moved field 1 to 3 "Workflow Code" and added Field 1 "Set Code" to Primary key

    Caption = 'POS Sales Workflow Steps';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Sales Workflow Step";
    SourceTableView = SORTING("Sequence No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Set Code"; "Set Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Set Code field';
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Subscriber Codeunit ID"; "Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Codeunit Name"; "Subscriber Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                }
                field("Subscriber Function"; "Subscriber Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Function field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
        }
    }

    actions
    {
    }
}

