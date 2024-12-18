#if not BC17
page 6184908 "NPR Spfy Logs"
{
    ApplicationArea = NPRShopify;
    UsageCategory = History;
    AdditionalSearchTerms = 'Spfy Item Price Logs,Item Price Logs,Shopify Item Logs';
    Caption = 'Shopify Logs';
    PageType = List;
    SourceTable = "NPR Spfy Log";
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Log Entry No.';
                }
                field(EntryDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Created At';
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies when the Log was created at.';
                }
                field("Message Type"; Rec."Message Type")
                {
                    Caption = 'Message Type';
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Log message type.';
                }
                field("Message Text"; Rec."Message Text")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Log message text.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Show Message")
            {
                Caption = 'Show Message';
                ApplicationArea = NPRShopify;
                Image = Text;
                ToolTip = 'Running this action will show the full message of the current log entry.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    InS: InStream;
                    MessageText: Text;
                begin
                    if Rec."Message Blob".HasValue() then begin
                        Rec.CalcFields("Message Blob");
                        Rec."Message Blob".CreateInStream(InS, TextEncoding::UTF8);
                        InS.ReadText(MessageText);
                        Message(MessageText);
                    end;
                end;
            }
        }
    }
}
#endif
