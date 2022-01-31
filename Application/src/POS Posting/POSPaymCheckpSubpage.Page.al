page 6150631 "NPR POS Paym. Checkp. Subpage"
{
    Extensible = False;
    Caption = 'POS Payment Bin Checkpoint';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Payment Bin Checkp.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method No."; Rec."Payment Method No.")
                {

                    ToolTip = 'Specifies the value of the Payment Method No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Bin No."; Rec."Payment Bin No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Bin No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Amount Incl. Float"; Rec."Calculated Amount Incl. Float")
                {

                    Visible = IsBlindCount = FALSE;
                    ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                    ApplicationArea = NPRRetail;
                }
                field("Counted Amount Incl. Float"; Rec."Counted Amount Incl. Float")
                {

                    ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnInit()
    begin
        IsBlindCount := false;
    end;

    trigger OnOpenPage()
    begin

        Rec.SetFilter("Calculated Amount Incl. Float", '<>%1', 0);
    end;

    var
        IsBlindCount: Boolean;

    procedure SetBlindCount(HideFields: Boolean)
    begin
        IsBlindCount := HideFields;
    end;
}

