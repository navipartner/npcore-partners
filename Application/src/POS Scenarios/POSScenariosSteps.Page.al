page 6150730 "NPR POS Scenarios Steps"
{

    Caption = 'POS Scenarios Steps';
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
                field("Set Code"; Rec."Set Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Set Code field';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field("Subscriber Codeunit Name"; Rec."Subscriber Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                }
                field("Subscriber Function"; Rec."Subscriber Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subscriber Function field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field(Enabled; Rec.Enabled)
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

