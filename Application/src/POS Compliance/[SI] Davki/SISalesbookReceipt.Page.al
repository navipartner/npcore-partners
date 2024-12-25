page 6184907 "NPR SI Salesbook Receipt"
{
    Caption = 'SI Salesbook Receipt';
    PageType = Card;
    UsageCategory = None;
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "NPR SI Salesbook Receipt";
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            group(Group)
            {
                ShowCaption = false;

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Set Number"; Rec."Set Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Set Number field.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Serial Number field.';
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Receipt Issue Date"; Rec."Receipt Issue Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Receipt Issue Date field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(100);
        Rec.SetRange("Entry No.", Rec."Entry No.");
        Rec.FilterGroup(0);
    end;
}