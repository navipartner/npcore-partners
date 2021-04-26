page 6151092 "NPR Nc RapidConnect Subform"
{
    Caption = 'Export Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "NPR Nc RapidConnect Trig.Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Insert Trigger"; Rec."Insert Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Trigger field';
                }
                field("Modify Trigger"; Rec."Modify Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Trigger field';
                }
                field(Control6151408; Rec."Trigger Fields")
                {
                    ApplicationArea = All;
                    HideValue = (Rec."Modify Trigger" <> 2);
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Trigger Fields field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Trigger Fields")
            {
                Image = List;
                RunObject = Page "NPR Nc RapidConnect Trg.Fields";
                RunPageLink = "Setup Code" = FIELD("Setup Code"),
                              "Table ID" = FIELD("Table ID");
                Visible = (Rec."Modify Trigger" = 2);
                ApplicationArea = All;
                ToolTip = 'Executes the Trigger Fields action';
            }
        }
    }
}

