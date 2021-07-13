page 6151264 "NPR POS Unit Rcpt.Txt Profiles"
{
    Caption = 'POS Unit Receipt Text Profiles';
    CardPageID = "NPR POS Unit Rcpt.Text Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Unit Rcpt.Txt Profile";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(IsReceiptTextSet; IsReceiptTextSet)
                {
                    Editable = false;
                    Caption = 'Is Receipt Text Set';

                    ToolTip = 'Specifies if the value of the Sales Ticket Receipt Text field is set. Sales Ticket Receipt Text field is available on the card.';
                    ApplicationArea = NPRRetail;
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

