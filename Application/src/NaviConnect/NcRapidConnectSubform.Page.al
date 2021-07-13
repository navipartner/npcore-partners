page 6151092 "NPR Nc RapidConnect Subform"
{
    Caption = 'Export Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Nc RapidConnect Trig.Table";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {

                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Insert Trigger"; Rec."Insert Trigger")
                {

                    ToolTip = 'Specifies the value of the Insert Trigger field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Modify Trigger"; Rec."Modify Trigger")
                {

                    ToolTip = 'Specifies the value of the Modify Trigger field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Control6151408; Rec."Trigger Fields")
                {

                    HideValue = (Rec."Modify Trigger" <> 2);
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Trigger Fields field';
                    ApplicationArea = NPRNaviConnect;
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

                ToolTip = 'Executes the Trigger Fields action';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }
}

