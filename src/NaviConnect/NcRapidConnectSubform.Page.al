page 6151092 "NPR Nc RapidConnect Subform"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.14/MHA /20180716  CASE 322308 Changed trigger field types from boolean to option to support Partial Trigger functionality

    Caption = 'Export Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Nc RapidConnect Trig.Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Insert Trigger"; "Insert Trigger")
                {
                    ApplicationArea = All;
                }
                field("Modify Trigger"; "Modify Trigger")
                {
                    ApplicationArea = All;
                }
                field(Control6151408; "Trigger Fields")
                {
                    ApplicationArea = All;
                    HideValue = ("Modify Trigger" <> 2);
                    ShowCaption = false;
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
                Visible = ("Modify Trigger" = 2);
                ApplicationArea = All;
            }
        }
    }
}

