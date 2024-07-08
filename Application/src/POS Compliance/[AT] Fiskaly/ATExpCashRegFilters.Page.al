page 6184643 "NPR AT Exp. Cash Reg. Filters"
{
    Caption = 'Export Cash Register Filters';
    Extensible = False;
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                InstructionalText = 'Filters for exporting cash register data. If none of the parameters is provided everything will be exported.';
                ShowCaption = false;

                group(ReceiptNumberFilters)
                {
                    ShowCaption = false;
                    field("Start Receipt No."; StartReceiptNo)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Start Receipt No.';
                        ToolTip = 'Specifies the start receipt number.';
                    }
                    field("End Receipt No."; EndReceiptNo)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'End Receipt No.';
                        ToolTip = 'Specifies the end receipt number.';
                    }
                }
                group(TimeSignatureFilters)
                {
                    ShowCaption = false;

                    field("Start Signature DateTime"; StartSignatureDateTime)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Start Signature DateTime';
                        ToolTip = 'Specifies the start signature datetime.';
                    }
                    field("End Signature DateTime"; EndSignatureDateTime)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'End Signature DateTime';
                        ToolTip = 'Specifies the end signature datetime.';
                    }
                }
            }
        }
    }

    var
        StartSignatureDateTime, EndSignatureDateTime : DateTime;
        StartReceiptNo, EndReceiptNo : Integer;

    internal procedure GetStartReceiptNo(): Integer
    begin
        exit(StartReceiptNo);
    end;

    internal procedure GetEndReceiptNo(): Integer
    begin
        exit(EndReceiptNo);
    end;

    internal procedure GetStartSignatureDateTime(): DateTime
    begin
        exit(StartSignatureDateTime);
    end;

    internal procedure GetEndSignatureDateTime(): DateTime
    begin
        exit(EndSignatureDateTime);
    end;

}
