page 6151264 "NPR POS Unit Rcpt.Txt Profiles"
{
    Caption = 'POS Unit Receipt Text Profiles';
    CardPageID = "NPR POS Unit Rcpt.Text Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Unit Rcpt.Txt Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(IsReceiptTextSet; IsReceiptTextSet)
                {
                    Editable = false;
                    Caption = 'Is Receipt Text Set';
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the value of the Sales Ticket Receipt Text field is set. Sales Ticket Receipt Text field is available on the card.';
                }
            }
        }
    }
    var
        IsReceiptTextSet: Boolean;

    trigger OnAfterGetRecord()
    var
        ReceiptFooterMgt: codeunit "NPR Receipt Footer Mgt.";
    begin
        IsReceiptTextSet := ReceiptFooterMgt.IsReceiptTextSet(Rec);
    end;
}

