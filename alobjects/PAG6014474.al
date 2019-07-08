page 6014474 "Retail Price Log Setup"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created
    // NPR5.48/MHA /20181102  CASE 334573 Insert with trigger in OnOpenPage()

    AccessByPermission = TableData "Change Log Setup"=RIM;
    Caption = 'Retail Price Log Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Retail Price Log Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Price Log Activated";"Price Log Activated")
                {
                }
                field("Task Queue Activated";"Task Queue Activated")
                {
                }
                field("Delete Price Log Entries after";"Delete Price Log Entries after")
                {
                }
            }
            group(Logging)
            {
                field("Item Unit Price";"Item Unit Price")
                {
                }
                field("Sales Price";"Sales Price")
                {
                }
                field("Sales Line Discount";"Sales Line Discount")
                {
                }
                field("Period Discount";"Period Discount")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Activate Price Log")
            {
                Caption = 'Activate Price Log';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = "Price Log Activated";

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "Retail Price Log Mgt.";
                begin
                    RetailPriceLogMgt.EnablePriceLog(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          //-NPR5.48 [334573]
          //INSERT;
          Insert(true);
          //+NPR5.48 [334573]
        end;
    end;
}

