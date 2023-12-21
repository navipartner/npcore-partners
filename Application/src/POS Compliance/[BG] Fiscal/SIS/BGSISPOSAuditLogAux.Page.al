page 6151316 "NPR BG SIS POS Audit Log Aux."
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG POS SIS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS POS Audit Log Aux.";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if not (Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"]) then
                            exit;

                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("Entry No.", Rec."POS Entry No.");
                        POSEntry.FilterGroup(0);
                        POSEntryList.SetTableView(POSEntry);
                        POSEntryList.Run();
                    end;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the total amount including taxes for the transaction.';
                }
                field("Grand Receipt No."; Rec."Grand Receipt No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Grand Receipt No. field.';
                }
                field("Receipt Timestamp"; Rec."Receipt Timestamp")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the timestamp of the receipt in the format “ss,mm,hh;DD,MM,YY"';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Transaction Type field.';
                }
                field("Extended Receipt"; Rec."Extended Receipt")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Extended Receipt field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowRequestContent)
            {
                ApplicationArea = NPRBGSISFiscal;
                Caption = 'Show Request Content';
                Image = Find;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Shows the content of related request.';

                trigger OnAction()
                begin
                    Message(Rec.GetRequestText());
                end;
            }
            // TO-DO this will be finished in one of the future tasks
            // action(ShowReceiptData)
            // {
            //     ApplicationArea = NPRBGSISFiscal;
            //     Caption = 'Show Receipt Data';
            //     Image = Find;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     ToolTip = 'Shows the receipt data.';

            //     trigger OnAction()
            //     begin
            //         Message(Rec.GetReceiptData());
            //     end;
            // }
        }
    }
}
