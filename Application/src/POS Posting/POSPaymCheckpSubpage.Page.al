page 6150631 "NPR POS Paym. Checkp. Subpage"
{
    // NPR5.45/TSA /20180727 CASE 322769 Initial Version
    // NPR5.49/TSA /20190314 CASE 348458 Blind count

    Caption = 'POS Payment Bin Checkpoint';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Payment Bin Checkp.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Payment Method No."; "Payment Method No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method No. field';
                }
                field("Payment Bin No."; "Payment Bin No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Bin No. field';
                }
                field("Calculated Amount Incl. Float"; "Calculated Amount Incl. Float")
                {
                    ApplicationArea = All;
                    Visible = IsBlindCount = FALSE;
                    ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                }
                field("Counted Amount Incl. Float"; "Counted Amount Incl. Float")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
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

        //-NPR5.49 [348458]
        IsBlindCount := false;
        //+NPR5.49 [348458]
    end;

    trigger OnOpenPage()
    begin

        SetFilter("Calculated Amount Incl. Float", '<>%1', 0);
    end;

    var
        PageMode: Option PRELIMINARY,FINAL;
        IsBlindCount: Boolean;

    procedure SetBlindCount(HideFields: Boolean)
    begin

        //-NPR5.49 [348458]

        IsBlindCount := HideFields;

        //+NPR5.49 [348458]
    end;
}

