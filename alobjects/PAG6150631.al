page 6150631 "POS Payment Checkpoint Subpage"
{
    // NPR5.45/TSA /20180727 CASE 322769 Initial Version
    // NPR5.49/TSA /20190314 CASE 348458 Blind count

    Caption = 'POS Payment Bin Checkpoint';
    Editable = false;
    PageType = ListPart;
    SourceTable = "POS Payment Bin Checkpoint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Payment Method No.";"Payment Method No.")
                {
                }
                field("Payment Bin No.";"Payment Bin No.")
                {
                    Visible = false;
                }
                field("Calculated Amount Incl. Float";"Calculated Amount Incl. Float")
                {
                    Visible = IsBlindCount = FALSE;
                }
                field("Counted Amount Incl. Float";"Counted Amount Incl. Float")
                {
                }
                field(Comment;Comment)
                {
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

        SetFilter ("Calculated Amount Incl. Float", '<>%1', 0);
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

