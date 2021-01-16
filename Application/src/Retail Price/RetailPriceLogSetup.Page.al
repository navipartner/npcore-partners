page 6014474 "NPR Retail Price Log Setup"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created
    // NPR5.48/MHA /20181102  CASE 334573 Insert with trigger in OnOpenPage()

    AccessByPermission = TableData "Change Log Setup" = RIM;
    Caption = 'Retail Price Log Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Retail Price Log Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Price Log Activated"; "Price Log Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Log Activated field';
                }
                field("Task Queue Activated"; "Task Queue Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Queue Activated field';
                }
                field("Delete Price Log Entries after"; "Delete Price Log Entries after")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Price Log Entries after field';
                }
            }
            group(Logging)
            {
                field("Item Unit Price"; "Item Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Unit Price field';
                }
                field("Sales Price"; "Sales Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price field';
                }
                field("Sales Line Discount"; "Sales Line Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line Discount field';
                }
                field("Period Discount"; "Period Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Discount field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Activate Price Log action';

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
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

