page 6060054 "Item Worksheet Field Setup"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.32/BR  /20170523  CASE 277555 Fix error in Lookup for new records

    Caption = 'Item Worksheet Field Setup';
    PageType = List;
    SourceTable = "Item Worksheet Field Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name";"Worksheet Template Name")
                {
                }
                field("Worksheet Name";"Worksheet Name")
                {
                }
                field("Field Number";"Field Number")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Target Field Number Create";"Target Field Number Create")
                {
                }
                field("Target Field Name Create";"Target Field Name Create")
                {
                }
                field("Target Field Caption Create";"Target Field Caption Create")
                {
                }
                field("Target Field Number Update";"Target Field Number Update")
                {
                }
                field("Target Field Name Update";"Target Field Name Update")
                {
                }
                field("Target Field Caption Update";"Target Field Caption Update")
                {
                }
                field("Process Create";"Process Create")
                {
                }
                field("Process Update";"Process Update")
                {
                }
                field("Default Value for Create";"Default Value for Create")
                {
                }
                field("Mapped Values";"Mapped Values")
                {
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
                RunObject = Page "Item Worksheet Field Mapping";
                RunPageLink = "Worksheet Template Name"=FIELD("Worksheet Template Name"),
                              "Worksheet Name"=FIELD("Worksheet Name"),
                              "Table No."=FIELD("Table No."),
                              "Field Number"=FIELD("Field Number");
                RunPageView = SORTING("Worksheet Template Name","Worksheet Name","Table No.","Field Number","Source Value")
                              ORDER(Ascending);
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

