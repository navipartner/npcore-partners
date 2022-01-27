page 6014474 "NPR Retail Price Log Setup"
{
    Extensible = False;
    // NPR5.40/MHA /20180316  CASE 304031 Object created
    // NPR5.48/MHA /20181102  CASE 334573 Insert with trigger in OnOpenPage()

    AccessByPermission = TableData "Change Log Setup" = RIM;
    Caption = 'Retail Price Log Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Retail Price Log Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Price Log Activated"; Rec."Price Log Activated")
                {

                    ToolTip = 'Specifies the value of the Price Log Activated field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Queue Activated"; Rec."Task Queue Activated")
                {

                    ToolTip = 'Specifies the value of the Task Queue Activated field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Price Log Entries after"; Rec."Delete Price Log Entries after")
                {

                    ToolTip = 'Specifies the value of the Delete Price Log Entries after field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Logging)
            {
                field("Item Unit Price"; Rec."Item Unit Price")
                {

                    ToolTip = 'Specifies the value of the Item Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price"; Rec."Sales Price")
                {

                    ToolTip = 'Specifies the value of the Sales Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Line Discount"; Rec."Sales Line Discount")
                {

                    ToolTip = 'Specifies the value of the Sales Line Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Discount"; Rec."Period Discount")
                {

                    ToolTip = 'Specifies the value of the Period Discount field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Price Log Activated";

                ToolTip = 'Executes the Activate Price Log action';
                ApplicationArea = NPRRetail;

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
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            //-NPR5.48 [334573]
            //INSERT;
            Rec.Insert(true);
            //+NPR5.48 [334573]
        end;
    end;
}

