page 6014475 "Retail Price Log Entries"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created

    Caption = 'Retail Price Log Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Retail Price Log Entry";
    SourceTableView = SORTING("Date and Time");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time";"Date and Time")
                {
                    Visible = false;
                }
                field(Date;Date)
                {
                }
                field(Time;Time)
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Change Log Entry No.";"Change Log Entry No.")
                {
                    Visible = false;
                }
                field("Table No.";"Table No.")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Old Value";"Old Value")
                {
                }
                field("New Value";"New Value")
                {
                }
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Price Log")
            {
                AccessByPermission = TableData "Change Log Entry"=R;
                Caption = 'Update Price Log';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "Retail Price Log Mgt.";
                begin
                    RetailPriceLogMgt.UpdatePriceLog();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

