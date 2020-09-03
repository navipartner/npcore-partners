page 6060060 "NPR Item Worksh. Vrty. Mapping"
{
    // NPR5.37/BR  /20170922  CASE 268786 Added Mapping option to import
    // NPR5.43/JKL /20180525 CASE 314287  Added worksheet filter fields
    // NPR5.46/JKL /20180927 CASE 314287  rearranged fields + removed page update

    Caption = 'Item Worksheet Variety Mapping';
    PageType = List;
    SourceTable = "NPR Item Worksh. Vrty Mapping";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; "Worksheet Template Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Item Wksh. Maping Field"; "Item Wksh. Maping Field")
                {
                    ApplicationArea = All;
                    LookupPageID = "NPR Item Worksh. Field Setup";
                }
                field("Item Wksh. Maping Field Name"; "Item Wksh. Maping Field Name")
                {
                    ApplicationArea = All;
                }
                field("Item Wksh. Maping Field Value"; "Item Wksh. Maping Field Value")
                {
                    ApplicationArea = All;
                }
                field("Vendor Variety Value"; "Vendor Variety Value")
                {
                    ApplicationArea = All;
                }
                field(Variety; Variety)
                {
                    ApplicationArea = All;
                }
                field("Variety Table"; "Variety Table")
                {
                    ApplicationArea = All;
                }
                field("Variety Value"; "Variety Value")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.46 [314287]
                        //CurrPage.UPDATE(FALSE);
                        //+NPR5.46 [314287]
                    end;
                }
                field("Variety Value Description"; "Variety Value Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

