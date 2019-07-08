page 6151092 "Nc RapidConnect Subform"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.14/MHA /20180716  CASE 322308 Changed trigger field types from boolean to option to support Partial Trigger functionality

    Caption = 'Export Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Nc RapidConnect Trigger Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Table Name";"Table Name")
                {
                }
                field("Insert Trigger";"Insert Trigger")
                {
                }
                field("Modify Trigger";"Modify Trigger")
                {
                }
                field(Control6151408;"Trigger Fields")
                {
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
                RunObject = Page "Nc RapidConnect Trigger Fields";
                RunPageLink = "Setup Code"=FIELD("Setup Code"),
                              "Table ID"=FIELD("Table ID");
                Visible = ("Modify Trigger"=2);
            }
        }
    }
}

