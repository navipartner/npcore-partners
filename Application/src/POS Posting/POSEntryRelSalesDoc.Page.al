﻿page 6151006 "NPR POS Entry Rel. Sales Doc."
{
    Extensible = False;
    Caption = 'POS Entry Related Sales Documents';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR POS Entry Sales Doc. Link";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Document Type"; Rec."Sales Document Type")
                {

                    ToolTip = 'Specifies the value of the Sales Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document No"; Rec."Sales Document No")
                {

                    ToolTip = 'Specifies the value of the Sales Document No field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                    end;
                }
                field("POS Entry Reference Type"; Rec."POS Entry Reference Type")
                {

                    ToolTip = 'Specifies the value of the POS Entry Reference Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Sales Document Status"; Rec."Post Sales Document Status")
                {
                    ApplicationArea = NPRRetail;
                    Visible = AsyncEnabled;
                    ToolTip = 'Specifies the value of the Post Sales Document Status field';
                }
                field("Post Sales Invoice Type"; Rec."Post Sales Invoice Type")
                {
                    ApplicationArea = NPRRetail;
                    Visible = AsyncEnabled;
                    ToolTip = 'Specifies the value of the Post Sales Document Type field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Related Sale Document Lines")
            {
                Caption = 'Related Sale Document Lines';
                Image = ViewDocumentLine;
                ToolTip = 'Related Sale Document Lines';
                ApplicationArea = NPRRetail;
                RunObject = page "NPR POS Entry S.Lines Relation";
                RunPageLink = "POS Entry No." = field("POS Entry No."),
                            "POS Entry Reference Line No." = field("POS Entry Reference Line No."),
                            "Sale Document No." = field("Sales Document No");
            }
        }
    }

    var
        RecordVar: Variant;
        AsyncEnabled: Boolean;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();
    end;
}

