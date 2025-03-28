﻿page 6150659 "NPR POS Posting Log Parameters"
{
    Extensible = False;
    Caption = 'POS Posting Log Parameters';
    Editable = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR POS Posting Log";

    layout
    {
        area(content)
        {
            field("Parameter Posting Date"; Rec."Parameter Posting Date")
            {
                Caption = 'Posting Date';
                ToolTip = 'Specifies the value of the Posting Date field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Replace Posting Date"; Rec."Parameter Replace Posting Date")
            {
                Caption = 'Replace Posting Date';
                ToolTip = 'Specifies the value of the Replace Posting Date field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Replace Doc. Date"; Rec."Parameter Replace Doc. Date")
            {
                Caption = 'Replace Doc. Date';
                ToolTip = 'Specifies the value of the Replace Doc. Date field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Post Item Entries"; Rec."Parameter Post Item Entries")
            {
                Caption = 'Post Item Entries';
                ToolTip = 'Specifies the value of the Post Item Entries field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Post POS Entries"; Rec."Parameter Post POS Entries")
            {
                Caption = 'Post POS Entries to G/L';
                ToolTip = 'Specifies the value of the Post POS Entries field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Post Sales Documents"; Rec."Parameter Post Sales Documents")
            {
                Caption = 'Post Sales Documents';
                ToolTip = 'Specifies the value of the Post Sales Documents field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Post Compressed"; Rec."Parameter Post Compressed")
            {
                Caption = 'Post Compressed';
                ToolTip = 'Specifies the value of the Post Compressed field';
                ApplicationArea = NPRRetail;
            }
            field("Parameter Stop On Error"; Rec."Parameter Stop On Error")
            {
                Caption = 'Stop On Error';
                ToolTip = 'Specifies the value of the Stop On Error field';
                ApplicationArea = NPRRetail;
            }
            field("Last POS Entry No. at Posting"; Rec."Last POS Entry No. at Posting")
            {
                Caption = 'Last POS Entry No.';
                ToolTip = 'Specifies the value of the Last POS Entry No. field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
