page 6060054 "NPR Item Worksh. Field Setup"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.32/BR  /20170523  CASE 277555 Fix error in Lookup for new records

    Caption = 'Item Worksheet Field Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Worksh. Field Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; "Worksheet Template Name")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field("Field Number"; "Field Number")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                }
                field("Target Field Number Create"; "Target Field Number Create")
                {
                    ApplicationArea = All;
                }
                field("Target Field Name Create"; "Target Field Name Create")
                {
                    ApplicationArea = All;
                }
                field("Target Field Caption Create"; "Target Field Caption Create")
                {
                    ApplicationArea = All;
                }
                field("Target Field Number Update"; "Target Field Number Update")
                {
                    ApplicationArea = All;
                }
                field("Target Field Name Update"; "Target Field Name Update")
                {
                    ApplicationArea = All;
                }
                field("Target Field Caption Update"; "Target Field Caption Update")
                {
                    ApplicationArea = All;
                }
                field("Process Create"; "Process Create")
                {
                    ApplicationArea = All;
                }
                field("Process Update"; "Process Update")
                {
                    ApplicationArea = All;
                }
                field("Default Value for Create"; "Default Value for Create")
                {
                    ApplicationArea = All;
                }
                field("Mapped Values"; "Mapped Values")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Field Value Map")
            {
                Caption = 'Field Value Map';
                Image = MapDimensions;
                RunObject = Page "NPR Item Worksh. Field Mapping";
                RunPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Table No." = FIELD("Table No."),
                              "Field Number" = FIELD("Field Number");
                RunPageView = SORTING("Worksheet Template Name", "Worksheet Name", "Table No.", "Field Number", "Source Value")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.32 [277555]
        "Table No." := xRec."Table No.";
        "Target Table No. Create" := xRec."Target Table No. Create";
        "Target Table No. Update" := xRec."Target Table No. Update";
        //+NPR5.32 [277555]
    end;
}

